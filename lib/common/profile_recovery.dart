import 'package:archive/archive_io.dart';
import 'package:bett_box/models/models.dart';

String? _subscriptionSource(Profile profile) {
  final uri = Uri.tryParse(profile.url.trim());
  if (uri == null ||
      !(uri.isScheme('https') || uri.isScheme('http')) ||
      uri.host.isEmpty ||
      profile.bundle != null) {
    return null;
  }
  return uri.removeFragment().toString();
}

/// Plans a compatible restore without changing the IDs of local subscriptions.
class ProfileRecovery {
  final List<Profile> profiles;
  final Map<String, String> _targetIds;
  final Map<String, List<String>> _sourceIds;

  ProfileRecovery._(this.profiles, this._targetIds, this._sourceIds);

  factory ProfileRecovery.compatible(
    List<Profile> incoming,
    List<Profile> local,
  ) {
    final localById = {for (final profile in local) profile.id: profile};
    final localBySource = <String, Profile>{};
    final reservedIds = incoming.map((profile) => profile.id).toSet();
    for (final profile in local) {
      final source = _subscriptionSource(profile);
      if (source != null && !reservedIds.contains(profile.id)) {
        localBySource.putIfAbsent(source, () => profile);
      }
    }
    // An exact ID in the backup takes precedence over a URL-only match.
    final targetsBySource = <String, String>{};
    for (final profile in incoming) {
      final source = _subscriptionSource(profile);
      if (source != null && localById.containsKey(profile.id)) {
        targetsBySource.putIfAbsent(source, () => profile.id);
      }
    }

    final targetIds = <String, String>{};
    final sourceIds = <String, List<String>>{};
    final restored = <String, Profile>{};
    for (final profile in incoming) {
      final source = _subscriptionSource(profile);
      final exactMatch = localById[profile.id];
      final targetId =
          exactMatch?.id ??
          targetsBySource[source] ??
          localBySource[source]?.id ??
          profile.id;
      if (source != null) targetsBySource.putIfAbsent(source, () => targetId);
      targetIds[profile.id] = targetId;
      final sources = sourceIds.putIfAbsent(targetId, () => []);
      if (targetId == profile.id) {
        sources.insert(0, profile.id);
        restored[targetId] = profile;
      } else {
        sources.add(profile.id);
        restored.putIfAbsent(
          targetId,
          () => profile.copyWith(
            id: targetId,
            label: localById[targetId]?.label ?? profile.label,
          ),
        );
      }
    }

    final profiles = restored.values.map((profile) {
      final bundle = profile.bundle;
      if (bundle == null) return profile;
      final seen = <String>{};
      return profile.copyWith.bundle!(
        members: [
          for (final member in bundle.members)
            if (seen.add(targetIds[member.id] ?? member.id))
              member.copyWith(id: targetIds[member.id] ?? member.id),
        ],
        failures: {
          for (final entry in bundle.failures.entries)
            targetIds[entry.key] ?? entry.key: entry.value,
        },
      );
    }).toList();
    return ProfileRecovery._(profiles, targetIds, sourceIds);
  }

  String? targetId(String? sourceId) => _targetIds[sourceId] ?? sourceId;

  Iterable<String> sourceIds(String targetId) =>
      _sourceIds[targetId] ?? [targetId];

  ArchiveFile? providerFile(ArchiveFile file, String normalizedName) {
    final parts = normalizedName.split('/');
    if (parts.length < 4 || parts[0] != 'profiles' || parts[1] != 'providers') {
      return file;
    }
    final sourceId = parts[2];
    final target = targetId(sourceId);
    if (target == null || sourceIds(target).first != sourceId) return null;
    if (target == sourceId) return file;
    parts[2] = target;
    return ArchiveFile.bytes(parts.join('/'), file.content);
  }
}
