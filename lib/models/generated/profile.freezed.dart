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

 String get id; String? get label; String? get currentGroupName; String get url; DateTime? get lastUpdateDate; Duration get autoUpdateDuration; SubscriptionInfo? get subscriptionInfo; Map<String, SubscriptionInfo> get providerSubscriptions; bool get autoUpdate; SelectedMap get selectedMap; Set<String> get unfoldSet; OverrideData get overrideData;@JsonKey(includeToJson: false, includeFromJson: false) bool get isUpdating; String? get scriptId; bool get managed; bool get managedStyleApplied; String? get ageSecretKey;@JsonKey(name: 'group-switches') Map<String, bool> get groupSwitches; ProfileUsageStyle get usageStyle; ProfileBundle? get bundle;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.currentGroupName, _this.currentGroupName) || other.currentGroupName == _this.currentGroupName)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.lastUpdateDate, _this.lastUpdateDate) || other.lastUpdateDate == _this.lastUpdateDate)&&(identical(other.autoUpdateDuration, _this.autoUpdateDuration) || other.autoUpdateDuration == _this.autoUpdateDuration)&&(identical(other.subscriptionInfo, _this.subscriptionInfo) || other.subscriptionInfo == _this.subscriptionInfo)&&const DeepCollectionEquality().equals(other.providerSubscriptions, _this.providerSubscriptions)&&(identical(other.autoUpdate, _this.autoUpdate) || other.autoUpdate == _this.autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _this.unfoldSet)&&(identical(other.overrideData, _this.overrideData) || other.overrideData == _this.overrideData)&&(identical(other.isUpdating, _this.isUpdating) || other.isUpdating == _this.isUpdating)&&(identical(other.scriptId, _this.scriptId) || other.scriptId == _this.scriptId)&&(identical(other.managed, _this.managed) || other.managed == _this.managed)&&(identical(other.managedStyleApplied, _this.managedStyleApplied) || other.managedStyleApplied == _this.managedStyleApplied)&&(identical(other.ageSecretKey, _this.ageSecretKey) || other.ageSecretKey == _this.ageSecretKey)&&const DeepCollectionEquality().equals(other.groupSwitches, _this.groupSwitches)&&(identical(other.usageStyle, _this.usageStyle) || other.usageStyle == _this.usageStyle)&&(identical(other.bundle, _this.bundle) || other.bundle == _this.bundle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hashAll([runtimeType,_this.id,_this.label,_this.currentGroupName,_this.url,_this.lastUpdateDate,_this.autoUpdateDuration,_this.subscriptionInfo,const DeepCollectionEquality().hash(_this.providerSubscriptions),_this.autoUpdate,const DeepCollectionEquality().hash(_this.selectedMap),const DeepCollectionEquality().hash(_this.unfoldSet),_this.overrideData,_this.isUpdating,_this.scriptId,_this.managed,_this.managedStyleApplied,_this.ageSecretKey,const DeepCollectionEquality().hash(_this.groupSwitches),_this.usageStyle,_this.bundle]);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, label: ${_this.label}, currentGroupName: ${_this.currentGroupName}, url: ${_this.url}, lastUpdateDate: ${_this.lastUpdateDate}, autoUpdateDuration: ${_this.autoUpdateDuration}, subscriptionInfo: ${_this.subscriptionInfo}, providerSubscriptions: ${_this.providerSubscriptions}, autoUpdate: ${_this.autoUpdate}, selectedMap: ${_this.selectedMap}, unfoldSet: ${_this.unfoldSet}, overrideData: ${_this.overrideData}, isUpdating: ${_this.isUpdating}, scriptId: ${_this.scriptId}, managed: ${_this.managed}, managedStyleApplied: ${_this.managedStyleApplied}, ageSecretKey: ${_this.ageSecretKey}, groupSwitches: ${_this.groupSwitches}, usageStyle: ${_this.usageStyle}, bundle: ${_this.bundle})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, Map<String, SubscriptionInfo> providerSubscriptions, bool autoUpdate, SelectedMap selectedMap, Set<String> unfoldSet, OverrideData overrideData,@JsonKey(includeToJson: false, includeFromJson: false) bool isUpdating, String? scriptId, bool managed, bool managedStyleApplied, String? ageSecretKey,@JsonKey(name: 'group-switches') Map<String, bool> groupSwitches, ProfileUsageStyle usageStyle, ProfileBundle? bundle
});


