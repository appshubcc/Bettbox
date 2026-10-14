// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettingProps {

 String? get locale;@JsonKey(fromJson: dashboardWidgetsSafeFromJson) List<DashboardWidget> get dashboardWidgets;@JsonKey(fromJson: mobileDashboardWidgetsSafeFromJson) List<DashboardWidget> get mobileDashboardWidgets;@JsonKey(fromJson: desktopDashboardWidgetsSafeFromJson) List<DashboardWidget> get desktopDashboardWidgets;@JsonKey(fromJson: pinnedMediaPlatformsSafeFromJson) List<MediaPlatform> get pinnedMediaPlatforms; bool get mediaUnlockMoreStreamingPlatforms; bool get mediaUnlockExtraDetails; bool get mediaUnlockRefreshOnNodeChange; bool get mediaUnlockColorfulIcons; bool get mediaUnlockRefreshByCategory; bool get onlyStatisticsProxy; bool get autoLaunch; bool get silentLaunch; bool get smartDelayLaunch; bool get autoRun; bool get openLogs; bool get closeConnections; bool get logAiSearch; bool get flushDnsOnNetworkChange; String get testUrl; bool get showStartSwitch; StartSwitchStyle get startSwitchStyle; String? get startSwitchOnLabel; String? get startSwitchOffLabel; bool get enableNavBarHapticFeedback; bool get autoCheckUpdate; bool get showLabel; bool get disclaimerAccepted; bool get minimizeOnExit; bool get hidden; bool get keepDockIcon; bool get developerMode; RecoveryStrategy get recoveryStrategy; bool get enableHighPriority; bool get sidebarCollapsed; bool get sidebarFlyout; bool get sidebarFlyoutOutsideTools; SidebarFlyoutDelay get sidebarFlyoutDelay;@JsonKey(fromJson: sidebarFlyoutEntriesSafeFromJson) List<SidebarFlyoutEntry> get sidebarFlyoutEntries; String? get dashboardTitle;
/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<AppSettingProps> get copyWith => _$AppSettingPropsCopyWithImpl<AppSettingProps>(this as AppSettingProps, _$identity);

  /// Serializes this AppSettingProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppSettingProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettingProps&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&const DeepCollectionEquality().equals(other.dashboardWidgets, _this.dashboardWidgets)&&const DeepCollectionEquality().equals(other.mobileDashboardWidgets, _this.mobileDashboardWidgets)&&const DeepCollectionEquality().equals(other.desktopDashboardWidgets, _this.desktopDashboardWidgets)&&const DeepCollectionEquality().equals(other.pinnedMediaPlatforms, _this.pinnedMediaPlatforms)&&(identical(other.mediaUnlockMoreStreamingPlatforms, _this.mediaUnlockMoreStreamingPlatforms) || other.mediaUnlockMoreStreamingPlatforms == _this.mediaUnlockMoreStreamingPlatforms)&&(identical(other.mediaUnlockExtraDetails, _this.mediaUnlockExtraDetails) || other.mediaUnlockExtraDetails == _this.mediaUnlockExtraDetails)&&(identical(other.mediaUnlockRefreshOnNodeChange, _this.mediaUnlockRefreshOnNodeChange) || other.mediaUnlockRefreshOnNodeChange == _this.mediaUnlockRefreshOnNodeChange)&&(identical(other.mediaUnlockColorfulIcons, _this.mediaUnlockColorfulIcons) || other.mediaUnlockColorfulIcons == _this.mediaUnlockColorfulIcons)&&(identical(other.mediaUnlockRefreshByCategory, _this.mediaUnlockRefreshByCategory) || other.mediaUnlockRefreshByCategory == _this.mediaUnlockRefreshByCategory)&&(identical(other.onlyStatisticsProxy, _this.onlyStatisticsProxy) || other.onlyStatisticsProxy == _this.onlyStatisticsProxy)&&(identical(other.autoLaunch, _this.autoLaunch) || other.autoLaunch == _this.autoLaunch)&&(identical(other.silentLaunch, _this.silentLaunch) || other.silentLaunch == _this.silentLaunch)&&(identical(other.smartDelayLaunch, _this.smartDelayLaunch) || other.smartDelayLaunch == _this.smartDelayLaunch)&&(identical(other.autoRun, _this.autoRun) || other.autoRun == _this.autoRun)&&(identical(other.openLogs, _this.openLogs) || other.openLogs == _this.openLogs)&&(identical(other.closeConnections, _this.closeConnections) || other.closeConnections == _this.closeConnections)&&(identical(other.logAiSearch, _this.logAiSearch) || other.logAiSearch == _this.logAiSearch)&&(identical(other.flushDnsOnNetworkChange, _this.flushDnsOnNetworkChange) || other.flushDnsOnNetworkChange == _this.flushDnsOnNetworkChange)&&(identical(other.testUrl, _this.testUrl) || other.testUrl == _this.testUrl)&&(identical(other.showStartSwitch, _this.showStartSwitch) || other.showStartSwitch == _this.showStartSwitch)&&(identical(other.startSwitchStyle, _this.startSwitchStyle) || other.startSwitchStyle == _this.startSwitchStyle)&&(identical(other.startSwitchOnLabel, _this.startSwitchOnLabel) || other.startSwitchOnLabel == _this.startSwitchOnLabel)&&(identical(other.startSwitchOffLabel, _this.startSwitchOffLabel) || other.startSwitchOffLabel == _this.startSwitchOffLabel)&&(identical(other.enableNavBarHapticFeedback, _this.enableNavBarHapticFeedback) || other.enableNavBarHapticFeedback == _this.enableNavBarHapticFeedback)&&(identical(other.autoCheckUpdate, _this.autoCheckUpdate) || other.autoCheckUpdate == _this.autoCheckUpdate)&&(identical(other.showLabel, _this.showLabel) || other.showLabel == _this.showLabel)&&(identical(other.disclaimerAccepted, _this.disclaimerAccepted) || other.disclaimerAccepted == _this.disclaimerAccepted)&&(identical(other.minimizeOnExit, _this.minimizeOnExit) || other.minimizeOnExit == _this.minimizeOnExit)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.keepDockIcon, _this.keepDockIcon) || other.keepDockIcon == _this.keepDockIcon)&&(identical(other.developerMode, _this.developerMode) || other.developerMode == _this.developerMode)&&(identical(other.recoveryStrategy, _this.recoveryStrategy) || other.recoveryStrategy == _this.recoveryStrategy)&&(identical(other.enableHighPriority, _this.enableHighPriority) || other.enableHighPriority == _this.enableHighPriority)&&(identical(other.sidebarCollapsed, _this.sidebarCollapsed) || other.sidebarCollapsed == _this.sidebarCollapsed)&&(identical(other.sidebarFlyout, _this.sidebarFlyout) || other.sidebarFlyout == _this.sidebarFlyout)&&(identical(other.sidebarFlyoutOutsideTools, _this.sidebarFlyoutOutsideTools) || other.sidebarFlyoutOutsideTools == _this.sidebarFlyoutOutsideTools)&&(identical(other.sidebarFlyoutDelay, _this.sidebarFlyoutDelay) || other.sidebarFlyoutDelay == _this.sidebarFlyoutDelay)&&const DeepCollectionEquality().equals(other.sidebarFlyoutEntries, _this.sidebarFlyoutEntries)&&(identical(other.dashboardTitle, _this.dashboardTitle) || other.dashboardTitle == _this.dashboardTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppSettingProps;
  return Object.hashAll([runtimeType,_this.locale,const DeepCollectionEquality().hash(_this.dashboardWidgets),const DeepCollectionEquality().hash(_this.mobileDashboardWidgets),const DeepCollectionEquality().hash(_this.desktopDashboardWidgets),const DeepCollectionEquality().hash(_this.pinnedMediaPlatforms),_this.mediaUnlockMoreStreamingPlatforms,_this.mediaUnlockExtraDetails,_this.mediaUnlockRefreshOnNodeChange,_this.mediaUnlockColorfulIcons,_this.mediaUnlockRefreshByCategory,_this.onlyStatisticsProxy,_this.autoLaunch,_this.silentLaunch,_this.smartDelayLaunch,_this.autoRun,_this.openLogs,_this.closeConnections,_this.logAiSearch,_this.flushDnsOnNetworkChange,_this.testUrl,_this.showStartSwitch,_this.startSwitchStyle,_this.startSwitchOnLabel,_this.startSwitchOffLabel,_this.enableNavBarHapticFeedback,_this.autoCheckUpdate,_this.showLabel,_this.disclaimerAccepted,_this.minimizeOnExit,_this.hidden,_this.keepDockIcon,_this.developerMode,_this.recoveryStrategy,_this.enableHighPriority,_this.sidebarCollapsed,_this.sidebarFlyout,_this.sidebarFlyoutOutsideTools,_this.sidebarFlyoutDelay,const DeepCollectionEquality().hash(_this.sidebarFlyoutEntries),_this.dashboardTitle]);
}

@override
String toString() {
  final _this = this as AppSettingProps;
  return 'AppSettingProps(locale: ${_this.locale}, dashboardWidgets: ${_this.dashboardWidgets}, mobileDashboardWidgets: ${_this.mobileDashboardWidgets}, desktopDashboardWidgets: ${_this.desktopDashboardWidgets}, pinnedMediaPlatforms: ${_this.pinnedMediaPlatforms}, mediaUnlockMoreStreamingPlatforms: ${_this.mediaUnlockMoreStreamingPlatforms}, mediaUnlockExtraDetails: ${_this.mediaUnlockExtraDetails}, mediaUnlockRefreshOnNodeChange: ${_this.mediaUnlockRefreshOnNodeChange}, mediaUnlockColorfulIcons: ${_this.mediaUnlockColorfulIcons}, mediaUnlockRefreshByCategory: ${_this.mediaUnlockRefreshByCategory}, onlyStatisticsProxy: ${_this.onlyStatisticsProxy}, autoLaunch: ${_this.autoLaunch}, silentLaunch: ${_this.silentLaunch}, smartDelayLaunch: ${_this.smartDelayLaunch}, autoRun: ${_this.autoRun}, openLogs: ${_this.openLogs}, closeConnections: ${_this.closeConnections}, logAiSearch: ${_this.logAiSearch}, flushDnsOnNetworkChange: ${_this.flushDnsOnNetworkChange}, testUrl: ${_this.testUrl}, showStartSwitch: ${_this.showStartSwitch}, startSwitchStyle: ${_this.startSwitchStyle}, startSwitchOnLabel: ${_this.startSwitchOnLabel}, startSwitchOffLabel: ${_this.startSwitchOffLabel}, enableNavBarHapticFeedback: ${_this.enableNavBarHapticFeedback}, autoCheckUpdate: ${_this.autoCheckUpdate}, showLabel: ${_this.showLabel}, disclaimerAccepted: ${_this.disclaimerAccepted}, minimizeOnExit: ${_this.minimizeOnExit}, hidden: ${_this.hidden}, keepDockIcon: ${_this.keepDockIcon}, developerMode: ${_this.developerMode}, recoveryStrategy: ${_this.recoveryStrategy}, enableHighPriority: ${_this.enableHighPriority}, sidebarCollapsed: ${_this.sidebarCollapsed}, sidebarFlyout: ${_this.sidebarFlyout}, sidebarFlyoutOutsideTools: ${_this.sidebarFlyoutOutsideTools}, sidebarFlyoutDelay: ${_this.sidebarFlyoutDelay}, sidebarFlyoutEntries: ${_this.sidebarFlyoutEntries}, dashboardTitle: ${_this.dashboardTitle})';
}


}

