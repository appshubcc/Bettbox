// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionInfo {

 int get upload; int get download; int get total; int get expire;
/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<SubscriptionInfo> get copyWith => _$SubscriptionInfoCopyWithImpl<SubscriptionInfo>(this as SubscriptionInfo, _$identity);

  /// Serializes this SubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionInfo&&(identical(other.upload, _this.upload) || other.upload == _this.upload)&&(identical(other.download, _this.download) || other.download == _this.download)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.expire, _this.expire) || other.expire == _this.expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionInfo;
  return Object.hash(runtimeType,_this.upload,_this.download,_this.total,_this.expire);
}

@override
String toString() {
  final _this = this as SubscriptionInfo;
  return 'SubscriptionInfo(upload: ${_this.upload}, download: ${_this.download}, total: ${_this.total}, expire: ${_this.expire})';
}


}

/// @nodoc
abstract mixin class $SubscriptionInfoCopyWith<$Res>  {
  factory $SubscriptionInfoCopyWith(SubscriptionInfo value, $Res Function(SubscriptionInfo) _then) = _$SubscriptionInfoCopyWithImpl;
@useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class _$SubscriptionInfoCopyWithImpl<$Res>
    implements $SubscriptionInfoCopyWith<$Res> {
  _$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final SubscriptionInfo _self;
  final $Res Function(SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionInfo].
extension SubscriptionInfoPatterns on SubscriptionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionInfo value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo():
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int upload,  int download,  int total,  int expire)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionInfo implements SubscriptionInfo {
  const _SubscriptionInfo({this.upload = 0, this.download = 0, this.total = 0, this.expire = 0});
  factory _SubscriptionInfo.fromJson(Map<String, dynamic> json) => _$SubscriptionInfoFromJson(json);

@override@JsonKey() final  int upload;
@override@JsonKey() final  int download;
@override@JsonKey() final  int total;
@override@JsonKey() final  int expire;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionInfoCopyWith<_SubscriptionInfo> get copyWith => __$SubscriptionInfoCopyWithImpl<_SubscriptionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,upload,download,total,expire);
}

