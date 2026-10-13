import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/panel/panel_auth.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/panel_login.dart';
import 'package:bett_box/widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// [Gamebox] 首页用户信息卡片。宽度和高度都与出站模式相同。
// 名称、用户、同步时间、流量、到期都读当前订阅，不写死「我的订阅」。
// 点击卡片走原版 showExtend 二级菜单。
class UserProfileCard extends ConsumerWidget {
  const UserProfileCard({super.key});

  void _openAccountSheet(BuildContext context, String title) {
    showExtend(
      context,
      builder: (sheetContext, type) {
        return AdaptiveSheetScaffold(
          type: type,
          title: title.isEmpty ? '账号' : title,
          body: generateListView(
            generateSection(
              items: [
                ListItem(
                  title: const Text('修改密码'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    showPanelChangePassword(
                      username: globalState.panelAccountName.value,
                    );
                  },
                ),
                ListItem(
                  title: const Text('退出账号'),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sync(WidgetRef ref, Profile profile) async {
    ref.read(profilesProvider.notifier).setProfile(
      profile.copyWith(isUpdating: true),
    );
    try {
      await globalState.appController.updateProfile(profile);
    } catch (e) {
      final current = ref.read(currentProfileProvider);
      if (current != null) {
        ref.read(profilesProvider.notifier).setProfile(
          current.copyWith(isUpdating: false),
        );
      }
      globalState.showNotifier(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final color = context.colorScheme.onSurfaceVariant;
    // [Gamebox] 与连通性卡片四行同一套字号/字重（labelMedium 12.ap）。
    final rowStyle = context.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 12.ap,
      color: context.colorScheme.onSurface,
    );
    final labelStyle = rowStyle?.copyWith(color: color);
    final title = (profile?.label ?? '').trim();
    final info = profile?.subscriptionInfo;
    final used = (info?.upload ?? 0) + (info?.download ?? 0);
    final traffic = info == null
        ? '-'
        : '${_trafficGb(used)} / ${_trafficGb(info.total)}';
    final expire = info?.expire ?? 0;
    final syncedAt = profile?.lastUpdateDate;
    final expireSoon = _expiringSoon(expire);

    return SizedBox(
      height: getWidgetHeight(2),
      child: CommonCard(
        onPressed: () => _openAccountSheet(context, title),
        child: Column(
          children: [
            Padding(
              // [Gamebox] 与连通性卡片同一套标题行边距，同步按钮贴在右上角。
              padding: EdgeInsets.fromLTRB(16.ap, 10.ap, 8.ap, 6.ap),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 18.ap,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: color,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24.ap,
                    height: 24.ap,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: profile == null || profile.isUpdating
                          ? null
                          : () => _sync(ref, profile),
                      icon: profile?.isUpdating == true
                          ? RepaintBoundary(
                              child: SizedBox(
                                width: 13.ap,
                                height: 13.ap,
                                child: SpinKitRing(
                                  color: context.colorScheme.primary,
                                  lineWidth: 1.5,
                                  size: 13.ap,
                                ),
                              ),
                            )
                          : Icon(Icons.sync, size: 16.ap, color: color),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.ap),
              child: Divider(
                height: 1,
                thickness: 1,
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.ap, 6.ap, 16.ap, 8.ap),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: globalState.panelAccountName,
                      builder: (_, name, _) {
                        return _line(
                          label: '用户',
                          value: name.trim().isEmpty ? '-' : name.trim(),
                          labelStyle: labelStyle,
                          valueStyle: rowStyle,
                        );
                      },
                    ),
                    _line(
                      label: '流量',
                      value: traffic,
                      labelStyle: labelStyle,
                      valueStyle: rowStyle,
                    ),
                    _line(
                      label: '同步',
                      // [Gamebox] 对齐 iGame 首页更新时间：YYYY-MM-DD HH:mm，停在首页也不会变。
                      value: _syncText(syncedAt),
                      labelStyle: labelStyle,
                      valueStyle: rowStyle,
                    ),
                    _line(
                      label: '到期',
                      value: _expireText(expire),
                      labelStyle: labelStyle,
                      // [Gamebox] 即将到期时不再单独打标签，直接把到期时间标红。
                      valueStyle: expireSoon
                          ? rowStyle?.copyWith(
                              color: context.colorScheme.error,
                            )
                          : rowStyle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// [Gamebox] 剩余不足 3 天且还没过期：到期时间用 error 色标红。
bool _expiringSoon(int expire) {
  if (expire <= 0) return false;
  final end = DateTime.fromMillisecondsSinceEpoch(expire * 1000);
  final remaining = end.difference(DateTime.now());
  return remaining > Duration.zero && remaining < const Duration(days: 3);
}

// [Gamebox] 订阅流量只显示 GB。整数不带小数，其余保留两位。
String _trafficGb(int bytes) {
  if (bytes <= 0) return '0 GB';
  final gb = bytes / 1024 / 1024 / 1024;
  final text = gb.toStringAsFixed(2);
  if (text.endsWith('.00')) {
    return '${gb.round()} GB';
  }
  return '$text GB';
}

// [Gamebox] 和到期时间一样显示到秒。
String _syncText(DateTime? time) {
  if (time == null) return '-';
  return time.showFull;
}

// [Gamebox] 对齐 iGame：时间是 00:00:00 时只显示日期，否则显示到秒。
String _expireText(int expire) {
  if (expire <= 0) return '-';
  final time = DateTime.fromMillisecondsSinceEpoch(expire * 1000).toLocal();
  if (time.hour == 0 && time.minute == 0 && time.second == 0) {
    return time.show;
  }
  return time.showFull;
}

// [Gamebox] 对齐 iGame 首页退出账号。确认后清订阅、清会话，回到登录小窗。
Future<void> _confirmLogout(BuildContext context) async {
  final result = await globalState.showCommonDialog<bool>(
    child: CommonDialog(
      title: '退出账号',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(false);
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(true);
          },
          child: const Text('退出账号'),
        ),
      ],
      child: const Text('是否退出账号'),
    ),
  );
  if (result != true) return;
  await logoutPanelAccount();
}

Widget _line({
  required String label,
  required String value,
  required TextStyle? labelStyle,
  required TextStyle? valueStyle,
}) {
  // [Gamebox] 行高 24.ap，与连通性卡片四行一致。
  return SizedBox(
    height: 24.ap,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$label:', style: labelStyle),
        SizedBox(width: 6.ap),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // [Gamebox] 数字等宽，同步时间和到期时间才能上下对齐。
            style: valueStyle?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    ),
  );
}