/// @nodoc
abstract mixin class $AppSettingPropsCopyWith<$Res>  {
  factory $AppSettingPropsCopyWith(AppSettingProps value, $Res Function(AppSettingProps) _then) = _$AppSettingPropsCopyWithImpl;
@useResult
$Res call({
 String? locale,@JsonKey(fromJson: dashboardWidgetsSafeFromJson) List<DashboardWidget> dashboardWidgets,@JsonKey(fromJson: mobileDashboardWidgetsSafeFromJson) List<DashboardWidget> mobileDashboardWidgets,@JsonKey(fromJson: desktopDashboardWidgetsSafeFromJson) List<DashboardWidget> desktopDashboardWidgets,@JsonKey(fromJson: pinnedMediaPlatformsSafeFromJson) List<MediaPlatform> pinnedMediaPlatforms, bool mediaUnlockMoreStreamingPlatforms, bool mediaUnlockExtraDetails, bool mediaUnlockRefreshOnNodeChange, bool mediaUnlockColorfulIcons, bool mediaUnlockRefreshByCategory, bool onlyStatisticsProxy, bool autoLaunch, bool silentLaunch, bool smartDelayLaunch, bool autoRun, bool openLogs, bool closeConnections, bool logAiSearch, bool flushDnsOnNetworkChange, String testUrl, bool showStartSwitch, StartSwitchStyle startSwitchStyle, String? startSwitchOnLabel, String? startSwitchOffLabel, bool enableNavBarHapticFeedback, bool autoCheckUpdate, bool showLabel, bool disclaimerAccepted, bool minimizeOnExit, bool hidden, bool keepDockIcon, bool developerMode, RecoveryStrategy recoveryStrategy, bool enableHighPriority, bool sidebarCollapsed, bool sidebarFlyout, bool sidebarFlyoutOutsideTools, SidebarFlyoutDelay sidebarFlyoutDelay,@JsonKey(fromJson: sidebarFlyoutEntriesSafeFromJson) List<SidebarFlyoutEntry> sidebarFlyoutEntries, String? dashboardTitle
});




}
/// @nodoc
class _$AppSettingPropsCopyWithImpl<$Res>
    implements $AppSettingPropsCopyWith<$Res> {
  _$AppSettingPropsCopyWithImpl(this._self, this._then);

  final AppSettingProps _self;
  final $Res Function(AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = freezed,Object? dashboardWidgets = null,Object? mobileDashboardWidgets = null,Object? desktopDashboardWidgets = null,Object? pinnedMediaPlatforms = null,Object? mediaUnlockMoreStreamingPlatforms = null,Object? mediaUnlockExtraDetails = null,Object? mediaUnlockRefreshOnNodeChange = null,Object? mediaUnlockColorfulIcons = null,Object? mediaUnlockRefreshByCategory = null,Object? onlyStatisticsProxy = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? smartDelayLaunch = null,Object? autoRun = null,Object? openLogs = null,Object? closeConnections = null,Object? logAiSearch = null,Object? flushDnsOnNetworkChange = null,Object? testUrl = null,Object? showStartSwitch = null,Object? startSwitchStyle = null,Object? startSwitchOnLabel = freezed,Object? startSwitchOffLabel = freezed,Object? enableNavBarHapticFeedback = null,Object? autoCheckUpdate = null,Object? showLabel = null,Object? disclaimerAccepted = null,Object? minimizeOnExit = null,Object? hidden = null,Object? keepDockIcon = null,Object? developerMode = null,Object? recoveryStrategy = null,Object? enableHighPriority = null,Object? sidebarCollapsed = null,Object? sidebarFlyout = null,Object? sidebarFlyoutOutsideTools = null,Object? sidebarFlyoutDelay = null,Object? sidebarFlyoutEntries = null,Object? dashboardTitle = freezed,}) {
  return _then(AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,dashboardWidgets: null == dashboardWidgets ? _self.dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,mobileDashboardWidgets: null == mobileDashboardWidgets ? _self.mobileDashboardWidgets : mobileDashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,desktopDashboardWidgets: null == desktopDashboardWidgets ? _self.desktopDashboardWidgets : desktopDashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,pinnedMediaPlatforms: null == pinnedMediaPlatforms ? _self.pinnedMediaPlatforms : pinnedMediaPlatforms // ignore: cast_nullable_to_non_nullable
as List<MediaPlatform>,mediaUnlockMoreStreamingPlatforms: null == mediaUnlockMoreStreamingPlatforms ? _self.mediaUnlockMoreStreamingPlatforms : mediaUnlockMoreStreamingPlatforms // ignore: cast_nullable_to_non_nullable
as bool,mediaUnlockExtraDetails: null == mediaUnlockExtraDetails ? _self.mediaUnlockExtraDetails : mediaUnlockExtraDetails // ignore: cast_nullable_to_non_nullable
as bool,mediaUnlockRefreshOnNodeChange: null == mediaUnlockRefreshOnNodeChange ? _self.mediaUnlockRefreshOnNodeChange : mediaUnlockRefreshOnNodeChange // ignore: cast_nullable_to_non_nullable
as bool,mediaUnlockColorfulIcons: null == mediaUnlockColorfulIcons ? _self.mediaUnlockColorfulIcons : mediaUnlockColorfulIcons // ignore: cast_nullable_to_non_nullable
as bool,mediaUnlockRefreshByCategory: null == mediaUnlockRefreshByCategory ? _self.mediaUnlockRefreshByCategory : mediaUnlockRefreshByCategory // ignore: cast_nullable_to_non_nullable
as bool,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,smartDelayLaunch: null == smartDelayLaunch ? _self.smartDelayLaunch : smartDelayLaunch // ignore: cast_nullable_to_non_nullable
as bool,autoRun: null == autoRun ? _self.autoRun : autoRun // ignore: cast_nullable_to_non_nullable
as bool,openLogs: null == openLogs ? _self.openLogs : openLogs // ignore: cast_nullable_to_non_nullable
as bool,closeConnections: null == closeConnections ? _self.closeConnections : closeConnections // ignore: cast_nullable_to_non_nullable
as bool,logAiSearch: null == logAiSearch ? _self.logAiSearch : logAiSearch // ignore: cast_nullable_to_non_nullable
as bool,flushDnsOnNetworkChange: null == flushDnsOnNetworkChange ? _self.flushDnsOnNetworkChange : flushDnsOnNetworkChange // ignore: cast_nullable_to_non_nullable
as bool,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,showStartSwitch: null == showStartSwitch ? _self.showStartSwitch : showStartSwitch // ignore: cast_nullable_to_non_nullable
as bool,startSwitchStyle: null == startSwitchStyle ? _self.startSwitchStyle : startSwitchStyle // ignore: cast_nullable_to_non_nullable
as StartSwitchStyle,startSwitchOnLabel: freezed == startSwitchOnLabel ? _self.startSwitchOnLabel : startSwitchOnLabel // ignore: cast_nullable_to_non_nullable
as String?,startSwitchOffLabel: freezed == startSwitchOffLabel ? _self.startSwitchOffLabel : startSwitchOffLabel // ignore: cast_nullable_to_non_nullable
as String?,enableNavBarHapticFeedback: null == enableNavBarHapticFeedback ? _self.enableNavBarHapticFeedback : enableNavBarHapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,showLabel: null == showLabel ? _self.showLabel : showLabel // ignore: cast_nullable_to_non_nullable
as bool,disclaimerAccepted: null == disclaimerAccepted ? _self.disclaimerAccepted : disclaimerAccepted // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,keepDockIcon: null == keepDockIcon ? _self.keepDockIcon : keepDockIcon // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,recoveryStrategy: null == recoveryStrategy ? _self.recoveryStrategy : recoveryStrategy // ignore: cast_nullable_to_non_nullable
as RecoveryStrategy,enableHighPriority: null == enableHighPriority ? _self.enableHighPriority : enableHighPriority // ignore: cast_nullable_to_non_nullable
as bool,sidebarCollapsed: null == sidebarCollapsed ? _self.sidebarCollapsed : sidebarCollapsed // ignore: cast_nullable_to_non_nullable
as bool,sidebarFlyout: null == sidebarFlyout ? _self.sidebarFlyout : sidebarFlyout // ignore: cast_nullable_to_non_nullable
as bool,sidebarFlyoutOutsideTools: null == sidebarFlyoutOutsideTools ? _self.sidebarFlyoutOutsideTools : sidebarFlyoutOutsideTools // ignore: cast_nullable_to_non_nullable
as bool,sidebarFlyoutDelay: null == sidebarFlyoutDelay ? _self.sidebarFlyoutDelay : sidebarFlyoutDelay // ignore: cast_nullable_to_non_nullable
as SidebarFlyoutDelay,sidebarFlyoutEntries: null == sidebarFlyoutEntries ? _self.sidebarFlyoutEntries : sidebarFlyoutEntries // ignore: cast_nullable_to_non_nullable
as List<SidebarFlyoutEntry>,dashboardTitle: freezed == dashboardTitle ? _self.dashboardTitle : dashboardTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettingProps].
extension AppSettingPropsPatterns on AppSettingProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettingProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettingProps value)  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettingProps value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locale, @JsonKey(fromJson: dashboardWidgetsSafeFromJson)  List<DashboardWidget> dashboardWidgets, @JsonKey(fromJson: mobileDashboardWidgetsSafeFromJson)  List<DashboardWidget> mobileDashboardWidgets, @JsonKey(fromJson: desktopDashboardWidgetsSafeFromJson)  List<DashboardWidget> desktopDashboardWidgets, @JsonKey(fromJson: pinnedMediaPlatformsSafeFromJson)  List<MediaPlatform> pinnedMediaPlatforms,  bool mediaUnlockMoreStreamingPlatforms,  bool mediaUnlockExtraDetails,  bool mediaUnlockRefreshOnNodeChange,  bool mediaUnlockColorfulIcons,  bool mediaUnlockRefreshByCategory,  bool onlyStatisticsProxy,  bool autoLaunch,  bool silentLaunch,  bool smartDelayLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  bool logAiSearch,  bool flushDnsOnNetworkChange,  String testUrl,  bool showStartSwitch,  StartSwitchStyle startSwitchStyle,  String? startSwitchOnLabel,  String? startSwitchOffLabel,  bool enableNavBarHapticFeedback,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool minimizeOnExit,  bool hidden,  bool keepDockIcon,  bool developerMode,  RecoveryStrategy recoveryStrategy,  bool enableHighPriority,  bool sidebarCollapsed,  bool sidebarFlyout,  bool sidebarFlyoutOutsideTools,  SidebarFlyoutDelay sidebarFlyoutDelay, @JsonKey(fromJson: sidebarFlyoutEntriesSafeFromJson)  List<SidebarFlyoutEntry> sidebarFlyoutEntries,  String? dashboardTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.dashboardWidgets,_that.mobileDashboardWidgets,_that.desktopDashboardWidgets,_that.pinnedMediaPlatforms,_that.mediaUnlockMoreStreamingPlatforms,_that.mediaUnlockExtraDetails,_that.mediaUnlockRefreshOnNodeChange,_that.mediaUnlockColorfulIcons,_that.mediaUnlockRefreshByCategory,_that.onlyStatisticsProxy,_that.autoLaunch,_that.silentLaunch,_that.smartDelayLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.logAiSearch,_that.flushDnsOnNetworkChange,_that.testUrl,_that.showStartSwitch,_that.startSwitchStyle,_that.startSwitchOnLabel,_that.startSwitchOffLabel,_that.enableNavBarHapticFeedback,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.minimizeOnExit,_that.hidden,_that.keepDockIcon,_that.developerMode,_that.recoveryStrategy,_that.enableHighPriority,_that.sidebarCollapsed,_that.sidebarFlyout,_that.sidebarFlyoutOutsideTools,_that.sidebarFlyoutDelay,_that.sidebarFlyoutEntries,_that.dashboardTitle);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locale, @JsonKey(fromJson: dashboardWidgetsSafeFromJson)  List<DashboardWidget> dashboardWidgets, @JsonKey(fromJson: mobileDashboardWidgetsSafeFromJson)  List<DashboardWidget> mobileDashboardWidgets, @JsonKey(fromJson: desktopDashboardWidgetsSafeFromJson)  List<DashboardWidget> desktopDashboardWidgets, @JsonKey(fromJson: pinnedMediaPlatformsSafeFromJson)  List<MediaPlatform> pinnedMediaPlatforms,  bool mediaUnlockMoreStreamingPlatforms,  bool mediaUnlockExtraDetails,  bool mediaUnlockRefreshOnNodeChange,  bool mediaUnlockColorfulIcons,  bool mediaUnlockRefreshByCategory,  bool onlyStatisticsProxy,  bool autoLaunch,  bool silentLaunch,  bool smartDelayLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  bool logAiSearch,  bool flushDnsOnNetworkChange,  String testUrl,  bool showStartSwitch,  StartSwitchStyle startSwitchStyle,  String? startSwitchOnLabel,  String? startSwitchOffLabel,  bool enableNavBarHapticFeedback,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool minimizeOnExit,  bool hidden,  bool keepDockIcon,  bool developerMode,  RecoveryStrategy recoveryStrategy,  bool enableHighPriority,  bool sidebarCollapsed,  bool sidebarFlyout,  bool sidebarFlyoutOutsideTools,  SidebarFlyoutDelay sidebarFlyoutDelay, @JsonKey(fromJson: sidebarFlyoutEntriesSafeFromJson)  List<SidebarFlyoutEntry> sidebarFlyoutEntries,  String? dashboardTitle)  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps():
return $default(_that.locale,_that.dashboardWidgets,_that.mobileDashboardWidgets,_that.desktopDashboardWidgets,_that.pinnedMediaPlatforms,_that.mediaUnlockMoreStreamingPlatforms,_that.mediaUnlockExtraDetails,_that.mediaUnlockRefreshOnNodeChange,_that.mediaUnlockColorfulIcons,_that.mediaUnlockRefreshByCategory,_that.onlyStatisticsProxy,_that.autoLaunch,_that.silentLaunch,_that.smartDelayLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.logAiSearch,_that.flushDnsOnNetworkChange,_that.testUrl,_that.showStartSwitch,_that.startSwitchStyle,_that.startSwitchOnLabel,_that.startSwitchOffLabel,_that.enableNavBarHapticFeedback,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.minimizeOnExit,_that.hidden,_that.keepDockIcon,_that.developerMode,_that.recoveryStrategy,_that.enableHighPriority,_that.sidebarCollapsed,_that.sidebarFlyout,_that.sidebarFlyoutOutsideTools,_that.sidebarFlyoutDelay,_that.sidebarFlyoutEntries,_that.dashboardTitle);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locale, @JsonKey(fromJson: dashboardWidgetsSafeFromJson)  List<DashboardWidget> dashboardWidgets, @JsonKey(fromJson: mobileDashboardWidgetsSafeFromJson)  List<DashboardWidget> mobileDashboardWidgets, @JsonKey(fromJson: desktopDashboardWidgetsSafeFromJson)  List<DashboardWidget> desktopDashboardWidgets, @JsonKey(fromJson: pinnedMediaPlatformsSafeFromJson)  List<MediaPlatform> pinnedMediaPlatforms,  bool mediaUnlockMoreStreamingPlatforms,  bool mediaUnlockExtraDetails,  bool mediaUnlockRefreshOnNodeChange,  bool mediaUnlockColorfulIcons,  bool mediaUnlockRefreshByCategory,  bool onlyStatisticsProxy,  bool autoLaunch,  bool silentLaunch,  bool smartDelayLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  bool logAiSearch,  bool flushDnsOnNetworkChange,  String testUrl,  bool showStartSwitch,  StartSwitchStyle startSwitchStyle,  String? startSwitchOnLabel,  String? startSwitchOffLabel,  bool enableNavBarHapticFeedback,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool minimizeOnExit,  bool hidden,  bool keepDockIcon,  bool developerMode,  RecoveryStrategy recoveryStrategy,  bool enableHighPriority,  bool sidebarCollapsed,  bool sidebarFlyout,  bool sidebarFlyoutOutsideTools,  SidebarFlyoutDelay sidebarFlyoutDelay, @JsonKey(fromJson: sidebarFlyoutEntriesSafeFromJson)  List<SidebarFlyoutEntry> sidebarFlyoutEntries,  String? dashboardTitle)?  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.dashboardWidgets,_that.mobileDashboardWidgets,_that.desktopDashboardWidgets,_that.pinnedMediaPlatforms,_that.mediaUnlockMoreStreamingPlatforms,_that.mediaUnlockExtraDetails,_that.mediaUnlockRefreshOnNodeChange,_that.mediaUnlockColorfulIcons,_that.mediaUnlockRefreshByCategory,_that.onlyStatisticsProxy,_that.autoLaunch,_that.silentLaunch,_that.smartDelayLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.logAiSearch,_that.flushDnsOnNetworkChange,_that.testUrl,_that.showStartSwitch,_that.startSwitchStyle,_that.startSwitchOnLabel,_that.startSwitchOffLabel,_that.enableNavBarHapticFeedback,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.minimizeOnExit,_that.hidden,_that.keepDockIcon,_that.developerMode,_that.recoveryStrategy,_that.enableHighPriority,_that.sidebarCollapsed,_that.sidebarFlyout,_that.sidebarFlyoutOutsideTools,_that.sidebarFlyoutDelay,_that.sidebarFlyoutEntries,_that.dashboardTitle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettingProps implements AppSettingProps {
  const _AppSettingProps({this.locale, @JsonKey(fromJson: dashboardWidgetsSafeFromJson)  List<DashboardWidget> dashboardWidgets = defaultDashboardWidgets, @JsonKey(fromJson: mobileDashboardWidgetsSafeFromJson)  List<DashboardWidget> mobileDashboardWidgets = defaultAndroidDashboardWidgets, @JsonKey(fromJson: desktopDashboardWidgetsSafeFromJson)  List<DashboardWidget> desktopDashboardWidgets = defaultDashboardWidgets, @JsonKey(fromJson: pinnedMediaPlatformsSafeFromJson)  List<MediaPlatform> pinnedMediaPlatforms = defaultPinnedMediaPlatforms, this.mediaUnlockMoreStreamingPlatforms = false, this.mediaUnlockExtraDetails = false, this.mediaUnlockRefreshOnNodeChange = true, this.mediaUnlockColorfulIcons = true, this.mediaUnlockRefreshByCategory = true, this.onlyStatisticsProxy = true, this.autoLaunch = false, this.silentLaunch = false, this.smartDelayLaunch = false, this.autoRun = false, this.openLogs = true, this.closeConnections = true, this.logAiSearch = true, this.flushDnsOnNetworkChange = false, this.testUrl = defaultTestUrl, this.showStartSwitch = true, this.startSwitchStyle = StartSwitchStyle.outlined, this.startSwitchOnLabel, this.startSwitchOffLabel, this.enableNavBarHapticFeedback = true, this.autoCheckUpdate = true, this.showLabel = false, this.disclaimerAccepted = false, this.minimizeOnExit = true, this.hidden = false, this.keepDockIcon = true, this.developerMode = false, this.recoveryStrategy = RecoveryStrategy.compatible, this.enableHighPriority = false, this.sidebarCollapsed = false, this.sidebarFlyout = true, this.sidebarFlyoutOutsideTools = false, this.sidebarFlyoutDelay = SidebarFlyoutDelay.standard, @JsonKey(fromJson: sidebarFlyoutEntriesSafeFromJson)  List<SidebarFlyoutEntry> sidebarFlyoutEntries = defaultSidebarFlyoutEntries, this.dashboardTitle}): _dashboardWidgets = dashboardWidgets,_mobileDashboardWidgets = mobileDashboardWidgets,_desktopDashboardWidgets = desktopDashboardWidgets,_pinnedMediaPlatforms = pinnedMediaPlatforms,_sidebarFlyoutEntries = sidebarFlyoutEntries;
  factory _AppSettingProps.fromJson(Map<String, dynamic> json) => _$AppSettingPropsFromJson(json);

@override final  String? locale;
 final  List<DashboardWidget> _dashboardWidgets;
@override@JsonKey(fromJson: dashboardWidgetsSafeFromJson) List<DashboardWidget> get dashboardWidgets {
  if (_dashboardWidgets is EqualUnmodifiableListView) return _dashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dashboardWidgets);
}

 final  List<DashboardWidget> _mobileDashboardWidgets;
@override@JsonKey(fromJson: mobileDashboardWidgetsSafeFromJson) List<DashboardWidget> get mobileDashboardWidgets {
  if (_mobileDashboardWidgets is EqualUnmodifiableListView) return _mobileDashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mobileDashboardWidgets);
}

 final  List<DashboardWidget> _desktopDashboardWidgets;
@override@JsonKey(fromJson: desktopDashboardWidgetsSafeFromJson) List<DashboardWidget> get desktopDashboardWidgets {
  if (_desktopDashboardWidgets is EqualUnmodifiableListView) return _desktopDashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_desktopDashboardWidgets);
}

 final  List<MediaPlatform> _pinnedMediaPlatforms;
@override@JsonKey(fromJson: pinnedMediaPlatformsSafeFromJson) List<MediaPlatform> get pinnedMediaPlatforms {
  if (_pinnedMediaPlatforms is EqualUnmodifiableListView) return _pinnedMediaPlatforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pinnedMediaPlatforms);
}

@override@JsonKey() final  bool mediaUnlockMoreStreamingPlatforms;
@override@JsonKey() final  bool mediaUnlockExtraDetails;
@override@JsonKey() final  bool mediaUnlockRefreshOnNodeChange;
@override@JsonKey() final  bool mediaUnlockColorfulIcons;
@override@JsonKey() final  bool mediaUnlockRefreshByCategory;
@override@JsonKey() final  bool onlyStatisticsProxy;
@override@JsonKey() final  bool autoLaunch;
@override@JsonKey() final  bool silentLaunch;
@override@JsonKey() final  bool smartDelayLaunch;
@override@JsonKey() final  bool autoRun;
@override@JsonKey() final  bool openLogs;
@override@JsonKey() final  bool closeConnections;
@override@JsonKey() final  bool logAiSearch;
@override@JsonKey() final  bool flushDnsOnNetworkChange;
@override@JsonKey() final  String testUrl;
@override@JsonKey() final  bool showStartSwitch;
@override@JsonKey() final  StartSwitchStyle startSwitchStyle;
@override final  String? startSwitchOnLabel;
@override final  String? startSwitchOffLabel;
@override@JsonKey() final  bool enableNavBarHapticFeedback;
@override@JsonKey() final  bool autoCheckUpdate;
@override@JsonKey() final  bool showLabel;
@override@JsonKey() final  bool disclaimerAccepted;
@override@JsonKey() final  bool minimizeOnExit;
@override@JsonKey() final  bool hidden;
@override@JsonKey() final  bool keepDockIcon;
@override@JsonKey() final  bool developerMode;
@override@JsonKey() final  RecoveryStrategy recoveryStrategy;
@override@JsonKey() final  bool enableHighPriority;
@override@JsonKey() final  bool sidebarCollapsed;
@override@JsonKey() final  bool sidebarFlyout;
@override@JsonKey() final  bool sidebarFlyoutOutsideTools;
@override@JsonKey() final  SidebarFlyoutDelay sidebarFlyoutDelay;
 final  List<SidebarFlyoutEntry> _sidebarFlyoutEntries;
@override@JsonKey(fromJson: sidebarFlyoutEntriesSafeFromJson) List<SidebarFlyoutEntry> get sidebarFlyoutEntries {
  if (_sidebarFlyoutEntries is EqualUnmodifiableListView) return _sidebarFlyoutEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sidebarFlyoutEntries);
}

@override final  String? dashboardTitle;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingPropsCopyWith<_AppSettingProps> get copyWith => __$AppSettingPropsCopyWithImpl<_AppSettingProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettingProps&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other.dashboardWidgets, _dashboardWidgets)&&const DeepCollectionEquality().equals(other.mobileDashboardWidgets, _mobileDashboardWidgets)&&const DeepCollectionEquality().equals(other.desktopDashboardWidgets, _desktopDashboardWidgets)&&const DeepCollectionEquality().equals(other.pinnedMediaPlatforms, _pinnedMediaPlatforms)&&(identical(other.mediaUnlockMoreStreamingPlatforms, mediaUnlockMoreStreamingPlatforms) || other.mediaUnlockMoreStreamingPlatforms == mediaUnlockMoreStreamingPlatforms)&&(identical(other.mediaUnlockExtraDetails, mediaUnlockExtraDetails) || other.mediaUnlockExtraDetails == mediaUnlockExtraDetails)&&(identical(other.mediaUnlockRefreshOnNodeChange, mediaUnlockRefreshOnNodeChange) || other.mediaUnlockRefreshOnNodeChange == mediaUnlockRefreshOnNodeChange)&&(identical(other.mediaUnlockColorfulIcons, mediaUnlockColorfulIcons) || other.mediaUnlockColorfulIcons == mediaUnlockColorfulIcons)&&(identical(other.mediaUnlockRefreshByCategory, mediaUnlockRefreshByCategory) || other.mediaUnlockRefreshByCategory == mediaUnlockRefreshByCategory)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.silentLaunch, silentLaunch) || other.silentLaunch == silentLaunch)&&(identical(other.smartDelayLaunch, smartDelayLaunch) || other.smartDelayLaunch == smartDelayLaunch)&&(identical(other.autoRun, autoRun) || other.autoRun == autoRun)&&(identical(other.openLogs, openLogs) || other.openLogs == openLogs)&&(identical(other.closeConnections, closeConnections) || other.closeConnections == closeConnections)&&(identical(other.logAiSearch, logAiSearch) || other.logAiSearch == logAiSearch)&&(identical(other.flushDnsOnNetworkChange, flushDnsOnNetworkChange) || other.flushDnsOnNetworkChange == flushDnsOnNetworkChange)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.showStartSwitch, showStartSwitch) || other.showStartSwitch == showStartSwitch)&&(identical(other.startSwitchStyle, startSwitchStyle) || other.startSwitchStyle == startSwitchStyle)&&(identical(other.startSwitchOnLabel, startSwitchOnLabel) || other.startSwitchOnLabel == startSwitchOnLabel)&&(identical(other.startSwitchOffLabel, startSwitchOffLabel) || other.startSwitchOffLabel == startSwitchOffLabel)&&(identical(other.enableNavBarHapticFeedback, enableNavBarHapticFeedback) || other.enableNavBarHapticFeedback == enableNavBarHapticFeedback)&&(identical(other.autoCheckUpdate, autoCheckUpdate) || other.autoCheckUpdate == autoCheckUpdate)&&(identical(other.showLabel, showLabel) || other.showLabel == showLabel)&&(identical(other.disclaimerAccepted, disclaimerAccepted) || other.disclaimerAccepted == disclaimerAccepted)&&(identical(other.minimizeOnExit, minimizeOnExit) || other.minimizeOnExit == minimizeOnExit)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.keepDockIcon, keepDockIcon) || other.keepDockIcon == keepDockIcon)&&(identical(other.developerMode, developerMode) || other.developerMode == developerMode)&&(identical(other.recoveryStrategy, recoveryStrategy) || other.recoveryStrategy == recoveryStrategy)&&(identical(other.enableHighPriority, enableHighPriority) || other.enableHighPriority == enableHighPriority)&&(identical(other.sidebarCollapsed, sidebarCollapsed) || other.sidebarCollapsed == sidebarCollapsed)&&(identical(other.sidebarFlyout, sidebarFlyout) || other.sidebarFlyout == sidebarFlyout)&&(identical(other.sidebarFlyoutOutsideTools, sidebarFlyoutOutsideTools) || other.sidebarFlyoutOutsideTools == sidebarFlyoutOutsideTools)&&(identical(other.sidebarFlyoutDelay, sidebarFlyoutDelay) || other.sidebarFlyoutDelay == sidebarFlyoutDelay)&&const DeepCollectionEquality().equals(other.sidebarFlyoutEntries, _sidebarFlyoutEntries)&&(identical(other.dashboardTitle, dashboardTitle) || other.dashboardTitle == dashboardTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,locale,const DeepCollectionEquality().hash(_dashboardWidgets),const DeepCollectionEquality().hash(_mobileDashboardWidgets),const DeepCollectionEquality().hash(_desktopDashboardWidgets),const DeepCollectionEquality().hash(_pinnedMediaPlatforms),mediaUnlockMoreStreamingPlatforms,mediaUnlockExtraDetails,mediaUnlockRefreshOnNodeChange,mediaUnlockColorfulIcons,mediaUnlockRefreshByCategory,onlyStatisticsProxy,autoLaunch,silentLaunch,smartDelayLaunch,autoRun,openLogs,closeConnections,logAiSearch,flushDnsOnNetworkChange,testUrl,showStartSwitch,startSwitchStyle,startSwitchOnLabel,startSwitchOffLabel,enableNavBarHapticFeedback,autoCheckUpdate,showLabel,disclaimerAccepted,minimizeOnExit,hidden,keepDockIcon,developerMode,recoveryStrategy,enableHighPriority,sidebarCollapsed,sidebarFlyout,sidebarFlyoutOutsideTools,sidebarFlyoutDelay,const DeepCollectionEquality().hash(_sidebarFlyoutEntries),dashboardTitle]);
}

@override
String toString() {
    return 'AppSettingProps(locale: $locale, dashboardWidgets: $dashboardWidgets, mobileDashboardWidgets: $mobileDashboardWidgets, desktopDashboardWidgets: $desktopDashboardWidgets, pinnedMediaPlatforms: $pinnedMediaPlatforms, mediaUnlockMoreStreamingPlatforms: $mediaUnlockMoreStreamingPlatforms, mediaUnlockExtraDetails: $mediaUnlockExtraDetails, mediaUnlockRefreshOnNodeChange: $mediaUnlockRefreshOnNodeChange, mediaUnlockColorfulIcons: $mediaUnlockColorfulIcons, mediaUnlockRefreshByCategory: $mediaUnlockRefreshByCategory, onlyStatisticsProxy: $onlyStatisticsProxy, autoLaunch: $autoLaunch, silentLaunch: $silentLaunch, smartDelayLaunch: $smartDelayLaunch, autoRun: $autoRun, openLogs: $openLogs, closeConnections: $closeConnections, logAiSearch: $logAiSearch, flushDnsOnNetworkChange: $flushDnsOnNetworkChange, testUrl: $testUrl, showStartSwitch: $showStartSwitch, startSwitchStyle: $startSwitchStyle, startSwitchOnLabel: $startSwitchOnLabel, startSwitchOffLabel: $startSwitchOffLabel, enableNavBarHapticFeedback: $enableNavBarHapticFeedback, autoCheckUpdate: $autoCheckUpdate, showLabel: $showLabel, disclaimerAccepted: $disclaimerAccepted, minimizeOnExit: $minimizeOnExit, hidden: $hidden, keepDockIcon: $keepDockIcon, developerMode: $developerMode, recoveryStrategy: $recoveryStrategy, enableHighPriority: $enableHighPriority, sidebarCollapsed: $sidebarCollapsed, sidebarFlyout: $sidebarFlyout, sidebarFlyoutOutsideTools: $sidebarFlyoutOutsideTools, sidebarFlyoutDelay: $sidebarFlyoutDelay, sidebarFlyoutEntries: $sidebarFlyoutEntries, dashboardTitle: $dashboardTitle)';
}


}