@override
String toString() {
    return 'SubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionInfoCopyWith<$Res> implements $SubscriptionInfoCopyWith<$Res> {
  factory _$SubscriptionInfoCopyWith(_SubscriptionInfo value, $Res Function(_SubscriptionInfo) _then) = __$SubscriptionInfoCopyWithImpl;
@override @useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class __$SubscriptionInfoCopyWithImpl<$Res>
    implements _$SubscriptionInfoCopyWith<$Res> {
  __$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final _SubscriptionInfo _self;
  final $Res Function(_SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(_SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Profile {

 String get id; String? get label; String? get currentGroupName; String get url; DateTime? get lastUpdateDate; Duration get autoUpdateDuration; SubscriptionInfo? get subscriptionInfo; Map<String, SubscriptionInfo> get providerSubscriptions; bool get autoUpdate; SelectedMap get selectedMap; Set<String> get unfoldSet; OverrideData get overrideData;@JsonKey(includeToJson: false, includeFromJson: false) bool get isUpdating; bool get useScriptOverride; String? get ageSecretKey;@JsonKey(name: 'group-switches') Map<String, bool> get groupSwitches; ProfileUsageStyle get usageStyle;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.currentGroupName, _this.currentGroupName) || other.currentGroupName == _this.currentGroupName)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.lastUpdateDate, _this.lastUpdateDate) || other.lastUpdateDate == _this.lastUpdateDate)&&(identical(other.autoUpdateDuration, _this.autoUpdateDuration) || other.autoUpdateDuration == _this.autoUpdateDuration)&&(identical(other.subscriptionInfo, _this.subscriptionInfo) || other.subscriptionInfo == _this.subscriptionInfo)&&const DeepCollectionEquality().equals(other.providerSubscriptions, _this.providerSubscriptions)&&(identical(other.autoUpdate, _this.autoUpdate) || other.autoUpdate == _this.autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _this.unfoldSet)&&(identical(other.overrideData, _this.overrideData) || other.overrideData == _this.overrideData)&&(identical(other.isUpdating, _this.isUpdating) || other.isUpdating == _this.isUpdating)&&(identical(other.useScriptOverride, _this.useScriptOverride) || other.useScriptOverride == _this.useScriptOverride)&&(identical(other.ageSecretKey, _this.ageSecretKey) || other.ageSecretKey == _this.ageSecretKey)&&const DeepCollectionEquality().equals(other.groupSwitches, _this.groupSwitches)&&(identical(other.usageStyle, _this.usageStyle) || other.usageStyle == _this.usageStyle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.id,_this.label,_this.currentGroupName,_this.url,_this.lastUpdateDate,_this.autoUpdateDuration,_this.subscriptionInfo,const DeepCollectionEquality().hash(_this.providerSubscriptions),_this.autoUpdate,const DeepCollectionEquality().hash(_this.selectedMap),const DeepCollectionEquality().hash(_this.unfoldSet),_this.overrideData,_this.isUpdating,_this.useScriptOverride,_this.ageSecretKey,const DeepCollectionEquality().hash(_this.groupSwitches),_this.usageStyle);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, label: ${_this.label}, currentGroupName: ${_this.currentGroupName}, url: ${_this.url}, lastUpdateDate: ${_this.lastUpdateDate}, autoUpdateDuration: ${_this.autoUpdateDuration}, subscriptionInfo: ${_this.subscriptionInfo}, providerSubscriptions: ${_this.providerSubscriptions}, autoUpdate: ${_this.autoUpdate}, selectedMap: ${_this.selectedMap}, unfoldSet: ${_this.unfoldSet}, overrideData: ${_this.overrideData}, isUpdating: ${_this.isUpdating}, useScriptOverride: ${_this.useScriptOverride}, ageSecretKey: ${_this.ageSecretKey}, groupSwitches: ${_this.groupSwitches}, usageStyle: ${_this.usageStyle})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, Map<String, SubscriptionInfo> providerSubscriptions, bool autoUpdate, SelectedMap selectedMap, Set<String> unfoldSet, OverrideData overrideData,@JsonKey(includeToJson: false, includeFromJson: false) bool isUpdating, bool useScriptOverride, String? ageSecretKey,@JsonKey(name: 'group-switches') Map<String, bool> groupSwitches, ProfileUsageStyle usageStyle
});


