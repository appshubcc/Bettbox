import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/about.dart';
import 'package:bett_box/views/access.dart';
import 'package:bett_box/views/application_setting.dart';
import 'package:bett_box/views/config/config.dart';
import 'package:bett_box/views/connection/connections.dart';
import 'package:bett_box/views/hotkey.dart';
import 'package:bett_box/views/other_setting.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show dirname, join;

import 'backup_and_recovery.dart';
import 'developer.dart';
import 'theme.dart';

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  Widget _buildNavigationPage(NavigationItem navigationItem) {
    if (navigationItem.label == PageLabel.connections) {
      return const ConnectionsView(respectCurrentPage: false);
    }
    return navigationItem.builder(context);
  }

  Widget _buildNavigationMenuItem(NavigationItem navigationItem) {
    return ListItem.next(
      leading: navigationItem.icon,
      title: Text(Intl.message(navigationItem.label.name)),
      subtitle: navigationItem.description != null
          ? Text(Intl.message(navigationItem.description!))
          : null,
      delegate: NextDelegate(
        title: Intl.message(navigationItem.label.name),
        builder: (_) => _buildNavigationPage(navigationItem),
        wrap: false,
      ),
    );
  }

  Widget _buildModernSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListHeader(
            title: title,
            padding: const EdgeInsets.only(left: 8, bottom: 8),
          ),
          CommonCard(
            type: CommonCardType.filled,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i != items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.colorScheme.outlineVariant.withValues(
                        alpha:
                            context.colorScheme.brightness == Brightness.light
                            ? 0.3
                            : 0.2,
                      ),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm2 = ref.watch(
      appSettingProvider.select(
        (state) => VM2(a: state.locale, b: state.developerMode),
      ),
    );
    final isMobileView = ref.watch(isMobileViewProvider);

    final items = [
      Consumer(
        builder: (_, ref, _) {
          final state = ref.watch(moreToolsSelectorStateProvider);
          if (state.navigationItems.isEmpty) {
            return Container();
          }
          return _buildModernSection(
            context,
            title: appLocalizations.more,
            items: state.navigationItems
                .map((item) => _buildNavigationMenuItem(item))
                .toList(),
          );
        },
      ),
      _buildModernSection(
        context,
        title: appLocalizations.settings,
        items: [
          _LocaleItem(),
          _ThemeItem(),
          _BackupItem(),
          if (system.isDesktop) _HotkeyItem(),
          if (system.isWindows) _LoopbackItem(),
          if (system.isAndroid) _AccessItem(),
          _ConfigItem(),
          _OtherSettingItem(),
          _SettingItem(),
        ],
      ),
      _buildModernSection(
        context,
        title: appLocalizations.other,
        items: [_DisclaimerItem(), if (vm2.b) _DeveloperItem(), _InfoItem()],
      ),
    ];

    return CommonScaffold(
      title: appLocalizations.tools,
      body: ListView.builder(
        key: toolsStoreKey,
        itemCount: items.length,
        itemBuilder: (_, index) => items[index],
        padding: EdgeInsets.only(
          bottom:
              20 +
              (isMobileView ? getFloatingBottomBarReserveHeight(context) : 0),
          top: 8,
        ),
      ),
    );
  }
}

class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  static final List<Locale> _localeOptions =
      AppLocalizations.delegate.supportedLocales;

  String _getLocaleString(Locale locale) {
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final currentLocale =
        utils.getLocaleForString(locale) ?? utils.getSystemLocale();
    return ListItem<Locale>.options(
      leading: const Icon(Icons.language_outlined),
      title: Text(appLocalizations.language),
      subtitle: Text(Intl.message(currentLocale.toString())),
      delegate: OptionsDelegate(
        title: appLocalizations.language,
        options: _localeOptions,
        onChanged: (Locale? locale) {
          if (locale == null) return;
          ref
              .read(appSettingProvider.notifier)
              .updateState(
                (state) => state.copyWith(locale: locale.toString()),
              );
        },
        textBuilder: (locale) => _getLocaleString(locale),
        value: currentLocale,
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.style),
      title: Text(appLocalizations.theme),
      subtitle: Text(appLocalizations.themeDesc),
      delegate: NextDelegate(
        title: appLocalizations.theme,
        builder: (_) => const ThemeView(),
      ),
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.cloud_sync),
      title: Text(appLocalizations.backupAndRecovery),
      subtitle: Text(appLocalizations.backupAndRecoveryDesc),
      delegate: NextDelegate(
        title: appLocalizations.backupAndRecovery,
        builder: (_) => const BackupAndRecovery(),
      ),
    );
  }
}

class _HotkeyItem extends StatelessWidget {
  const _HotkeyItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.keyboard),
      title: Text(appLocalizations.hotkeyManagement),
      subtitle: Text(appLocalizations.hotkeyManagementDesc),
      delegate: NextDelegate(
        title: appLocalizations.hotkeyManagement,
        builder: (_) => const HotKeyView(),
      ),
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.lock),
      title: Text(appLocalizations.loopback),
      subtitle: Text(appLocalizations.loopbackDesc),
      onTap: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "WindowsLoopbackManager.exe")}"',
          '',
          showWindow: true,
        );
      },
    );
  }
}

class _AccessItem extends StatelessWidget {
  const _AccessItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.view_list),
      title: Text(appLocalizations.accessControl),
      subtitle: Text(appLocalizations.accessControlDesc),
      delegate: NextDelegate(
        title: appLocalizations.appAccessControl,
        builder: (_) => const AccessView(),
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.edit),
      title: Text(appLocalizations.basicConfig),
      subtitle: Text(appLocalizations.basicConfigDesc),
      delegate: NextDelegate(
        title: appLocalizations.basicConfig,
        builder: (_) => const ConfigView(),
      ),
    );
  }
}

class _OtherSettingItem extends StatelessWidget {
  const _OtherSettingItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.settings_suggest_outlined),
      title: Text(appLocalizations.otherSettings),
      subtitle: Text(appLocalizations.otherSettingsDesc),
      delegate: NextDelegate(
        title: appLocalizations.otherSettings,
        builder: (_) => const OtherSettingView(),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.settings),
      title: Text(appLocalizations.application),
      subtitle: Text(appLocalizations.applicationDesc),
      delegate: NextDelegate(
        title: appLocalizations.application,
        builder: (_) => const ApplicationSettingView(),
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.gavel),
      title: Text(appLocalizations.disclaimer),
      onTap: () async {
        final isDisclaimerAccepted = await globalState.appController
            .showDisclaimer();
        if (!isDisclaimerAccepted) {
          globalState.appController.handleExit();
        }
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.info),
      title: Text(appLocalizations.about),
      delegate: NextDelegate(
        title: appLocalizations.about,
        builder: (_) => const AboutView(),
      ),
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.developer_board),
      title: Text(appLocalizations.developerMode),
      delegate: NextDelegate(
        title: appLocalizations.developerMode,
        builder: (_) => const DeveloperView(),
      ),
    );
  }
}
