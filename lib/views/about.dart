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

// [Gamebox] 关于页外链。使用说明暂指 iGame Windows 仓库，群组和 QQ 与 iGame 客户端相同。
// 上游分别是 Github Releases、telegram.me/appshub_chat、telegram.me/appshub_channel。
const _usageUrl = 'https://github.com/mouren1988/iGame-for-Windows';
const _groupUrl = 'https://t.me/+UOt2DJZ7Qyo2YzA9';
const _qqGroupUrl = 'https://qm.qq.com/q/xjr21slB74';
const _repoAvatarUrl = 'https://github.com/mouren1988.png';

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
    // [Gamebox] 关于页链接。上游是 Github Releases、Telegram Group、Channel、FlClash、Mihomo。
    return generateSection(
      title: appLocalizations.more,
      items: [
        _LinkGridRow(
          left: _LinkGridTile(
            title: '使用说明',
            icon: Icons.menu_book_outlined,
            onTap: () => globalState.openUrl(_usageUrl),
          ),
          right: _LinkGridTile(
            title: appLocalizations.checkUpdate,
            icon: Icons.refresh,
            onTap: () => _checkUpdate(context),
          ),
        ),
        _LinkGridRow(
          left: _LinkGridTile(
            title: '我的群组',
            icon: Icons.launch,
            onTap: () => globalState.openUrl(_groupUrl),
          ),
          right: _LinkGridTile(
            title: '我的QQ群',
            icon: Icons.launch,
            onTap: () => globalState.openUrl(_qqGroupUrl),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContributorsSection() {
    // [Gamebox] 只保留仓库头像。上游是一批贡献者头像并随机排序。
    return generateSection(
      separated: false,
      title: appLocalizations.otherContributors,
      items: [
        ListItem(
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Avatar(
              contributor: Contributor(
                avatar: _repoAvatarUrl,
                name: 'mouren1988',
              ),
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
                          width: 48,
                          height: 48,
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
          child: ClipOval(
            child: Image.network(
              contributor.avatar,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(width: 36, height: 36),
            ),
          ),
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
      alpha: context.colorScheme.brightness == Brightness.light ? 0.6 : 0.45,
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