$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;$OverrideDataCopyWith<$Res> get overrideData;$ProfileBundleCopyWith<$Res>? get bundle;

}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? providerSubscriptions = null,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? overrideData = null,Object? isUpdating = null,Object? scriptId = freezed,Object? managed = null,Object? managedStyleApplied = null,Object? ageSecretKey = freezed,Object? groupSwitches = null,Object? usageStyle = null,Object? bundle = freezed,}) {
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
as bool,scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as String?,managed: null == managed ? _self.managed : managed // ignore: cast_nullable_to_non_nullable
as bool,managedStyleApplied: null == managedStyleApplied ? _self.managedStyleApplied : managedStyleApplied // ignore: cast_nullable_to_non_nullable
as bool,ageSecretKey: freezed == ageSecretKey ? _self.ageSecretKey : ageSecretKey // ignore: cast_nullable_to_non_nullable
as String?,groupSwitches: null == groupSwitches ? _self.groupSwitches : groupSwitches // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,usageStyle: null == usageStyle ? _self.usageStyle : usageStyle // ignore: cast_nullable_to_non_nullable
as ProfileUsageStyle,bundle: freezed == bundle ? _self.bundle : bundle // ignore: cast_nullable_to_non_nullable
as ProfileBundle?,
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
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileBundleCopyWith<$Res>? get bundle {
    if (_self.bundle == null) {
    return null;
  }

  return $ProfileBundleCopyWith<$Res>(_self.bundle!, (value) {
    return _then(_self.copyWith(bundle: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  Map<String, SubscriptionInfo> providerSubscriptions,  bool autoUpdate,  SelectedMap selectedMap,  Set<String> unfoldSet,  OverrideData overrideData, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating,  String? scriptId,  bool managed,  bool managedStyleApplied,  String? ageSecretKey, @JsonKey(name: 'group-switches')  Map<String, bool> groupSwitches,  ProfileUsageStyle usageStyle,  ProfileBundle? bundle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.providerSubscriptions,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.isUpdating,_that.scriptId,_that.managed,_that.managedStyleApplied,_that.ageSecretKey,_that.groupSwitches,_that.usageStyle,_that.bundle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  Map<String, SubscriptionInfo> providerSubscriptions,  bool autoUpdate,  SelectedMap selectedMap,  Set<String> unfoldSet,  OverrideData overrideData, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating,  String? scriptId,  bool managed,  bool managedStyleApplied,  String? ageSecretKey, @JsonKey(name: 'group-switches')  Map<String, bool> groupSwitches,  ProfileUsageStyle usageStyle,  ProfileBundle? bundle)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.providerSubscriptions,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.isUpdating,_that.scriptId,_that.managed,_that.managedStyleApplied,_that.ageSecretKey,_that.groupSwitches,_that.usageStyle,_that.bundle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  Map<String, SubscriptionInfo> providerSubscriptions,  bool autoUpdate,  SelectedMap selectedMap,  Set<String> unfoldSet,  OverrideData overrideData, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating,  String? scriptId,  bool managed,  bool managedStyleApplied,  String? ageSecretKey, @JsonKey(name: 'group-switches')  Map<String, bool> groupSwitches,  ProfileUsageStyle usageStyle,  ProfileBundle? bundle)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.providerSubscriptions,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.isUpdating,_that.scriptId,_that.managed,_that.managedStyleApplied,_that.ageSecretKey,_that.groupSwitches,_that.usageStyle,_that.bundle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, this.label, this.currentGroupName, this.url = '', this.lastUpdateDate, required this.autoUpdateDuration, this.subscriptionInfo,  Map<String, SubscriptionInfo> providerSubscriptions = const {}, this.autoUpdate = true,  SelectedMap selectedMap = const {},  Set<String> unfoldSet = const {}, this.overrideData = const OverrideData(), @JsonKey(includeToJson: false, includeFromJson: false) this.isUpdating = false, this.scriptId, this.managed = false, this.managedStyleApplied = false, this.ageSecretKey, @JsonKey(name: 'group-switches')  Map<String, bool> groupSwitches = const {}, this.usageStyle = ProfileUsageStyle.bar, this.bundle}): _providerSubscriptions = providerSubscriptions,_selectedMap = selectedMap,_unfoldSet = unfoldSet,_groupSwitches = groupSwitches;
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
@override final  String? scriptId;
@override@JsonKey() final  bool managed;
@override@JsonKey() final  bool managedStyleApplied;
@override final  String? ageSecretKey;
 final  Map<String, bool> _groupSwitches;
@override@JsonKey(name: 'group-switches') Map<String, bool> get groupSwitches {
  if (_groupSwitches is EqualUnmodifiableMapView) return _groupSwitches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupSwitches);
}

@override@JsonKey() final  ProfileUsageStyle usageStyle;
@override final  ProfileBundle? bundle;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.url, url) || other.url == url)&&(identical(other.lastUpdateDate, lastUpdateDate) || other.lastUpdateDate == lastUpdateDate)&&(identical(other.autoUpdateDuration, autoUpdateDuration) || other.autoUpdateDuration == autoUpdateDuration)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&const DeepCollectionEquality().equals(other.providerSubscriptions, _providerSubscriptions)&&(identical(other.autoUpdate, autoUpdate) || other.autoUpdate == autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _unfoldSet)&&(identical(other.overrideData, overrideData) || other.overrideData == overrideData)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.scriptId, scriptId) || other.scriptId == scriptId)&&(identical(other.managed, managed) || other.managed == managed)&&(identical(other.managedStyleApplied, managedStyleApplied) || other.managedStyleApplied == managedStyleApplied)&&(identical(other.ageSecretKey, ageSecretKey) || other.ageSecretKey == ageSecretKey)&&const DeepCollectionEquality().equals(other.groupSwitches, _groupSwitches)&&(identical(other.usageStyle, usageStyle) || other.usageStyle == usageStyle)&&(identical(other.bundle, bundle) || other.bundle == bundle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,label,currentGroupName,url,lastUpdateDate,autoUpdateDuration,subscriptionInfo,const DeepCollectionEquality().hash(_providerSubscriptions),autoUpdate,const DeepCollectionEquality().hash(_selectedMap),const DeepCollectionEquality().hash(_unfoldSet),overrideData,isUpdating,scriptId,managed,managedStyleApplied,ageSecretKey,const DeepCollectionEquality().hash(_groupSwitches),usageStyle,bundle]);
}