$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;$OverrideDataCopyWith<$Res> get overrideData;

}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? providerSubscriptions = null,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? overrideData = null,Object? isUpdating = null,Object? useScriptOverride = null,Object? ageSecretKey = freezed,Object? groupSwitches = null,Object? usageStyle = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,providerSubscriptions: null == providerSubscriptions ? _self.providerSubscriptions : providerSubscriptions // ignore: cast_nullable_to_non_nullable
as Map<String, SubscriptionInfo>,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as SelectedMap,unfoldSet: null == unfoldSet ? _self.unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,overrideData: null == overrideData ? _self.overrideData : overrideData // ignore: cast_nullable_to_non_nullable
as OverrideData,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,useScriptOverride: null == useScriptOverride ? _self.useScriptOverride : useScriptOverride // ignore: cast_nullable_to_non_nullable
as bool,ageSecretKey: freezed == ageSecretKey ? _self.ageSecretKey : ageSecretKey // ignore: cast_nullable_to_non_nullable
as String?,groupSwitches: null == groupSwitches ? _self.groupSwitches : groupSwitches // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,usageStyle: null == usageStyle ? _self.usageStyle : usageStyle // ignore: cast_nullable_to_non_nullable
as ProfileUsageStyle,
  ));
}
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<$Res> get overrideData {
  
  return $OverrideDataCopyWith<$Res>(_self.overrideData, (value) {
    return _then(_self.copyWith(overrideData: value));
  });
}
}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  Map<String, SubscriptionInfo> providerSubscriptions,  bool autoUpdate,  SelectedMap selectedMap,  Set<String> unfoldSet,  OverrideData overrideData, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating,  bool useScriptOverride,  String? ageSecretKey, @JsonKey(name: 'group-switches')  Map<String, bool> groupSwitches,  ProfileUsageStyle usageStyle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.providerSubscriptions,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.isUpdating,_that.useScriptOverride,_that.ageSecretKey,_that.groupSwitches,_that.usageStyle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  Map<String, SubscriptionInfo> providerSubscriptions,  bool autoUpdate,  SelectedMap selectedMap,  Set<String> unfoldSet,  OverrideData overrideData, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating,  bool useScriptOverride,  String? ageSecretKey, @JsonKey(name: 'group-switches')  Map<String, bool> groupSwitches,  ProfileUsageStyle usageStyle)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.providerSubscriptions,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.isUpdating,_that.useScriptOverride,_that.ageSecretKey,_that.groupSwitches,_that.usageStyle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  Map<String, SubscriptionInfo> providerSubscriptions,  bool autoUpdate,  SelectedMap selectedMap,  Set<String> unfoldSet,  OverrideData overrideData, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating,  bool useScriptOverride,  String? ageSecretKey, @JsonKey(name: 'group-switches')  Map<String, bool> groupSwitches,  ProfileUsageStyle usageStyle)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.providerSubscriptions,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.isUpdating,_that.useScriptOverride,_that.ageSecretKey,_that.groupSwitches,_that.usageStyle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, this.label, this.currentGroupName, this.url = '', this.lastUpdateDate, required this.autoUpdateDuration, this.subscriptionInfo,  Map<String, SubscriptionInfo> providerSubscriptions = const {}, this.autoUpdate = true,  SelectedMap selectedMap = const {},  Set<String> unfoldSet = const {}, this.overrideData = const OverrideData(), @JsonKey(includeToJson: false, includeFromJson: false) this.isUpdating = false, this.useScriptOverride = true, this.ageSecretKey, @JsonKey(name: 'group-switches')  Map<String, bool> groupSwitches = const {}, this.usageStyle = ProfileUsageStyle.bar}): _providerSubscriptions = providerSubscriptions,_selectedMap = selectedMap,_unfoldSet = unfoldSet,_groupSwitches = groupSwitches;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String? label;
@override final  String? currentGroupName;
@override@JsonKey() final  String url;
@override final  DateTime? lastUpdateDate;
@override final  Duration autoUpdateDuration;
@override final  SubscriptionInfo? subscriptionInfo;
 final  Map<String, SubscriptionInfo> _providerSubscriptions;
@override@JsonKey() Map<String, SubscriptionInfo> get providerSubscriptions {
  if (_providerSubscriptions is EqualUnmodifiableMapView) return _providerSubscriptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_providerSubscriptions);
}

@override@JsonKey() final  bool autoUpdate;
 final  SelectedMap _selectedMap;
@override@JsonKey() SelectedMap get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

 final  Set<String> _unfoldSet;
@override@JsonKey() Set<String> get unfoldSet {
  if (_unfoldSet is EqualUnmodifiableSetView) return _unfoldSet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unfoldSet);
}

@override@JsonKey() final  OverrideData overrideData;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isUpdating;
@override@JsonKey() final  bool useScriptOverride;
@override final  String? ageSecretKey;
 final  Map<String, bool> _groupSwitches;
@override@JsonKey(name: 'group-switches') Map<String, bool> get groupSwitches {
  if (_groupSwitches is EqualUnmodifiableMapView) return _groupSwitches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupSwitches);
}

