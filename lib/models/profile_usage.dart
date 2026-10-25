import 'dart:math' as math;

import 'package:bett_box/common/app_localizations.dart';
import 'package:bett_box/enum/enum.dart';

import 'common.dart';
import 'profile.dart';

double? _usageRatio(int used, int total) =>
    total > 0 ? (used / total).clamp(0.0, 1.0) : null;

int _usedBytes(SubscriptionInfo info) => info.upload + info.download;

class ProfileUsage {
  static const _maxSegments = 4;

  final List<MapEntry<String, SubscriptionInfo>> items;
  final List<MapEntry<String, SubscriptionInfo>> shown;
  final List<SubscriptionInfo> rest;

  const ProfileUsage._(this.items, this.shown, this.rest);

  static ProfileUsage? of(Profile profile) {
    final items = profile.subscriptionUsages;
    if (items.isEmpty) return null;
    final shown = items.topByUsage(
      items.length > _maxSegments ? _maxSegments - 1 : items.length,
    );
    return ProfileUsage._(items, shown, [
      for (final item in items)
        if (!shown.contains(item)) item.value,
    ]);
  }

  bool get isMulti => items.length > 1;

  int get used => items.fold(0, (sum, item) => sum + _usedBytes(item.value));

  int get total => items.fold(0, (sum, item) => sum + item.value.total);

  bool get unlimited => items.any((item) => item.value.total <= 0);

  double? get ratio => unlimited ? null : _usageRatio(used, total);

  String get totalText => unlimited ? '∞' : TrafficValue(value: total).show;

  String get usageText => '${TrafficValue(value: used).show} / $totalText';

  List<double> get segments {
    final limited = rest.where((info) => info.total > 0);
    return [
      for (final item in shown)
        ?_usageRatio(_usedBytes(item.value), item.value.total),
      if (limited.isNotEmpty)
        ?_usageRatio(
          limited.fold(0, (sum, info) => sum + _usedBytes(info)),
          limited.fold(0, (sum, info) => sum + info.total),
        ),
    ];
  }

  SubscriptionInfo get _nearest {
    final expiring =
        items
            .map((item) => item.value)
            .where((info) => info.expire > 0)
            .toList()
          ..sort((a, b) => a.expire.compareTo(b.expire));
    return expiring.firstOrNull ?? items.first.value;
  }

  String? get expireText => _nearest.expireDesc;

  DateTime? get expireAt {
    final expire = _nearest.expire;
    return expire > 0
        ? DateTime.fromMillisecondsSinceEpoch(expire * 1000)
        : null;
  }

  int? get remaining => unlimited ? null : math.max(total - used, 0);

  int? get daysLeft {
    final expire = _nearest.expire;
    if (expire <= 0) return null;
    final end = DateTime.fromMillisecondsSinceEpoch(expire * 1000);
    return math.max(end.difference(DateTime.now()).inDays, 0);
  }

  bool get isExpired {
    final expire = _nearest.expire;
    return expire > 0 && expire * 1000 < DateTime.now().millisecondsSinceEpoch;
  }

  String get breakdown => [
    for (final item in shown)
      '${item.key} ${switch (_usageRatio(_usedBytes(item.value), item.value.total)) {
        final ratio? => '${(ratio * 100).round()}%',
        null => TrafficValue(value: _usedBytes(item.value)).shortShow,
      }}',
    if (rest.isNotEmpty) '+${rest.length}',
  ].join('  ·  ');
}

extension ProfileUsageExt on Profile {
  String? usageExpireText(ProfileUsage? usage) =>
      usage?.expireText ??
      (type == ProfileType.file ? appLocalizations.localFile : null);
}