/// @nodoc
abstract mixin class _$AppSettingPropsCopyWith<$Res> implements $AppSettingPropsCopyWith<$Res> {
  factory _$AppSettingPropsCopyWith(_AppSettingProps value, $Res Function(_AppSettingProps) _then) = __$AppSettingPropsCopyWithImpl;
@override @useResult
$Res call({
 String? locale,@JsonKey(fromJson: dashboardWidgetsSafeFromJson) List<DashboardWidget> dashboardWidgets,@JsonKey(fromJson: mobileDashboardWidgetsSafeFromJson) List<DashboardWidget> mobileDashboardWidgets,@JsonKey(fromJson: desktopDashboardWidgetsSafeFromJson) List<DashboardWidget> desktopDashboardWidgets,@JsonKey(fromJson: pinnedMediaPlatformsSafeFromJson) List<MediaPlatform> pinnedMediaPlatforms, bool mediaUnlockMoreStreamingPlatforms, bool mediaUnlockExtraDetails, bool mediaUnlockRefreshOnNodeChange, bool mediaUnlockColorfulIcons, bool mediaUnlockRefreshByCategory, bool onlyStatisticsProxy, bool autoLaunch, bool silentLaunch, bool smartDelayLaunch, bool autoRun, bool openLogs, bool closeConnections, bool logAiSearch, bool flushDnsOnNetworkChange, String testUrl, bool showStartSwitch, StartSwitchStyle startSwitchStyle, String? startSwitchOnLabel, String? startSwitchOffLabel, bool enableNavBarHapticFeedback, bool autoCheckUpdate, bool showLabel, bool disclaimerAccepted, bool minimizeOnExit, bool hidden, bool keepDockIcon, bool developerMode, RecoveryStrategy recoveryStrategy, bool enableHighPriority, bool sidebarCollapsed, bool sidebarFlyout, bool sidebarFlyoutOutsideTools, SidebarFlyoutDelay sidebarFlyoutDelay,@JsonKey(fromJson: sidebarFlyoutEntriesSafeFromJson) List<SidebarFlyoutEntry> sidebarFlyoutEntries, String? dashboardTitle
});




}
/// @nodoc
class __$AppSettingPropsCopyWithImpl<$Res>
    implements _$AppSettingPropsCopyWith<$Res> {
  __$AppSettingPropsCopyWithImpl(this._self, this._then);

  final _AppSettingProps _self;
  final $Res Function(_AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = freezed,Object? dashboardWidgets = null,Object? mobileDashboardWidgets = null,Object? desktopDashboardWidgets = null,Object? pinnedMediaPlatforms = null,Object? mediaUnlockMoreStreamingPlatforms = null,Object? mediaUnlockExtraDetails = null,Object? mediaUnlockRefreshOnNodeChange = null,Object? mediaUnlockColorfulIcons = null,Object? mediaUnlockRefreshByCategory = null,Object? onlyStatisticsProxy = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? smartDelayLaunch = null,Object? autoRun = null,Object? openLogs = null,Object? closeConnections = null,Object? logAiSearch = null,Object? flushDnsOnNetworkChange = null,Object? testUrl = null,Object? showStartSwitch = null,Object? startSwitchStyle = null,Object? startSwitchOnLabel = freezed,Object? startSwitchOffLabel = freezed,Object? enableNavBarHapticFeedback = null,Object? autoCheckUpdate = null,Object? showLabel = null,Object? disclaimerAccepted = null,Object? minimizeOnExit = null,Object? hidden = null,Object? keepDockIcon = null,Object? developerMode = null,Object? recoveryStrategy = null,Object? enableHighPriority = null,Object? sidebarCollapsed = null,Object? sidebarFlyout = null,Object? sidebarFlyoutOutsideTools = null,Object? sidebarFlyoutDelay = null,Object? sidebarFlyoutEntries = null,Object? dashboardTitle = freezed,}) {
  return _then(_AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,dashboardWidgets: null == dashboardWidgets ? _self._dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,mobileDashboardWidgets: null == mobileDashboardWidgets ? _self._mobileDashboardWidgets : mobileDashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,desktopDashboardWidgets: null == desktopDashboardWidgets ? _self._desktopDashboardWidgets : desktopDashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,pinnedMediaPlatforms: null == pinnedMediaPlatforms ? _self._pinnedMediaPlatforms : pinnedMediaPlatforms // ignore: cast_nullable_to_non_nullable
as List<MediaPlatform>,mediaUnlockMoreStreamingPlatforms: null == mediaUnlockMoreStreamingPlatforms ? _self.mediaUnlockMoreStreamingPlatforms : mediaUnlockMoreStreamingPlatforms // ignore: cast_nullable_to_non_nullable
as bool,mediaUnlockExtraDetails: null == mediaUnlockExtraDetails ? _self.mediaUnlockExtraDetails : mediaUnlockExtraDetails // ignore: cast_nullable_to_non_nullable
as bool,mediaUnlockRefreshOnNodeChange: null == mediaUnlockRefreshOnNodeChange ? _self.mediaUnlockRefreshOnNodeChange : mediaUnlockRefreshOnNodeChange // ignore: cast_nullable_to_non_nullable
as bool,mediaUnlockColorfulIcons: null == mediaUnlockColorfulIcons ? _self.mediaUnlockColorfulIcons : mediaUnlockColorfulIcons // ignore: cast_nullable_to_non_nullable
as bool,mediaUnlockRefreshByCategory: null == mediaUnlockRefreshByCategory ? _self.mediaUnlockRefreshByCategory : mediaUnlockRefreshByCategory // ignore: cast_nullable_to_non_nullable
as bool,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,smartDelayLaunch: null == smartDelayLaunch ? _self.smartDelayLaunch : smartDelayLaunch // ignore: cast_nullable_to_non_nullable
as bool,autoRun: null == autoRun ? _self.autoRun : autoRun // ignore: cast_nullable_to_non_nullable
as bool,openLogs: null == openLogs ? _self.openLogs : openLogs // ignore: cast_nullable_to_non_nullable
as bool,closeConnections: null == closeConnections ? _self.closeConnections : closeConnections // ignore: cast_nullable_to_non_nullable
as bool,logAiSearch: null == logAiSearch ? _self.logAiSearch : logAiSearch // ignore: cast_nullable_to_non_nullable
as bool,flushDnsOnNetworkChange: null == flushDnsOnNetworkChange ? _self.flushDnsOnNetworkChange : flushDnsOnNetworkChange // ignore: cast_nullable_to_non_nullable
as bool,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,showStartSwitch: null == showStartSwitch ? _self.showStartSwitch : showStartSwitch // ignore: cast_nullable_to_non_nullable
as bool,startSwitchStyle: null == startSwitchStyle ? _self.startSwitchStyle : startSwitchStyle // ignore: cast_nullable_to_non_nullable
as StartSwitchStyle,startSwitchOnLabel: freezed == startSwitchOnLabel ? _self.startSwitchOnLabel : startSwitchOnLabel // ignore: cast_nullable_to_non_nullable
as String?,startSwitchOffLabel: freezed == startSwitchOffLabel ? _self.startSwitchOffLabel : startSwitchOffLabel // ignore: cast_nullable_to_non_nullable
as String?,enableNavBarHapticFeedback: null == enableNavBarHapticFeedback ? _self.enableNavBarHapticFeedback : enableNavBarHapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,showLabel: null == showLabel ? _self.showLabel : showLabel // ignore: cast_nullable_to_non_nullable
as bool,disclaimerAccepted: null == disclaimerAccepted ? _self.disclaimerAccepted : disclaimerAccepted // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,keepDockIcon: null == keepDockIcon ? _self.keepDockIcon : keepDockIcon // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,recoveryStrategy: null == recoveryStrategy ? _self.recoveryStrategy : recoveryStrategy // ignore: cast_nullable_to_non_nullable
as RecoveryStrategy,enableHighPriority: null == enableHighPriority ? _self.enableHighPriority : enableHighPriority // ignore: cast_nullable_to_non_nullable
as bool,sidebarCollapsed: null == sidebarCollapsed ? _self.sidebarCollapsed : sidebarCollapsed // ignore: cast_nullable_to_non_nullable
as bool,sidebarFlyout: null == sidebarFlyout ? _self.sidebarFlyout : sidebarFlyout // ignore: cast_nullable_to_non_nullable
as bool,sidebarFlyoutOutsideTools: null == sidebarFlyoutOutsideTools ? _self.sidebarFlyoutOutsideTools : sidebarFlyoutOutsideTools // ignore: cast_nullable_to_non_nullable
as bool,sidebarFlyoutDelay: null == sidebarFlyoutDelay ? _self.sidebarFlyoutDelay : sidebarFlyoutDelay // ignore: cast_nullable_to_non_nullable
as SidebarFlyoutDelay,sidebarFlyoutEntries: null == sidebarFlyoutEntries ? _self._sidebarFlyoutEntries : sidebarFlyoutEntries // ignore: cast_nullable_to_non_nullable
as List<SidebarFlyoutEntry>,dashboardTitle: freezed == dashboardTitle ? _self.dashboardTitle : dashboardTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AccessControl {

 bool get enable; AccessControlMode get mode; List<String> get acceptList; List<String> get rejectList; List<String> get manualList;@JsonKey(unknownEnumValue: AccessSortType.none) AccessSortType get sort; bool get isFilterSystemApp; bool get isFilterNonInternetApp;
/// Create a copy of AccessControl
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessControlCopyWith<AccessControl> get copyWith => _$AccessControlCopyWithImpl<AccessControl>(this as AccessControl, _$identity);

  /// Serializes this AccessControl to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccessControl;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessControl&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.acceptList, _this.acceptList)&&const DeepCollectionEquality().equals(other.rejectList, _this.rejectList)&&const DeepCollectionEquality().equals(other.manualList, _this.manualList)&&(identical(other.sort, _this.sort) || other.sort == _this.sort)&&(identical(other.isFilterSystemApp, _this.isFilterSystemApp) || other.isFilterSystemApp == _this.isFilterSystemApp)&&(identical(other.isFilterNonInternetApp, _this.isFilterNonInternetApp) || other.isFilterNonInternetApp == _this.isFilterNonInternetApp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccessControl;
  return Object.hash(runtimeType,_this.enable,_this.mode,const DeepCollectionEquality().hash(_this.acceptList),const DeepCollectionEquality().hash(_this.rejectList),const DeepCollectionEquality().hash(_this.manualList),_this.sort,_this.isFilterSystemApp,_this.isFilterNonInternetApp);
}

@override
String toString() {
  final _this = this as AccessControl;
  return 'AccessControl(enable: ${_this.enable}, mode: ${_this.mode}, acceptList: ${_this.acceptList}, rejectList: ${_this.rejectList}, manualList: ${_this.manualList}, sort: ${_this.sort}, isFilterSystemApp: ${_this.isFilterSystemApp}, isFilterNonInternetApp: ${_this.isFilterNonInternetApp})';
}


}

/// @nodoc
abstract mixin class $AccessControlCopyWith<$Res>  {
  factory $AccessControlCopyWith(AccessControl value, $Res Function(AccessControl) _then) = _$AccessControlCopyWithImpl;
@useResult
$Res call({
 bool enable, AccessControlMode mode, List<String> acceptList, List<String> rejectList, List<String> manualList,@JsonKey(unknownEnumValue: AccessSortType.none) AccessSortType sort, bool isFilterSystemApp, bool isFilterNonInternetApp
});




}
/// @nodoc
class _$AccessControlCopyWithImpl<$Res>
    implements $AccessControlCopyWith<$Res> {
  _$AccessControlCopyWithImpl(this._self, this._then);

  final AccessControl _self;
  final $Res Function(AccessControl) _then;

/// Create a copy of AccessControl
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? mode = null,Object? acceptList = null,Object? rejectList = null,Object? manualList = null,Object? sort = null,Object? isFilterSystemApp = null,Object? isFilterNonInternetApp = null,}) {
  return _then(AccessControl(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AccessControlMode,acceptList: null == acceptList ? _self.acceptList : acceptList // ignore: cast_nullable_to_non_nullable
as List<String>,rejectList: null == rejectList ? _self.rejectList : rejectList // ignore: cast_nullable_to_non_nullable
as List<String>,manualList: null == manualList ? _self.manualList : manualList // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as AccessSortType,isFilterSystemApp: null == isFilterSystemApp ? _self.isFilterSystemApp : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
as bool,isFilterNonInternetApp: null == isFilterNonInternetApp ? _self.isFilterNonInternetApp : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AccessControl].
extension AccessControlPatterns on AccessControl {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccessControl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccessControl() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccessControl value)  $default,){
final _that = this;
switch (_that) {
case _AccessControl():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccessControl value)?  $default,){
final _that = this;
switch (_that) {
case _AccessControl() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  List<String> manualList, @JsonKey(unknownEnumValue: AccessSortType.none)  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccessControl() when $default != null:
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.manualList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  List<String> manualList, @JsonKey(unknownEnumValue: AccessSortType.none)  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)  $default,) {final _that = this;
switch (_that) {
case _AccessControl():
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.manualList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  List<String> manualList, @JsonKey(unknownEnumValue: AccessSortType.none)  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)?  $default,) {final _that = this;
switch (_that) {
case _AccessControl() when $default != null:
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.manualList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccessControl implements AccessControl {
  const _AccessControl({this.enable = false, this.mode = AccessControlMode.rejectSelected,  List<String> acceptList = const [],  List<String> rejectList = const [],  List<String> manualList = const [], @JsonKey(unknownEnumValue: AccessSortType.none) this.sort = AccessSortType.none, this.isFilterSystemApp = false, this.isFilterNonInternetApp = false}): _acceptList = acceptList,_rejectList = rejectList,_manualList = manualList;
  factory _AccessControl.fromJson(Map<String, dynamic> json) => _$AccessControlFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  AccessControlMode mode;
 final  List<String> _acceptList;
@override@JsonKey() List<String> get acceptList {
  if (_acceptList is EqualUnmodifiableListView) return _acceptList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acceptList);
}

 final  List<String> _rejectList;
@override@JsonKey() List<String> get rejectList {
  if (_rejectList is EqualUnmodifiableListView) return _rejectList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectList);
}

 final  List<String> _manualList;
@override@JsonKey() List<String> get manualList {
  if (_manualList is EqualUnmodifiableListView) return _manualList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_manualList);
}

@override@JsonKey(unknownEnumValue: AccessSortType.none) final  AccessSortType sort;
@override@JsonKey() final  bool isFilterSystemApp;
@override@JsonKey() final  bool isFilterNonInternetApp;

/// Create a copy of AccessControl
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessControlCopyWith<_AccessControl> get copyWith => __$AccessControlCopyWithImpl<_AccessControl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccessControlToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessControl&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.acceptList, _acceptList)&&const DeepCollectionEquality().equals(other.rejectList, _rejectList)&&const DeepCollectionEquality().equals(other.manualList, _manualList)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.isFilterSystemApp, isFilterSystemApp) || other.isFilterSystemApp == isFilterSystemApp)&&(identical(other.isFilterNonInternetApp, isFilterNonInternetApp) || other.isFilterNonInternetApp == isFilterNonInternetApp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,mode,const DeepCollectionEquality().hash(_acceptList),const DeepCollectionEquality().hash(_rejectList),const DeepCollectionEquality().hash(_manualList),sort,isFilterSystemApp,isFilterNonInternetApp);
}

@override
String toString() {
    return 'AccessControl(enable: $enable, mode: $mode, acceptList: $acceptList, rejectList: $rejectList, manualList: $manualList, sort: $sort, isFilterSystemApp: $isFilterSystemApp, isFilterNonInternetApp: $isFilterNonInternetApp)';
}


}

/// @nodoc
abstract mixin class _$AccessControlCopyWith<$Res> implements $AccessControlCopyWith<$Res> {
  factory _$AccessControlCopyWith(_AccessControl value, $Res Function(_AccessControl) _then) = __$AccessControlCopyWithImpl;
@override @useResult
$Res call({
 bool enable, AccessControlMode mode, List<String> acceptList, List<String> rejectList, List<String> manualList,@JsonKey(unknownEnumValue: AccessSortType.none) AccessSortType sort, bool isFilterSystemApp, bool isFilterNonInternetApp
});




}
/// @nodoc
class __$AccessControlCopyWithImpl<$Res>
    implements _$AccessControlCopyWith<$Res> {
  __$AccessControlCopyWithImpl(this._self, this._then);

  final _AccessControl _self;
  final $Res Function(_AccessControl) _then;

/// Create a copy of AccessControl
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? mode = null,Object? acceptList = null,Object? rejectList = null,Object? manualList = null,Object? sort = null,Object? isFilterSystemApp = null,Object? isFilterNonInternetApp = null,}) {
  return _then(_AccessControl(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AccessControlMode,acceptList: null == acceptList ? _self._acceptList : acceptList // ignore: cast_nullable_to_non_nullable
as List<String>,rejectList: null == rejectList ? _self._rejectList : rejectList // ignore: cast_nullable_to_non_nullable
as List<String>,manualList: null == manualList ? _self._manualList : manualList // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as AccessSortType,isFilterSystemApp: null == isFilterSystemApp ? _self.isFilterSystemApp : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
as bool,isFilterNonInternetApp: null == isFilterNonInternetApp ? _self.isFilterNonInternetApp : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WindowProps {

 double get width; double get height; double? get top; double? get left; bool get isPinned; double get scaleFactor;
/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<WindowProps> get copyWith => _$WindowPropsCopyWithImpl<WindowProps>(this as WindowProps, _$identity);

  /// Serializes this WindowProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WindowProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WindowProps&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.top, _this.top) || other.top == _this.top)&&(identical(other.left, _this.left) || other.left == _this.left)&&(identical(other.isPinned, _this.isPinned) || other.isPinned == _this.isPinned)&&(identical(other.scaleFactor, _this.scaleFactor) || other.scaleFactor == _this.scaleFactor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WindowProps;
  return Object.hash(runtimeType,_this.width,_this.height,_this.top,_this.left,_this.isPinned,_this.scaleFactor);
}

@override
String toString() {
  final _this = this as WindowProps;
  return 'WindowProps(width: ${_this.width}, height: ${_this.height}, top: ${_this.top}, left: ${_this.left}, isPinned: ${_this.isPinned}, scaleFactor: ${_this.scaleFactor})';
}


}

/// @nodoc
abstract mixin class $WindowPropsCopyWith<$Res>  {
  factory $WindowPropsCopyWith(WindowProps value, $Res Function(WindowProps) _then) = _$WindowPropsCopyWithImpl;
@useResult
$Res call({
 double width, double height, double? top, double? left, bool isPinned, double scaleFactor
});




}
/// @nodoc
class _$WindowPropsCopyWithImpl<$Res>
    implements $WindowPropsCopyWith<$Res> {
  _$WindowPropsCopyWithImpl(this._self, this._then);

  final WindowProps _self;
  final $Res Function(WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? top = freezed,Object? left = freezed,Object? isPinned = null,Object? scaleFactor = null,}) {
  return _then(WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,top: freezed == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double?,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,scaleFactor: null == scaleFactor ? _self.scaleFactor : scaleFactor // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WindowProps].
extension WindowPropsPatterns on WindowProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WindowProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WindowProps value)  $default,){
final _that = this;
switch (_that) {
case _WindowProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WindowProps value)?  $default,){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double width,  double height,  double? top,  double? left,  bool isPinned,  double scaleFactor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.top,_that.left,_that.isPinned,_that.scaleFactor);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double width,  double height,  double? top,  double? left,  bool isPinned,  double scaleFactor)  $default,) {final _that = this;
switch (_that) {
case _WindowProps():
return $default(_that.width,_that.height,_that.top,_that.left,_that.isPinned,_that.scaleFactor);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double width,  double height,  double? top,  double? left,  bool isPinned,  double scaleFactor)?  $default,) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.top,_that.left,_that.isPinned,_that.scaleFactor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WindowProps implements WindowProps {
  const _WindowProps({this.width = 910, this.height = 620, this.top, this.left, this.isPinned = false, this.scaleFactor = 1.0});
  factory _WindowProps.fromJson(Map<String, dynamic> json) => _$WindowPropsFromJson(json);

@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override final  double? top;
@override final  double? left;
@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  double scaleFactor;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WindowPropsCopyWith<_WindowProps> get copyWith => __$WindowPropsCopyWithImpl<_WindowProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WindowPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WindowProps&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.top, top) || other.top == top)&&(identical(other.left, left) || other.left == left)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.scaleFactor, scaleFactor) || other.scaleFactor == scaleFactor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,width,height,top,left,isPinned,scaleFactor);
}