@override@JsonKey() final  ProfileUsageStyle usageStyle;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.url, url) || other.url == url)&&(identical(other.lastUpdateDate, lastUpdateDate) || other.lastUpdateDate == lastUpdateDate)&&(identical(other.autoUpdateDuration, autoUpdateDuration) || other.autoUpdateDuration == autoUpdateDuration)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&const DeepCollectionEquality().equals(other.providerSubscriptions, _providerSubscriptions)&&(identical(other.autoUpdate, autoUpdate) || other.autoUpdate == autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _unfoldSet)&&(identical(other.overrideData, overrideData) || other.overrideData == overrideData)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.useScriptOverride, useScriptOverride) || other.useScriptOverride == useScriptOverride)&&(identical(other.ageSecretKey, ageSecretKey) || other.ageSecretKey == ageSecretKey)&&const DeepCollectionEquality().equals(other.groupSwitches, _groupSwitches)&&(identical(other.usageStyle, usageStyle) || other.usageStyle == usageStyle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,currentGroupName,url,lastUpdateDate,autoUpdateDuration,subscriptionInfo,const DeepCollectionEquality().hash(_providerSubscriptions),autoUpdate,const DeepCollectionEquality().hash(_selectedMap),const DeepCollectionEquality().hash(_unfoldSet),overrideData,isUpdating,useScriptOverride,ageSecretKey,const DeepCollectionEquality().hash(_groupSwitches),usageStyle);
}

@override
String toString() {
    return 'Profile(id: $id, label: $label, currentGroupName: $currentGroupName, url: $url, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, subscriptionInfo: $subscriptionInfo, providerSubscriptions: $providerSubscriptions, autoUpdate: $autoUpdate, selectedMap: $selectedMap, unfoldSet: $unfoldSet, overrideData: $overrideData, isUpdating: $isUpdating, useScriptOverride: $useScriptOverride, ageSecretKey: $ageSecretKey, groupSwitches: $groupSwitches, usageStyle: $usageStyle)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, Map<String, SubscriptionInfo> providerSubscriptions, bool autoUpdate, SelectedMap selectedMap, Set<String> unfoldSet, OverrideData overrideData,@JsonKey(includeToJson: false, includeFromJson: false) bool isUpdating, bool useScriptOverride, String? ageSecretKey,@JsonKey(name: 'group-switches') Map<String, bool> groupSwitches, ProfileUsageStyle usageStyle
});


@override $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;@override $OverrideDataCopyWith<$Res> get overrideData;

}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? providerSubscriptions = null,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? overrideData = null,Object? isUpdating = null,Object? useScriptOverride = null,Object? ageSecretKey = freezed,Object? groupSwitches = null,Object? usageStyle = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,providerSubscriptions: null == providerSubscriptions ? _self._providerSubscriptions : providerSubscriptions // ignore: cast_nullable_to_non_nullable
as Map<String, SubscriptionInfo>,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as SelectedMap,unfoldSet: null == unfoldSet ? _self._unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,overrideData: null == overrideData ? _self.overrideData : overrideData // ignore: cast_nullable_to_non_nullable
as OverrideData,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,useScriptOverride: null == useScriptOverride ? _self.useScriptOverride : useScriptOverride // ignore: cast_nullable_to_non_nullable
as bool,ageSecretKey: freezed == ageSecretKey ? _self.ageSecretKey : ageSecretKey // ignore: cast_nullable_to_non_nullable
as String?,groupSwitches: null == groupSwitches ? _self._groupSwitches : groupSwitches // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,usageStyle: null == usageStyle ? _self.usageStyle : usageStyle // ignore: cast_nullable_to_non_nullable
as ProfileUsageStyle,
  ));
}

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<$Res> get overrideData {
  
  return $OverrideDataCopyWith<$Res>(_self.overrideData, (value) {
    return _then(_self.copyWith(overrideData: value));
  });
}
}


/// @nodoc
mixin _$OverrideData {

 bool get enable; OverrideRule get rule;
/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<OverrideData> get copyWith => _$OverrideDataCopyWithImpl<OverrideData>(this as OverrideData, _$identity);

  /// Serializes this OverrideData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OverrideData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverrideData&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.rule, _this.rule) || other.rule == _this.rule));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OverrideData;
  return Object.hash(runtimeType,_this.enable,_this.rule);
}

