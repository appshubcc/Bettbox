use anyhow::{ensure, Context, Result};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::{num::NonZeroU16, path::Path, sync::Mutex};
use windows::core::{ComInterface, BSTR};
use windows::Win32::{
    Foundation::{VARIANT_FALSE, VARIANT_TRUE},
    NetworkManagement::WindowsFirewall::{
        INetFwPolicy2, INetFwRule, INetFwRules, NetFwPolicy2, NetFwRule, NET_FW_ACTION_ALLOW,
        NET_FW_IP_PROTOCOL_ANY, NET_FW_IP_PROTOCOL_TCP, NET_FW_IP_PROTOCOL_UDP,
        NET_FW_PROFILE2_ALL, NET_FW_PROFILE2_DOMAIN, NET_FW_PROFILE2_PRIVATE,
        NET_FW_PROFILE2_PUBLIC, NET_FW_RULE_DIR_IN,
    },
    System::{
        Com::{
            CoCreateInstance, CoInitializeEx, CoUninitialize, CLSCTX_INPROC_SERVER,
            COINIT_MULTITHREADED,
        },
        Ole::IEnumVARIANT,
        Variant::{VariantClear, VARIANT, VT_DISPATCH},
    },
};

// Older clients confirmed only private TCP. Require the current scope explicitly.
#[derive(Debug, Deserialize)]
pub enum Scope {
    #[serde(rename = "mixed_tcp_udp_private_public_local_subnet")]
    Mixed,
}

#[derive(Debug, Deserialize)]
#[serde(tag = "action", rename_all = "snake_case", deny_unknown_fields)]
pub enum Request {
    Status {
        port: u16,
        scope: Scope,
    },
    Allow {
        port: NonZeroU16,
        expected_core: String,
        scope: Scope,
    },
    Disable {},
}

#[derive(Debug, PartialEq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum Status {
    Inactive,
    Scoped,
    Legacy,
    NeedsReview,
}

struct ComApartment;

impl ComApartment {
    fn init() -> Result<Self> {
        unsafe { CoInitializeEx(None, COINIT_MULTITHREADED)? };
        Ok(Self)
    }
}

impl Drop for ComApartment {
    fn drop(&mut self) {
        unsafe { CoUninitialize() }
    }
}

struct Identity {
    path: String,
    suffix: String,
}

#[derive(Clone, Copy, PartialEq)]
enum Transport {
    Tcp,
    Udp,
}

const TRANSPORTS: [Transport; 2] = [Transport::Tcp, Transport::Udp];
const LAN_PROFILES: i32 = NET_FW_PROFILE2_PRIVATE.0 | NET_FW_PROFILE2_PUBLIC.0;

impl Transport {
    fn protocol(self) -> i32 {
        match self {
            Self::Tcp => NET_FW_IP_PROTOCOL_TCP.0,
            Self::Udp => NET_FW_IP_PROTOCOL_UDP.0,
        }
    }
}

impl Identity {
    fn rule_name(&self, transport: Transport) -> String {
        let label = match transport {
            Transport::Tcp => "TCP",
            Transport::Udp => "UDP",
        };
        format!("Bettbox LAN Proxy ({label}) [{}]", self.suffix)
    }

    fn for_helper(helper: &Path) -> Result<Self> {
        let name = helper.file_name().context("Missing helper filename")?;
        let core = if name.eq_ignore_ascii_case("BettboxDevHelperService.exe") {
            "BettboxDevCore.exe"
        } else {
            ensure!(
                name.eq_ignore_ascii_case("BettboxHelperService.exe"),
                "Unknown helper executable"
            );
            "BettboxCore.exe"
        };
        let path = helper.with_file_name(core);
        let path = path.to_str().context("Invalid core path")?.to_owned();
        // Different installations may coexist and Windows allows duplicate display names.
        let digest = Sha256::digest(path.to_ascii_lowercase().as_bytes());
        Ok(Self {
            path,
            suffix: hex::encode(&digest[..8]),
        })
    }
}

#[derive(Default)]
struct InstalledRules {
    managed: Vec<(Transport, INetFwRule)>,
    legacy: Vec<INetFwRule>,
}

