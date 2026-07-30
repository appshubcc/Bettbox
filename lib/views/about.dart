import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Contributor {
  final String avatar;
  final String name;

  const Contributor({required this.avatar, required this.name});
}

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<void> _checkUpdate(BuildContext context) async {
    final commonScaffoldState = context.commonScaffoldState;
    if (commonScaffoldState?.mounted != true) return;
    final data = await globalState.appController.safeRun<Map<String, dynamic>?>(
      request.checkForUpdate,
      title: appLocalizations.checkUpdate,
      needLoading: true,
    );
    globalState.appController.checkUpdateResultHandle(
      data: data,
      handleError: true,
    );
  }

  List<Widget> _buildMoreSection(BuildContext context) {
    return generateSection(
      title: appLocalizations.more,
      items: [
        _LinkGridRow(
          left: _LinkGridTile(
            title: 'Github Releases',
            icon: Icons.star,
            onTap: () =>
                globalState.openUrl('https://github.com/appshubcc/Bettbox'),
          ),
          right: _LinkGridTile(
            title: appLocalizations.checkUpdate,
            icon: Icons.refresh,
            onTap: () => _checkUpdate(context),
          ),
        ),
        _LinkGridRow(
          left: _LinkGridTile(
            title: 'Telegram Group',
            icon: Icons.launch,
            onTap: () =>
                globalState.openUrl('https://telegram.me/appshub_chat'),
          ),
          right: _LinkGridTile(
            title: 'Channel',
            icon: Icons.launch,
            onTap: () =>
                globalState.openUrl('https://telegram.me/appshub_channel'),
          ),
        ),
        _LinkGridRow(
          left: _LinkGridTile(
            title: 'FlClash',
            icon: Icons.launch,
            onTap: () =>
                globalState.openUrl('https://github.com/chen08209/FlClash'),
          ),
          right: _LinkGridTile(
            title: 'Mihomo',
            icon: Icons.launch,
            onTap: () =>
                globalState.openUrl('https://github.com/MetaCubeX/mihomo'),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContributorsSection() {
    final contributors = [
      const Contributor(
        avatar: 'assets/images/avatars/june2.jpg',
        name: 'June2',
      ),
      const Contributor(avatar: 'assets/images/avatars/arue.jpg', name: 'Arue'),
      const Contributor(
        avatar: 'assets/images/avatars/dabaozi.jpg',
        name: '大包子',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/xiaolou.png',
        name: '小楼',
      ),
      const Contributor(avatar: 'assets/images/avatars/www.jpg', name: 'Www'),
      const Contributor(
        avatar: 'assets/images/avatars/AIsouler.jpg',
        name: 'AIsouler',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/songchenwen.jpg',
        name: 'songchenwen',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/EriDeLee.jpg',
        name: 'EriDeLee',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/AdySnowflake.png',
        name: 'AdySnowflake',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/CyberVacation.jpg',
        name: 'CyberVacation',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/VillagerTom.png',
        name: 'VillagerTom',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/ZeonX.jpg',
        name: 'ZeonX',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/feitianmoo.png',
        name: 'feitianmoo',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/kouhe3.jpg',
        name: 'kouhe3',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/soffchen.png',
        name: 'soffchen',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/utafrali.jpg',
        name: 'utafrali',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/wfion.png',
        name: 'wfion',
      ),
    ]..shuffle();
    return generateSection(
      separated: false,
      title: appLocalizations.otherContributors,
      items: [
        ListItem(
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 24,
              children: [
                for (final contributor in contributors)
                  Avatar(contributor: contributor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (_, ref, _) {
                return _DeveloperModeDetector(
                  child: Wrap(
                    spacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 64,
                          height: 64,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '${globalState.packageInfo.version}+${globalState.packageInfo.buildNumber}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                  onEnterDeveloperMode: () {
                    ref
                        .read(appSettingProvider.notifier)
                        .updateState(
                          (state) => state.copyWith(developerMode: true),
                        );
                    context.showNotifier(
                      appLocalizations.developerModeEnableTip,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              appLocalizations.desc,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ..._buildContributorsSection(),
      ..._buildMoreSection(context),
    ];
    return generateListView(items);
  }
}

class Avatar extends StatelessWidget {
  final Contributor contributor;

  const Avatar({super.key, required this.contributor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CircleAvatar(foregroundImage: AssetImage(contributor.avatar)),
        ),
        const SizedBox(height: 4),
        Text(contributor.name, style: context.textTheme.bodySmall),
      ],
    );
  }
}

class _DeveloperModeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnterDeveloperMode;

  const _DeveloperModeDetector({
    required this.child,
    required this.onEnterDeveloperMode,
  });

  @override
  State<_DeveloperModeDetector> createState() => _DeveloperModeDetectorState();
}

class _DeveloperModeDetectorState extends State<_DeveloperModeDetector> {
  int _counter = 0;
  Timer? _timer;

  void _handleTap() {
    _counter++;
    if (_counter >= 5) {
      widget.onEnterDeveloperMode();
      _resetCounter();
    } else {
      _timer?.cancel();
      _timer = Timer(Duration(seconds: 1), _resetCounter);
    }
  }

  void _resetCounter() {
    _counter = 0;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _handleTap, child: widget.child);
  }
}

class _LinkGridRow extends StatelessWidget {
  final _LinkGridTile left;
  final _LinkGridTile right;

  const _LinkGridRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final dividerColor = context.colorScheme.outlineVariant.withValues(
      alpha: context.colorScheme.brightness == Brightness.light ? 0.3 : 0.2,
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          VerticalDivider(
            width: 1,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: dividerColor,
          ),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _LinkGridTile extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  const _LinkGridTile({required this.title, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