@override
String toString() {
    return 'Profile(id: $id, label: $label, currentGroupName: $currentGroupName, url: $url, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, subscriptionInfo: $subscriptionInfo, providerSubscriptions: $providerSubscriptions, autoUpdate: $autoUpdate, selectedMap: $selectedMap, unfoldSet: $unfoldSet, overrideData: $overrideData, isUpdating: $isUpdating, scriptId: $scriptId, managed: $managed, managedStyleApplied: $managedStyleApplied, ageSecretKey: $ageSecretKey, groupSwitches: $groupSwitches, usageStyle: $usageStyle, bundle: $bundle)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, Map<String, SubscriptionInfo> providerSubscriptions, bool autoUpdate, SelectedMap selectedMap, Set<String> unfoldSet, OverrideData overrideData,@JsonKey(includeToJson: false, includeFromJson: false) bool isUpdating, String? scriptId, bool managed, bool managedStyleApplied, String? ageSecretKey,@JsonKey(name: 'group-switches') Map<String, bool> groupSwitches, ProfileUsageStyle usageStyle, ProfileBundle? bundle
});


@override $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;@override $OverrideDataCopyWith<$Res> get overrideData;@override $ProfileBundleCopyWith<$Res>? get bundle;

}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? providerSubscriptions = null,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? overrideData = null,Object? isUpdating = null,Object? scriptId = freezed,Object? managed = null,Object? managedStyleApplied = null,Object? ageSecretKey = freezed,Object? groupSwitches = null,Object? usageStyle = null,Object? bundle = freezed,}) {
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
as bool,scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as String?,managed: null == managed ? _self.managed : managed // ignore: cast_nullable_to_non_nullable
as bool,managedStyleApplied: null == managedStyleApplied ? _self.managedStyleApplied : managedStyleApplied // ignore: cast_nullable_to_non_nullable
as bool,ageSecretKey: freezed == ageSecretKey ? _self.ageSecretKey : ageSecretKey // ignore: cast_nullable_to_non_nullable
as String?,groupSwitches: null == groupSwitches ? _self._groupSwitches : groupSwitches // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,usageStyle: null == usageStyle ? _self.usageStyle : usageStyle // ignore: cast_nullable_to_non_nullable
as ProfileUsageStyle,bundle: freezed == bundle ? _self.bundle : bundle // ignore: cast_nullable_to_non_nullable
as ProfileBundle?,
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
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileBundleCopyWith<$Res>? get bundle {
    if (_self.bundle == null) {
    return null;
  }

  return $ProfileBundleCopyWith<$Res>(_self.bundle!, (value) {
    return _then(_self.copyWith(bundle: value));
  });
}
}