impl InstalledRules {
    unsafe fn read(rules: &INetFwRules, identity: &Identity) -> Result<Self> {
        let mut found = Self::default();
        let names = TRANSPORTS.map(|t| (t, identity.rule_name(t)));
        let iter: IEnumVARIANT = rules._NewEnum()?.cast()?;
        loop {
            let mut value = VARIANT::default();
            let mut fetched = 0;
            iter.Next(std::slice::from_mut(&mut value), &mut fetched)
                .ok()?;
            if fetched == 0 {
                break;
            }
            let variant = &value.Anonymous.Anonymous;
            let rule = if variant.vt == VT_DISPATCH {
                variant
                    .Anonymous
                    .pdispVal
                    .as_ref()
                    .map(|dispatch| dispatch.cast::<INetFwRule>())
            } else {
                None
            };
            VariantClear(&mut value)?;
            let rule = rule.context("Unexpected firewall rule enumerator value")??;
            let name = rule.Name()?.to_string();
            let managed = names.iter().find(|(_, n)| name.eq_ignore_ascii_case(n));
            if managed.is_none()
                && !["Bettbox Core", "Bettbox Dev Core"]
                    .iter()
                    .any(|n| name.eq_ignore_ascii_case(n))
            {
                continue;
            }
            let own_app = rule
                .ApplicationName()?
                .to_string()
                .eq_ignore_ascii_case(&identity.path)
                && rule.Direction()? == NET_FW_RULE_DIR_IN
                && rule.Action()? == NET_FW_ACTION_ALLOW;
            if let Some((transport, _)) = managed {
                ensure!(
                    own_app && rule.Grouping()?.to_string() == "Bettbox",
                    "Firewall rule name is in use by another policy"
                );
                found.managed.push((*transport, rule));
            } else if own_app
                && rule.Protocol()? == NET_FW_IP_PROTOCOL_ANY.0
                && rule.Grouping()?.is_empty()
                && matches!(rule.RemoteAddresses()?.to_string().as_str(), "*" | "")
            {
                let profiles = rule.Profiles()?;
                let all_profiles =
                    NET_FW_PROFILE2_DOMAIN.0 | NET_FW_PROFILE2_PRIVATE.0 | NET_FW_PROFILE2_PUBLIC.0;
                if profiles == NET_FW_PROFILE2_ALL.0 || profiles == all_profiles {
                    found.legacy.push(rule);
                }
            }
        }
        Ok(found)
    }

    unsafe fn status(&self, port: u16) -> Result<Status> {
        for rule in &self.legacy {
            if rule.Enabled()?.as_bool() {
                return Ok(Status::Legacy);
            }
        }
        let (mut tcp, mut udp) = (false, false);
        for (transport, rule) in &self.managed {
            if rule.Enabled()?.as_bool() {
                if !matches_scope(rule, port, *transport)? {
                    return Ok(Status::NeedsReview);
                }
                match transport {
                    Transport::Tcp => tcp = true,
                    Transport::Udp => udp = true,
                }
            }
        }
        Ok(match (tcp, udp) {
            (false, false) => Status::Inactive,
            (true, true) => Status::Scoped,
            _ => Status::NeedsReview,
        })
    }

    unsafe fn disable(&self) -> Result<()> {
        disable_rules(
            self.legacy
                .iter()
                .chain(self.managed.iter().map(|(_, rule)| rule)),
        )
    }

    unsafe fn allow(
        &self,
        rules: &INetFwRules,
        identity: &Identity,
        port: NonZeroU16,
    ) -> Result<()> {
        self.disable()?;
        let mut prepared = Vec::new();
        for transport in TRANSPORTS {
            let rule = match self.managed.iter().find(|(t, _)| *t == transport) {
                Some((_, rule)) => {
                    configure(rule, identity, port, transport)?;
                    rule.clone()
                }
                None => {
                    let rule: INetFwRule =
                        CoCreateInstance(&NetFwRule, None, CLSCTX_INPROC_SERVER)?;
                    configure(&rule, identity, port, transport)?;
                    rules.Add(&rule)?;
                    // Fetch the installed rule before changing it in place.
                    rules.Item(&BSTR::from(identity.rule_name(transport)))?
                }
            };
            prepared.push(rule);
        }
        for rule in &prepared {
            if let Err(e) = rule.SetEnabled(VARIANT_TRUE) {
                disable_rules(&prepared).context("Unable to roll back mixed-port rules")?;
                return Err(e.into());
            }
        }
        Ok(())
    }
}