@override
String toString() {
    return 'WindowProps(width: $width, height: $height, top: $top, left: $left, isPinned: $isPinned, scaleFactor: $scaleFactor)';
}


}

/// @nodoc
abstract mixin class _$WindowPropsCopyWith<$Res> implements $WindowPropsCopyWith<$Res> {
  factory _$WindowPropsCopyWith(_WindowProps value, $Res Function(_WindowProps) _then) = __$WindowPropsCopyWithImpl;
@override @useResult
$Res call({
 double width, double height, double? top, double? left, bool isPinned, double scaleFactor
});




}
/// @nodoc
class __$WindowPropsCopyWithImpl<$Res>
    implements _$WindowPropsCopyWith<$Res> {
  __$WindowPropsCopyWithImpl(this._self, this._then);

  final _WindowProps _self;
  final $Res Function(_WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? top = freezed,Object? left = freezed,Object? isPinned = null,Object? scaleFactor = null,}) {
  return _then(_WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,top: freezed == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double?,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,scaleFactor: null == scaleFactor ? _self.scaleFactor : scaleFactor // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$VpnProps {

 bool get enable; bool get systemProxy; bool get allowBypass; bool get bypassPrivateRoute; bool get dozeSuspend; bool get smartAutoStop; String get smartAutoStopNetworks; bool get storeFix; bool get networkFix; bool get loopbackProtection; bool get disableQuic; bool get highPriorityNotification; bool get networkSpeedNotification; bool get excludeChina; bool get trayEnhancement; TrayClickBehavior get trayLeftClickBehavior; TrayClickBehavior get trayRightClickBehavior; bool get enableTraySpeed; bool get alwaysShowTitleBar; bool get quickResponse; AccessControl get accessControl;
/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<VpnProps> get copyWith => _$VpnPropsCopyWithImpl<VpnProps>(this as VpnProps, _$identity);

  /// Serializes this VpnProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VpnProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&(identical(other.allowBypass, _this.allowBypass) || other.allowBypass == _this.allowBypass)&&(identical(other.bypassPrivateRoute, _this.bypassPrivateRoute) || other.bypassPrivateRoute == _this.bypassPrivateRoute)&&(identical(other.dozeSuspend, _this.dozeSuspend) || other.dozeSuspend == _this.dozeSuspend)&&(identical(other.smartAutoStop, _this.smartAutoStop) || other.smartAutoStop == _this.smartAutoStop)&&(identical(other.smartAutoStopNetworks, _this.smartAutoStopNetworks) || other.smartAutoStopNetworks == _this.smartAutoStopNetworks)&&(identical(other.storeFix, _this.storeFix) || other.storeFix == _this.storeFix)&&(identical(other.networkFix, _this.networkFix) || other.networkFix == _this.networkFix)&&(identical(other.loopbackProtection, _this.loopbackProtection) || other.loopbackProtection == _this.loopbackProtection)&&(identical(other.disableQuic, _this.disableQuic) || other.disableQuic == _this.disableQuic)&&(identical(other.highPriorityNotification, _this.highPriorityNotification) || other.highPriorityNotification == _this.highPriorityNotification)&&(identical(other.networkSpeedNotification, _this.networkSpeedNotification) || other.networkSpeedNotification == _this.networkSpeedNotification)&&(identical(other.excludeChina, _this.excludeChina) || other.excludeChina == _this.excludeChina)&&(identical(other.trayEnhancement, _this.trayEnhancement) || other.trayEnhancement == _this.trayEnhancement)&&(identical(other.trayLeftClickBehavior, _this.trayLeftClickBehavior) || other.trayLeftClickBehavior == _this.trayLeftClickBehavior)&&(identical(other.trayRightClickBehavior, _this.trayRightClickBehavior) || other.trayRightClickBehavior == _this.trayRightClickBehavior)&&(identical(other.enableTraySpeed, _this.enableTraySpeed) || other.enableTraySpeed == _this.enableTraySpeed)&&(identical(other.alwaysShowTitleBar, _this.alwaysShowTitleBar) || other.alwaysShowTitleBar == _this.alwaysShowTitleBar)&&(identical(other.quickResponse, _this.quickResponse) || other.quickResponse == _this.quickResponse)&&(identical(other.accessControl, _this.accessControl) || other.accessControl == _this.accessControl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VpnProps;
  return Object.hashAll([runtimeType,_this.enable,_this.systemProxy,_this.allowBypass,_this.bypassPrivateRoute,_this.dozeSuspend,_this.smartAutoStop,_this.smartAutoStopNetworks,_this.storeFix,_this.networkFix,_this.loopbackProtection,_this.disableQuic,_this.highPriorityNotification,_this.networkSpeedNotification,_this.excludeChina,_this.trayEnhancement,_this.trayLeftClickBehavior,_this.trayRightClickBehavior,_this.enableTraySpeed,_this.alwaysShowTitleBar,_this.quickResponse,_this.accessControl]);
}

@override
String toString() {
  final _this = this as VpnProps;
  return 'VpnProps(enable: ${_this.enable}, systemProxy: ${_this.systemProxy}, allowBypass: ${_this.allowBypass}, bypassPrivateRoute: ${_this.bypassPrivateRoute}, dozeSuspend: ${_this.dozeSuspend}, smartAutoStop: ${_this.smartAutoStop}, smartAutoStopNetworks: ${_this.smartAutoStopNetworks}, storeFix: ${_this.storeFix}, networkFix: ${_this.networkFix}, loopbackProtection: ${_this.loopbackProtection}, disableQuic: ${_this.disableQuic}, highPriorityNotification: ${_this.highPriorityNotification}, networkSpeedNotification: ${_this.networkSpeedNotification}, excludeChina: ${_this.excludeChina}, trayEnhancement: ${_this.trayEnhancement}, trayLeftClickBehavior: ${_this.trayLeftClickBehavior}, trayRightClickBehavior: ${_this.trayRightClickBehavior}, enableTraySpeed: ${_this.enableTraySpeed}, alwaysShowTitleBar: ${_this.alwaysShowTitleBar}, quickResponse: ${_this.quickResponse}, accessControl: ${_this.accessControl})';
}


}

/// @nodoc
abstract mixin class $VpnPropsCopyWith<$Res>  {
  factory $VpnPropsCopyWith(VpnProps value, $Res Function(VpnProps) _then) = _$VpnPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, bool systemProxy, bool allowBypass, bool bypassPrivateRoute, bool dozeSuspend, bool smartAutoStop, String smartAutoStopNetworks, bool storeFix, bool networkFix, bool loopbackProtection, bool disableQuic, bool highPriorityNotification, bool networkSpeedNotification, bool excludeChina, bool trayEnhancement, TrayClickBehavior trayLeftClickBehavior, TrayClickBehavior trayRightClickBehavior, bool enableTraySpeed, bool alwaysShowTitleBar, bool quickResponse, AccessControl accessControl
});


$AccessControlCopyWith<$Res> get accessControl;

}
/// @nodoc
class _$VpnPropsCopyWithImpl<$Res>
    implements $VpnPropsCopyWith<$Res> {
  _$VpnPropsCopyWithImpl(this._self, this._then);

  final VpnProps _self;
  final $Res Function(VpnProps) _then;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? systemProxy = null,Object? allowBypass = null,Object? bypassPrivateRoute = null,Object? dozeSuspend = null,Object? smartAutoStop = null,Object? smartAutoStopNetworks = null,Object? storeFix = null,Object? networkFix = null,Object? loopbackProtection = null,Object? disableQuic = null,Object? highPriorityNotification = null,Object? networkSpeedNotification = null,Object? excludeChina = null,Object? trayEnhancement = null,Object? trayLeftClickBehavior = null,Object? trayRightClickBehavior = null,Object? enableTraySpeed = null,Object? alwaysShowTitleBar = null,Object? quickResponse = null,Object? accessControl = null,}) {
  return _then(VpnProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,bypassPrivateRoute: null == bypassPrivateRoute ? _self.bypassPrivateRoute : bypassPrivateRoute // ignore: cast_nullable_to_non_nullable
as bool,dozeSuspend: null == dozeSuspend ? _self.dozeSuspend : dozeSuspend // ignore: cast_nullable_to_non_nullable
as bool,smartAutoStop: null == smartAutoStop ? _self.smartAutoStop : smartAutoStop // ignore: cast_nullable_to_non_nullable
as bool,smartAutoStopNetworks: null == smartAutoStopNetworks ? _self.smartAutoStopNetworks : smartAutoStopNetworks // ignore: cast_nullable_to_non_nullable
as String,storeFix: null == storeFix ? _self.storeFix : storeFix // ignore: cast_nullable_to_non_nullable
as bool,networkFix: null == networkFix ? _self.networkFix : networkFix // ignore: cast_nullable_to_non_nullable
as bool,loopbackProtection: null == loopbackProtection ? _self.loopbackProtection : loopbackProtection // ignore: cast_nullable_to_non_nullable
as bool,disableQuic: null == disableQuic ? _self.disableQuic : disableQuic // ignore: cast_nullable_to_non_nullable
as bool,highPriorityNotification: null == highPriorityNotification ? _self.highPriorityNotification : highPriorityNotification // ignore: cast_nullable_to_non_nullable
as bool,networkSpeedNotification: null == networkSpeedNotification ? _self.networkSpeedNotification : networkSpeedNotification // ignore: cast_nullable_to_non_nullable
as bool,excludeChina: null == excludeChina ? _self.excludeChina : excludeChina // ignore: cast_nullable_to_non_nullable
as bool,trayEnhancement: null == trayEnhancement ? _self.trayEnhancement : trayEnhancement // ignore: cast_nullable_to_non_nullable
as bool,trayLeftClickBehavior: null == trayLeftClickBehavior ? _self.trayLeftClickBehavior : trayLeftClickBehavior // ignore: cast_nullable_to_non_nullable
as TrayClickBehavior,trayRightClickBehavior: null == trayRightClickBehavior ? _self.trayRightClickBehavior : trayRightClickBehavior // ignore: cast_nullable_to_non_nullable
as TrayClickBehavior,enableTraySpeed: null == enableTraySpeed ? _self.enableTraySpeed : enableTraySpeed // ignore: cast_nullable_to_non_nullable
as bool,alwaysShowTitleBar: null == alwaysShowTitleBar ? _self.alwaysShowTitleBar : alwaysShowTitleBar // ignore: cast_nullable_to_non_nullable
as bool,quickResponse: null == quickResponse ? _self.quickResponse : quickResponse // ignore: cast_nullable_to_non_nullable
as bool,accessControl: null == accessControl ? _self.accessControl : accessControl // ignore: cast_nullable_to_non_nullable
as AccessControl,
  ));
}
/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlCopyWith<$Res> get accessControl {
  
  return $AccessControlCopyWith<$Res>(_self.accessControl, (value) {
    return _then(_self.copyWith(accessControl: value));
  });
}
}


/// Adds pattern-matching-related methods to [VpnProps].
extension VpnPropsPatterns on VpnProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnProps value)  $default,){
final _that = this;
switch (_that) {
case _VpnProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnProps value)?  $default,){
final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  bool systemProxy,  bool allowBypass,  bool bypassPrivateRoute,  bool dozeSuspend,  bool smartAutoStop,  String smartAutoStopNetworks,  bool storeFix,  bool networkFix,  bool loopbackProtection,  bool disableQuic,  bool highPriorityNotification,  bool networkSpeedNotification,  bool excludeChina,  bool trayEnhancement,  TrayClickBehavior trayLeftClickBehavior,  TrayClickBehavior trayRightClickBehavior,  bool enableTraySpeed,  bool alwaysShowTitleBar,  bool quickResponse,  AccessControl accessControl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that.enable,_that.systemProxy,_that.allowBypass,_that.bypassPrivateRoute,_that.dozeSuspend,_that.smartAutoStop,_that.smartAutoStopNetworks,_that.storeFix,_that.networkFix,_that.loopbackProtection,_that.disableQuic,_that.highPriorityNotification,_that.networkSpeedNotification,_that.excludeChina,_that.trayEnhancement,_that.trayLeftClickBehavior,_that.trayRightClickBehavior,_that.enableTraySpeed,_that.alwaysShowTitleBar,_that.quickResponse,_that.accessControl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  bool systemProxy,  bool allowBypass,  bool bypassPrivateRoute,  bool dozeSuspend,  bool smartAutoStop,  String smartAutoStopNetworks,  bool storeFix,  bool networkFix,  bool loopbackProtection,  bool disableQuic,  bool highPriorityNotification,  bool networkSpeedNotification,  bool excludeChina,  bool trayEnhancement,  TrayClickBehavior trayLeftClickBehavior,  TrayClickBehavior trayRightClickBehavior,  bool enableTraySpeed,  bool alwaysShowTitleBar,  bool quickResponse,  AccessControl accessControl)  $default,) {final _that = this;
switch (_that) {
case _VpnProps():
return $default(_that.enable,_that.systemProxy,_that.allowBypass,_that.bypassPrivateRoute,_that.dozeSuspend,_that.smartAutoStop,_that.smartAutoStopNetworks,_that.storeFix,_that.networkFix,_that.loopbackProtection,_that.disableQuic,_that.highPriorityNotification,_that.networkSpeedNotification,_that.excludeChina,_that.trayEnhancement,_that.trayLeftClickBehavior,_that.trayRightClickBehavior,_that.enableTraySpeed,_that.alwaysShowTitleBar,_that.quickResponse,_that.accessControl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  bool systemProxy,  bool allowBypass,  bool bypassPrivateRoute,  bool dozeSuspend,  bool smartAutoStop,  String smartAutoStopNetworks,  bool storeFix,  bool networkFix,  bool loopbackProtection,  bool disableQuic,  bool highPriorityNotification,  bool networkSpeedNotification,  bool excludeChina,  bool trayEnhancement,  TrayClickBehavior trayLeftClickBehavior,  TrayClickBehavior trayRightClickBehavior,  bool enableTraySpeed,  bool alwaysShowTitleBar,  bool quickResponse,  AccessControl accessControl)?  $default,) {final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that.enable,_that.systemProxy,_that.allowBypass,_that.bypassPrivateRoute,_that.dozeSuspend,_that.smartAutoStop,_that.smartAutoStopNetworks,_that.storeFix,_that.networkFix,_that.loopbackProtection,_that.disableQuic,_that.highPriorityNotification,_that.networkSpeedNotification,_that.excludeChina,_that.trayEnhancement,_that.trayLeftClickBehavior,_that.trayRightClickBehavior,_that.enableTraySpeed,_that.alwaysShowTitleBar,_that.quickResponse,_that.accessControl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnProps implements VpnProps {
  const _VpnProps({this.enable = true, this.systemProxy = true, this.allowBypass = false, this.bypassPrivateRoute = true, this.dozeSuspend = true, this.smartAutoStop = false, this.smartAutoStopNetworks = '', this.storeFix = false, this.networkFix = false, this.loopbackProtection = false, this.disableQuic = false, this.highPriorityNotification = false, this.networkSpeedNotification = false, this.excludeChina = false, this.trayEnhancement = false, this.trayLeftClickBehavior = TrayClickBehavior.showPanel, this.trayRightClickBehavior = TrayClickBehavior.showMenu, this.enableTraySpeed = false, this.alwaysShowTitleBar = true, this.quickResponse = true, this.accessControl = defaultAccessControl});
  factory _VpnProps.fromJson(Map<String, dynamic> json) => _$VpnPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  bool systemProxy;
@override@JsonKey() final  bool allowBypass;
@override@JsonKey() final  bool bypassPrivateRoute;
@override@JsonKey() final  bool dozeSuspend;
@override@JsonKey() final  bool smartAutoStop;
@override@JsonKey() final  String smartAutoStopNetworks;
@override@JsonKey() final  bool storeFix;
@override@JsonKey() final  bool networkFix;
@override@JsonKey() final  bool loopbackProtection;
@override@JsonKey() final  bool disableQuic;
@override@JsonKey() final  bool highPriorityNotification;
@override@JsonKey() final  bool networkSpeedNotification;
@override@JsonKey() final  bool excludeChina;
@override@JsonKey() final  bool trayEnhancement;
@override@JsonKey() final  TrayClickBehavior trayLeftClickBehavior;
@override@JsonKey() final  TrayClickBehavior trayRightClickBehavior;
@override@JsonKey() final  bool enableTraySpeed;
@override@JsonKey() final  bool alwaysShowTitleBar;
@override@JsonKey() final  bool quickResponse;
@override@JsonKey() final  AccessControl accessControl;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnPropsCopyWith<_VpnProps> get copyWith => __$VpnPropsCopyWithImpl<_VpnProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VpnPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.bypassPrivateRoute, bypassPrivateRoute) || other.bypassPrivateRoute == bypassPrivateRoute)&&(identical(other.dozeSuspend, dozeSuspend) || other.dozeSuspend == dozeSuspend)&&(identical(other.smartAutoStop, smartAutoStop) || other.smartAutoStop == smartAutoStop)&&(identical(other.smartAutoStopNetworks, smartAutoStopNetworks) || other.smartAutoStopNetworks == smartAutoStopNetworks)&&(identical(other.storeFix, storeFix) || other.storeFix == storeFix)&&(identical(other.networkFix, networkFix) || other.networkFix == networkFix)&&(identical(other.loopbackProtection, loopbackProtection) || other.loopbackProtection == loopbackProtection)&&(identical(other.disableQuic, disableQuic) || other.disableQuic == disableQuic)&&(identical(other.highPriorityNotification, highPriorityNotification) || other.highPriorityNotification == highPriorityNotification)&&(identical(other.networkSpeedNotification, networkSpeedNotification) || other.networkSpeedNotification == networkSpeedNotification)&&(identical(other.excludeChina, excludeChina) || other.excludeChina == excludeChina)&&(identical(other.trayEnhancement, trayEnhancement) || other.trayEnhancement == trayEnhancement)&&(identical(other.trayLeftClickBehavior, trayLeftClickBehavior) || other.trayLeftClickBehavior == trayLeftClickBehavior)&&(identical(other.trayRightClickBehavior, trayRightClickBehavior) || other.trayRightClickBehavior == trayRightClickBehavior)&&(identical(other.enableTraySpeed, enableTraySpeed) || other.enableTraySpeed == enableTraySpeed)&&(identical(other.alwaysShowTitleBar, alwaysShowTitleBar) || other.alwaysShowTitleBar == alwaysShowTitleBar)&&(identical(other.quickResponse, quickResponse) || other.quickResponse == quickResponse)&&(identical(other.accessControl, accessControl) || other.accessControl == accessControl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,enable,systemProxy,allowBypass,bypassPrivateRoute,dozeSuspend,smartAutoStop,smartAutoStopNetworks,storeFix,networkFix,loopbackProtection,disableQuic,highPriorityNotification,networkSpeedNotification,excludeChina,trayEnhancement,trayLeftClickBehavior,trayRightClickBehavior,enableTraySpeed,alwaysShowTitleBar,quickResponse,accessControl]);
}

@override
String toString() {
    return 'VpnProps(enable: $enable, systemProxy: $systemProxy, allowBypass: $allowBypass, bypassPrivateRoute: $bypassPrivateRoute, dozeSuspend: $dozeSuspend, smartAutoStop: $smartAutoStop, smartAutoStopNetworks: $smartAutoStopNetworks, storeFix: $storeFix, networkFix: $networkFix, loopbackProtection: $loopbackProtection, disableQuic: $disableQuic, highPriorityNotification: $highPriorityNotification, networkSpeedNotification: $networkSpeedNotification, excludeChina: $excludeChina, trayEnhancement: $trayEnhancement, trayLeftClickBehavior: $trayLeftClickBehavior, trayRightClickBehavior: $trayRightClickBehavior, enableTraySpeed: $enableTraySpeed, alwaysShowTitleBar: $alwaysShowTitleBar, quickResponse: $quickResponse, accessControl: $accessControl)';
}


}

/// @nodoc
abstract mixin class _$VpnPropsCopyWith<$Res> implements $VpnPropsCopyWith<$Res> {
  factory _$VpnPropsCopyWith(_VpnProps value, $Res Function(_VpnProps) _then) = __$VpnPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, bool systemProxy, bool allowBypass, bool bypassPrivateRoute, bool dozeSuspend, bool smartAutoStop, String smartAutoStopNetworks, bool storeFix, bool networkFix, bool loopbackProtection, bool disableQuic, bool highPriorityNotification, bool networkSpeedNotification, bool excludeChina, bool trayEnhancement, TrayClickBehavior trayLeftClickBehavior, TrayClickBehavior trayRightClickBehavior, bool enableTraySpeed, bool alwaysShowTitleBar, bool quickResponse, AccessControl accessControl
});


