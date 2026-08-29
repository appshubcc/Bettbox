import { commonEventManager } from '@kit.BasicServicesKit';
import { Want } from '@kit.AbilityKit';
import { connection, vpnExtension, VpnExtensionAbility } from '@kit.NetworkKit';
import { sendFd } from 'libvpnfd.so';

const BUNDLE_NAME = 'com.appshub.bett_box';
const VPN_STARTED_EVENT = `${BUNDLE_NAME}.VPN_STARTED`;

interface VpnOptions {
  ipv4Address: string;
  ipv6Address: string;
  routeAddress: Array<string>;
  dnsServerAddress: string;
}

interface CidrAddress {
  address: string;
  prefixLength: number;
  family: number;
}

export default class BettboxVpnExtensionAbility extends VpnExtensionAbility {
  private connection: vpnExtension.VpnConnection | null = null;

  onCreate(want: Want): void {
    const options: VpnOptions = {
      ipv4Address: want.parameters?.ipv4Address as string,
      ipv6Address: want.parameters?.ipv6Address as string,
      routeAddress: want.parameters?.routeAddress as Array<string>,
      dnsServerAddress: want.parameters?.dnsServerAddress as string
    };
    this.createVpn(options);
  }

  onDestroy(): void {
    if (this.connection != null) {
      this.connection.destroy();
      this.connection = null;
    }
  }

  private async createVpn(options: VpnOptions): Promise<void> {
    try {
      const addresses: Array<connection.LinkAddress> = [
        this.toLinkAddress(this.parseCidr(options.ipv4Address))
      ];
      if (options.ipv6Address.length > 0) {
        addresses.push(this.toLinkAddress(this.parseCidr(options.ipv6Address)));
      }

      const routes = this.createRoutes(options);
      const config: vpnExtension.VpnConfig = {
        addresses: addresses,
        routes: routes,
        dnsAddresses: options.dnsServerAddress.length > 0
          ? [options.dnsServerAddress]
          : [],
        mtu: 1480,
        isIPv4Accepted: true,
        isIPv6Accepted: options.ipv6Address.length > 0,
        isBlocking: true,
        blockedApplications: [BUNDLE_NAME]
      };

      this.connection = vpnExtension.createVpnConnection(this.context);
      const fd = await this.connection.create(config);
      await this.connection.protectProcessNet();
      if (!sendFd(fd)) {
        throw new Error('Failed to transfer the VPN file descriptor');
      }
      commonEventManager.publish(VPN_STARTED_EVENT, {
        bundleName: BUNDLE_NAME,
        code: 1
      }, () => {
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : `${error}`;
      this.publishStartFailure(message);
    }
  }

  private publishStartFailure(message: string): void {
    commonEventManager.publish(VPN_STARTED_EVENT, {
      bundleName: BUNDLE_NAME,
      code: -1,
      data: message
    }, () => {
    });
  }

  private createRoutes(options: VpnOptions): Array<connection.RouteInfo> {
    const routeCidrs = options.routeAddress.length > 0
      ? options.routeAddress
      : ['0.0.0.0/0'];
    if (options.ipv6Address.length > 0 &&
      routeCidrs.findIndex((value) => value.includes(':')) < 0) {
      routeCidrs.push('::/0');
    }
    return routeCidrs.map((value) => {
      const cidr = this.parseCidr(value);
      const route: connection.RouteInfo = {
        interface: '',
        destination: this.toLinkAddress(cidr),
        gateway: {
          address: cidr.family === 1 ? '0.0.0.0' : '::',
          family: cidr.family
        },
        hasGateway: false,
        isDefaultRoute: cidr.prefixLength === 0
      };
      return route;
    });
  }

  private toLinkAddress(cidr: CidrAddress): connection.LinkAddress {
    return {
      address: {
        address: cidr.address,
        family: cidr.family
      },
      prefixLength: cidr.prefixLength
    };
  }

  private parseCidr(value: string): CidrAddress {
    const parts = value.split('/');
    if (parts.length !== 2) {
      throw new Error(`Invalid CIDR: ${value}`);
    }
    const family = parts[0].includes(':') ? 2 : 1;
    const prefixLength = Number(parts[1]);
    const maxPrefixLength = family === 1 ? 32 : 128;
    if (!Number.isInteger(prefixLength) || prefixLength < 0 ||
      prefixLength > maxPrefixLength) {
      throw new Error(`Invalid CIDR prefix: ${value}`);
    }
    return {
      address: parts[0],
      prefixLength: prefixLength,
      family: family
    };
  }
}