unsafe fn disable_rules<'a>(rules: impl IntoIterator<Item = &'a INetFwRule>) -> Result<()> {
    let mut result = Ok(());
    for rule in rules {
        let disable = rule.Enabled().and_then(|enabled| {
            if enabled.as_bool() {
                rule.SetEnabled(VARIANT_FALSE)
            } else {
                Ok(())
            }
        });
        if let Err(e) = disable {
            result = Err(e.into());
        }
    }
    result
}

unsafe fn matches_scope(rule: &INetFwRule, port: u16, transport: Transport) -> Result<bool> {
    Ok(rule.Profiles()? == LAN_PROFILES
        && rule.Protocol()? == transport.protocol()
        && rule.LocalPorts()?.to_string() == port.to_string()
        && rule
            .RemoteAddresses()?
            .to_string()
            .eq_ignore_ascii_case("LocalSubnet")
        && !rule.EdgeTraversal()?.as_bool())
}

unsafe fn configure(
    rule: &INetFwRule,
    identity: &Identity,
    port: NonZeroU16,
    transport: Transport,
) -> Result<()> {
    rule.SetEnabled(VARIANT_FALSE)?;
    rule.SetName(&BSTR::from(identity.rule_name(transport)))?;
    rule.SetGrouping(&BSTR::from("Bettbox"))?;
    rule.SetApplicationName(&BSTR::from(identity.path.as_str()))?;
    rule.SetDirection(NET_FW_RULE_DIR_IN)?;
    rule.SetAction(NET_FW_ACTION_ALLOW)?;
    rule.SetProfiles(LAN_PROFILES)?;
    rule.SetProtocol(transport.protocol())?;
    rule.SetLocalPorts(&BSTR::from(port.to_string()))?;
    rule.SetRemoteAddresses(&BSTR::from("LocalSubnet"))?;
    rule.SetEdgeTraversal(VARIANT_FALSE)?;
    Ok(())
}

