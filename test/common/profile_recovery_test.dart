import 'package:archive/archive_io.dart';
import 'package:bett_box/common/profile_recovery.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profile(String id, String url, {String? label}) => Profile(
  id: id,
  url: url,
  label: label ?? 'Subscription',
  autoUpdateDuration: const Duration(days: 1),
);

void main() {
  const url = 'https://example.test/sub?token=a';

  test('restores the same subscription into its existing ID and label', () {
    final local = _profile('local', url, label: 'My subscription');
    final incoming = _profile(
      'backup',
      ' HTTPS://EXAMPLE.TEST/sub?token=a#label ',
    );
    final restore = ProfileRecovery.compatible([incoming], [local]);

    expect(restore.profiles.single.id, local.id);
    expect(restore.profiles.single.label, local.label);
    expect(restore.targetId(incoming.id), local.id);
    expect(restore.sourceIds(local.id), ['backup']);
    final again = ProfileRecovery.compatible([incoming], restore.profiles);
    expect(again.profiles, restore.profiles);
  });

  test('preserves distinct tokens and local files with the same label', () {
    final local = [_profile('local', url), _profile('local-file', '')];
    final incoming = [
      _profile('backup', 'https://example.test/sub?token=b'),
      _profile('backup-file', ''),
    ];

    expect(ProfileRecovery.compatible(incoming, local).profiles, incoming);
  });

  test('prefers an exact ID over URL matching regardless of archive order', () {
    final exact = _profile('existing', url, label: 'Restored label');
    final restore = ProfileRecovery.compatible(
      [_profile('duplicate', url), exact],
      [_profile('existing', url), _profile('other-local', url)],
    );

    expect(restore.profiles.map((profile) => profile.id), [
      'other-local',
      'existing',
    ]);
    expect(restore.profiles.last, exact);
    expect(restore.targetId('duplicate'), 'other-local');
    expect(restore.sourceIds('existing'), ['existing']);
  });

  test('keeps same-URL subscriptions inside one backup separate', () {
    final incoming = [
      _profile('first', url, label: 'A'),
      _profile('second', url, label: 'B'),
    ];
    final restore = ProfileRecovery.compatible(incoming, [
      _profile('local', url, label: 'Local'),
    ]);

    expect(restore.profiles.map((profile) => profile.id), ['local', 'second']);
    expect(restore.profiles.map((profile) => profile.label), ['Local', 'B']);
    expect(ProfileRecovery.compatible(incoming, const []).profiles, incoming);
  });

  test('rewrites bundle member IDs and archived provider cache paths', () {
    final bundle = _profile('bundle', '').copyWith(
      bundle: const ProfileBundle(
        members: [BundleMember(id: 'backup', prefix: 'A')],
        failures: {'backup': 'Refresh failed'},
      ),
    );
    final restore = ProfileRecovery.compatible(
      [bundle, _profile('backup', url)],
      [_profile('local', url)],
    );
    expect(restore.profiles.first.bundle?.members, [
      const BundleMember(id: 'local', prefix: 'A'),
    ]);
    expect(restore.profiles.first.bundle?.failures, {
      'local': 'Refresh failed',
    });

    const path = 'profiles/providers/backup/proxy/config.yaml';
    final file = restore.providerFile(ArchiveFile.bytes(path, [1]), path);
    expect(file?.name, 'profiles/providers/local/proxy/config.yaml');
    expect(file?.content, [1]);
  });
}