@override $AccessControlCopyWith<$Res> get accessControl;

}
/// @nodoc
class __$VpnPropsCopyWithImpl<$Res>
    implements _$VpnPropsCopyWith<$Res> {
  __$VpnPropsCopyWithImpl(this._self, this._then);

  final _VpnProps _self;
  final $Res Function(_VpnProps) _then;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? systemProxy = null,Object? allowBypass = null,Object? bypassPrivateRoute = null,Object? dozeSuspend = null,Object? smartAutoStop = null,Object? smartAutoStopNetworks = null,Object? storeFix = null,Object? networkFix = null,Object? loopbackProtection = null,Object? disableQuic = null,Object? highPriorityNotification = null,Object? networkSpeedNotification = null,Object? excludeChina = null,Object? trayEnhancement = null,Object? trayLeftClickBehavior = null,Object? trayRightClickBehavior = null,Object? enableTraySpeed = null,Object? alwaysShowTitleBar = null,Object? quickResponse = null,Object? accessControl = null,}) {
  return _then(_VpnProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,bypassPrivateRoute: null == bypassPrivateRoute ? _self.bypassPrivateRoute : bypassPrivateRoute // ignore: cast_nullable_to_non_nullable
as bool,dozeSuspend: null == dozeSuspend ? _self.dozeSuspend : dozeSuspend // ignore: cast_nullable_to_non_nullable
as bool,smartAutoStop: null == smartAutoStop ? _self.smartAutoStop : smartAutoStop // ignore: cast_nullable_to_non_nullable
as bool,smartAutoStopNetworks: null == smartAutoStopNetworks ? _self.smartAutoStopNetworks : smartAutoStopNetworks // ignore: cast_nullable_to_non_nullable
as String,storeFix: null == storeFix ? _self.storeFix : storeFix // ignore: cast_nullable_to_non_nullable
as bool,networkFix: null == networkFix ? _self.networkFix : networkFix // ignore: cast_nullable_to_non_nullable
as bool,loopbackProtection: null == loopbackProtection ? _self.loopbackProtection : loopbackProtection // ignore: cast_nullable_to_non_nullable
as bool,disableQuic: null == disableQuic ? _self.disableQuic : disableQuic // ignore: cast_nullable_to_non_nullable
as bool,highPriorityNotification: null == highPriorityNotification ? _self.highPriorityNotification : highPriorityNotification // ignore: cast_nullable_to_non_nullable
as bool,networkSpeedNotification: null == networkSpeedNotification ? _self.networkSpeedNotification : networkSpeedNotification // ignore: cast_nullable_to_non_nullable
as bool,excludeChina: null == excludeChina ? _self.excludeChina : excludeChina // ignore: cast_nullable_to_non_nullable
as bool,trayEnhancement: null == trayEnhancement ? _self.trayEnhancement : trayEnhancement // ignore: cast_nullable_to_non_nullable
as bool,trayLeftClickBehavior: null == trayLeftClickBehavior ? _self.trayLeftClickBehavior : trayLeftClickBehavior // ignore: cast_nullable_to_non_nullable
as TrayClickBehavior,trayRightClickBehavior: null == trayRightClickBehavior ? _self.trayRightClickBehavior : trayRightClickBehavior // ignore: cast_nullable_to_non_nullable
as TrayClickBehavior,enableTraySpeed: null == enableTraySpeed ? _self.enableTraySpeed : enableTraySpeed // ignore: cast_nullable_to_non_nullable
as bool,alwaysShowTitleBar: null == alwaysShowTitleBar ? _self.alwaysShowTitleBar : alwaysShowTitleBar // ignore: cast_nullable_to_non_nullable
as bool,quickResponse: null == quickResponse ? _self.quickResponse : quickResponse // ignore: cast_nullable_to_non_nullable
as bool,accessControl: null == accessControl ? _self.accessControl : accessControl // ignore: cast_nullable_to_non_nullable
as AccessControl,
  ));
}

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlCopyWith<$Res> get accessControl {
  
  return $AccessControlCopyWith<$Res>(_self.accessControl, (value) {
    return _then(_self.copyWith(accessControl: value));
  });
}
}


/// @nodoc
mixin _$NetworkProps {

 bool get systemProxy;@JsonKey(fromJson: bypassDomainSafeFromJson) List<String> get bypassDomain; bool get bypassPrivateRoute; List<String> get bypassPrivateRouteAddress; bool get autoSetSystemDns;
/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<NetworkProps> get copyWith => _$NetworkPropsCopyWithImpl<NetworkProps>(this as NetworkProps, _$identity);

  /// Serializes this NetworkProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NetworkProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkProps&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _this.bypassDomain)&&(identical(other.bypassPrivateRoute, _this.bypassPrivateRoute) || other.bypassPrivateRoute == _this.bypassPrivateRoute)&&const DeepCollectionEquality().equals(other.bypassPrivateRouteAddress, _this.bypassPrivateRouteAddress)&&(identical(other.autoSetSystemDns, _this.autoSetSystemDns) || other.autoSetSystemDns == _this.autoSetSystemDns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NetworkProps;
  return Object.hash(runtimeType,_this.systemProxy,const DeepCollectionEquality().hash(_this.bypassDomain),_this.bypassPrivateRoute,const DeepCollectionEquality().hash(_this.bypassPrivateRouteAddress),_this.autoSetSystemDns);
}

@override
String toString() {
  final _this = this as NetworkProps;
  return 'NetworkProps(systemProxy: ${_this.systemProxy}, bypassDomain: ${_this.bypassDomain}, bypassPrivateRoute: ${_this.bypassPrivateRoute}, bypassPrivateRouteAddress: ${_this.bypassPrivateRouteAddress}, autoSetSystemDns: ${_this.autoSetSystemDns})';
}


}

/// @nodoc
abstract mixin class $NetworkPropsCopyWith<$Res>  {
  factory $NetworkPropsCopyWith(NetworkProps value, $Res Function(NetworkProps) _then) = _$NetworkPropsCopyWithImpl;
@useResult
$Res call({
 bool systemProxy,@JsonKey(fromJson: bypassDomainSafeFromJson) List<String> bypassDomain, bool bypassPrivateRoute, List<String> bypassPrivateRouteAddress, bool autoSetSystemDns
});




}
/// @nodoc
class _$NetworkPropsCopyWithImpl<$Res>
    implements $NetworkPropsCopyWith<$Res> {
  _$NetworkPropsCopyWithImpl(this._self, this._then);

  final NetworkProps _self;
  final $Res Function(NetworkProps) _then;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? systemProxy = null,Object? bypassDomain = null,Object? bypassPrivateRoute = null,Object? bypassPrivateRouteAddress = null,Object? autoSetSystemDns = null,}) {
  return _then(NetworkProps(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self.bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,bypassPrivateRoute: null == bypassPrivateRoute ? _self.bypassPrivateRoute : bypassPrivateRoute // ignore: cast_nullable_to_non_nullable
as bool,bypassPrivateRouteAddress: null == bypassPrivateRouteAddress ? _self.bypassPrivateRouteAddress : bypassPrivateRouteAddress // ignore: cast_nullable_to_non_nullable
as List<String>,autoSetSystemDns: null == autoSetSystemDns ? _self.autoSetSystemDns : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkProps].
extension NetworkPropsPatterns on NetworkProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkProps value)  $default,){
final _that = this;
switch (_that) {
case _NetworkProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkProps value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool systemProxy, @JsonKey(fromJson: bypassDomainSafeFromJson)  List<String> bypassDomain,  bool bypassPrivateRoute,  List<String> bypassPrivateRouteAddress,  bool autoSetSystemDns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain,_that.bypassPrivateRoute,_that.bypassPrivateRouteAddress,_that.autoSetSystemDns);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool systemProxy, @JsonKey(fromJson: bypassDomainSafeFromJson)  List<String> bypassDomain,  bool bypassPrivateRoute,  List<String> bypassPrivateRouteAddress,  bool autoSetSystemDns)  $default,) {final _that = this;
switch (_that) {
case _NetworkProps():
return $default(_that.systemProxy,_that.bypassDomain,_that.bypassPrivateRoute,_that.bypassPrivateRouteAddress,_that.autoSetSystemDns);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool systemProxy, @JsonKey(fromJson: bypassDomainSafeFromJson)  List<String> bypassDomain,  bool bypassPrivateRoute,  List<String> bypassPrivateRouteAddress,  bool autoSetSystemDns)?  $default,) {final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain,_that.bypassPrivateRoute,_that.bypassPrivateRouteAddress,_that.autoSetSystemDns);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetworkProps implements NetworkProps {
  const _NetworkProps({this.systemProxy = true, @JsonKey(fromJson: bypassDomainSafeFromJson)  List<String> bypassDomain = defaultBypassDomain, this.bypassPrivateRoute = true,  List<String> bypassPrivateRouteAddress = const [], this.autoSetSystemDns = true}): _bypassDomain = bypassDomain,_bypassPrivateRouteAddress = bypassPrivateRouteAddress;
  factory _NetworkProps.fromJson(Map<String, dynamic> json) => _$NetworkPropsFromJson(json);

@override@JsonKey() final  bool systemProxy;
 final  List<String> _bypassDomain;
@override@JsonKey(fromJson: bypassDomainSafeFromJson) List<String> get bypassDomain {
  if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bypassDomain);
}

@override@JsonKey() final  bool bypassPrivateRoute;
 final  List<String> _bypassPrivateRouteAddress;
@override@JsonKey() List<String> get bypassPrivateRouteAddress {
  if (_bypassPrivateRouteAddress is EqualUnmodifiableListView) return _bypassPrivateRouteAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bypassPrivateRouteAddress);
}

@override@JsonKey() final  bool autoSetSystemDns;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkPropsCopyWith<_NetworkProps> get copyWith => __$NetworkPropsCopyWithImpl<_NetworkProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkProps&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _bypassDomain)&&(identical(other.bypassPrivateRoute, bypassPrivateRoute) || other.bypassPrivateRoute == bypassPrivateRoute)&&const DeepCollectionEquality().equals(other.bypassPrivateRouteAddress, _bypassPrivateRouteAddress)&&(identical(other.autoSetSystemDns, autoSetSystemDns) || other.autoSetSystemDns == autoSetSystemDns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),bypassPrivateRoute,const DeepCollectionEquality().hash(_bypassPrivateRouteAddress),autoSetSystemDns);
}

@override
String toString() {
    return 'NetworkProps(systemProxy: $systemProxy, bypassDomain: $bypassDomain, bypassPrivateRoute: $bypassPrivateRoute, bypassPrivateRouteAddress: $bypassPrivateRouteAddress, autoSetSystemDns: $autoSetSystemDns)';
}


}

/// @nodoc
abstract mixin class _$NetworkPropsCopyWith<$Res> implements $NetworkPropsCopyWith<$Res> {
  factory _$NetworkPropsCopyWith(_NetworkProps value, $Res Function(_NetworkProps) _then) = __$NetworkPropsCopyWithImpl;
@override @useResult
$Res call({
 bool systemProxy,@JsonKey(fromJson: bypassDomainSafeFromJson) List<String> bypassDomain, bool bypassPrivateRoute, List<String> bypassPrivateRouteAddress, bool autoSetSystemDns
});




}
/// @nodoc
class __$NetworkPropsCopyWithImpl<$Res>
    implements _$NetworkPropsCopyWith<$Res> {
  __$NetworkPropsCopyWithImpl(this._self, this._then);

  final _NetworkProps _self;
  final $Res Function(_NetworkProps) _then;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? systemProxy = null,Object? bypassDomain = null,Object? bypassPrivateRoute = null,Object? bypassPrivateRouteAddress = null,Object? autoSetSystemDns = null,}) {
  return _then(_NetworkProps(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self._bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,bypassPrivateRoute: null == bypassPrivateRoute ? _self.bypassPrivateRoute : bypassPrivateRoute // ignore: cast_nullable_to_non_nullable
as bool,bypassPrivateRouteAddress: null == bypassPrivateRouteAddress ? _self._bypassPrivateRouteAddress : bypassPrivateRouteAddress // ignore: cast_nullable_to_non_nullable
as List<String>,autoSetSystemDns: null == autoSetSystemDns ? _self.autoSetSystemDns : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TailscaleNetwork {

 String get id; String get label; String get authKey; String get hostname; String get controlUrl; String get exitNode; bool get exitNodeAllowLanAccess; bool get acceptRoutes; bool get udp; List<String> get routes; List<String> get dns;
/// Create a copy of TailscaleNetwork
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TailscaleNetworkCopyWith<TailscaleNetwork> get copyWith => _$TailscaleNetworkCopyWithImpl<TailscaleNetwork>(this as TailscaleNetwork, _$identity);

  /// Serializes this TailscaleNetwork to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TailscaleNetwork;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TailscaleNetwork&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.authKey, _this.authKey) || other.authKey == _this.authKey)&&(identical(other.hostname, _this.hostname) || other.hostname == _this.hostname)&&(identical(other.controlUrl, _this.controlUrl) || other.controlUrl == _this.controlUrl)&&(identical(other.exitNode, _this.exitNode) || other.exitNode == _this.exitNode)&&(identical(other.exitNodeAllowLanAccess, _this.exitNodeAllowLanAccess) || other.exitNodeAllowLanAccess == _this.exitNodeAllowLanAccess)&&(identical(other.acceptRoutes, _this.acceptRoutes) || other.acceptRoutes == _this.acceptRoutes)&&(identical(other.udp, _this.udp) || other.udp == _this.udp)&&const DeepCollectionEquality().equals(other.routes, _this.routes)&&const DeepCollectionEquality().equals(other.dns, _this.dns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TailscaleNetwork;
  return Object.hash(runtimeType,_this.id,_this.label,_this.authKey,_this.hostname,_this.controlUrl,_this.exitNode,_this.exitNodeAllowLanAccess,_this.acceptRoutes,_this.udp,const DeepCollectionEquality().hash(_this.routes),const DeepCollectionEquality().hash(_this.dns));
}

@override
String toString() {
  final _this = this as TailscaleNetwork;
  return 'TailscaleNetwork(id: ${_this.id}, label: ${_this.label}, authKey: ${_this.authKey}, hostname: ${_this.hostname}, controlUrl: ${_this.controlUrl}, exitNode: ${_this.exitNode}, exitNodeAllowLanAccess: ${_this.exitNodeAllowLanAccess}, acceptRoutes: ${_this.acceptRoutes}, udp: ${_this.udp}, routes: ${_this.routes}, dns: ${_this.dns})';
}


}

/// @nodoc
abstract mixin class $TailscaleNetworkCopyWith<$Res>  {
  factory $TailscaleNetworkCopyWith(TailscaleNetwork value, $Res Function(TailscaleNetwork) _then) = _$TailscaleNetworkCopyWithImpl;
@useResult
$Res call({
 String id, String label, String authKey, String hostname, String controlUrl, String exitNode, bool exitNodeAllowLanAccess, bool acceptRoutes, bool udp, List<String> routes, List<String> dns
});




}
/// @nodoc
class _$TailscaleNetworkCopyWithImpl<$Res>
    implements $TailscaleNetworkCopyWith<$Res> {
  _$TailscaleNetworkCopyWithImpl(this._self, this._then);

  final TailscaleNetwork _self;
  final $Res Function(TailscaleNetwork) _then;

/// Create a copy of TailscaleNetwork
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? authKey = null,Object? hostname = null,Object? controlUrl = null,Object? exitNode = null,Object? exitNodeAllowLanAccess = null,Object? acceptRoutes = null,Object? udp = null,Object? routes = null,Object? dns = null,}) {
  return _then(TailscaleNetwork(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,authKey: null == authKey ? _self.authKey : authKey // ignore: cast_nullable_to_non_nullable
as String,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,controlUrl: null == controlUrl ? _self.controlUrl : controlUrl // ignore: cast_nullable_to_non_nullable
as String,exitNode: null == exitNode ? _self.exitNode : exitNode // ignore: cast_nullable_to_non_nullable
as String,exitNodeAllowLanAccess: null == exitNodeAllowLanAccess ? _self.exitNodeAllowLanAccess : exitNodeAllowLanAccess // ignore: cast_nullable_to_non_nullable
as bool,acceptRoutes: null == acceptRoutes ? _self.acceptRoutes : acceptRoutes // ignore: cast_nullable_to_non_nullable
as bool,udp: null == udp ? _self.udp : udp // ignore: cast_nullable_to_non_nullable
as bool,routes: null == routes ? _self.routes : routes // ignore: cast_nullable_to_non_nullable
as List<String>,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TailscaleNetwork].
extension TailscaleNetworkPatterns on TailscaleNetwork {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TailscaleNetwork value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TailscaleNetwork() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TailscaleNetwork value)  $default,){
final _that = this;
switch (_that) {
case _TailscaleNetwork():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TailscaleNetwork value)?  $default,){
final _that = this;
switch (_that) {
case _TailscaleNetwork() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String authKey,  String hostname,  String controlUrl,  String exitNode,  bool exitNodeAllowLanAccess,  bool acceptRoutes,  bool udp,  List<String> routes,  List<String> dns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TailscaleNetwork() when $default != null:
return $default(_that.id,_that.label,_that.authKey,_that.hostname,_that.controlUrl,_that.exitNode,_that.exitNodeAllowLanAccess,_that.acceptRoutes,_that.udp,_that.routes,_that.dns);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String authKey,  String hostname,  String controlUrl,  String exitNode,  bool exitNodeAllowLanAccess,  bool acceptRoutes,  bool udp,  List<String> routes,  List<String> dns)  $default,) {final _that = this;
switch (_that) {
case _TailscaleNetwork():
return $default(_that.id,_that.label,_that.authKey,_that.hostname,_that.controlUrl,_that.exitNode,_that.exitNodeAllowLanAccess,_that.acceptRoutes,_that.udp,_that.routes,_that.dns);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String authKey,  String hostname,  String controlUrl,  String exitNode,  bool exitNodeAllowLanAccess,  bool acceptRoutes,  bool udp,  List<String> routes,  List<String> dns)?  $default,) {final _that = this;
switch (_that) {
case _TailscaleNetwork() when $default != null:
return $default(_that.id,_that.label,_that.authKey,_that.hostname,_that.controlUrl,_that.exitNode,_that.exitNodeAllowLanAccess,_that.acceptRoutes,_that.udp,_that.routes,_that.dns);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TailscaleNetwork implements TailscaleNetwork {
  const _TailscaleNetwork({required this.id, this.label = 'Tailscale', this.authKey = '', this.hostname = '', this.controlUrl = '', this.exitNode = '', this.exitNodeAllowLanAccess = false, this.acceptRoutes = true, this.udp = true,  List<String> routes = defaultTailscaleRoutes,  List<String> dns = const []}): _routes = routes,_dns = dns;
  factory _TailscaleNetwork.fromJson(Map<String, dynamic> json) => _$TailscaleNetworkFromJson(json);

@override final  String id;
@override@JsonKey() final  String label;
@override@JsonKey() final  String authKey;
@override@JsonKey() final  String hostname;
@override@JsonKey() final  String controlUrl;
@override@JsonKey() final  String exitNode;
@override@JsonKey() final  bool exitNodeAllowLanAccess;
@override@JsonKey() final  bool acceptRoutes;
@override@JsonKey() final  bool udp;
 final  List<String> _routes;
@override@JsonKey() List<String> get routes {
  if (_routes is EqualUnmodifiableListView) return _routes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routes);
}

 final  List<String> _dns;
@override@JsonKey() List<String> get dns {
  if (_dns is EqualUnmodifiableListView) return _dns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dns);
}


/// Create a copy of TailscaleNetwork
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TailscaleNetworkCopyWith<_TailscaleNetwork> get copyWith => __$TailscaleNetworkCopyWithImpl<_TailscaleNetwork>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TailscaleNetworkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TailscaleNetwork&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.authKey, authKey) || other.authKey == authKey)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.controlUrl, controlUrl) || other.controlUrl == controlUrl)&&(identical(other.exitNode, exitNode) || other.exitNode == exitNode)&&(identical(other.exitNodeAllowLanAccess, exitNodeAllowLanAccess) || other.exitNodeAllowLanAccess == exitNodeAllowLanAccess)&&(identical(other.acceptRoutes, acceptRoutes) || other.acceptRoutes == acceptRoutes)&&(identical(other.udp, udp) || other.udp == udp)&&const DeepCollectionEquality().equals(other.routes, _routes)&&const DeepCollectionEquality().equals(other.dns, _dns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,authKey,hostname,controlUrl,exitNode,exitNodeAllowLanAccess,acceptRoutes,udp,const DeepCollectionEquality().hash(_routes),const DeepCollectionEquality().hash(_dns));
}

