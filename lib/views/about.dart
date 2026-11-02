import 'dart:async';
import 'dart:ui';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
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
    final links = [
      _LinkTile(
        title: 'Github Releases',
        icon: Icons.star,
        onTap: () =>
            globalState.openUrl('https://github.com/appshubcc/Bettbox'),
      ),
      _LinkTile(
        title: appLocalizations.checkUpdate,
        icon: Icons.refresh,
        external: false,
        onTap: () => _checkUpdate(context),
      ),
      _LinkTile(
        title: 'Telegram Group',
        icon: Icons.forum_outlined,
        onTap: () => globalState.openUrl('https://t.me/bettbox_chat'),
      ),
      _LinkTile(
        title: 'Channel',
        icon: Icons.campaign_outlined,
        onTap: () => globalState.openUrl('https://t.me/appshub_channel'),
      ),
      _LinkTile(
        prefix: 'Forked from',
        title: 'FlClash',
        icon: Icons.code,
        onTap: () =>
            globalState.openUrl('https://github.com/chen08209/FlClash'),
      ),
      _LinkTile(
        prefix: 'Powered by',
        title: 'Mihomo',
        icon: Icons.memory,
        onTap: () => globalState.openUrl('https://github.com/MetaCubeX/mihomo'),
      ),
    ];
    return generateSection(
      title: appLocalizations.more,
      items: [
        for (var i = 0; i < links.length; i += 2)
          _LinkGridRow(left: links[i], right: links[i + 1]),
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
      const Contributor(
        avatar: 'assets/images/avatars/uclort.jpg',
        name: 'uclort',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/Catapult291.jpg',
        name: 'Catapult291',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/fig0ut.jpg',
        name: 'fig0ut',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/HarwoodKinnav.jpg',
        name: 'HarwoodKinnav',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/aaANDkk.jpg',
        name: 'aaANDkk',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/YumeYuka.jpg',
        name: 'YumeYuka',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/jasonsamtago.jpg',
        name: 'jasonsamtago',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/argsno.jpg',
        name: 'argsno',
      ),
      const Contributor(
        avatar: 'assets/images/avatars/suplzzz.jpg',
        name: 'suplzzz',
      ),
    ]..shuffle();
    return generateSection(
      separated: false,
      title: appLocalizations.otherContributors,
      items: [ListItem(title: _ContributorsRow(contributors: contributors))],
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

class _ContributorsRow extends StatefulWidget {
  final List<Contributor> contributors;

  const _ContributorsRow({required this.contributors});

  @override
  State<_ContributorsRow> createState() => _ContributorsRowState();
}

class _ContributorsRowState extends State<_ContributorsRow> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Shader _createEdgeShader(Rect rect) {
    final position = _controller.hasClients ? _controller.position : null;
    final hasBefore = position != null && position.extentBefore > 0;
    final hasAfter = position == null || position.extentAfter > 0;
    return LinearGradient(
      colors: [
        hasBefore ? Colors.transparent : Colors.white,
        Colors.white,
        Colors.white,
        hasAfter ? Colors.transparent : Colors.white,
      ],
      stops: const [0, 0.1, 0.9, 1],
    ).createShader(rect);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        child: Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          thickness: 4,
          radius: const Radius.circular(2),
          child: ShaderMask(
            shaderCallback: _createEdgeShader,
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 24,
                children: [
                  for (final contributor in widget.contributors)
                    Avatar(contributor: contributor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkGridRow extends StatelessWidget {
  final _LinkTile left;
  final _LinkTile right;

  const _LinkGridRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          VerticalDivider(
            width: 1,
            thickness: 1,
            indent: 10,
            endIndent: 10,
            color: colorScheme.outlineVariant.withValues(
              alpha: colorScheme.brightness == Brightness.light ? 0.6 : 0.45,
            ),
          ),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String? prefix;
  final String title;
  final IconData icon;
  final bool external;
  final VoidCallback onTap;

  const _LinkTile({
    this.prefix,
    required this.title,
    required this.icon,
    this.external = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final prefix = this.prefix;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.opacity12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: colorScheme.primary),
                ),
                const Spacer(),
                Icon(
                  external ? Icons.arrow_outward : Icons.arrow_forward,
                  size: 16,
                  color: colorScheme.onSurfaceVariant.opacity50,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  if (prefix != null)
                    TextSpan(
                      text: '$prefix ',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.opacity80,
                      ),
                    ),
                  TextSpan(text: title),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
