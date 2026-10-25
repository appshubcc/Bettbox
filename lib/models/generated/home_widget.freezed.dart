// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../home_widget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeWidgetColors {

 int get surface; int get tonal; int get onSurface; int get onSurfaceVariant; int get primary; int get onPrimary; int get active; int get onActive;
/// Create a copy of HomeWidgetColors
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeWidgetColorsCopyWith<HomeWidgetColors> get copyWith => _$HomeWidgetColorsCopyWithImpl<HomeWidgetColors>(this as HomeWidgetColors, _$identity);

  /// Serializes this HomeWidgetColors to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeWidgetColors;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeWidgetColors&&(identical(other.surface, _this.surface) || other.surface == _this.surface)&&(identical(other.tonal, _this.tonal) || other.tonal == _this.tonal)&&(identical(other.onSurface, _this.onSurface) || other.onSurface == _this.onSurface)&&(identical(other.onSurfaceVariant, _this.onSurfaceVariant) || other.onSurfaceVariant == _this.onSurfaceVariant)&&(identical(other.primary, _this.primary) || other.primary == _this.primary)&&(identical(other.onPrimary, _this.onPrimary) || other.onPrimary == _this.onPrimary)&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.onActive, _this.onActive) || other.onActive == _this.onActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeWidgetColors;
  return Object.hash(runtimeType,_this.surface,_this.tonal,_this.onSurface,_this.onSurfaceVariant,_this.primary,_this.onPrimary,_this.active,_this.onActive);
}

@override
String toString() {
  final _this = this as HomeWidgetColors;
  return 'HomeWidgetColors(surface: ${_this.surface}, tonal: ${_this.tonal}, onSurface: ${_this.onSurface}, onSurfaceVariant: ${_this.onSurfaceVariant}, primary: ${_this.primary}, onPrimary: ${_this.onPrimary}, active: ${_this.active}, onActive: ${_this.onActive})';
}


}