@override
String toString() {
    return 'TailscaleNetwork(id: $id, label: $label, authKey: $authKey, hostname: $hostname, controlUrl: $controlUrl, exitNode: $exitNode, exitNodeAllowLanAccess: $exitNodeAllowLanAccess, acceptRoutes: $acceptRoutes, udp: $udp, routes: $routes, dns: $dns)';
}


}

/// @nodoc
abstract mixin class _$TailscaleNetworkCopyWith<$Res> implements $TailscaleNetworkCopyWith<$Res> {
  factory _$TailscaleNetworkCopyWith(_TailscaleNetwork value, $Res Function(_TailscaleNetwork) _then) = __$TailscaleNetworkCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String authKey, String hostname, String controlUrl, String exitNode, bool exitNodeAllowLanAccess, bool acceptRoutes, bool udp, List<String> routes, List<String> dns
});




}
/// @nodoc
class __$TailscaleNetworkCopyWithImpl<$Res>
    implements _$TailscaleNetworkCopyWith<$Res> {
  __$TailscaleNetworkCopyWithImpl(this._self, this._then);

  final _TailscaleNetwork _self;
  final $Res Function(_TailscaleNetwork) _then;

/// Create a copy of TailscaleNetwork
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? authKey = null,Object? hostname = null,Object? controlUrl = null,Object? exitNode = null,Object? exitNodeAllowLanAccess = null,Object? acceptRoutes = null,Object? udp = null,Object? routes = null,Object? dns = null,}) {
  return _then(_TailscaleNetwork(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,authKey: null == authKey ? _self.authKey : authKey // ignore: cast_nullable_to_non_nullable
as String,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,controlUrl: null == controlUrl ? _self.controlUrl : controlUrl // ignore: cast_nullable_to_non_nullable
as String,exitNode: null == exitNode ? _self.exitNode : exitNode // ignore: cast_nullable_to_non_nullable
as String,exitNodeAllowLanAccess: null == exitNodeAllowLanAccess ? _self.exitNodeAllowLanAccess : exitNodeAllowLanAccess // ignore: cast_nullable_to_non_nullable
as bool,acceptRoutes: null == acceptRoutes ? _self.acceptRoutes : acceptRoutes // ignore: cast_nullable_to_non_nullable
as bool,udp: null == udp ? _self.udp : udp // ignore: cast_nullable_to_non_nullable
as bool,routes: null == routes ? _self._routes : routes // ignore: cast_nullable_to_non_nullable
as List<String>,dns: null == dns ? _self._dns : dns // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$TailscaleProps {

 bool get enable; String? get activeId; List<TailscaleNetwork> get networks;
/// Create a copy of TailscaleProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TailscalePropsCopyWith<TailscaleProps> get copyWith => _$TailscalePropsCopyWithImpl<TailscaleProps>(this as TailscaleProps, _$identity);

  /// Serializes this TailscaleProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TailscaleProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TailscaleProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.activeId, _this.activeId) || other.activeId == _this.activeId)&&const DeepCollectionEquality().equals(other.networks, _this.networks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TailscaleProps;
  return Object.hash(runtimeType,_this.enable,_this.activeId,const DeepCollectionEquality().hash(_this.networks));
}

@override
String toString() {
  final _this = this as TailscaleProps;
  return 'TailscaleProps(enable: ${_this.enable}, activeId: ${_this.activeId}, networks: ${_this.networks})';
}


}

/// @nodoc
abstract mixin class $TailscalePropsCopyWith<$Res>  {
  factory $TailscalePropsCopyWith(TailscaleProps value, $Res Function(TailscaleProps) _then) = _$TailscalePropsCopyWithImpl;
@useResult
$Res call({
 bool enable, String? activeId, List<TailscaleNetwork> networks
});




}
/// @nodoc
class _$TailscalePropsCopyWithImpl<$Res>
    implements $TailscalePropsCopyWith<$Res> {
  _$TailscalePropsCopyWithImpl(this._self, this._then);

  final TailscaleProps _self;
  final $Res Function(TailscaleProps) _then;

/// Create a copy of TailscaleProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? activeId = freezed,Object? networks = null,}) {
  return _then(TailscaleProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as String?,networks: null == networks ? _self.networks : networks // ignore: cast_nullable_to_non_nullable
as List<TailscaleNetwork>,
  ));
}

}


/// Adds pattern-matching-related methods to [TailscaleProps].
extension TailscalePropsPatterns on TailscaleProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TailscaleProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TailscaleProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TailscaleProps value)  $default,){
final _that = this;
switch (_that) {
case _TailscaleProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TailscaleProps value)?  $default,){
final _that = this;
switch (_that) {
case _TailscaleProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String? activeId,  List<TailscaleNetwork> networks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TailscaleProps() when $default != null:
return $default(_that.enable,_that.activeId,_that.networks);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String? activeId,  List<TailscaleNetwork> networks)  $default,) {final _that = this;
switch (_that) {
case _TailscaleProps():
return $default(_that.enable,_that.activeId,_that.networks);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String? activeId,  List<TailscaleNetwork> networks)?  $default,) {final _that = this;
switch (_that) {
case _TailscaleProps() when $default != null:
return $default(_that.enable,_that.activeId,_that.networks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TailscaleProps implements TailscaleProps {
  const _TailscaleProps({this.enable = false, this.activeId,  List<TailscaleNetwork> networks = const []}): _networks = networks;
  factory _TailscaleProps.fromJson(Map<String, dynamic> json) => _$TailscalePropsFromJson(json);

@override@JsonKey() final  bool enable;
@override final  String? activeId;
 final  List<TailscaleNetwork> _networks;
@override@JsonKey() List<TailscaleNetwork> get networks {
  if (_networks is EqualUnmodifiableListView) return _networks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_networks);
}


/// Create a copy of TailscaleProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TailscalePropsCopyWith<_TailscaleProps> get copyWith => __$TailscalePropsCopyWithImpl<_TailscaleProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TailscalePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TailscaleProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.activeId, activeId) || other.activeId == activeId)&&const DeepCollectionEquality().equals(other.networks, _networks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,activeId,const DeepCollectionEquality().hash(_networks));
}

@override
String toString() {
    return 'TailscaleProps(enable: $enable, activeId: $activeId, networks: $networks)';
}


}

/// @nodoc
abstract mixin class _$TailscalePropsCopyWith<$Res> implements $TailscalePropsCopyWith<$Res> {
  factory _$TailscalePropsCopyWith(_TailscaleProps value, $Res Function(_TailscaleProps) _then) = __$TailscalePropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String? activeId, List<TailscaleNetwork> networks
});




}
/// @nodoc
class __$TailscalePropsCopyWithImpl<$Res>
    implements _$TailscalePropsCopyWith<$Res> {
  __$TailscalePropsCopyWithImpl(this._self, this._then);

  final _TailscaleProps _self;
  final $Res Function(_TailscaleProps) _then;

/// Create a copy of TailscaleProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? activeId = freezed,Object? networks = null,}) {
  return _then(_TailscaleProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as String?,networks: null == networks ? _self._networks : networks // ignore: cast_nullable_to_non_nullable
as List<TailscaleNetwork>,
  ));
}


}


/// @nodoc
mixin _$ProxiesStyle {

 ProxiesType get type; ProxiesSortType get sortType; ProxiesLayout get layout; ProxiesIconStyle get iconStyle; ProxyCardType get cardType; DelayAnimationType get delayAnimation; bool get syncDelayAnimation; Map<String, String> get iconMap; int get concurrencyLimit; bool get autoStickyHeader; bool get showHiddenItems; bool get hasCustomizedStyle;
/// Create a copy of ProxiesStyle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesStyleCopyWith<ProxiesStyle> get copyWith => _$ProxiesStyleCopyWithImpl<ProxiesStyle>(this as ProxiesStyle, _$identity);

  /// Serializes this ProxiesStyle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxiesStyle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesStyle&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.sortType, _this.sortType) || other.sortType == _this.sortType)&&(identical(other.layout, _this.layout) || other.layout == _this.layout)&&(identical(other.iconStyle, _this.iconStyle) || other.iconStyle == _this.iconStyle)&&(identical(other.cardType, _this.cardType) || other.cardType == _this.cardType)&&(identical(other.delayAnimation, _this.delayAnimation) || other.delayAnimation == _this.delayAnimation)&&(identical(other.syncDelayAnimation, _this.syncDelayAnimation) || other.syncDelayAnimation == _this.syncDelayAnimation)&&const DeepCollectionEquality().equals(other.iconMap, _this.iconMap)&&(identical(other.concurrencyLimit, _this.concurrencyLimit) || other.concurrencyLimit == _this.concurrencyLimit)&&(identical(other.autoStickyHeader, _this.autoStickyHeader) || other.autoStickyHeader == _this.autoStickyHeader)&&(identical(other.showHiddenItems, _this.showHiddenItems) || other.showHiddenItems == _this.showHiddenItems)&&(identical(other.hasCustomizedStyle, _this.hasCustomizedStyle) || other.hasCustomizedStyle == _this.hasCustomizedStyle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxiesStyle;
  return Object.hash(runtimeType,_this.type,_this.sortType,_this.layout,_this.iconStyle,_this.cardType,_this.delayAnimation,_this.syncDelayAnimation,const DeepCollectionEquality().hash(_this.iconMap),_this.concurrencyLimit,_this.autoStickyHeader,_this.showHiddenItems,_this.hasCustomizedStyle);
}

@override
String toString() {
  final _this = this as ProxiesStyle;
  return 'ProxiesStyle(type: ${_this.type}, sortType: ${_this.sortType}, layout: ${_this.layout}, iconStyle: ${_this.iconStyle}, cardType: ${_this.cardType}, delayAnimation: ${_this.delayAnimation}, syncDelayAnimation: ${_this.syncDelayAnimation}, iconMap: ${_this.iconMap}, concurrencyLimit: ${_this.concurrencyLimit}, autoStickyHeader: ${_this.autoStickyHeader}, showHiddenItems: ${_this.showHiddenItems}, hasCustomizedStyle: ${_this.hasCustomizedStyle})';
}


}

/// @nodoc
abstract mixin class $ProxiesStyleCopyWith<$Res>  {
  factory $ProxiesStyleCopyWith(ProxiesStyle value, $Res Function(ProxiesStyle) _then) = _$ProxiesStyleCopyWithImpl;
@useResult
$Res call({
 ProxiesType type, ProxiesSortType sortType, ProxiesLayout layout, ProxiesIconStyle iconStyle, ProxyCardType cardType, DelayAnimationType delayAnimation, bool syncDelayAnimation, Map<String, String> iconMap, int concurrencyLimit, bool autoStickyHeader, bool showHiddenItems, bool hasCustomizedStyle
});




}
/// @nodoc
class _$ProxiesStyleCopyWithImpl<$Res>
    implements $ProxiesStyleCopyWith<$Res> {
  _$ProxiesStyleCopyWithImpl(this._self, this._then);

  final ProxiesStyle _self;
  final $Res Function(ProxiesStyle) _then;

/// Create a copy of ProxiesStyle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? sortType = null,Object? layout = null,Object? iconStyle = null,Object? cardType = null,Object? delayAnimation = null,Object? syncDelayAnimation = null,Object? iconMap = null,Object? concurrencyLimit = null,Object? autoStickyHeader = null,Object? showHiddenItems = null,Object? hasCustomizedStyle = null,}) {
  return _then(ProxiesStyle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as ProxiesLayout,iconStyle: null == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as ProxiesIconStyle,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,delayAnimation: null == delayAnimation ? _self.delayAnimation : delayAnimation // ignore: cast_nullable_to_non_nullable
as DelayAnimationType,syncDelayAnimation: null == syncDelayAnimation ? _self.syncDelayAnimation : syncDelayAnimation // ignore: cast_nullable_to_non_nullable
as bool,iconMap: null == iconMap ? _self.iconMap : iconMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,concurrencyLimit: null == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int,autoStickyHeader: null == autoStickyHeader ? _self.autoStickyHeader : autoStickyHeader // ignore: cast_nullable_to_non_nullable
as bool,showHiddenItems: null == showHiddenItems ? _self.showHiddenItems : showHiddenItems // ignore: cast_nullable_to_non_nullable
as bool,hasCustomizedStyle: null == hasCustomizedStyle ? _self.hasCustomizedStyle : hasCustomizedStyle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesStyle].
extension ProxiesStylePatterns on ProxiesStyle {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesStyle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesStyle() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesStyle value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesStyle():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesStyle value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesStyle() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType,  DelayAnimationType delayAnimation,  bool syncDelayAnimation,  Map<String, String> iconMap,  int concurrencyLimit,  bool autoStickyHeader,  bool showHiddenItems,  bool hasCustomizedStyle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesStyle() when $default != null:
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.delayAnimation,_that.syncDelayAnimation,_that.iconMap,_that.concurrencyLimit,_that.autoStickyHeader,_that.showHiddenItems,_that.hasCustomizedStyle);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType,  DelayAnimationType delayAnimation,  bool syncDelayAnimation,  Map<String, String> iconMap,  int concurrencyLimit,  bool autoStickyHeader,  bool showHiddenItems,  bool hasCustomizedStyle)  $default,) {final _that = this;
switch (_that) {
case _ProxiesStyle():
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.delayAnimation,_that.syncDelayAnimation,_that.iconMap,_that.concurrencyLimit,_that.autoStickyHeader,_that.showHiddenItems,_that.hasCustomizedStyle);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType,  DelayAnimationType delayAnimation,  bool syncDelayAnimation,  Map<String, String> iconMap,  int concurrencyLimit,  bool autoStickyHeader,  bool showHiddenItems,  bool hasCustomizedStyle)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesStyle() when $default != null:
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.delayAnimation,_that.syncDelayAnimation,_that.iconMap,_that.concurrencyLimit,_that.autoStickyHeader,_that.showHiddenItems,_that.hasCustomizedStyle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxiesStyle implements ProxiesStyle {
  const _ProxiesStyle({this.type = ProxiesType.tab, this.sortType = ProxiesSortType.none, this.layout = ProxiesLayout.standard, this.iconStyle = ProxiesIconStyle.none, this.cardType = ProxyCardType.shrink, this.delayAnimation = DelayAnimationType.none, this.syncDelayAnimation = true,  Map<String, String> iconMap = const {}, this.concurrencyLimit = 250, this.autoStickyHeader = true, this.showHiddenItems = false, this.hasCustomizedStyle = false}): _iconMap = iconMap;
  factory _ProxiesStyle.fromJson(Map<String, dynamic> json) => _$ProxiesStyleFromJson(json);

@override@JsonKey() final  ProxiesType type;
@override@JsonKey() final  ProxiesSortType sortType;
@override@JsonKey() final  ProxiesLayout layout;
@override@JsonKey() final  ProxiesIconStyle iconStyle;
@override@JsonKey() final  ProxyCardType cardType;
@override@JsonKey() final  DelayAnimationType delayAnimation;
@override@JsonKey() final  bool syncDelayAnimation;
 final  Map<String, String> _iconMap;
@override@JsonKey() Map<String, String> get iconMap {
  if (_iconMap is EqualUnmodifiableMapView) return _iconMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_iconMap);
}

@override@JsonKey() final  int concurrencyLimit;
@override@JsonKey() final  bool autoStickyHeader;
@override@JsonKey() final  bool showHiddenItems;
@override@JsonKey() final  bool hasCustomizedStyle;

/// Create a copy of ProxiesStyle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesStyleCopyWith<_ProxiesStyle> get copyWith => __$ProxiesStyleCopyWithImpl<_ProxiesStyle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxiesStyleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesStyle&&(identical(other.type, type) || other.type == type)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.delayAnimation, delayAnimation) || other.delayAnimation == delayAnimation)&&(identical(other.syncDelayAnimation, syncDelayAnimation) || other.syncDelayAnimation == syncDelayAnimation)&&const DeepCollectionEquality().equals(other.iconMap, _iconMap)&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.autoStickyHeader, autoStickyHeader) || other.autoStickyHeader == autoStickyHeader)&&(identical(other.showHiddenItems, showHiddenItems) || other.showHiddenItems == showHiddenItems)&&(identical(other.hasCustomizedStyle, hasCustomizedStyle) || other.hasCustomizedStyle == hasCustomizedStyle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,sortType,layout,iconStyle,cardType,delayAnimation,syncDelayAnimation,const DeepCollectionEquality().hash(_iconMap),concurrencyLimit,autoStickyHeader,showHiddenItems,hasCustomizedStyle);
}

@override
String toString() {
    return 'ProxiesStyle(type: $type, sortType: $sortType, layout: $layout, iconStyle: $iconStyle, cardType: $cardType, delayAnimation: $delayAnimation, syncDelayAnimation: $syncDelayAnimation, iconMap: $iconMap, concurrencyLimit: $concurrencyLimit, autoStickyHeader: $autoStickyHeader, showHiddenItems: $showHiddenItems, hasCustomizedStyle: $hasCustomizedStyle)';
}


}

/// @nodoc
abstract mixin class _$ProxiesStyleCopyWith<$Res> implements $ProxiesStyleCopyWith<$Res> {
  factory _$ProxiesStyleCopyWith(_ProxiesStyle value, $Res Function(_ProxiesStyle) _then) = __$ProxiesStyleCopyWithImpl;
@override @useResult
$Res call({
 ProxiesType type, ProxiesSortType sortType, ProxiesLayout layout, ProxiesIconStyle iconStyle, ProxyCardType cardType, DelayAnimationType delayAnimation, bool syncDelayAnimation, Map<String, String> iconMap, int concurrencyLimit, bool autoStickyHeader, bool showHiddenItems, bool hasCustomizedStyle
});




}
/// @nodoc
class __$ProxiesStyleCopyWithImpl<$Res>
    implements _$ProxiesStyleCopyWith<$Res> {
  __$ProxiesStyleCopyWithImpl(this._self, this._then);

  final _ProxiesStyle _self;
  final $Res Function(_ProxiesStyle) _then;

/// Create a copy of ProxiesStyle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? sortType = null,Object? layout = null,Object? iconStyle = null,Object? cardType = null,Object? delayAnimation = null,Object? syncDelayAnimation = null,Object? iconMap = null,Object? concurrencyLimit = null,Object? autoStickyHeader = null,Object? showHiddenItems = null,Object? hasCustomizedStyle = null,}) {
  return _then(_ProxiesStyle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as ProxiesLayout,iconStyle: null == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as ProxiesIconStyle,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,delayAnimation: null == delayAnimation ? _self.delayAnimation : delayAnimation // ignore: cast_nullable_to_non_nullable
as DelayAnimationType,syncDelayAnimation: null == syncDelayAnimation ? _self.syncDelayAnimation : syncDelayAnimation // ignore: cast_nullable_to_non_nullable
as bool,iconMap: null == iconMap ? _self._iconMap : iconMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,concurrencyLimit: null == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int,autoStickyHeader: null == autoStickyHeader ? _self.autoStickyHeader : autoStickyHeader // ignore: cast_nullable_to_non_nullable
as bool,showHiddenItems: null == showHiddenItems ? _self.showHiddenItems : showHiddenItems // ignore: cast_nullable_to_non_nullable
as bool,hasCustomizedStyle: null == hasCustomizedStyle ? _self.hasCustomizedStyle : hasCustomizedStyle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TextScale {

 bool get enable; double get scale;
/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextScaleCopyWith<TextScale> get copyWith => _$TextScaleCopyWithImpl<TextScale>(this as TextScale, _$identity);

  /// Serializes this TextScale to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextScale;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextScale&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.scale, _this.scale) || other.scale == _this.scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextScale;
  return Object.hash(runtimeType,_this.enable,_this.scale);
}

@override
String toString() {
  final _this = this as TextScale;
  return 'TextScale(enable: ${_this.enable}, scale: ${_this.scale})';
}


}

/// @nodoc
abstract mixin class $TextScaleCopyWith<$Res>  {
  factory $TextScaleCopyWith(TextScale value, $Res Function(TextScale) _then) = _$TextScaleCopyWithImpl;
@useResult
$Res call({
 bool enable, double scale
});




}
/// @nodoc
class _$TextScaleCopyWithImpl<$Res>
    implements $TextScaleCopyWith<$Res> {
  _$TextScaleCopyWithImpl(this._self, this._then);

  final TextScale _self;
  final $Res Function(TextScale) _then;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? scale = null,}) {
  return _then(TextScale(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextScale].
extension TextScalePatterns on TextScale {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextScale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextScale value)  $default,){
final _that = this;
switch (_that) {
case _TextScale():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextScale value)?  $default,){
final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  double scale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that.enable,_that.scale);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  double scale)  $default,) {final _that = this;
switch (_that) {
case _TextScale():
return $default(_that.enable,_that.scale);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  double scale)?  $default,) {final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that.enable,_that.scale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextScale implements TextScale {
  const _TextScale({this.enable = false, this.scale = 1.0});
  factory _TextScale.fromJson(Map<String, dynamic> json) => _$TextScaleFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  double scale;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextScaleCopyWith<_TextScale> get copyWith => __$TextScaleCopyWithImpl<_TextScale>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextScaleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextScale&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.scale, scale) || other.scale == scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,scale);
}