@override
String toString() {
  final _this = this as OverrideData;
  return 'OverrideData(enable: ${_this.enable}, rule: ${_this.rule})';
}


}

/// @nodoc
abstract mixin class $OverrideDataCopyWith<$Res>  {
  factory $OverrideDataCopyWith(OverrideData value, $Res Function(OverrideData) _then) = _$OverrideDataCopyWithImpl;
@useResult
$Res call({
 bool enable, OverrideRule rule
});


$OverrideRuleCopyWith<$Res> get rule;

}
/// @nodoc
class _$OverrideDataCopyWithImpl<$Res>
    implements $OverrideDataCopyWith<$Res> {
  _$OverrideDataCopyWithImpl(this._self, this._then);

  final OverrideData _self;
  final $Res Function(OverrideData) _then;

/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? rule = null,}) {
  return _then(OverrideData(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as OverrideRule,
  ));
}
/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideRuleCopyWith<$Res> get rule {
  
  return $OverrideRuleCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}
}


/// Adds pattern-matching-related methods to [OverrideData].
extension OverrideDataPatterns on OverrideData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverrideData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverrideData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverrideData value)  $default,){
final _that = this;
switch (_that) {
case _OverrideData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverrideData value)?  $default,){
final _that = this;
switch (_that) {
case _OverrideData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  OverrideRule rule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverrideData() when $default != null:
return $default(_that.enable,_that.rule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  OverrideRule rule)  $default,) {final _that = this;
switch (_that) {
case _OverrideData():
return $default(_that.enable,_that.rule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  OverrideRule rule)?  $default,) {final _that = this;
switch (_that) {
case _OverrideData() when $default != null:
return $default(_that.enable,_that.rule);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverrideData implements OverrideData {
  const _OverrideData({this.enable = false, this.rule = const OverrideRule()});
  factory _OverrideData.fromJson(Map<String, dynamic> json) => _$OverrideDataFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  OverrideRule rule;

/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverrideDataCopyWith<_OverrideData> get copyWith => __$OverrideDataCopyWithImpl<_OverrideData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverrideDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverrideData&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.rule, rule) || other.rule == rule));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,rule);
}

@override
String toString() {
    return 'OverrideData(enable: $enable, rule: $rule)';
}


}

/// @nodoc
abstract mixin class _$OverrideDataCopyWith<$Res> implements $OverrideDataCopyWith<$Res> {
  factory _$OverrideDataCopyWith(_OverrideData value, $Res Function(_OverrideData) _then) = __$OverrideDataCopyWithImpl;
@override @useResult
$Res call({
 bool enable, OverrideRule rule
});


@override $OverrideRuleCopyWith<$Res> get rule;

}
/// @nodoc
class __$OverrideDataCopyWithImpl<$Res>
    implements _$OverrideDataCopyWith<$Res> {
  __$OverrideDataCopyWithImpl(this._self, this._then);

  final _OverrideData _self;
  final $Res Function(_OverrideData) _then;

/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? rule = null,}) {
  return _then(_OverrideData(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as OverrideRule,
  ));
}

/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideRuleCopyWith<$Res> get rule {
  
  return $OverrideRuleCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}
}


/// @nodoc
mixin _$OverrideRule {

 OverrideRuleType get type; List<Rule> get overrideRules; List<Rule> get addedRules;
/// Create a copy of OverrideRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverrideRuleCopyWith<OverrideRule> get copyWith => _$OverrideRuleCopyWithImpl<OverrideRule>(this as OverrideRule, _$identity);

  /// Serializes this OverrideRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OverrideRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverrideRule&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.overrideRules, _this.overrideRules)&&const DeepCollectionEquality().equals(other.addedRules, _this.addedRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OverrideRule;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.overrideRules),const DeepCollectionEquality().hash(_this.addedRules));
}

@override
String toString() {
  final _this = this as OverrideRule;
  return 'OverrideRule(type: ${_this.type}, overrideRules: ${_this.overrideRules}, addedRules: ${_this.addedRules})';
}


}

