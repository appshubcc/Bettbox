import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:bett_box/models/models.dart';
import 'package:synchronized/synchronized.dart';

import 'path.dart';

final _iconSearchPattern = RegExp(r'[^\p{L}\p{N}]', unicode: true);

String iconSearchKey(String value) =>
    value.toLowerCase().replaceAll(_iconSearchPattern, '');

String iconFileStem(String value) {
  final name = Uri.decodeComponent(value.substring(value.lastIndexOf('/') + 1));
  return name.toLowerCase().endsWith('.svg')
      ? name.substring(0, name.length - 4)
      : name;
}

extension IconSetIconExt on IconSetIcon {
  String get label => iconFileStem(name).replaceAll('_', ' ');
}

bool _isHttpUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      (uri.isScheme('http') || uri.isScheme('https')) &&
      uri.host.isNotEmpty;
}

({String name, List<IconSetIcon> icons}) parseIconSet(String content) {
  final document = json.decode(content);
  if (document is! Map || document['icons'] is! List) {
    throw const FormatException('Not an icon set');
  }
  final seen = <String>{};
  final icons = <IconSetIcon>[];
  for (final item in document['icons'] as List) {
    if (item is! Map) continue;
    final url = item['url'];
    if (url is! String || !_isHttpUrl(url) || !seen.add(url)) continue;
    final name = item['name'];
    icons.add(
      IconSetIcon(
        name: name is String && name.trim().isNotEmpty
            ? name.trim()
            : Uri.parse(url).pathSegments.lastOrNull ?? url,
        url: url,
      ),
    );
  }
  if (icons.isEmpty) {
    throw const FormatException('An icon set without icons');
  }
  final name = document['name'];
  return (name: name is String ? name.trim() : '', icons: icons);
}

class IconSetStore {
  final _lock = Lock();

  IconSetStore._();

  static final instance = IconSetStore._();

  Future<List<IconSet>> read() => _lock.synchronized(() async {
    final file = File(await appPath.iconSetsPath);
    if (!await file.exists()) return const [];
    final text = await file.readAsString();
    try {
      return await Isolate.run(
        () => [
          for (final item in json.decode(text) as List)
            IconSet.fromJson(Map<String, Object?>.from(item as Map)),
        ],
      );
    } catch (_) {
      return const [];
    }
  });

  Future<void> write(List<IconSet> sets) => _lock.synchronized(() async {
    final file = File(await appPath.iconSetsPath);
    final text = await Isolate.run(
      () => json.encode([for (final set in sets) set.toJson()]),
    );
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(text, flush: true);
    await temp.rename(file.path);
  });
}
