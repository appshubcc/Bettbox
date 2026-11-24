import 'package:flutter/services.dart';

class MeshTemplate {
  final String title;

  const MeshTemplate(this.title);

  Future<String> load(String languageCode) async {
    final language = languageCode == 'zh' ? 'zh' : 'en';
    final sections = await Future.wait([
      for (final section in [title.toLowerCase(), 'common'])
        rootBundle.loadString('assets/mesh/$section.$language.yaml'),
    ]);
    return sections.join('\n');
  }
}

const meshTemplates = [
  MeshTemplate('EasyTier'),
  MeshTemplate('ZeroTier'),
  MeshTemplate('Tailscale'),
];
