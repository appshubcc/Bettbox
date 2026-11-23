class MeshTemplate {
  final String title;
  final String content;

  const MeshTemplate({required this.title, required this.content});
}

/// YAML skeletons for the mesh outbounds supported by the bundled core.
///
/// The core validates the fields on import. State directories are assigned by
/// the app per node, so templates leave `state-dir` out.
const meshTemplates = [
  MeshTemplate(
    title: 'EasyTier',
    content: '''name: EasyTier
type: easytier
network-name: example
network-secret: secret
# At least one peer is required when no listeners are configured.
peers:
  - tcp://192.0.2.10:11010
udp: true
''',
  ),
  MeshTemplate(
    title: 'ZeroTier',
    content: '''name: ZeroTier
type: zerotier
# 16-digit ZeroTier network ID
network: "0123456789abcdef"
udp: true
''',
  ),
  MeshTemplate(
    title: 'Tailscale',
    content: '''name: Tailscale
type: tailscale
# Leave auth-key empty to log in with the link printed in the core log.
# auth-key: tskey-auth-xxxx
udp: true
''',
  ),
];
