import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/home_widget.freezed.dart';
part 'generated/home_widget.g.dart';

@freezed
abstract class HomeWidgetColors with _$HomeWidgetColors {
  const factory HomeWidgetColors({
    required int surface,
    required int tonal,
    required int onSurface,
    required int onSurfaceVariant,
    required int primary,
    required int onPrimary,
    required int active,
    required int onActive,
  }) = _HomeWidgetColors;

  factory HomeWidgetColors.fromJson(Map<String, Object?> json) =>
      _$HomeWidgetColorsFromJson(json);
}

@freezed
abstract class HomeWidgetSnapshot with _$HomeWidgetSnapshot {
  const factory HomeWidgetSnapshot({
    @Default(false) bool hasProfile,
    @Default('') String emptyText,
    @Default('') String name,
    @Default('') String updated,
    @Default('') String subtitle,
    @Default(false) bool expired,
    @Default('') String used,
    @Default('') String total,
    @Default('') String usage,
    @Default('') String percent,
    @Default([0]) List<double> segments,
    @Default('') String firstLabel,
    @Default('') String firstValue,
    @Default('') String secondLabel,
    @Default('') String secondValue,
    @Default('') String expireShort,
    @Default('') String nodeLabel,
    @Default('') String node,
    @Default('') String delay,
    @Default(0) int delayColor,
    @Default(false) bool canRefresh,
    @Default(false) bool refreshing,
    @Default('') String onLabel,
    @Default('') String offLabel,
    required HomeWidgetColors light,
    required HomeWidgetColors dark,
  }) = _HomeWidgetSnapshot;

  factory HomeWidgetSnapshot.fromJson(Map<String, Object?> json) =>
      _$HomeWidgetSnapshotFromJson(json);
}