pub fn handle(request: Request) -> Result<Status> {
    static LOCK: Mutex<()> = Mutex::new(());
    let _lock = LOCK.lock().unwrap_or_else(|e| e.into_inner());
    let identity = Identity::for_helper(&std::env::current_exe()?)?;
    let _apartment = ComApartment::init()?;
    unsafe {
        let policy: INetFwPolicy2 = CoCreateInstance(&NetFwPolicy2, None, CLSCTX_INPROC_SERVER)?;
        let rules = policy.Rules()?;
        let found = InstalledRules::read(&rules, &identity)?;
        match request {
            Request::Status {
                port,
                scope: Scope::Mixed,
            } => found.status(port),
            Request::Disable {} => {
                found.disable()?;
                Ok(Status::Inactive)
            }
            Request::Allow {
                port,
                expected_core,
                scope: Scope::Mixed,
            } => {
                ensure!(
                    identity.path.eq_ignore_ascii_case(&expected_core),
                    "App and helper core paths differ"
                );
                ensure!(
                    Path::new(&identity.path).is_file(),
                    "Installed core executable is missing"
                );
                if found.status(port.get())? != Status::Scoped {
                    found.allow(&rules, &identity, port)?;
                    return InstalledRules::read(&rules, &identity)?.status(port.get());
                }
                Ok(Status::Scoped)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_invalid_grants() {
        let scope = "mixed_tcp_udp_private_public_local_subnet";
        for port in ["0", "-1", "65536", "\"*\"", "\"7890-7900\""] {
            let body = format!(
                r#"{{"action":"allow","port":{port},"expected_core":"test","scope":"{scope}"}}"#
            );
            assert!(serde_json::from_str::<Request>(&body).is_err());
        }
        let grant =
            format!(r#""action":"allow","port":7890,"expected_core":"test","scope":"{scope}""#);
        assert!(serde_json::from_str::<Request>(&format!("{{{grant}}}")).is_ok());
        assert!(
            serde_json::from_str::<Request>(&format!(r#"{{{grant},"profiles":"any"}}"#)).is_err()
        );
        assert!(serde_json::from_str::<Request>(
            r#"{"action":"allow","port":7890,"expected_core":"test"}"#
        )
        .is_err());
        assert!(serde_json::from_str::<Request>(&format!(
            r#"{{"action":"status","port":0,"scope":"{scope}"}}"#
        ))
        .is_ok());
    }

    #[test]
    #[ignore = "requires the Windows Firewall service"]
    fn reads_installed_policy_without_writing() -> Result<()> {
        let _apartment = ComApartment::init()?;
        let helper = std::env::current_exe()?.with_file_name("BettboxHelperService.exe");
        let identity = Identity::for_helper(&helper)?;
        unsafe {
            let policy: INetFwPolicy2 =
                CoCreateInstance(&NetFwPolicy2, None, CLSCTX_INPROC_SERVER)?;
            InstalledRules::read(&policy.Rules()?, &identity)?.status(7890)?;
        }
        Ok(())
    }

    #[test]
    fn derives_core_from_installed_helper() -> Result<()> {
        let helper = Path::new(r"C:\Program Files\Bettbox\BettboxHelperService.exe");
        let stable = Identity::for_helper(helper)?;
        let dev = Identity::for_helper(&helper.with_file_name("BettboxDevHelperService.exe"))?;
        assert_eq!(
            Path::new(&stable.path),
            helper.with_file_name("BettboxCore.exe")
        );
        assert_eq!(
            Path::new(&dev.path),
            helper.with_file_name("BettboxDevCore.exe")
        );
        assert_ne!(
            stable.rule_name(Transport::Tcp),
            dev.rule_name(Transport::Tcp)
        );
        assert!(Identity::for_helper(&helper.with_file_name("other.exe")).is_err());
        Ok(())
    }

    #[test]
    fn scopes_and_disables_detached_firewall_rules() -> Result<()> {
        let _apartment = ComApartment::init()?;
        let identity = Identity::for_helper(Path::new(
            r"C:\Program Files\Bettbox\BettboxHelperService.exe",
        ))?;
        unsafe {
            // These COM objects are never added to the machine's policy.
            let tcp: INetFwRule = CoCreateInstance(&NetFwRule, None, CLSCTX_INPROC_SERVER)?;
            let udp: INetFwRule = CoCreateInstance(&NetFwRule, None, CLSCTX_INPROC_SERVER)?;
            let legacy: INetFwRule = CoCreateInstance(&NetFwRule, None, CLSCTX_INPROC_SERVER)?;
            for (transport, rule) in [(Transport::Tcp, &tcp), (Transport::Udp, &udp)] {
                configure(rule, &identity, NonZeroU16::new(7890).unwrap(), transport)?;
                assert!(!rule.Enabled()?.as_bool());
                assert_eq!(rule.ApplicationName()?.to_string(), identity.path);
                assert_eq!(rule.Direction()?, NET_FW_RULE_DIR_IN);
                assert_eq!(rule.Action()?, NET_FW_ACTION_ALLOW);
                assert_eq!(
                    rule.Profiles()?,
                    NET_FW_PROFILE2_PRIVATE.0 | NET_FW_PROFILE2_PUBLIC.0
                );
                assert_eq!(rule.Protocol()?, transport.protocol());
            }
            let found = InstalledRules {
                managed: vec![(Transport::Tcp, tcp.clone()), (Transport::Udp, udp.clone())],
                legacy: vec![legacy.clone()],
            };
            tcp.SetEnabled(VARIANT_TRUE)?;
            assert_eq!(found.status(7890)?, Status::NeedsReview);
            udp.SetEnabled(VARIANT_TRUE)?;
            assert_eq!(found.status(7890)?, Status::Scoped);
            tcp.SetProfiles(NET_FW_PROFILE2_PRIVATE.0)?;
            assert_eq!(found.status(7890)?, Status::NeedsReview);
            tcp.SetProfiles(LAN_PROFILES)?;
            assert_eq!(found.status(7891)?, Status::NeedsReview);
            legacy.SetEnabled(VARIANT_TRUE)?;
            assert_eq!(found.status(7890)?, Status::Legacy);
            found.disable()?;
            found.disable()?;
            assert_eq!(found.status(7890)?, Status::Inactive);
            assert!(
                !tcp.Enabled()?.as_bool()
                    && !udp.Enabled()?.as_bool()
                    && !legacy.Enabled()?.as_bool()
            );
            udp.SetRemoteAddresses(&BSTR::from("*"))?;
            tcp.SetEnabled(VARIANT_TRUE)?;
            udp.SetEnabled(VARIANT_TRUE)?;
            assert_eq!(found.status(7890)?, Status::NeedsReview);
        }
        Ok(())
    }
}