/// @nodoc
mixin _$BundleMember {

 String get id; String? get prefix;
/// Create a copy of BundleMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleMemberCopyWith<BundleMember> get copyWith => _$BundleMemberCopyWithImpl<BundleMember>(this as BundleMember, _$identity);

  /// Serializes this BundleMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BundleMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleMember&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.prefix, _this.prefix) || other.prefix == _this.prefix));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BundleMember;
  return Object.hash(runtimeType,_this.id,_this.prefix);
}

@override
String toString() {
  final _this = this as BundleMember;
  return 'BundleMember(id: ${_this.id}, prefix: ${_this.prefix})';
}


}

/// @nodoc
abstract mixin class $BundleMemberCopyWith<$Res>  {
  factory $BundleMemberCopyWith(BundleMember value, $Res Function(BundleMember) _then) = _$BundleMemberCopyWithImpl;
@useResult
$Res call({
 String id, String? prefix
});




}
/// @nodoc
class _$BundleMemberCopyWithImpl<$Res>
    implements $BundleMemberCopyWith<$Res> {
  _$BundleMemberCopyWithImpl(this._self, this._then);

  final BundleMember _self;
  final $Res Function(BundleMember) _then;

/// Create a copy of BundleMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prefix = freezed,}) {
  return _then(BundleMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleMember].
extension BundleMemberPatterns on BundleMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleMember value)  $default,){
final _that = this;
switch (_that) {
case _BundleMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleMember value)?  $default,){
final _that = this;
switch (_that) {
case _BundleMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? prefix)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleMember() when $default != null:
return $default(_that.id,_that.prefix);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? prefix)  $default,) {final _that = this;
switch (_that) {
case _BundleMember():
return $default(_that.id,_that.prefix);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? prefix)?  $default,) {final _that = this;
switch (_that) {
case _BundleMember() when $default != null:
return $default(_that.id,_that.prefix);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleMember implements BundleMember {
  const _BundleMember({required this.id, this.prefix});
  factory _BundleMember.fromJson(Map<String, dynamic> json) => _$BundleMemberFromJson(json);

@override final  String id;
@override final  String? prefix;

/// Create a copy of BundleMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleMemberCopyWith<_BundleMember> get copyWith => __$BundleMemberCopyWithImpl<_BundleMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleMember&&(identical(other.id, id) || other.id == id)&&(identical(other.prefix, prefix) || other.prefix == prefix));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,prefix);
}

@override
String toString() {
    return 'BundleMember(id: $id, prefix: $prefix)';
}


}

/// @nodoc
abstract mixin class _$BundleMemberCopyWith<$Res> implements $BundleMemberCopyWith<$Res> {
  factory _$BundleMemberCopyWith(_BundleMember value, $Res Function(_BundleMember) _then) = __$BundleMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String? prefix
});




}
/// @nodoc
class __$BundleMemberCopyWithImpl<$Res>
    implements _$BundleMemberCopyWith<$Res> {
  __$BundleMemberCopyWithImpl(this._self, this._then);

  final _BundleMember _self;
  final $Res Function(_BundleMember) _then;

/// Create a copy of BundleMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prefix = freezed,}) {
  return _then(_BundleMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BundleReport {

 int get proxies; int get duplicates; int get groups;
/// Create a copy of BundleReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleReportCopyWith<BundleReport> get copyWith => _$BundleReportCopyWithImpl<BundleReport>(this as BundleReport, _$identity);

  /// Serializes this BundleReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BundleReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleReport&&(identical(other.proxies, _this.proxies) || other.proxies == _this.proxies)&&(identical(other.duplicates, _this.duplicates) || other.duplicates == _this.duplicates)&&(identical(other.groups, _this.groups) || other.groups == _this.groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BundleReport;
  return Object.hash(runtimeType,_this.proxies,_this.duplicates,_this.groups);
}

@override
String toString() {
  final _this = this as BundleReport;
  return 'BundleReport(proxies: ${_this.proxies}, duplicates: ${_this.duplicates}, groups: ${_this.groups})';
}


}

/// @nodoc
abstract mixin class $BundleReportCopyWith<$Res>  {
  factory $BundleReportCopyWith(BundleReport value, $Res Function(BundleReport) _then) = _$BundleReportCopyWithImpl;
@useResult
$Res call({
 int proxies, int duplicates, int groups
});




}
/// @nodoc
class _$BundleReportCopyWithImpl<$Res>
    implements $BundleReportCopyWith<$Res> {
  _$BundleReportCopyWithImpl(this._self, this._then);

  final BundleReport _self;
  final $Res Function(BundleReport) _then;

/// Create a copy of BundleReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxies = null,Object? duplicates = null,Object? groups = null,}) {
  return _then(BundleReport(
proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as int,duplicates: null == duplicates ? _self.duplicates : duplicates // ignore: cast_nullable_to_non_nullable
as int,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleReport].
extension BundleReportPatterns on BundleReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleReport value)  $default,){
final _that = this;
switch (_that) {
case _BundleReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleReport value)?  $default,){
final _that = this;
switch (_that) {
case _BundleReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int proxies,  int duplicates,  int groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleReport() when $default != null:
return $default(_that.proxies,_that.duplicates,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int proxies,  int duplicates,  int groups)  $default,) {final _that = this;
switch (_that) {
case _BundleReport():
return $default(_that.proxies,_that.duplicates,_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int proxies,  int duplicates,  int groups)?  $default,) {final _that = this;
switch (_that) {
case _BundleReport() when $default != null:
return $default(_that.proxies,_that.duplicates,_that.groups);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleReport implements BundleReport {
  const _BundleReport({this.proxies = 0, this.duplicates = 0, this.groups = 0});
  factory _BundleReport.fromJson(Map<String, dynamic> json) => _$BundleReportFromJson(json);

@override@JsonKey() final  int proxies;
@override@JsonKey() final  int duplicates;
@override@JsonKey() final  int groups;

/// Create a copy of BundleReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleReportCopyWith<_BundleReport> get copyWith => __$BundleReportCopyWithImpl<_BundleReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleReport&&(identical(other.proxies, proxies) || other.proxies == proxies)&&(identical(other.duplicates, duplicates) || other.duplicates == duplicates)&&(identical(other.groups, groups) || other.groups == groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,proxies,duplicates,groups);
}

@override
String toString() {
    return 'BundleReport(proxies: $proxies, duplicates: $duplicates, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$BundleReportCopyWith<$Res> implements $BundleReportCopyWith<$Res> {
  factory _$BundleReportCopyWith(_BundleReport value, $Res Function(_BundleReport) _then) = __$BundleReportCopyWithImpl;
@override @useResult
$Res call({
 int proxies, int duplicates, int groups
});




}
/// @nodoc
class __$BundleReportCopyWithImpl<$Res>
    implements _$BundleReportCopyWith<$Res> {
  __$BundleReportCopyWithImpl(this._self, this._then);

  final _BundleReport _self;
  final $Res Function(_BundleReport) _then;

/// Create a copy of BundleReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxies = null,Object? duplicates = null,Object? groups = null,}) {
  return _then(_BundleReport(
proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as int,duplicates: null == duplicates ? _self.duplicates : duplicates // ignore: cast_nullable_to_non_nullable
as int,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProfileBundle {

 List<BundleMember> get members; BundleReport get report; Map<String, String> get failures; bool get collapsed;
/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileBundleCopyWith<ProfileBundle> get copyWith => _$ProfileBundleCopyWithImpl<ProfileBundle>(this as ProfileBundle, _$identity);

  /// Serializes this ProfileBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileBundle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileBundle&&const DeepCollectionEquality().equals(other.members, _this.members)&&(identical(other.report, _this.report) || other.report == _this.report)&&const DeepCollectionEquality().equals(other.failures, _this.failures)&&(identical(other.collapsed, _this.collapsed) || other.collapsed == _this.collapsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileBundle;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.members),_this.report,const DeepCollectionEquality().hash(_this.failures),_this.collapsed);
}

@override
String toString() {
  final _this = this as ProfileBundle;
  return 'ProfileBundle(members: ${_this.members}, report: ${_this.report}, failures: ${_this.failures}, collapsed: ${_this.collapsed})';
}


}

/// @nodoc
abstract mixin class $ProfileBundleCopyWith<$Res>  {
  factory $ProfileBundleCopyWith(ProfileBundle value, $Res Function(ProfileBundle) _then) = _$ProfileBundleCopyWithImpl;
@useResult
$Res call({
 List<BundleMember> members, BundleReport report, Map<String, String> failures, bool collapsed
});


$BundleReportCopyWith<$Res> get report;

}
/// @nodoc
class _$ProfileBundleCopyWithImpl<$Res>
    implements $ProfileBundleCopyWith<$Res> {
  _$ProfileBundleCopyWithImpl(this._self, this._then);

  final ProfileBundle _self;
  final $Res Function(ProfileBundle) _then;

/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? members = null,Object? report = null,Object? failures = null,Object? collapsed = null,}) {
  return _then(ProfileBundle(
members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<BundleMember>,report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as BundleReport,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as Map<String, String>,collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BundleReportCopyWith<$Res> get report {
  
  return $BundleReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileBundle].
extension ProfileBundlePatterns on ProfileBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileBundle value)  $default,){
final _that = this;
switch (_that) {
case _ProfileBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileBundle value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BundleMember> members,  BundleReport report,  Map<String, String> failures,  bool collapsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileBundle() when $default != null:
return $default(_that.members,_that.report,_that.failures,_that.collapsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BundleMember> members,  BundleReport report,  Map<String, String> failures,  bool collapsed)  $default,) {final _that = this;
switch (_that) {
case _ProfileBundle():
return $default(_that.members,_that.report,_that.failures,_that.collapsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BundleMember> members,  BundleReport report,  Map<String, String> failures,  bool collapsed)?  $default,) {final _that = this;
switch (_that) {
case _ProfileBundle() when $default != null:
return $default(_that.members,_that.report,_that.failures,_that.collapsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileBundle implements ProfileBundle {
  const _ProfileBundle({ List<BundleMember> members = const [], this.report = const BundleReport(),  Map<String, String> failures = const {}, this.collapsed = false}): _members = members,_failures = failures;
  factory _ProfileBundle.fromJson(Map<String, dynamic> json) => _$ProfileBundleFromJson(json);

 final  List<BundleMember> _members;
@override@JsonKey() List<BundleMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override@JsonKey() final  BundleReport report;
 final  Map<String, String> _failures;
@override@JsonKey() Map<String, String> get failures {
  if (_failures is EqualUnmodifiableMapView) return _failures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_failures);
}

@override@JsonKey() final  bool collapsed;

/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileBundleCopyWith<_ProfileBundle> get copyWith => __$ProfileBundleCopyWithImpl<_ProfileBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileBundleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileBundle&&const DeepCollectionEquality().equals(other.members, _members)&&(identical(other.report, report) || other.report == report)&&const DeepCollectionEquality().equals(other.failures, _failures)&&(identical(other.collapsed, collapsed) || other.collapsed == collapsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_members),report,const DeepCollectionEquality().hash(_failures),collapsed);
}

@override
String toString() {
    return 'ProfileBundle(members: $members, report: $report, failures: $failures, collapsed: $collapsed)';
}


}

/// @nodoc
abstract mixin class _$ProfileBundleCopyWith<$Res> implements $ProfileBundleCopyWith<$Res> {
  factory _$ProfileBundleCopyWith(_ProfileBundle value, $Res Function(_ProfileBundle) _then) = __$ProfileBundleCopyWithImpl;
@override @useResult
$Res call({
 List<BundleMember> members, BundleReport report, Map<String, String> failures, bool collapsed
});


@override $BundleReportCopyWith<$Res> get report;

}
/// @nodoc
class __$ProfileBundleCopyWithImpl<$Res>
    implements _$ProfileBundleCopyWith<$Res> {
  __$ProfileBundleCopyWithImpl(this._self, this._then);

  final _ProfileBundle _self;
  final $Res Function(_ProfileBundle) _then;

/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? members = null,Object? report = null,Object? failures = null,Object? collapsed = null,}) {
  return _then(_ProfileBundle(
members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<BundleMember>,report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as BundleReport,failures: null == failures ? _self._failures : failures // ignore: cast_nullable_to_non_nullable
as Map<String, String>,collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BundleReportCopyWith<$Res> get report {
  
  return $BundleReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
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

 List<Rule> get addedRules;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverrideRule&&const DeepCollectionEquality().equals(other.addedRules, _this.addedRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OverrideRule;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.addedRules));
}

@override
String toString() {
  final _this = this as OverrideRule;
  return 'OverrideRule(addedRules: ${_this.addedRules})';
}


}

/// @nodoc
abstract mixin class $OverrideRuleCopyWith<$Res>  {
  factory $OverrideRuleCopyWith(OverrideRule value, $Res Function(OverrideRule) _then) = _$OverrideRuleCopyWithImpl;
@useResult
$Res call({
 List<Rule> addedRules
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
@pragma('vm:prefer-inline') @override $Res call({Object? addedRules = null,}) {
  return _then(OverrideRule(
addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Rule> addedRules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
return $default(_that.addedRules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Rule> addedRules)  $default,) {final _that = this;
switch (_that) {
case _OverrideRule():
return $default(_that.addedRules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Rule> addedRules)?  $default,) {final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
return $default(_that.addedRules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverrideRule implements OverrideRule {
  const _OverrideRule({ List<Rule> addedRules = const []}): _addedRules = addedRules;
  factory _OverrideRule.fromJson(Map<String, dynamic> json) => _$OverrideRuleFromJson(json);

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverrideRule&&const DeepCollectionEquality().equals(other.addedRules, _addedRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_addedRules));
}

@override
String toString() {
    return 'OverrideRule(addedRules: $addedRules)';
}


}

/// @nodoc
abstract mixin class _$OverrideRuleCopyWith<$Res> implements $OverrideRuleCopyWith<$Res> {
  factory _$OverrideRuleCopyWith(_OverrideRule value, $Res Function(_OverrideRule) _then) = __$OverrideRuleCopyWithImpl;
@override @useResult
$Res call({
 List<Rule> addedRules
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
@override @pragma('vm:prefer-inline') $Res call({Object? addedRules = null,}) {
  return _then(_OverrideRule(
addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,
  ));
}


}

// dart format on