/// @nodoc
abstract mixin class $HomeWidgetColorsCopyWith<$Res>  {
  factory $HomeWidgetColorsCopyWith(HomeWidgetColors value, $Res Function(HomeWidgetColors) _then) = _$HomeWidgetColorsCopyWithImpl;
@useResult
$Res call({
 int surface, int tonal, int onSurface, int onSurfaceVariant, int primary, int onPrimary, int active, int onActive
});




}
/// @nodoc
class _$HomeWidgetColorsCopyWithImpl<$Res>
    implements $HomeWidgetColorsCopyWith<$Res> {
  _$HomeWidgetColorsCopyWithImpl(this._self, this._then);

  final HomeWidgetColors _self;
  final $Res Function(HomeWidgetColors) _then;

/// Create a copy of HomeWidgetColors
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surface = null,Object? tonal = null,Object? onSurface = null,Object? onSurfaceVariant = null,Object? primary = null,Object? onPrimary = null,Object? active = null,Object? onActive = null,}) {
  return _then(HomeWidgetColors(
surface: null == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as int,tonal: null == tonal ? _self.tonal : tonal // ignore: cast_nullable_to_non_nullable
as int,onSurface: null == onSurface ? _self.onSurface : onSurface // ignore: cast_nullable_to_non_nullable
as int,onSurfaceVariant: null == onSurfaceVariant ? _self.onSurfaceVariant : onSurfaceVariant // ignore: cast_nullable_to_non_nullable
as int,primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as int,onPrimary: null == onPrimary ? _self.onPrimary : onPrimary // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as int,onActive: null == onActive ? _self.onActive : onActive // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeWidgetColors].
extension HomeWidgetColorsPatterns on HomeWidgetColors {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeWidgetColors value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeWidgetColors() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeWidgetColors value)  $default,){
final _that = this;
switch (_that) {
case _HomeWidgetColors():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeWidgetColors value)?  $default,){
final _that = this;
switch (_that) {
case _HomeWidgetColors() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int surface,  int tonal,  int onSurface,  int onSurfaceVariant,  int primary,  int onPrimary,  int active,  int onActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeWidgetColors() when $default != null:
return $default(_that.surface,_that.tonal,_that.onSurface,_that.onSurfaceVariant,_that.primary,_that.onPrimary,_that.active,_that.onActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int surface,  int tonal,  int onSurface,  int onSurfaceVariant,  int primary,  int onPrimary,  int active,  int onActive)  $default,) {final _that = this;
switch (_that) {
case _HomeWidgetColors():
return $default(_that.surface,_that.tonal,_that.onSurface,_that.onSurfaceVariant,_that.primary,_that.onPrimary,_that.active,_that.onActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int surface,  int tonal,  int onSurface,  int onSurfaceVariant,  int primary,  int onPrimary,  int active,  int onActive)?  $default,) {final _that = this;
switch (_that) {
case _HomeWidgetColors() when $default != null:
return $default(_that.surface,_that.tonal,_that.onSurface,_that.onSurfaceVariant,_that.primary,_that.onPrimary,_that.active,_that.onActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeWidgetColors implements HomeWidgetColors {
  const _HomeWidgetColors({required this.surface, required this.tonal, required this.onSurface, required this.onSurfaceVariant, required this.primary, required this.onPrimary, required this.active, required this.onActive});
  factory _HomeWidgetColors.fromJson(Map<String, dynamic> json) => _$HomeWidgetColorsFromJson(json);

@override final  int surface;
@override final  int tonal;
@override final  int onSurface;
@override final  int onSurfaceVariant;
@override final  int primary;
@override final  int onPrimary;
@override final  int active;
@override final  int onActive;

/// Create a copy of HomeWidgetColors
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeWidgetColorsCopyWith<_HomeWidgetColors> get copyWith => __$HomeWidgetColorsCopyWithImpl<_HomeWidgetColors>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeWidgetColorsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeWidgetColors&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.tonal, tonal) || other.tonal == tonal)&&(identical(other.onSurface, onSurface) || other.onSurface == onSurface)&&(identical(other.onSurfaceVariant, onSurfaceVariant) || other.onSurfaceVariant == onSurfaceVariant)&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.onPrimary, onPrimary) || other.onPrimary == onPrimary)&&(identical(other.active, active) || other.active == active)&&(identical(other.onActive, onActive) || other.onActive == onActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,surface,tonal,onSurface,onSurfaceVariant,primary,onPrimary,active,onActive);
}

@override
String toString() {
    return 'HomeWidgetColors(surface: $surface, tonal: $tonal, onSurface: $onSurface, onSurfaceVariant: $onSurfaceVariant, primary: $primary, onPrimary: $onPrimary, active: $active, onActive: $onActive)';
}


}

/// @nodoc
abstract mixin class _$HomeWidgetColorsCopyWith<$Res> implements $HomeWidgetColorsCopyWith<$Res> {
  factory _$HomeWidgetColorsCopyWith(_HomeWidgetColors value, $Res Function(_HomeWidgetColors) _then) = __$HomeWidgetColorsCopyWithImpl;
@override @useResult
$Res call({
 int surface, int tonal, int onSurface, int onSurfaceVariant, int primary, int onPrimary, int active, int onActive
});




}
/// @nodoc
class __$HomeWidgetColorsCopyWithImpl<$Res>
    implements _$HomeWidgetColorsCopyWith<$Res> {
  __$HomeWidgetColorsCopyWithImpl(this._self, this._then);

  final _HomeWidgetColors _self;
  final $Res Function(_HomeWidgetColors) _then;

/// Create a copy of HomeWidgetColors
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surface = null,Object? tonal = null,Object? onSurface = null,Object? onSurfaceVariant = null,Object? primary = null,Object? onPrimary = null,Object? active = null,Object? onActive = null,}) {
  return _then(_HomeWidgetColors(
surface: null == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as int,tonal: null == tonal ? _self.tonal : tonal // ignore: cast_nullable_to_non_nullable
as int,onSurface: null == onSurface ? _self.onSurface : onSurface // ignore: cast_nullable_to_non_nullable
as int,onSurfaceVariant: null == onSurfaceVariant ? _self.onSurfaceVariant : onSurfaceVariant // ignore: cast_nullable_to_non_nullable
as int,primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as int,onPrimary: null == onPrimary ? _self.onPrimary : onPrimary // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as int,onActive: null == onActive ? _self.onActive : onActive // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$HomeWidgetSnapshot {

 bool get hasProfile; String get emptyText; String get name; String get updated; String get subtitle; bool get expired; String get used; String get total; String get usage; String get percent; List<double> get segments; String get firstLabel; String get firstValue; String get secondLabel; String get secondValue; String get expireShort; String get nodeLabel; String get node; String get delay; int get delayColor; bool get canRefresh; bool get refreshing; String get onLabel; String get offLabel; HomeWidgetColors get light; HomeWidgetColors get dark;
/// Create a copy of HomeWidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeWidgetSnapshotCopyWith<HomeWidgetSnapshot> get copyWith => _$HomeWidgetSnapshotCopyWithImpl<HomeWidgetSnapshot>(this as HomeWidgetSnapshot, _$identity);

  /// Serializes this HomeWidgetSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeWidgetSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeWidgetSnapshot&&(identical(other.hasProfile, _this.hasProfile) || other.hasProfile == _this.hasProfile)&&(identical(other.emptyText, _this.emptyText) || other.emptyText == _this.emptyText)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.updated, _this.updated) || other.updated == _this.updated)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.expired, _this.expired) || other.expired == _this.expired)&&(identical(other.used, _this.used) || other.used == _this.used)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.usage, _this.usage) || other.usage == _this.usage)&&(identical(other.percent, _this.percent) || other.percent == _this.percent)&&const DeepCollectionEquality().equals(other.segments, _this.segments)&&(identical(other.firstLabel, _this.firstLabel) || other.firstLabel == _this.firstLabel)&&(identical(other.firstValue, _this.firstValue) || other.firstValue == _this.firstValue)&&(identical(other.secondLabel, _this.secondLabel) || other.secondLabel == _this.secondLabel)&&(identical(other.secondValue, _this.secondValue) || other.secondValue == _this.secondValue)&&(identical(other.expireShort, _this.expireShort) || other.expireShort == _this.expireShort)&&(identical(other.nodeLabel, _this.nodeLabel) || other.nodeLabel == _this.nodeLabel)&&(identical(other.node, _this.node) || other.node == _this.node)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&(identical(other.delayColor, _this.delayColor) || other.delayColor == _this.delayColor)&&(identical(other.canRefresh, _this.canRefresh) || other.canRefresh == _this.canRefresh)&&(identical(other.refreshing, _this.refreshing) || other.refreshing == _this.refreshing)&&(identical(other.onLabel, _this.onLabel) || other.onLabel == _this.onLabel)&&(identical(other.offLabel, _this.offLabel) || other.offLabel == _this.offLabel)&&(identical(other.light, _this.light) || other.light == _this.light)&&(identical(other.dark, _this.dark) || other.dark == _this.dark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeWidgetSnapshot;
  return Object.hashAll([runtimeType,_this.hasProfile,_this.emptyText,_this.name,_this.updated,_this.subtitle,_this.expired,_this.used,_this.total,_this.usage,_this.percent,const DeepCollectionEquality().hash(_this.segments),_this.firstLabel,_this.firstValue,_this.secondLabel,_this.secondValue,_this.expireShort,_this.nodeLabel,_this.node,_this.delay,_this.delayColor,_this.canRefresh,_this.refreshing,_this.onLabel,_this.offLabel,_this.light,_this.dark]);
}

@override
String toString() {
  final _this = this as HomeWidgetSnapshot;
  return 'HomeWidgetSnapshot(hasProfile: ${_this.hasProfile}, emptyText: ${_this.emptyText}, name: ${_this.name}, updated: ${_this.updated}, subtitle: ${_this.subtitle}, expired: ${_this.expired}, used: ${_this.used}, total: ${_this.total}, usage: ${_this.usage}, percent: ${_this.percent}, segments: ${_this.segments}, firstLabel: ${_this.firstLabel}, firstValue: ${_this.firstValue}, secondLabel: ${_this.secondLabel}, secondValue: ${_this.secondValue}, expireShort: ${_this.expireShort}, nodeLabel: ${_this.nodeLabel}, node: ${_this.node}, delay: ${_this.delay}, delayColor: ${_this.delayColor}, canRefresh: ${_this.canRefresh}, refreshing: ${_this.refreshing}, onLabel: ${_this.onLabel}, offLabel: ${_this.offLabel}, light: ${_this.light}, dark: ${_this.dark})';
}


}

/// @nodoc
abstract mixin class $HomeWidgetSnapshotCopyWith<$Res>  {
  factory $HomeWidgetSnapshotCopyWith(HomeWidgetSnapshot value, $Res Function(HomeWidgetSnapshot) _then) = _$HomeWidgetSnapshotCopyWithImpl;
@useResult
$Res call({
 bool hasProfile, String emptyText, String name, String updated, String subtitle, bool expired, String used, String total, String usage, String percent, List<double> segments, String firstLabel, String firstValue, String secondLabel, String secondValue, String expireShort, String nodeLabel, String node, String delay, int delayColor, bool canRefresh, bool refreshing, String onLabel, String offLabel, HomeWidgetColors light, HomeWidgetColors dark
});


$HomeWidgetColorsCopyWith<$Res> get light;$HomeWidgetColorsCopyWith<$Res> get dark;

}
/// @nodoc
class _$HomeWidgetSnapshotCopyWithImpl<$Res>
    implements $HomeWidgetSnapshotCopyWith<$Res> {
  _$HomeWidgetSnapshotCopyWithImpl(this._self, this._then);

  final HomeWidgetSnapshot _self;
  final $Res Function(HomeWidgetSnapshot) _then;

/// Create a copy of HomeWidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasProfile = null,Object? emptyText = null,Object? name = null,Object? updated = null,Object? subtitle = null,Object? expired = null,Object? used = null,Object? total = null,Object? usage = null,Object? percent = null,Object? segments = null,Object? firstLabel = null,Object? firstValue = null,Object? secondLabel = null,Object? secondValue = null,Object? expireShort = null,Object? nodeLabel = null,Object? node = null,Object? delay = null,Object? delayColor = null,Object? canRefresh = null,Object? refreshing = null,Object? onLabel = null,Object? offLabel = null,Object? light = null,Object? dark = null,}) {
  return _then(HomeWidgetSnapshot(
hasProfile: null == hasProfile ? _self.hasProfile : hasProfile // ignore: cast_nullable_to_non_nullable
as bool,emptyText: null == emptyText ? _self.emptyText : emptyText // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,updated: null == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,expired: null == expired ? _self.expired : expired // ignore: cast_nullable_to_non_nullable
as bool,used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as String,segments: null == segments ? _self.segments : segments // ignore: cast_nullable_to_non_nullable
as List<double>,firstLabel: null == firstLabel ? _self.firstLabel : firstLabel // ignore: cast_nullable_to_non_nullable
as String,firstValue: null == firstValue ? _self.firstValue : firstValue // ignore: cast_nullable_to_non_nullable
as String,secondLabel: null == secondLabel ? _self.secondLabel : secondLabel // ignore: cast_nullable_to_non_nullable
as String,secondValue: null == secondValue ? _self.secondValue : secondValue // ignore: cast_nullable_to_non_nullable
as String,expireShort: null == expireShort ? _self.expireShort : expireShort // ignore: cast_nullable_to_non_nullable
as String,nodeLabel: null == nodeLabel ? _self.nodeLabel : nodeLabel // ignore: cast_nullable_to_non_nullable
as String,node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as String,delayColor: null == delayColor ? _self.delayColor : delayColor // ignore: cast_nullable_to_non_nullable
as int,canRefresh: null == canRefresh ? _self.canRefresh : canRefresh // ignore: cast_nullable_to_non_nullable
as bool,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,onLabel: null == onLabel ? _self.onLabel : onLabel // ignore: cast_nullable_to_non_nullable
as String,offLabel: null == offLabel ? _self.offLabel : offLabel // ignore: cast_nullable_to_non_nullable
as String,light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as HomeWidgetColors,dark: null == dark ? _self.dark : dark // ignore: cast_nullable_to_non_nullable
as HomeWidgetColors,
  ));
}
/// Create a copy of HomeWidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeWidgetColorsCopyWith<$Res> get light {
  
  return $HomeWidgetColorsCopyWith<$Res>(_self.light, (value) {
    return _then(_self.copyWith(light: value));
  });
}/// Create a copy of HomeWidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeWidgetColorsCopyWith<$Res> get dark {
  
  return $HomeWidgetColorsCopyWith<$Res>(_self.dark, (value) {
    return _then(_self.copyWith(dark: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeWidgetSnapshot].
extension HomeWidgetSnapshotPatterns on HomeWidgetSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeWidgetSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeWidgetSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeWidgetSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _HomeWidgetSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeWidgetSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _HomeWidgetSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasProfile,  String emptyText,  String name,  String updated,  String subtitle,  bool expired,  String used,  String total,  String usage,  String percent,  List<double> segments,  String firstLabel,  String firstValue,  String secondLabel,  String secondValue,  String expireShort,  String nodeLabel,  String node,  String delay,  int delayColor,  bool canRefresh,  bool refreshing,  String onLabel,  String offLabel,  HomeWidgetColors light,  HomeWidgetColors dark)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeWidgetSnapshot() when $default != null:
return $default(_that.hasProfile,_that.emptyText,_that.name,_that.updated,_that.subtitle,_that.expired,_that.used,_that.total,_that.usage,_that.percent,_that.segments,_that.firstLabel,_that.firstValue,_that.secondLabel,_that.secondValue,_that.expireShort,_that.nodeLabel,_that.node,_that.delay,_that.delayColor,_that.canRefresh,_that.refreshing,_that.onLabel,_that.offLabel,_that.light,_that.dark);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasProfile,  String emptyText,  String name,  String updated,  String subtitle,  bool expired,  String used,  String total,  String usage,  String percent,  List<double> segments,  String firstLabel,  String firstValue,  String secondLabel,  String secondValue,  String expireShort,  String nodeLabel,  String node,  String delay,  int delayColor,  bool canRefresh,  bool refreshing,  String onLabel,  String offLabel,  HomeWidgetColors light,  HomeWidgetColors dark)  $default,) {final _that = this;
switch (_that) {
case _HomeWidgetSnapshot():
return $default(_that.hasProfile,_that.emptyText,_that.name,_that.updated,_that.subtitle,_that.expired,_that.used,_that.total,_that.usage,_that.percent,_that.segments,_that.firstLabel,_that.firstValue,_that.secondLabel,_that.secondValue,_that.expireShort,_that.nodeLabel,_that.node,_that.delay,_that.delayColor,_that.canRefresh,_that.refreshing,_that.onLabel,_that.offLabel,_that.light,_that.dark);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasProfile,  String emptyText,  String name,  String updated,  String subtitle,  bool expired,  String used,  String total,  String usage,  String percent,  List<double> segments,  String firstLabel,  String firstValue,  String secondLabel,  String secondValue,  String expireShort,  String nodeLabel,  String node,  String delay,  int delayColor,  bool canRefresh,  bool refreshing,  String onLabel,  String offLabel,  HomeWidgetColors light,  HomeWidgetColors dark)?  $default,) {final _that = this;
switch (_that) {
case _HomeWidgetSnapshot() when $default != null:
return $default(_that.hasProfile,_that.emptyText,_that.name,_that.updated,_that.subtitle,_that.expired,_that.used,_that.total,_that.usage,_that.percent,_that.segments,_that.firstLabel,_that.firstValue,_that.secondLabel,_that.secondValue,_that.expireShort,_that.nodeLabel,_that.node,_that.delay,_that.delayColor,_that.canRefresh,_that.refreshing,_that.onLabel,_that.offLabel,_that.light,_that.dark);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeWidgetSnapshot implements HomeWidgetSnapshot {
  const _HomeWidgetSnapshot({this.hasProfile = false, this.emptyText = '', this.name = '', this.updated = '', this.subtitle = '', this.expired = false, this.used = '', this.total = '', this.usage = '', this.percent = '',  List<double> segments = const [0], this.firstLabel = '', this.firstValue = '', this.secondLabel = '', this.secondValue = '', this.expireShort = '', this.nodeLabel = '', this.node = '', this.delay = '', this.delayColor = 0, this.canRefresh = false, this.refreshing = false, this.onLabel = '', this.offLabel = '', required this.light, required this.dark}): _segments = segments;
  factory _HomeWidgetSnapshot.fromJson(Map<String, dynamic> json) => _$HomeWidgetSnapshotFromJson(json);

@override@JsonKey() final  bool hasProfile;
@override@JsonKey() final  String emptyText;
@override@JsonKey() final  String name;
@override@JsonKey() final  String updated;
@override@JsonKey() final  String subtitle;
@override@JsonKey() final  bool expired;
@override@JsonKey() final  String used;
@override@JsonKey() final  String total;
@override@JsonKey() final  String usage;
@override@JsonKey() final  String percent;
 final  List<double> _segments;
@override@JsonKey() List<double> get segments {
  if (_segments is EqualUnmodifiableListView) return _segments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segments);
}

@override@JsonKey() final  String firstLabel;
@override@JsonKey() final  String firstValue;
@override@JsonKey() final  String secondLabel;
@override@JsonKey() final  String secondValue;
@override@JsonKey() final  String expireShort;
@override@JsonKey() final  String nodeLabel;
@override@JsonKey() final  String node;
@override@JsonKey() final  String delay;
@override@JsonKey() final  int delayColor;
@override@JsonKey() final  bool canRefresh;
@override@JsonKey() final  bool refreshing;
@override@JsonKey() final  String onLabel;
@override@JsonKey() final  String offLabel;
@override final  HomeWidgetColors light;
@override final  HomeWidgetColors dark;

/// Create a copy of HomeWidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeWidgetSnapshotCopyWith<_HomeWidgetSnapshot> get copyWith => __$HomeWidgetSnapshotCopyWithImpl<_HomeWidgetSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeWidgetSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeWidgetSnapshot&&(identical(other.hasProfile, hasProfile) || other.hasProfile == hasProfile)&&(identical(other.emptyText, emptyText) || other.emptyText == emptyText)&&(identical(other.name, name) || other.name == name)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.expired, expired) || other.expired == expired)&&(identical(other.used, used) || other.used == used)&&(identical(other.total, total) || other.total == total)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.percent, percent) || other.percent == percent)&&const DeepCollectionEquality().equals(other.segments, _segments)&&(identical(other.firstLabel, firstLabel) || other.firstLabel == firstLabel)&&(identical(other.firstValue, firstValue) || other.firstValue == firstValue)&&(identical(other.secondLabel, secondLabel) || other.secondLabel == secondLabel)&&(identical(other.secondValue, secondValue) || other.secondValue == secondValue)&&(identical(other.expireShort, expireShort) || other.expireShort == expireShort)&&(identical(other.nodeLabel, nodeLabel) || other.nodeLabel == nodeLabel)&&(identical(other.node, node) || other.node == node)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.delayColor, delayColor) || other.delayColor == delayColor)&&(identical(other.canRefresh, canRefresh) || other.canRefresh == canRefresh)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.onLabel, onLabel) || other.onLabel == onLabel)&&(identical(other.offLabel, offLabel) || other.offLabel == offLabel)&&(identical(other.light, light) || other.light == light)&&(identical(other.dark, dark) || other.dark == dark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,hasProfile,emptyText,name,updated,subtitle,expired,used,total,usage,percent,const DeepCollectionEquality().hash(_segments),firstLabel,firstValue,secondLabel,secondValue,expireShort,nodeLabel,node,delay,delayColor,canRefresh,refreshing,onLabel,offLabel,light,dark]);
}

@override
String toString() {
    return 'HomeWidgetSnapshot(hasProfile: $hasProfile, emptyText: $emptyText, name: $name, updated: $updated, subtitle: $subtitle, expired: $expired, used: $used, total: $total, usage: $usage, percent: $percent, segments: $segments, firstLabel: $firstLabel, firstValue: $firstValue, secondLabel: $secondLabel, secondValue: $secondValue, expireShort: $expireShort, nodeLabel: $nodeLabel, node: $node, delay: $delay, delayColor: $delayColor, canRefresh: $canRefresh, refreshing: $refreshing, onLabel: $onLabel, offLabel: $offLabel, light: $light, dark: $dark)';
}


}

/// @nodoc
abstract mixin class _$HomeWidgetSnapshotCopyWith<$Res> implements $HomeWidgetSnapshotCopyWith<$Res> {
  factory _$HomeWidgetSnapshotCopyWith(_HomeWidgetSnapshot value, $Res Function(_HomeWidgetSnapshot) _then) = __$HomeWidgetSnapshotCopyWithImpl;
@override @useResult
$Res call({
 bool hasProfile, String emptyText, String name, String updated, String subtitle, bool expired, String used, String total, String usage, String percent, List<double> segments, String firstLabel, String firstValue, String secondLabel, String secondValue, String expireShort, String nodeLabel, String node, String delay, int delayColor, bool canRefresh, bool refreshing, String onLabel, String offLabel, HomeWidgetColors light, HomeWidgetColors dark
});


@override $HomeWidgetColorsCopyWith<$Res> get light;@override $HomeWidgetColorsCopyWith<$Res> get dark;

}
/// @nodoc
class __$HomeWidgetSnapshotCopyWithImpl<$Res>
    implements _$HomeWidgetSnapshotCopyWith<$Res> {
  __$HomeWidgetSnapshotCopyWithImpl(this._self, this._then);

  final _HomeWidgetSnapshot _self;
  final $Res Function(_HomeWidgetSnapshot) _then;

/// Create a copy of HomeWidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasProfile = null,Object? emptyText = null,Object? name = null,Object? updated = null,Object? subtitle = null,Object? expired = null,Object? used = null,Object? total = null,Object? usage = null,Object? percent = null,Object? segments = null,Object? firstLabel = null,Object? firstValue = null,Object? secondLabel = null,Object? secondValue = null,Object? expireShort = null,Object? nodeLabel = null,Object? node = null,Object? delay = null,Object? delayColor = null,Object? canRefresh = null,Object? refreshing = null,Object? onLabel = null,Object? offLabel = null,Object? light = null,Object? dark = null,}) {
  return _then(_HomeWidgetSnapshot(
hasProfile: null == hasProfile ? _self.hasProfile : hasProfile // ignore: cast_nullable_to_non_nullable
as bool,emptyText: null == emptyText ? _self.emptyText : emptyText // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,updated: null == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,expired: null == expired ? _self.expired : expired // ignore: cast_nullable_to_non_nullable
as bool,used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as String,segments: null == segments ? _self._segments : segments // ignore: cast_nullable_to_non_nullable
as List<double>,firstLabel: null == firstLabel ? _self.firstLabel : firstLabel // ignore: cast_nullable_to_non_nullable
as String,firstValue: null == firstValue ? _self.firstValue : firstValue // ignore: cast_nullable_to_non_nullable
as String,secondLabel: null == secondLabel ? _self.secondLabel : secondLabel // ignore: cast_nullable_to_non_nullable
as String,secondValue: null == secondValue ? _self.secondValue : secondValue // ignore: cast_nullable_to_non_nullable
as String,expireShort: null == expireShort ? _self.expireShort : expireShort // ignore: cast_nullable_to_non_nullable
as String,nodeLabel: null == nodeLabel ? _self.nodeLabel : nodeLabel // ignore: cast_nullable_to_non_nullable
as String,node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as String,delayColor: null == delayColor ? _self.delayColor : delayColor // ignore: cast_nullable_to_non_nullable
as int,canRefresh: null == canRefresh ? _self.canRefresh : canRefresh // ignore: cast_nullable_to_non_nullable
as bool,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,onLabel: null == onLabel ? _self.onLabel : onLabel // ignore: cast_nullable_to_non_nullable
as String,offLabel: null == offLabel ? _self.offLabel : offLabel // ignore: cast_nullable_to_non_nullable
as String,light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as HomeWidgetColors,dark: null == dark ? _self.dark : dark // ignore: cast_nullable_to_non_nullable
as HomeWidgetColors,
  ));
}

/// Create a copy of HomeWidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeWidgetColorsCopyWith<$Res> get light {
  
  return $HomeWidgetColorsCopyWith<$Res>(_self.light, (value) {
    return _then(_self.copyWith(light: value));
  });
}/// Create a copy of HomeWidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeWidgetColorsCopyWith<$Res> get dark {
  
  return $HomeWidgetColorsCopyWith<$Res>(_self.dark, (value) {
    return _then(_self.copyWith(dark: value));
  });
}
}

// dart format on