/// @nodoc
abstract mixin class $OverrideRuleCopyWith<$Res>  {
  factory $OverrideRuleCopyWith(OverrideRule value, $Res Function(OverrideRule) _then) = _$OverrideRuleCopyWithImpl;
@useResult
$Res call({
 OverrideRuleType type, List<Rule> overrideRules, List<Rule> addedRules
});




}
/// @nodoc
class _$OverrideRuleCopyWithImpl<$Res>
    implements $OverrideRuleCopyWith<$Res> {
  _$OverrideRuleCopyWithImpl(this._self, this._then);

  final OverrideRule _self;
  final $Res Function(OverrideRule) _then;

/// Create a copy of OverrideRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? overrideRules = null,Object? addedRules = null,}) {
  return _then(OverrideRule(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OverrideRuleType,overrideRules: null == overrideRules ? _self.overrideRules : overrideRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,
  ));
}

}


/// Adds pattern-matching-related methods to [OverrideRule].
extension OverrideRulePatterns on OverrideRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverrideRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverrideRule value)  $default,){
final _that = this;
switch (_that) {
case _OverrideRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverrideRule value)?  $default,){
final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OverrideRuleType type,  List<Rule> overrideRules,  List<Rule> addedRules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
return $default(_that.type,_that.overrideRules,_that.addedRules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OverrideRuleType type,  List<Rule> overrideRules,  List<Rule> addedRules)  $default,) {final _that = this;
switch (_that) {
case _OverrideRule():
return $default(_that.type,_that.overrideRules,_that.addedRules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OverrideRuleType type,  List<Rule> overrideRules,  List<Rule> addedRules)?  $default,) {final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
return $default(_that.type,_that.overrideRules,_that.addedRules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverrideRule implements OverrideRule {
  const _OverrideRule({this.type = OverrideRuleType.added,  List<Rule> overrideRules = const [],  List<Rule> addedRules = const []}): _overrideRules = overrideRules,_addedRules = addedRules;
  factory _OverrideRule.fromJson(Map<String, dynamic> json) => _$OverrideRuleFromJson(json);

@override@JsonKey() final  OverrideRuleType type;
 final  List<Rule> _overrideRules;
@override@JsonKey() List<Rule> get overrideRules {
  if (_overrideRules is EqualUnmodifiableListView) return _overrideRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_overrideRules);
}

 final  List<Rule> _addedRules;
@override@JsonKey() List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}


/// Create a copy of OverrideRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverrideRuleCopyWith<_OverrideRule> get copyWith => __$OverrideRuleCopyWithImpl<_OverrideRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverrideRuleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverrideRule&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.overrideRules, _overrideRules)&&const DeepCollectionEquality().equals(other.addedRules, _addedRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_overrideRules),const DeepCollectionEquality().hash(_addedRules));
}

@override
String toString() {
    return 'OverrideRule(type: $type, overrideRules: $overrideRules, addedRules: $addedRules)';
}


}

/// @nodoc
abstract mixin class _$OverrideRuleCopyWith<$Res> implements $OverrideRuleCopyWith<$Res> {
  factory _$OverrideRuleCopyWith(_OverrideRule value, $Res Function(_OverrideRule) _then) = __$OverrideRuleCopyWithImpl;
@override @useResult
$Res call({
 OverrideRuleType type, List<Rule> overrideRules, List<Rule> addedRules
});




}
/// @nodoc
class __$OverrideRuleCopyWithImpl<$Res>
    implements _$OverrideRuleCopyWith<$Res> {
  __$OverrideRuleCopyWithImpl(this._self, this._then);

  final _OverrideRule _self;
  final $Res Function(_OverrideRule) _then;

/// Create a copy of OverrideRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? overrideRules = null,Object? addedRules = null,}) {
  return _then(_OverrideRule(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OverrideRuleType,overrideRules: null == overrideRules ? _self._overrideRules : overrideRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,
  ));
}


}

// dart format on