@override
String toString() {
    return 'TextScale(enable: $enable, scale: $scale)';
}


}

/// @nodoc
abstract mixin class _$TextScaleCopyWith<$Res> implements $TextScaleCopyWith<$Res> {
  factory _$TextScaleCopyWith(_TextScale value, $Res Function(_TextScale) _then) = __$TextScaleCopyWithImpl;
@override @useResult
$Res call({
 bool enable, double scale
});




}
/// @nodoc
class __$TextScaleCopyWithImpl<$Res>
    implements _$TextScaleCopyWith<$Res> {
  __$TextScaleCopyWithImpl(this._self, this._then);

  final _TextScale _self;
  final $Res Function(_TextScale) _then;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? scale = null,}) {
  return _then(_TextScale(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ThemeProps {

 int? get primaryColor; List<int> get primaryColors; ThemeMode get themeMode; DynamicSchemeVariant get schemeVariant; bool get pureBlack; TextScale get textScale; bool get useDarkIcon; bool get useHarmonyFont; bool get invertTrayIcon;
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<ThemeProps> get copyWith => _$ThemePropsCopyWithImpl<ThemeProps>(this as ThemeProps, _$identity);

  /// Serializes this ThemeProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ThemeProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeProps&&(identical(other.primaryColor, _this.primaryColor) || other.primaryColor == _this.primaryColor)&&const DeepCollectionEquality().equals(other.primaryColors, _this.primaryColors)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.schemeVariant, _this.schemeVariant) || other.schemeVariant == _this.schemeVariant)&&(identical(other.pureBlack, _this.pureBlack) || other.pureBlack == _this.pureBlack)&&(identical(other.textScale, _this.textScale) || other.textScale == _this.textScale)&&(identical(other.useDarkIcon, _this.useDarkIcon) || other.useDarkIcon == _this.useDarkIcon)&&(identical(other.useHarmonyFont, _this.useHarmonyFont) || other.useHarmonyFont == _this.useHarmonyFont)&&(identical(other.invertTrayIcon, _this.invertTrayIcon) || other.invertTrayIcon == _this.invertTrayIcon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThemeProps;
  return Object.hash(runtimeType,_this.primaryColor,const DeepCollectionEquality().hash(_this.primaryColors),_this.themeMode,_this.schemeVariant,_this.pureBlack,_this.textScale,_this.useDarkIcon,_this.useHarmonyFont,_this.invertTrayIcon);
}

@override
String toString() {
  final _this = this as ThemeProps;
  return 'ThemeProps(primaryColor: ${_this.primaryColor}, primaryColors: ${_this.primaryColors}, themeMode: ${_this.themeMode}, schemeVariant: ${_this.schemeVariant}, pureBlack: ${_this.pureBlack}, textScale: ${_this.textScale}, useDarkIcon: ${_this.useDarkIcon}, useHarmonyFont: ${_this.useHarmonyFont}, invertTrayIcon: ${_this.invertTrayIcon})';
}


}

/// @nodoc
abstract mixin class $ThemePropsCopyWith<$Res>  {
  factory $ThemePropsCopyWith(ThemeProps value, $Res Function(ThemeProps) _then) = _$ThemePropsCopyWithImpl;
@useResult
$Res call({
 int? primaryColor, List<int> primaryColors, ThemeMode themeMode, DynamicSchemeVariant schemeVariant, bool pureBlack, TextScale textScale, bool useDarkIcon, bool useHarmonyFont, bool invertTrayIcon
});


$TextScaleCopyWith<$Res> get textScale;

}
/// @nodoc
class _$ThemePropsCopyWithImpl<$Res>
    implements $ThemePropsCopyWith<$Res> {
  _$ThemePropsCopyWithImpl(this._self, this._then);

  final ThemeProps _self;
  final $Res Function(ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? themeMode = null,Object? schemeVariant = null,Object? pureBlack = null,Object? textScale = null,Object? useDarkIcon = null,Object? useHarmonyFont = null,Object? invertTrayIcon = null,}) {
  return _then(ThemeProps(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self.primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,schemeVariant: null == schemeVariant ? _self.schemeVariant : schemeVariant // ignore: cast_nullable_to_non_nullable
as DynamicSchemeVariant,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as TextScale,useDarkIcon: null == useDarkIcon ? _self.useDarkIcon : useDarkIcon // ignore: cast_nullable_to_non_nullable
as bool,useHarmonyFont: null == useHarmonyFont ? _self.useHarmonyFont : useHarmonyFont // ignore: cast_nullable_to_non_nullable
as bool,invertTrayIcon: null == invertTrayIcon ? _self.invertTrayIcon : invertTrayIcon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextScaleCopyWith<$Res> get textScale {
  
  return $TextScaleCopyWith<$Res>(_self.textScale, (value) {
    return _then(_self.copyWith(textScale: value));
  });
}
}


/// Adds pattern-matching-related methods to [ThemeProps].
extension ThemePropsPatterns on ThemeProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeProps value)  $default,){
final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeProps value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  TextScale textScale,  bool useDarkIcon,  bool useHarmonyFont,  bool invertTrayIcon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.schemeVariant,_that.pureBlack,_that.textScale,_that.useDarkIcon,_that.useHarmonyFont,_that.invertTrayIcon);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  TextScale textScale,  bool useDarkIcon,  bool useHarmonyFont,  bool invertTrayIcon)  $default,) {final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.schemeVariant,_that.pureBlack,_that.textScale,_that.useDarkIcon,_that.useHarmonyFont,_that.invertTrayIcon);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  TextScale textScale,  bool useDarkIcon,  bool useHarmonyFont,  bool invertTrayIcon)?  $default,) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.schemeVariant,_that.pureBlack,_that.textScale,_that.useDarkIcon,_that.useHarmonyFont,_that.invertTrayIcon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeProps implements ThemeProps {
  const _ThemeProps({this.primaryColor,  List<int> primaryColors = defaultPrimaryColors, this.themeMode = ThemeMode.system, this.schemeVariant = DynamicSchemeVariant.content, this.pureBlack = false, this.textScale = const TextScale(), this.useDarkIcon = false, this.useHarmonyFont = false, this.invertTrayIcon = false}): _primaryColors = primaryColors;
  factory _ThemeProps.fromJson(Map<String, dynamic> json) => _$ThemePropsFromJson(json);

@override final  int? primaryColor;
 final  List<int> _primaryColors;
@override@JsonKey() List<int> get primaryColors {
  if (_primaryColors is EqualUnmodifiableListView) return _primaryColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryColors);
}

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  DynamicSchemeVariant schemeVariant;
@override@JsonKey() final  bool pureBlack;
@override@JsonKey() final  TextScale textScale;
@override@JsonKey() final  bool useDarkIcon;
@override@JsonKey() final  bool useHarmonyFont;
@override@JsonKey() final  bool invertTrayIcon;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemePropsCopyWith<_ThemeProps> get copyWith => __$ThemePropsCopyWithImpl<_ThemeProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeProps&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other.primaryColors, _primaryColors)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.schemeVariant, schemeVariant) || other.schemeVariant == schemeVariant)&&(identical(other.pureBlack, pureBlack) || other.pureBlack == pureBlack)&&(identical(other.textScale, textScale) || other.textScale == textScale)&&(identical(other.useDarkIcon, useDarkIcon) || other.useDarkIcon == useDarkIcon)&&(identical(other.useHarmonyFont, useHarmonyFont) || other.useHarmonyFont == useHarmonyFont)&&(identical(other.invertTrayIcon, invertTrayIcon) || other.invertTrayIcon == invertTrayIcon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,primaryColor,const DeepCollectionEquality().hash(_primaryColors),themeMode,schemeVariant,pureBlack,textScale,useDarkIcon,useHarmonyFont,invertTrayIcon);
}

@override
String toString() {
    return 'ThemeProps(primaryColor: $primaryColor, primaryColors: $primaryColors, themeMode: $themeMode, schemeVariant: $schemeVariant, pureBlack: $pureBlack, textScale: $textScale, useDarkIcon: $useDarkIcon, useHarmonyFont: $useHarmonyFont, invertTrayIcon: $invertTrayIcon)';
}


}

/// @nodoc
abstract mixin class _$ThemePropsCopyWith<$Res> implements $ThemePropsCopyWith<$Res> {
  factory _$ThemePropsCopyWith(_ThemeProps value, $Res Function(_ThemeProps) _then) = __$ThemePropsCopyWithImpl;
@override @useResult
$Res call({
 int? primaryColor, List<int> primaryColors, ThemeMode themeMode, DynamicSchemeVariant schemeVariant, bool pureBlack, TextScale textScale, bool useDarkIcon, bool useHarmonyFont, bool invertTrayIcon
});


@override $TextScaleCopyWith<$Res> get textScale;

}
/// @nodoc
class __$ThemePropsCopyWithImpl<$Res>
    implements _$ThemePropsCopyWith<$Res> {
  __$ThemePropsCopyWithImpl(this._self, this._then);

  final _ThemeProps _self;
  final $Res Function(_ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? themeMode = null,Object? schemeVariant = null,Object? pureBlack = null,Object? textScale = null,Object? useDarkIcon = null,Object? useHarmonyFont = null,Object? invertTrayIcon = null,}) {
  return _then(_ThemeProps(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self._primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,schemeVariant: null == schemeVariant ? _self.schemeVariant : schemeVariant // ignore: cast_nullable_to_non_nullable
as DynamicSchemeVariant,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as TextScale,useDarkIcon: null == useDarkIcon ? _self.useDarkIcon : useDarkIcon // ignore: cast_nullable_to_non_nullable
as bool,useHarmonyFont: null == useHarmonyFont ? _self.useHarmonyFont : useHarmonyFont // ignore: cast_nullable_to_non_nullable
as bool,invertTrayIcon: null == invertTrayIcon ? _self.invertTrayIcon : invertTrayIcon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextScaleCopyWith<$Res> get textScale {
  
  return $TextScaleCopyWith<$Res>(_self.textScale, (value) {
    return _then(_self.copyWith(textScale: value));
  });
}
}


/// @nodoc
mixin _$ScriptProps {

 String? get currentId; List<Script> get scripts;
/// Create a copy of ScriptProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptPropsCopyWith<ScriptProps> get copyWith => _$ScriptPropsCopyWithImpl<ScriptProps>(this as ScriptProps, _$identity);

  /// Serializes this ScriptProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScriptProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScriptProps&&(identical(other.currentId, _this.currentId) || other.currentId == _this.currentId)&&const DeepCollectionEquality().equals(other.scripts, _this.scripts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScriptProps;
  return Object.hash(runtimeType,_this.currentId,const DeepCollectionEquality().hash(_this.scripts));
}

@override
String toString() {
  final _this = this as ScriptProps;
  return 'ScriptProps(currentId: ${_this.currentId}, scripts: ${_this.scripts})';
}


}

/// @nodoc
abstract mixin class $ScriptPropsCopyWith<$Res>  {
  factory $ScriptPropsCopyWith(ScriptProps value, $Res Function(ScriptProps) _then) = _$ScriptPropsCopyWithImpl;
@useResult
$Res call({
 String? currentId, List<Script> scripts
});




}
/// @nodoc
class _$ScriptPropsCopyWithImpl<$Res>
    implements $ScriptPropsCopyWith<$Res> {
  _$ScriptPropsCopyWithImpl(this._self, this._then);

  final ScriptProps _self;
  final $Res Function(ScriptProps) _then;

/// Create a copy of ScriptProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentId = freezed,Object? scripts = null,}) {
  return _then(ScriptProps(
currentId: freezed == currentId ? _self.currentId : currentId // ignore: cast_nullable_to_non_nullable
as String?,scripts: null == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,
  ));
}

}


/// Adds pattern-matching-related methods to [ScriptProps].
extension ScriptPropsPatterns on ScriptProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScriptProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScriptProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScriptProps value)  $default,){
final _that = this;
switch (_that) {
case _ScriptProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScriptProps value)?  $default,){
final _that = this;
switch (_that) {
case _ScriptProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? currentId,  List<Script> scripts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScriptProps() when $default != null:
return $default(_that.currentId,_that.scripts);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? currentId,  List<Script> scripts)  $default,) {final _that = this;
switch (_that) {
case _ScriptProps():
return $default(_that.currentId,_that.scripts);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? currentId,  List<Script> scripts)?  $default,) {final _that = this;
switch (_that) {
case _ScriptProps() when $default != null:
return $default(_that.currentId,_that.scripts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScriptProps implements ScriptProps {
  const _ScriptProps({this.currentId,  List<Script> scripts = const []}): _scripts = scripts;
  factory _ScriptProps.fromJson(Map<String, dynamic> json) => _$ScriptPropsFromJson(json);

@override final  String? currentId;
 final  List<Script> _scripts;
@override@JsonKey() List<Script> get scripts {
  if (_scripts is EqualUnmodifiableListView) return _scripts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scripts);
}


/// Create a copy of ScriptProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptPropsCopyWith<_ScriptProps> get copyWith => __$ScriptPropsCopyWithImpl<_ScriptProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScriptProps&&(identical(other.currentId, currentId) || other.currentId == currentId)&&const DeepCollectionEquality().equals(other.scripts, _scripts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentId,const DeepCollectionEquality().hash(_scripts));
}

@override
String toString() {
    return 'ScriptProps(currentId: $currentId, scripts: $scripts)';
}


}

/// @nodoc
abstract mixin class _$ScriptPropsCopyWith<$Res> implements $ScriptPropsCopyWith<$Res> {
  factory _$ScriptPropsCopyWith(_ScriptProps value, $Res Function(_ScriptProps) _then) = __$ScriptPropsCopyWithImpl;
@override @useResult
$Res call({
 String? currentId, List<Script> scripts
});




}
/// @nodoc
class __$ScriptPropsCopyWithImpl<$Res>
    implements _$ScriptPropsCopyWith<$Res> {
  __$ScriptPropsCopyWithImpl(this._self, this._then);

  final _ScriptProps _self;
  final $Res Function(_ScriptProps) _then;

/// Create a copy of ScriptProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentId = freezed,Object? scripts = null,}) {
  return _then(_ScriptProps(
currentId: freezed == currentId ? _self.currentId : currentId // ignore: cast_nullable_to_non_nullable
as String?,scripts: null == scripts ? _self._scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,
  ));
}


}


/// @nodoc
mixin _$Config {

@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps get appSetting; List<Profile> get profiles; List<HotKeyAction> get hotKeyActions; String? get currentProfileId; bool get overrideDns; bool get overrideNtp; bool get overrideSniffer; bool get overrideTunnel; bool get overrideExperimental; bool get overrideTestUrl; DAV? get dav; NetworkProps get networkProps;@JsonKey(fromJson: TailscaleProps.safeFromJson) TailscaleProps get tailscaleProps;@JsonKey(fromJson: VpnProps.safeFromJson) VpnProps get vpnProps;@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps get themeProps; ProxiesStyle get proxiesStyle; WindowProps get windowProps;@JsonKey(fromJson: ClashConfig.safeFormJson) ClashConfig get patchClashConfig; ScriptProps get scriptProps; String get nodeExcludeFilter; int get healthCheckTimeout;
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigCopyWith<Config> get copyWith => _$ConfigCopyWithImpl<Config>(this as Config, _$identity);

  /// Serializes this Config to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Config;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Config&&(identical(other.appSetting, _this.appSetting) || other.appSetting == _this.appSetting)&&const DeepCollectionEquality().equals(other.profiles, _this.profiles)&&const DeepCollectionEquality().equals(other.hotKeyActions, _this.hotKeyActions)&&(identical(other.currentProfileId, _this.currentProfileId) || other.currentProfileId == _this.currentProfileId)&&(identical(other.overrideDns, _this.overrideDns) || other.overrideDns == _this.overrideDns)&&(identical(other.overrideNtp, _this.overrideNtp) || other.overrideNtp == _this.overrideNtp)&&(identical(other.overrideSniffer, _this.overrideSniffer) || other.overrideSniffer == _this.overrideSniffer)&&(identical(other.overrideTunnel, _this.overrideTunnel) || other.overrideTunnel == _this.overrideTunnel)&&(identical(other.overrideExperimental, _this.overrideExperimental) || other.overrideExperimental == _this.overrideExperimental)&&(identical(other.overrideTestUrl, _this.overrideTestUrl) || other.overrideTestUrl == _this.overrideTestUrl)&&(identical(other.dav, _this.dav) || other.dav == _this.dav)&&(identical(other.networkProps, _this.networkProps) || other.networkProps == _this.networkProps)&&(identical(other.tailscaleProps, _this.tailscaleProps) || other.tailscaleProps == _this.tailscaleProps)&&(identical(other.vpnProps, _this.vpnProps) || other.vpnProps == _this.vpnProps)&&(identical(other.themeProps, _this.themeProps) || other.themeProps == _this.themeProps)&&(identical(other.proxiesStyle, _this.proxiesStyle) || other.proxiesStyle == _this.proxiesStyle)&&(identical(other.windowProps, _this.windowProps) || other.windowProps == _this.windowProps)&&(identical(other.patchClashConfig, _this.patchClashConfig) || other.patchClashConfig == _this.patchClashConfig)&&(identical(other.scriptProps, _this.scriptProps) || other.scriptProps == _this.scriptProps)&&(identical(other.nodeExcludeFilter, _this.nodeExcludeFilter) || other.nodeExcludeFilter == _this.nodeExcludeFilter)&&(identical(other.healthCheckTimeout, _this.healthCheckTimeout) || other.healthCheckTimeout == _this.healthCheckTimeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Config;
  return Object.hashAll([runtimeType,_this.appSetting,const DeepCollectionEquality().hash(_this.profiles),const DeepCollectionEquality().hash(_this.hotKeyActions),_this.currentProfileId,_this.overrideDns,_this.overrideNtp,_this.overrideSniffer,_this.overrideTunnel,_this.overrideExperimental,_this.overrideTestUrl,_this.dav,_this.networkProps,_this.tailscaleProps,_this.vpnProps,_this.themeProps,_this.proxiesStyle,_this.windowProps,_this.patchClashConfig,_this.scriptProps,_this.nodeExcludeFilter,_this.healthCheckTimeout]);
}

@override
String toString() {
  final _this = this as Config;
  return 'Config(appSetting: ${_this.appSetting}, profiles: ${_this.profiles}, hotKeyActions: ${_this.hotKeyActions}, currentProfileId: ${_this.currentProfileId}, overrideDns: ${_this.overrideDns}, overrideNtp: ${_this.overrideNtp}, overrideSniffer: ${_this.overrideSniffer}, overrideTunnel: ${_this.overrideTunnel}, overrideExperimental: ${_this.overrideExperimental}, overrideTestUrl: ${_this.overrideTestUrl}, dav: ${_this.dav}, networkProps: ${_this.networkProps}, tailscaleProps: ${_this.tailscaleProps}, vpnProps: ${_this.vpnProps}, themeProps: ${_this.themeProps}, proxiesStyle: ${_this.proxiesStyle}, windowProps: ${_this.windowProps}, patchClashConfig: ${_this.patchClashConfig}, scriptProps: ${_this.scriptProps}, nodeExcludeFilter: ${_this.nodeExcludeFilter}, healthCheckTimeout: ${_this.healthCheckTimeout})';
}


}

/// @nodoc
abstract mixin class $ConfigCopyWith<$Res>  {
  factory $ConfigCopyWith(Config value, $Res Function(Config) _then) = _$ConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps appSetting, List<Profile> profiles, List<HotKeyAction> hotKeyActions, String? currentProfileId, bool overrideDns, bool overrideNtp, bool overrideSniffer, bool overrideTunnel, bool overrideExperimental, bool overrideTestUrl, DAV? dav, NetworkProps networkProps,@JsonKey(fromJson: TailscaleProps.safeFromJson) TailscaleProps tailscaleProps,@JsonKey(fromJson: VpnProps.safeFromJson) VpnProps vpnProps,@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps, ProxiesStyle proxiesStyle, WindowProps windowProps,@JsonKey(fromJson: ClashConfig.safeFormJson) ClashConfig patchClashConfig, ScriptProps scriptProps, String nodeExcludeFilter, int healthCheckTimeout
});


$AppSettingPropsCopyWith<$Res> get appSetting;$DAVCopyWith<$Res>? get dav;$NetworkPropsCopyWith<$Res> get networkProps;$TailscalePropsCopyWith<$Res> get tailscaleProps;$VpnPropsCopyWith<$Res> get vpnProps;$ThemePropsCopyWith<$Res> get themeProps;$ProxiesStyleCopyWith<$Res> get proxiesStyle;$WindowPropsCopyWith<$Res> get windowProps;$ClashConfigCopyWith<$Res> get patchClashConfig;$ScriptPropsCopyWith<$Res> get scriptProps;

}
/// @nodoc
class _$ConfigCopyWithImpl<$Res>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._self, this._then);

  final Config _self;
  final $Res Function(Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appSetting = null,Object? profiles = null,Object? hotKeyActions = null,Object? currentProfileId = freezed,Object? overrideDns = null,Object? overrideNtp = null,Object? overrideSniffer = null,Object? overrideTunnel = null,Object? overrideExperimental = null,Object? overrideTestUrl = null,Object? dav = freezed,Object? networkProps = null,Object? tailscaleProps = null,Object? vpnProps = null,Object? themeProps = null,Object? proxiesStyle = null,Object? windowProps = null,Object? patchClashConfig = null,Object? scriptProps = null,Object? nodeExcludeFilter = null,Object? healthCheckTimeout = null,}) {
  return _then(Config(
appSetting: null == appSetting ? _self.appSetting : appSetting // ignore: cast_nullable_to_non_nullable
as AppSettingProps,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,hotKeyActions: null == hotKeyActions ? _self.hotKeyActions : hotKeyActions // ignore: cast_nullable_to_non_nullable
as List<HotKeyAction>,currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as String?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,overrideNtp: null == overrideNtp ? _self.overrideNtp : overrideNtp // ignore: cast_nullable_to_non_nullable
as bool,overrideSniffer: null == overrideSniffer ? _self.overrideSniffer : overrideSniffer // ignore: cast_nullable_to_non_nullable
as bool,overrideTunnel: null == overrideTunnel ? _self.overrideTunnel : overrideTunnel // ignore: cast_nullable_to_non_nullable
as bool,overrideExperimental: null == overrideExperimental ? _self.overrideExperimental : overrideExperimental // ignore: cast_nullable_to_non_nullable
as bool,overrideTestUrl: null == overrideTestUrl ? _self.overrideTestUrl : overrideTestUrl // ignore: cast_nullable_to_non_nullable
as bool,dav: freezed == dav ? _self.dav : dav // ignore: cast_nullable_to_non_nullable
as DAV?,networkProps: null == networkProps ? _self.networkProps : networkProps // ignore: cast_nullable_to_non_nullable
as NetworkProps,tailscaleProps: null == tailscaleProps ? _self.tailscaleProps : tailscaleProps // ignore: cast_nullable_to_non_nullable
as TailscaleProps,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,themeProps: null == themeProps ? _self.themeProps : themeProps // ignore: cast_nullable_to_non_nullable
as ThemeProps,proxiesStyle: null == proxiesStyle ? _self.proxiesStyle : proxiesStyle // ignore: cast_nullable_to_non_nullable
as ProxiesStyle,windowProps: null == windowProps ? _self.windowProps : windowProps // ignore: cast_nullable_to_non_nullable
as WindowProps,patchClashConfig: null == patchClashConfig ? _self.patchClashConfig : patchClashConfig // ignore: cast_nullable_to_non_nullable
as ClashConfig,scriptProps: null == scriptProps ? _self.scriptProps : scriptProps // ignore: cast_nullable_to_non_nullable
as ScriptProps,nodeExcludeFilter: null == nodeExcludeFilter ? _self.nodeExcludeFilter : nodeExcludeFilter // ignore: cast_nullable_to_non_nullable
as String,healthCheckTimeout: null == healthCheckTimeout ? _self.healthCheckTimeout : healthCheckTimeout // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<$Res> get appSetting {
  
  return $AppSettingPropsCopyWith<$Res>(_self.appSetting, (value) {
    return _then(_self.copyWith(appSetting: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DAVCopyWith<$Res>? get dav {
    if (_self.dav == null) {
    return null;
  }

  return $DAVCopyWith<$Res>(_self.dav!, (value) {
    return _then(_self.copyWith(dav: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<$Res> get networkProps {
  
  return $NetworkPropsCopyWith<$Res>(_self.networkProps, (value) {
    return _then(_self.copyWith(networkProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TailscalePropsCopyWith<$Res> get tailscaleProps {
  
  return $TailscalePropsCopyWith<$Res>(_self.tailscaleProps, (value) {
    return _then(_self.copyWith(tailscaleProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<$Res> get themeProps {
  
  return $ThemePropsCopyWith<$Res>(_self.themeProps, (value) {
    return _then(_self.copyWith(themeProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesStyleCopyWith<$Res> get proxiesStyle {
  
  return $ProxiesStyleCopyWith<$Res>(_self.proxiesStyle, (value) {
    return _then(_self.copyWith(proxiesStyle: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<$Res> get windowProps {
  
  return $WindowPropsCopyWith<$Res>(_self.windowProps, (value) {
    return _then(_self.copyWith(windowProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<$Res> get patchClashConfig {
  
  return $ClashConfigCopyWith<$Res>(_self.patchClashConfig, (value) {
    return _then(_self.copyWith(patchClashConfig: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptPropsCopyWith<$Res> get scriptProps {
  
  return $ScriptPropsCopyWith<$Res>(_self.scriptProps, (value) {
    return _then(_self.copyWith(scriptProps: value));
  });
}
}


/// Adds pattern-matching-related methods to [Config].
extension ConfigPatterns on Config {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Config value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Config value)  $default,){
final _that = this;
switch (_that) {
case _Config():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Config value)?  $default,){
final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSetting,  List<Profile> profiles,  List<HotKeyAction> hotKeyActions,  String? currentProfileId,  bool overrideDns,  bool overrideNtp,  bool overrideSniffer,  bool overrideTunnel,  bool overrideExperimental,  bool overrideTestUrl,  DAV? dav,  NetworkProps networkProps, @JsonKey(fromJson: TailscaleProps.safeFromJson)  TailscaleProps tailscaleProps, @JsonKey(fromJson: VpnProps.safeFromJson)  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyle proxiesStyle,  WindowProps windowProps, @JsonKey(fromJson: ClashConfig.safeFormJson)  ClashConfig patchClashConfig,  ScriptProps scriptProps,  String nodeExcludeFilter,  int healthCheckTimeout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.appSetting,_that.profiles,_that.hotKeyActions,_that.currentProfileId,_that.overrideDns,_that.overrideNtp,_that.overrideSniffer,_that.overrideTunnel,_that.overrideExperimental,_that.overrideTestUrl,_that.dav,_that.networkProps,_that.tailscaleProps,_that.vpnProps,_that.themeProps,_that.proxiesStyle,_that.windowProps,_that.patchClashConfig,_that.scriptProps,_that.nodeExcludeFilter,_that.healthCheckTimeout);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSetting,  List<Profile> profiles,  List<HotKeyAction> hotKeyActions,  String? currentProfileId,  bool overrideDns,  bool overrideNtp,  bool overrideSniffer,  bool overrideTunnel,  bool overrideExperimental,  bool overrideTestUrl,  DAV? dav,  NetworkProps networkProps, @JsonKey(fromJson: TailscaleProps.safeFromJson)  TailscaleProps tailscaleProps, @JsonKey(fromJson: VpnProps.safeFromJson)  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyle proxiesStyle,  WindowProps windowProps, @JsonKey(fromJson: ClashConfig.safeFormJson)  ClashConfig patchClashConfig,  ScriptProps scriptProps,  String nodeExcludeFilter,  int healthCheckTimeout)  $default,) {final _that = this;
switch (_that) {
case _Config():
return $default(_that.appSetting,_that.profiles,_that.hotKeyActions,_that.currentProfileId,_that.overrideDns,_that.overrideNtp,_that.overrideSniffer,_that.overrideTunnel,_that.overrideExperimental,_that.overrideTestUrl,_that.dav,_that.networkProps,_that.tailscaleProps,_that.vpnProps,_that.themeProps,_that.proxiesStyle,_that.windowProps,_that.patchClashConfig,_that.scriptProps,_that.nodeExcludeFilter,_that.healthCheckTimeout);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSetting,  List<Profile> profiles,  List<HotKeyAction> hotKeyActions,  String? currentProfileId,  bool overrideDns,  bool overrideNtp,  bool overrideSniffer,  bool overrideTunnel,  bool overrideExperimental,  bool overrideTestUrl,  DAV? dav,  NetworkProps networkProps, @JsonKey(fromJson: TailscaleProps.safeFromJson)  TailscaleProps tailscaleProps, @JsonKey(fromJson: VpnProps.safeFromJson)  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyle proxiesStyle,  WindowProps windowProps, @JsonKey(fromJson: ClashConfig.safeFormJson)  ClashConfig patchClashConfig,  ScriptProps scriptProps,  String nodeExcludeFilter,  int healthCheckTimeout)?  $default,) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.appSetting,_that.profiles,_that.hotKeyActions,_that.currentProfileId,_that.overrideDns,_that.overrideNtp,_that.overrideSniffer,_that.overrideTunnel,_that.overrideExperimental,_that.overrideTestUrl,_that.dav,_that.networkProps,_that.tailscaleProps,_that.vpnProps,_that.themeProps,_that.proxiesStyle,_that.windowProps,_that.patchClashConfig,_that.scriptProps,_that.nodeExcludeFilter,_that.healthCheckTimeout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Config implements Config {
  const _Config({@JsonKey(fromJson: AppSettingProps.safeFromJson) this.appSetting = defaultAppSettingProps,  List<Profile> profiles = const [],  List<HotKeyAction> hotKeyActions = const [], this.currentProfileId, this.overrideDns = false, this.overrideNtp = false, this.overrideSniffer = false, this.overrideTunnel = false, this.overrideExperimental = false, this.overrideTestUrl = true, this.dav, this.networkProps = defaultNetworkProps, @JsonKey(fromJson: TailscaleProps.safeFromJson) this.tailscaleProps = defaultTailscaleProps, @JsonKey(fromJson: VpnProps.safeFromJson) this.vpnProps = defaultVpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson) required this.themeProps, this.proxiesStyle = defaultProxiesStyle, this.windowProps = defaultWindowProps, @JsonKey(fromJson: ClashConfig.safeFormJson) this.patchClashConfig = defaultClashConfig, this.scriptProps = const ScriptProps(), this.nodeExcludeFilter = '', this.healthCheckTimeout = 5000}): _profiles = profiles,_hotKeyActions = hotKeyActions;
  factory _Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

@override@JsonKey(fromJson: AppSettingProps.safeFromJson) final  AppSettingProps appSetting;
 final  List<Profile> _profiles;
@override@JsonKey() List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

 final  List<HotKeyAction> _hotKeyActions;
@override@JsonKey() List<HotKeyAction> get hotKeyActions {
  if (_hotKeyActions is EqualUnmodifiableListView) return _hotKeyActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hotKeyActions);
}

@override final  String? currentProfileId;
@override@JsonKey() final  bool overrideDns;
@override@JsonKey() final  bool overrideNtp;
@override@JsonKey() final  bool overrideSniffer;
@override@JsonKey() final  bool overrideTunnel;
@override@JsonKey() final  bool overrideExperimental;
@override@JsonKey() final  bool overrideTestUrl;
@override final  DAV? dav;
@override@JsonKey() final  NetworkProps networkProps;
@override@JsonKey(fromJson: TailscaleProps.safeFromJson) final  TailscaleProps tailscaleProps;
@override@JsonKey(fromJson: VpnProps.safeFromJson) final  VpnProps vpnProps;
@override@JsonKey(fromJson: ThemeProps.safeFromJson) final  ThemeProps themeProps;
@override@JsonKey() final  ProxiesStyle proxiesStyle;
@override@JsonKey() final  WindowProps windowProps;
@override@JsonKey(fromJson: ClashConfig.safeFormJson) final  ClashConfig patchClashConfig;
@override@JsonKey() final  ScriptProps scriptProps;
@override@JsonKey() final  String nodeExcludeFilter;
@override@JsonKey() final  int healthCheckTimeout;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigCopyWith<_Config> get copyWith => __$ConfigCopyWithImpl<_Config>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Config&&(identical(other.appSetting, appSetting) || other.appSetting == appSetting)&&const DeepCollectionEquality().equals(other.profiles, _profiles)&&const DeepCollectionEquality().equals(other.hotKeyActions, _hotKeyActions)&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.overrideNtp, overrideNtp) || other.overrideNtp == overrideNtp)&&(identical(other.overrideSniffer, overrideSniffer) || other.overrideSniffer == overrideSniffer)&&(identical(other.overrideTunnel, overrideTunnel) || other.overrideTunnel == overrideTunnel)&&(identical(other.overrideExperimental, overrideExperimental) || other.overrideExperimental == overrideExperimental)&&(identical(other.overrideTestUrl, overrideTestUrl) || other.overrideTestUrl == overrideTestUrl)&&(identical(other.dav, dav) || other.dav == dav)&&(identical(other.networkProps, networkProps) || other.networkProps == networkProps)&&(identical(other.tailscaleProps, tailscaleProps) || other.tailscaleProps == tailscaleProps)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps)&&(identical(other.themeProps, themeProps) || other.themeProps == themeProps)&&(identical(other.proxiesStyle, proxiesStyle) || other.proxiesStyle == proxiesStyle)&&(identical(other.windowProps, windowProps) || other.windowProps == windowProps)&&(identical(other.patchClashConfig, patchClashConfig) || other.patchClashConfig == patchClashConfig)&&(identical(other.scriptProps, scriptProps) || other.scriptProps == scriptProps)&&(identical(other.nodeExcludeFilter, nodeExcludeFilter) || other.nodeExcludeFilter == nodeExcludeFilter)&&(identical(other.healthCheckTimeout, healthCheckTimeout) || other.healthCheckTimeout == healthCheckTimeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,appSetting,const DeepCollectionEquality().hash(_profiles),const DeepCollectionEquality().hash(_hotKeyActions),currentProfileId,overrideDns,overrideNtp,overrideSniffer,overrideTunnel,overrideExperimental,overrideTestUrl,dav,networkProps,tailscaleProps,vpnProps,themeProps,proxiesStyle,windowProps,patchClashConfig,scriptProps,nodeExcludeFilter,healthCheckTimeout]);
}

@override
String toString() {
    return 'Config(appSetting: $appSetting, profiles: $profiles, hotKeyActions: $hotKeyActions, currentProfileId: $currentProfileId, overrideDns: $overrideDns, overrideNtp: $overrideNtp, overrideSniffer: $overrideSniffer, overrideTunnel: $overrideTunnel, overrideExperimental: $overrideExperimental, overrideTestUrl: $overrideTestUrl, dav: $dav, networkProps: $networkProps, tailscaleProps: $tailscaleProps, vpnProps: $vpnProps, themeProps: $themeProps, proxiesStyle: $proxiesStyle, windowProps: $windowProps, patchClashConfig: $patchClashConfig, scriptProps: $scriptProps, nodeExcludeFilter: $nodeExcludeFilter, healthCheckTimeout: $healthCheckTimeout)';
}


}

/// @nodoc
abstract mixin class _$ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$ConfigCopyWith(_Config value, $Res Function(_Config) _then) = __$ConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps appSetting, List<Profile> profiles, List<HotKeyAction> hotKeyActions, String? currentProfileId, bool overrideDns, bool overrideNtp, bool overrideSniffer, bool overrideTunnel, bool overrideExperimental, bool overrideTestUrl, DAV? dav, NetworkProps networkProps,@JsonKey(fromJson: TailscaleProps.safeFromJson) TailscaleProps tailscaleProps,@JsonKey(fromJson: VpnProps.safeFromJson) VpnProps vpnProps,@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps, ProxiesStyle proxiesStyle, WindowProps windowProps,@JsonKey(fromJson: ClashConfig.safeFormJson) ClashConfig patchClashConfig, ScriptProps scriptProps, String nodeExcludeFilter, int healthCheckTimeout
});


@override $AppSettingPropsCopyWith<$Res> get appSetting;@override $DAVCopyWith<$Res>? get dav;@override $NetworkPropsCopyWith<$Res> get networkProps;@override $TailscalePropsCopyWith<$Res> get tailscaleProps;@override $VpnPropsCopyWith<$Res> get vpnProps;@override $ThemePropsCopyWith<$Res> get themeProps;@override $ProxiesStyleCopyWith<$Res> get proxiesStyle;@override $WindowPropsCopyWith<$Res> get windowProps;@override $ClashConfigCopyWith<$Res> get patchClashConfig;@override $ScriptPropsCopyWith<$Res> get scriptProps;

}
/// @nodoc
class __$ConfigCopyWithImpl<$Res>
    implements _$ConfigCopyWith<$Res> {
  __$ConfigCopyWithImpl(this._self, this._then);

  final _Config _self;
  final $Res Function(_Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appSetting = null,Object? profiles = null,Object? hotKeyActions = null,Object? currentProfileId = freezed,Object? overrideDns = null,Object? overrideNtp = null,Object? overrideSniffer = null,Object? overrideTunnel = null,Object? overrideExperimental = null,Object? overrideTestUrl = null,Object? dav = freezed,Object? networkProps = null,Object? tailscaleProps = null,Object? vpnProps = null,Object? themeProps = null,Object? proxiesStyle = null,Object? windowProps = null,Object? patchClashConfig = null,Object? scriptProps = null,Object? nodeExcludeFilter = null,Object? healthCheckTimeout = null,}) {
  return _then(_Config(
appSetting: null == appSetting ? _self.appSetting : appSetting // ignore: cast_nullable_to_non_nullable
as AppSettingProps,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,hotKeyActions: null == hotKeyActions ? _self._hotKeyActions : hotKeyActions // ignore: cast_nullable_to_non_nullable
as List<HotKeyAction>,currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as String?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,overrideNtp: null == overrideNtp ? _self.overrideNtp : overrideNtp // ignore: cast_nullable_to_non_nullable
as bool,overrideSniffer: null == overrideSniffer ? _self.overrideSniffer : overrideSniffer // ignore: cast_nullable_to_non_nullable
as bool,overrideTunnel: null == overrideTunnel ? _self.overrideTunnel : overrideTunnel // ignore: cast_nullable_to_non_nullable
as bool,overrideExperimental: null == overrideExperimental ? _self.overrideExperimental : overrideExperimental // ignore: cast_nullable_to_non_nullable
as bool,overrideTestUrl: null == overrideTestUrl ? _self.overrideTestUrl : overrideTestUrl // ignore: cast_nullable_to_non_nullable
as bool,dav: freezed == dav ? _self.dav : dav // ignore: cast_nullable_to_non_nullable
as DAV?,networkProps: null == networkProps ? _self.networkProps : networkProps // ignore: cast_nullable_to_non_nullable
as NetworkProps,tailscaleProps: null == tailscaleProps ? _self.tailscaleProps : tailscaleProps // ignore: cast_nullable_to_non_nullable
as TailscaleProps,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,themeProps: null == themeProps ? _self.themeProps : themeProps // ignore: cast_nullable_to_non_nullable
as ThemeProps,proxiesStyle: null == proxiesStyle ? _self.proxiesStyle : proxiesStyle // ignore: cast_nullable_to_non_nullable
as ProxiesStyle,windowProps: null == windowProps ? _self.windowProps : windowProps // ignore: cast_nullable_to_non_nullable
as WindowProps,patchClashConfig: null == patchClashConfig ? _self.patchClashConfig : patchClashConfig // ignore: cast_nullable_to_non_nullable
as ClashConfig,scriptProps: null == scriptProps ? _self.scriptProps : scriptProps // ignore: cast_nullable_to_non_nullable
as ScriptProps,nodeExcludeFilter: null == nodeExcludeFilter ? _self.nodeExcludeFilter : nodeExcludeFilter // ignore: cast_nullable_to_non_nullable
as String,healthCheckTimeout: null == healthCheckTimeout ? _self.healthCheckTimeout : healthCheckTimeout // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<$Res> get appSetting {
  
  return $AppSettingPropsCopyWith<$Res>(_self.appSetting, (value) {
    return _then(_self.copyWith(appSetting: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DAVCopyWith<$Res>? get dav {
    if (_self.dav == null) {
    return null;
  }

  return $DAVCopyWith<$Res>(_self.dav!, (value) {
    return _then(_self.copyWith(dav: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<$Res> get networkProps {
  
  return $NetworkPropsCopyWith<$Res>(_self.networkProps, (value) {
    return _then(_self.copyWith(networkProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TailscalePropsCopyWith<$Res> get tailscaleProps {
  
  return $TailscalePropsCopyWith<$Res>(_self.tailscaleProps, (value) {
    return _then(_self.copyWith(tailscaleProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<$Res> get themeProps {
  
  return $ThemePropsCopyWith<$Res>(_self.themeProps, (value) {
    return _then(_self.copyWith(themeProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesStyleCopyWith<$Res> get proxiesStyle {
  
  return $ProxiesStyleCopyWith<$Res>(_self.proxiesStyle, (value) {
    return _then(_self.copyWith(proxiesStyle: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<$Res> get windowProps {
  
  return $WindowPropsCopyWith<$Res>(_self.windowProps, (value) {
    return _then(_self.copyWith(windowProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<$Res> get patchClashConfig {
  
  return $ClashConfigCopyWith<$Res>(_self.patchClashConfig, (value) {
    return _then(_self.copyWith(patchClashConfig: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptPropsCopyWith<$Res> get scriptProps {
  
  return $ScriptPropsCopyWith<$Res>(_self.scriptProps, (value) {
    return _then(_self.copyWith(scriptProps: value));
  });
}
}

// dart format on
