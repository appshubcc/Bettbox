// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../traffic_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrafficStatsProps {

 bool get enable; bool get detail; int get retentionDays; bool get siteIcon;
/// Create a copy of TrafficStatsProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficStatsPropsCopyWith<TrafficStatsProps> get copyWith => _$TrafficStatsPropsCopyWithImpl<TrafficStatsProps>(this as TrafficStatsProps, _$identity);

  /// Serializes this TrafficStatsProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrafficStatsProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficStatsProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.retentionDays, _this.retentionDays) || other.retentionDays == _this.retentionDays)&&(identical(other.siteIcon, _this.siteIcon) || other.siteIcon == _this.siteIcon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrafficStatsProps;
  return Object.hash(runtimeType,_this.enable,_this.detail,_this.retentionDays,_this.siteIcon);
}

@override
String toString() {
  final _this = this as TrafficStatsProps;
  return 'TrafficStatsProps(enable: ${_this.enable}, detail: ${_this.detail}, retentionDays: ${_this.retentionDays}, siteIcon: ${_this.siteIcon})';
}


}

/// @nodoc
abstract mixin class $TrafficStatsPropsCopyWith<$Res>  {
  factory $TrafficStatsPropsCopyWith(TrafficStatsProps value, $Res Function(TrafficStatsProps) _then) = _$TrafficStatsPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, bool detail, int retentionDays, bool siteIcon
});




}
/// @nodoc
class _$TrafficStatsPropsCopyWithImpl<$Res>
    implements $TrafficStatsPropsCopyWith<$Res> {
  _$TrafficStatsPropsCopyWithImpl(this._self, this._then);

  final TrafficStatsProps _self;
  final $Res Function(TrafficStatsProps) _then;

/// Create a copy of TrafficStatsProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? detail = null,Object? retentionDays = null,Object? siteIcon = null,}) {
  return _then(TrafficStatsProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as bool,retentionDays: null == retentionDays ? _self.retentionDays : retentionDays // ignore: cast_nullable_to_non_nullable
as int,siteIcon: null == siteIcon ? _self.siteIcon : siteIcon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficStatsProps].
extension TrafficStatsPropsPatterns on TrafficStatsProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficStatsProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficStatsProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficStatsProps value)  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficStatsProps value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  bool detail,  int retentionDays,  bool siteIcon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficStatsProps() when $default != null:
return $default(_that.enable,_that.detail,_that.retentionDays,_that.siteIcon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  bool detail,  int retentionDays,  bool siteIcon)  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsProps():
return $default(_that.enable,_that.detail,_that.retentionDays,_that.siteIcon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  bool detail,  int retentionDays,  bool siteIcon)?  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsProps() when $default != null:
return $default(_that.enable,_that.detail,_that.retentionDays,_that.siteIcon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrafficStatsProps implements TrafficStatsProps {
  const _TrafficStatsProps({this.enable = false, this.detail = true, this.retentionDays = 7, this.siteIcon = true});
  factory _TrafficStatsProps.fromJson(Map<String, dynamic> json) => _$TrafficStatsPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  bool detail;
@override@JsonKey() final  int retentionDays;
@override@JsonKey() final  bool siteIcon;

/// Create a copy of TrafficStatsProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficStatsPropsCopyWith<_TrafficStatsProps> get copyWith => __$TrafficStatsPropsCopyWithImpl<_TrafficStatsProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficStatsPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficStatsProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.retentionDays, retentionDays) || other.retentionDays == retentionDays)&&(identical(other.siteIcon, siteIcon) || other.siteIcon == siteIcon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,detail,retentionDays,siteIcon);
}

@override
String toString() {
    return 'TrafficStatsProps(enable: $enable, detail: $detail, retentionDays: $retentionDays, siteIcon: $siteIcon)';
}


}

/// @nodoc
abstract mixin class _$TrafficStatsPropsCopyWith<$Res> implements $TrafficStatsPropsCopyWith<$Res> {
  factory _$TrafficStatsPropsCopyWith(_TrafficStatsProps value, $Res Function(_TrafficStatsProps) _then) = __$TrafficStatsPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, bool detail, int retentionDays, bool siteIcon
});




}
/// @nodoc
class __$TrafficStatsPropsCopyWithImpl<$Res>
    implements _$TrafficStatsPropsCopyWith<$Res> {
  __$TrafficStatsPropsCopyWithImpl(this._self, this._then);

  final _TrafficStatsProps _self;
  final $Res Function(_TrafficStatsProps) _then;

/// Create a copy of TrafficStatsProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? detail = null,Object? retentionDays = null,Object? siteIcon = null,}) {
  return _then(_TrafficStatsProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as bool,retentionDays: null == retentionDays ? _self.retentionDays : retentionDays // ignore: cast_nullable_to_non_nullable
as int,siteIcon: null == siteIcon ? _self.siteIcon : siteIcon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TrafficStatsOptions {

 bool get enable; bool get detail;@JsonKey(name: 'retention-days') int get retentionDays;@JsonKey(name: 'tz-offset') int get tzOffset;
/// Create a copy of TrafficStatsOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficStatsOptionsCopyWith<TrafficStatsOptions> get copyWith => _$TrafficStatsOptionsCopyWithImpl<TrafficStatsOptions>(this as TrafficStatsOptions, _$identity);

  /// Serializes this TrafficStatsOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrafficStatsOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficStatsOptions&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.retentionDays, _this.retentionDays) || other.retentionDays == _this.retentionDays)&&(identical(other.tzOffset, _this.tzOffset) || other.tzOffset == _this.tzOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrafficStatsOptions;
  return Object.hash(runtimeType,_this.enable,_this.detail,_this.retentionDays,_this.tzOffset);
}

@override
String toString() {
  final _this = this as TrafficStatsOptions;
  return 'TrafficStatsOptions(enable: ${_this.enable}, detail: ${_this.detail}, retentionDays: ${_this.retentionDays}, tzOffset: ${_this.tzOffset})';
}


}

/// @nodoc
abstract mixin class $TrafficStatsOptionsCopyWith<$Res>  {
  factory $TrafficStatsOptionsCopyWith(TrafficStatsOptions value, $Res Function(TrafficStatsOptions) _then) = _$TrafficStatsOptionsCopyWithImpl;
@useResult
$Res call({
 bool enable, bool detail,@JsonKey(name: 'retention-days') int retentionDays,@JsonKey(name: 'tz-offset') int tzOffset
});




}
/// @nodoc
class _$TrafficStatsOptionsCopyWithImpl<$Res>
    implements $TrafficStatsOptionsCopyWith<$Res> {
  _$TrafficStatsOptionsCopyWithImpl(this._self, this._then);

  final TrafficStatsOptions _self;
  final $Res Function(TrafficStatsOptions) _then;

/// Create a copy of TrafficStatsOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? detail = null,Object? retentionDays = null,Object? tzOffset = null,}) {
  return _then(TrafficStatsOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as bool,retentionDays: null == retentionDays ? _self.retentionDays : retentionDays // ignore: cast_nullable_to_non_nullable
as int,tzOffset: null == tzOffset ? _self.tzOffset : tzOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficStatsOptions].
extension TrafficStatsOptionsPatterns on TrafficStatsOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficStatsOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficStatsOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficStatsOptions value)  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficStatsOptions value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  bool detail, @JsonKey(name: 'retention-days')  int retentionDays, @JsonKey(name: 'tz-offset')  int tzOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficStatsOptions() when $default != null:
return $default(_that.enable,_that.detail,_that.retentionDays,_that.tzOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  bool detail, @JsonKey(name: 'retention-days')  int retentionDays, @JsonKey(name: 'tz-offset')  int tzOffset)  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsOptions():
return $default(_that.enable,_that.detail,_that.retentionDays,_that.tzOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  bool detail, @JsonKey(name: 'retention-days')  int retentionDays, @JsonKey(name: 'tz-offset')  int tzOffset)?  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsOptions() when $default != null:
return $default(_that.enable,_that.detail,_that.retentionDays,_that.tzOffset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrafficStatsOptions implements TrafficStatsOptions {
  const _TrafficStatsOptions({required this.enable, required this.detail, @JsonKey(name: 'retention-days') required this.retentionDays, @JsonKey(name: 'tz-offset') required this.tzOffset});
  factory _TrafficStatsOptions.fromJson(Map<String, dynamic> json) => _$TrafficStatsOptionsFromJson(json);

@override final  bool enable;
@override final  bool detail;
@override@JsonKey(name: 'retention-days') final  int retentionDays;
@override@JsonKey(name: 'tz-offset') final  int tzOffset;

/// Create a copy of TrafficStatsOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficStatsOptionsCopyWith<_TrafficStatsOptions> get copyWith => __$TrafficStatsOptionsCopyWithImpl<_TrafficStatsOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficStatsOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficStatsOptions&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.retentionDays, retentionDays) || other.retentionDays == retentionDays)&&(identical(other.tzOffset, tzOffset) || other.tzOffset == tzOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,detail,retentionDays,tzOffset);
}

@override
String toString() {
    return 'TrafficStatsOptions(enable: $enable, detail: $detail, retentionDays: $retentionDays, tzOffset: $tzOffset)';
}


}

/// @nodoc
abstract mixin class _$TrafficStatsOptionsCopyWith<$Res> implements $TrafficStatsOptionsCopyWith<$Res> {
  factory _$TrafficStatsOptionsCopyWith(_TrafficStatsOptions value, $Res Function(_TrafficStatsOptions) _then) = __$TrafficStatsOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, bool detail,@JsonKey(name: 'retention-days') int retentionDays,@JsonKey(name: 'tz-offset') int tzOffset
});




}
/// @nodoc
class __$TrafficStatsOptionsCopyWithImpl<$Res>
    implements _$TrafficStatsOptionsCopyWith<$Res> {
  __$TrafficStatsOptionsCopyWithImpl(this._self, this._then);

  final _TrafficStatsOptions _self;
  final $Res Function(_TrafficStatsOptions) _then;

/// Create a copy of TrafficStatsOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? detail = null,Object? retentionDays = null,Object? tzOffset = null,}) {
  return _then(_TrafficStatsOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as bool,retentionDays: null == retentionDays ? _self.retentionDays : retentionDays // ignore: cast_nullable_to_non_nullable
as int,tzOffset: null == tzOffset ? _self.tzOffset : tzOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TrafficStatsItem {

 String get name; int get up; int get down; int get hits; String get path; List<TrafficStatsItem> get subs;
/// Create a copy of TrafficStatsItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficStatsItemCopyWith<TrafficStatsItem> get copyWith => _$TrafficStatsItemCopyWithImpl<TrafficStatsItem>(this as TrafficStatsItem, _$identity);

  /// Serializes this TrafficStatsItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrafficStatsItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficStatsItem&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.up, _this.up) || other.up == _this.up)&&(identical(other.down, _this.down) || other.down == _this.down)&&(identical(other.hits, _this.hits) || other.hits == _this.hits)&&(identical(other.path, _this.path) || other.path == _this.path)&&const DeepCollectionEquality().equals(other.subs, _this.subs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrafficStatsItem;
  return Object.hash(runtimeType,_this.name,_this.up,_this.down,_this.hits,_this.path,const DeepCollectionEquality().hash(_this.subs));
}

@override
String toString() {
  final _this = this as TrafficStatsItem;
  return 'TrafficStatsItem(name: ${_this.name}, up: ${_this.up}, down: ${_this.down}, hits: ${_this.hits}, path: ${_this.path}, subs: ${_this.subs})';
}


}

/// @nodoc
abstract mixin class $TrafficStatsItemCopyWith<$Res>  {
  factory $TrafficStatsItemCopyWith(TrafficStatsItem value, $Res Function(TrafficStatsItem) _then) = _$TrafficStatsItemCopyWithImpl;
@useResult
$Res call({
 String name, int up, int down, int hits, String path, List<TrafficStatsItem> subs
});




}
/// @nodoc
class _$TrafficStatsItemCopyWithImpl<$Res>
    implements $TrafficStatsItemCopyWith<$Res> {
  _$TrafficStatsItemCopyWithImpl(this._self, this._then);

  final TrafficStatsItem _self;
  final $Res Function(TrafficStatsItem) _then;

/// Create a copy of TrafficStatsItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? up = null,Object? down = null,Object? hits = null,Object? path = null,Object? subs = null,}) {
  return _then(TrafficStatsItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,hits: null == hits ? _self.hits : hits // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,subs: null == subs ? _self.subs : subs // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficStatsItem].
extension TrafficStatsItemPatterns on TrafficStatsItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficStatsItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficStatsItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficStatsItem value)  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficStatsItem value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int up,  int down,  int hits,  String path,  List<TrafficStatsItem> subs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficStatsItem() when $default != null:
return $default(_that.name,_that.up,_that.down,_that.hits,_that.path,_that.subs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int up,  int down,  int hits,  String path,  List<TrafficStatsItem> subs)  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsItem():
return $default(_that.name,_that.up,_that.down,_that.hits,_that.path,_that.subs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int up,  int down,  int hits,  String path,  List<TrafficStatsItem> subs)?  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsItem() when $default != null:
return $default(_that.name,_that.up,_that.down,_that.hits,_that.path,_that.subs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrafficStatsItem implements TrafficStatsItem {
  const _TrafficStatsItem({this.name = '', this.up = 0, this.down = 0, this.hits = 0, this.path = '',  List<TrafficStatsItem> subs = const []}): _subs = subs;
  factory _TrafficStatsItem.fromJson(Map<String, dynamic> json) => _$TrafficStatsItemFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  int up;
@override@JsonKey() final  int down;
@override@JsonKey() final  int hits;
@override@JsonKey() final  String path;
 final  List<TrafficStatsItem> _subs;
@override@JsonKey() List<TrafficStatsItem> get subs {
  if (_subs is EqualUnmodifiableListView) return _subs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subs);
}


/// Create a copy of TrafficStatsItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficStatsItemCopyWith<_TrafficStatsItem> get copyWith => __$TrafficStatsItemCopyWithImpl<_TrafficStatsItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficStatsItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficStatsItem&&(identical(other.name, name) || other.name == name)&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down)&&(identical(other.hits, hits) || other.hits == hits)&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.subs, _subs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,up,down,hits,path,const DeepCollectionEquality().hash(_subs));
}

@override
String toString() {
    return 'TrafficStatsItem(name: $name, up: $up, down: $down, hits: $hits, path: $path, subs: $subs)';
}


}

/// @nodoc
abstract mixin class _$TrafficStatsItemCopyWith<$Res> implements $TrafficStatsItemCopyWith<$Res> {
  factory _$TrafficStatsItemCopyWith(_TrafficStatsItem value, $Res Function(_TrafficStatsItem) _then) = __$TrafficStatsItemCopyWithImpl;
@override @useResult
$Res call({
 String name, int up, int down, int hits, String path, List<TrafficStatsItem> subs
});




}
/// @nodoc
class __$TrafficStatsItemCopyWithImpl<$Res>
    implements _$TrafficStatsItemCopyWith<$Res> {
  __$TrafficStatsItemCopyWithImpl(this._self, this._then);

  final _TrafficStatsItem _self;
  final $Res Function(_TrafficStatsItem) _then;

/// Create a copy of TrafficStatsItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? up = null,Object? down = null,Object? hits = null,Object? path = null,Object? subs = null,}) {
  return _then(_TrafficStatsItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,hits: null == hits ? _self.hits : hits // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,subs: null == subs ? _self._subs : subs // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,
  ));
}


}


/// @nodoc
mixin _$TrafficStatsPoint {

 String get label; int get up; int get down;
/// Create a copy of TrafficStatsPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficStatsPointCopyWith<TrafficStatsPoint> get copyWith => _$TrafficStatsPointCopyWithImpl<TrafficStatsPoint>(this as TrafficStatsPoint, _$identity);

  /// Serializes this TrafficStatsPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrafficStatsPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficStatsPoint&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.up, _this.up) || other.up == _this.up)&&(identical(other.down, _this.down) || other.down == _this.down));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrafficStatsPoint;
  return Object.hash(runtimeType,_this.label,_this.up,_this.down);
}

@override
String toString() {
  final _this = this as TrafficStatsPoint;
  return 'TrafficStatsPoint(label: ${_this.label}, up: ${_this.up}, down: ${_this.down})';
}


}

/// @nodoc
abstract mixin class $TrafficStatsPointCopyWith<$Res>  {
  factory $TrafficStatsPointCopyWith(TrafficStatsPoint value, $Res Function(TrafficStatsPoint) _then) = _$TrafficStatsPointCopyWithImpl;
@useResult
$Res call({
 String label, int up, int down
});




}
/// @nodoc
class _$TrafficStatsPointCopyWithImpl<$Res>
    implements $TrafficStatsPointCopyWith<$Res> {
  _$TrafficStatsPointCopyWithImpl(this._self, this._then);

  final TrafficStatsPoint _self;
  final $Res Function(TrafficStatsPoint) _then;

/// Create a copy of TrafficStatsPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? up = null,Object? down = null,}) {
  return _then(TrafficStatsPoint(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficStatsPoint].
extension TrafficStatsPointPatterns on TrafficStatsPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficStatsPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficStatsPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficStatsPoint value)  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficStatsPoint value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int up,  int down)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficStatsPoint() when $default != null:
return $default(_that.label,_that.up,_that.down);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int up,  int down)  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsPoint():
return $default(_that.label,_that.up,_that.down);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int up,  int down)?  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsPoint() when $default != null:
return $default(_that.label,_that.up,_that.down);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrafficStatsPoint implements TrafficStatsPoint {
  const _TrafficStatsPoint({this.label = '', this.up = 0, this.down = 0});
  factory _TrafficStatsPoint.fromJson(Map<String, dynamic> json) => _$TrafficStatsPointFromJson(json);

@override@JsonKey() final  String label;
@override@JsonKey() final  int up;
@override@JsonKey() final  int down;

/// Create a copy of TrafficStatsPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficStatsPointCopyWith<_TrafficStatsPoint> get copyWith => __$TrafficStatsPointCopyWithImpl<_TrafficStatsPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficStatsPointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficStatsPoint&&(identical(other.label, label) || other.label == label)&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,up,down);
}

@override
String toString() {
    return 'TrafficStatsPoint(label: $label, up: $up, down: $down)';
}


}

/// @nodoc
abstract mixin class _$TrafficStatsPointCopyWith<$Res> implements $TrafficStatsPointCopyWith<$Res> {
  factory _$TrafficStatsPointCopyWith(_TrafficStatsPoint value, $Res Function(_TrafficStatsPoint) _then) = __$TrafficStatsPointCopyWithImpl;
@override @useResult
$Res call({
 String label, int up, int down
});




}
/// @nodoc
class __$TrafficStatsPointCopyWithImpl<$Res>
    implements _$TrafficStatsPointCopyWith<$Res> {
  __$TrafficStatsPointCopyWithImpl(this._self, this._then);

  final _TrafficStatsPoint _self;
  final $Res Function(_TrafficStatsPoint) _then;

/// Create a copy of TrafficStatsPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? up = null,Object? down = null,}) {
  return _then(_TrafficStatsPoint(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TrafficStatsResult {

 int get up; int get down;@JsonKey(name: 'proxy-up') int get proxyUp;@JsonKey(name: 'proxy-down') int get proxyDown; List<TrafficStatsPoint> get series; List<TrafficStatsItem> get hosts; List<TrafficStatsItem> get processes; List<TrafficStatsItem> get nodes; List<TrafficStatsItem> get profiles; List<TrafficStatsItem> get rules;@JsonKey(name: 'rule-hits') int get ruleHits; String get since;
/// Create a copy of TrafficStatsResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficStatsResultCopyWith<TrafficStatsResult> get copyWith => _$TrafficStatsResultCopyWithImpl<TrafficStatsResult>(this as TrafficStatsResult, _$identity);

  /// Serializes this TrafficStatsResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrafficStatsResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficStatsResult&&(identical(other.up, _this.up) || other.up == _this.up)&&(identical(other.down, _this.down) || other.down == _this.down)&&(identical(other.proxyUp, _this.proxyUp) || other.proxyUp == _this.proxyUp)&&(identical(other.proxyDown, _this.proxyDown) || other.proxyDown == _this.proxyDown)&&const DeepCollectionEquality().equals(other.series, _this.series)&&const DeepCollectionEquality().equals(other.hosts, _this.hosts)&&const DeepCollectionEquality().equals(other.processes, _this.processes)&&const DeepCollectionEquality().equals(other.nodes, _this.nodes)&&const DeepCollectionEquality().equals(other.profiles, _this.profiles)&&const DeepCollectionEquality().equals(other.rules, _this.rules)&&(identical(other.ruleHits, _this.ruleHits) || other.ruleHits == _this.ruleHits)&&(identical(other.since, _this.since) || other.since == _this.since));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrafficStatsResult;
  return Object.hash(runtimeType,_this.up,_this.down,_this.proxyUp,_this.proxyDown,const DeepCollectionEquality().hash(_this.series),const DeepCollectionEquality().hash(_this.hosts),const DeepCollectionEquality().hash(_this.processes),const DeepCollectionEquality().hash(_this.nodes),const DeepCollectionEquality().hash(_this.profiles),const DeepCollectionEquality().hash(_this.rules),_this.ruleHits,_this.since);
}

@override
String toString() {
  final _this = this as TrafficStatsResult;
  return 'TrafficStatsResult(up: ${_this.up}, down: ${_this.down}, proxyUp: ${_this.proxyUp}, proxyDown: ${_this.proxyDown}, series: ${_this.series}, hosts: ${_this.hosts}, processes: ${_this.processes}, nodes: ${_this.nodes}, profiles: ${_this.profiles}, rules: ${_this.rules}, ruleHits: ${_this.ruleHits}, since: ${_this.since})';
}


}

/// @nodoc
abstract mixin class $TrafficStatsResultCopyWith<$Res>  {
  factory $TrafficStatsResultCopyWith(TrafficStatsResult value, $Res Function(TrafficStatsResult) _then) = _$TrafficStatsResultCopyWithImpl;
@useResult
$Res call({
 int up, int down,@JsonKey(name: 'proxy-up') int proxyUp,@JsonKey(name: 'proxy-down') int proxyDown, List<TrafficStatsPoint> series, List<TrafficStatsItem> hosts, List<TrafficStatsItem> processes, List<TrafficStatsItem> nodes, List<TrafficStatsItem> profiles, List<TrafficStatsItem> rules,@JsonKey(name: 'rule-hits') int ruleHits, String since
});




}
/// @nodoc
class _$TrafficStatsResultCopyWithImpl<$Res>
    implements $TrafficStatsResultCopyWith<$Res> {
  _$TrafficStatsResultCopyWithImpl(this._self, this._then);

  final TrafficStatsResult _self;
  final $Res Function(TrafficStatsResult) _then;

/// Create a copy of TrafficStatsResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? up = null,Object? down = null,Object? proxyUp = null,Object? proxyDown = null,Object? series = null,Object? hosts = null,Object? processes = null,Object? nodes = null,Object? profiles = null,Object? rules = null,Object? ruleHits = null,Object? since = null,}) {
  return _then(TrafficStatsResult(
up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,proxyUp: null == proxyUp ? _self.proxyUp : proxyUp // ignore: cast_nullable_to_non_nullable
as int,proxyDown: null == proxyDown ? _self.proxyDown : proxyDown // ignore: cast_nullable_to_non_nullable
as int,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsPoint>,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,processes: null == processes ? _self.processes : processes // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,ruleHits: null == ruleHits ? _self.ruleHits : ruleHits // ignore: cast_nullable_to_non_nullable
as int,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficStatsResult].
extension TrafficStatsResultPatterns on TrafficStatsResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficStatsResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficStatsResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficStatsResult value)  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficStatsResult value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficStatsResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int up,  int down, @JsonKey(name: 'proxy-up')  int proxyUp, @JsonKey(name: 'proxy-down')  int proxyDown,  List<TrafficStatsPoint> series,  List<TrafficStatsItem> hosts,  List<TrafficStatsItem> processes,  List<TrafficStatsItem> nodes,  List<TrafficStatsItem> profiles,  List<TrafficStatsItem> rules, @JsonKey(name: 'rule-hits')  int ruleHits,  String since)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficStatsResult() when $default != null:
return $default(_that.up,_that.down,_that.proxyUp,_that.proxyDown,_that.series,_that.hosts,_that.processes,_that.nodes,_that.profiles,_that.rules,_that.ruleHits,_that.since);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int up,  int down, @JsonKey(name: 'proxy-up')  int proxyUp, @JsonKey(name: 'proxy-down')  int proxyDown,  List<TrafficStatsPoint> series,  List<TrafficStatsItem> hosts,  List<TrafficStatsItem> processes,  List<TrafficStatsItem> nodes,  List<TrafficStatsItem> profiles,  List<TrafficStatsItem> rules, @JsonKey(name: 'rule-hits')  int ruleHits,  String since)  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsResult():
return $default(_that.up,_that.down,_that.proxyUp,_that.proxyDown,_that.series,_that.hosts,_that.processes,_that.nodes,_that.profiles,_that.rules,_that.ruleHits,_that.since);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int up,  int down, @JsonKey(name: 'proxy-up')  int proxyUp, @JsonKey(name: 'proxy-down')  int proxyDown,  List<TrafficStatsPoint> series,  List<TrafficStatsItem> hosts,  List<TrafficStatsItem> processes,  List<TrafficStatsItem> nodes,  List<TrafficStatsItem> profiles,  List<TrafficStatsItem> rules, @JsonKey(name: 'rule-hits')  int ruleHits,  String since)?  $default,) {final _that = this;
switch (_that) {
case _TrafficStatsResult() when $default != null:
return $default(_that.up,_that.down,_that.proxyUp,_that.proxyDown,_that.series,_that.hosts,_that.processes,_that.nodes,_that.profiles,_that.rules,_that.ruleHits,_that.since);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrafficStatsResult implements TrafficStatsResult {
  const _TrafficStatsResult({this.up = 0, this.down = 0, @JsonKey(name: 'proxy-up') this.proxyUp = 0, @JsonKey(name: 'proxy-down') this.proxyDown = 0,  List<TrafficStatsPoint> series = const [],  List<TrafficStatsItem> hosts = const [],  List<TrafficStatsItem> processes = const [],  List<TrafficStatsItem> nodes = const [],  List<TrafficStatsItem> profiles = const [],  List<TrafficStatsItem> rules = const [], @JsonKey(name: 'rule-hits') this.ruleHits = 0, this.since = ''}): _series = series,_hosts = hosts,_processes = processes,_nodes = nodes,_profiles = profiles,_rules = rules;
  factory _TrafficStatsResult.fromJson(Map<String, dynamic> json) => _$TrafficStatsResultFromJson(json);

@override@JsonKey() final  int up;
@override@JsonKey() final  int down;
@override@JsonKey(name: 'proxy-up') final  int proxyUp;
@override@JsonKey(name: 'proxy-down') final  int proxyDown;
 final  List<TrafficStatsPoint> _series;
@override@JsonKey() List<TrafficStatsPoint> get series {
  if (_series is EqualUnmodifiableListView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_series);
}

 final  List<TrafficStatsItem> _hosts;
@override@JsonKey() List<TrafficStatsItem> get hosts {
  if (_hosts is EqualUnmodifiableListView) return _hosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hosts);
}

 final  List<TrafficStatsItem> _processes;
@override@JsonKey() List<TrafficStatsItem> get processes {
  if (_processes is EqualUnmodifiableListView) return _processes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_processes);
}

 final  List<TrafficStatsItem> _nodes;
@override@JsonKey() List<TrafficStatsItem> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}

 final  List<TrafficStatsItem> _profiles;
@override@JsonKey() List<TrafficStatsItem> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

 final  List<TrafficStatsItem> _rules;
@override@JsonKey() List<TrafficStatsItem> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

@override@JsonKey(name: 'rule-hits') final  int ruleHits;
@override@JsonKey() final  String since;

/// Create a copy of TrafficStatsResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficStatsResultCopyWith<_TrafficStatsResult> get copyWith => __$TrafficStatsResultCopyWithImpl<_TrafficStatsResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficStatsResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficStatsResult&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down)&&(identical(other.proxyUp, proxyUp) || other.proxyUp == proxyUp)&&(identical(other.proxyDown, proxyDown) || other.proxyDown == proxyDown)&&const DeepCollectionEquality().equals(other.series, _series)&&const DeepCollectionEquality().equals(other.hosts, _hosts)&&const DeepCollectionEquality().equals(other.processes, _processes)&&const DeepCollectionEquality().equals(other.nodes, _nodes)&&const DeepCollectionEquality().equals(other.profiles, _profiles)&&const DeepCollectionEquality().equals(other.rules, _rules)&&(identical(other.ruleHits, ruleHits) || other.ruleHits == ruleHits)&&(identical(other.since, since) || other.since == since));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,up,down,proxyUp,proxyDown,const DeepCollectionEquality().hash(_series),const DeepCollectionEquality().hash(_hosts),const DeepCollectionEquality().hash(_processes),const DeepCollectionEquality().hash(_nodes),const DeepCollectionEquality().hash(_profiles),const DeepCollectionEquality().hash(_rules),ruleHits,since);
}

@override
String toString() {
    return 'TrafficStatsResult(up: $up, down: $down, proxyUp: $proxyUp, proxyDown: $proxyDown, series: $series, hosts: $hosts, processes: $processes, nodes: $nodes, profiles: $profiles, rules: $rules, ruleHits: $ruleHits, since: $since)';
}


}

/// @nodoc
abstract mixin class _$TrafficStatsResultCopyWith<$Res> implements $TrafficStatsResultCopyWith<$Res> {
  factory _$TrafficStatsResultCopyWith(_TrafficStatsResult value, $Res Function(_TrafficStatsResult) _then) = __$TrafficStatsResultCopyWithImpl;
@override @useResult
$Res call({
 int up, int down,@JsonKey(name: 'proxy-up') int proxyUp,@JsonKey(name: 'proxy-down') int proxyDown, List<TrafficStatsPoint> series, List<TrafficStatsItem> hosts, List<TrafficStatsItem> processes, List<TrafficStatsItem> nodes, List<TrafficStatsItem> profiles, List<TrafficStatsItem> rules,@JsonKey(name: 'rule-hits') int ruleHits, String since
});




}
/// @nodoc
class __$TrafficStatsResultCopyWithImpl<$Res>
    implements _$TrafficStatsResultCopyWith<$Res> {
  __$TrafficStatsResultCopyWithImpl(this._self, this._then);

  final _TrafficStatsResult _self;
  final $Res Function(_TrafficStatsResult) _then;

/// Create a copy of TrafficStatsResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? up = null,Object? down = null,Object? proxyUp = null,Object? proxyDown = null,Object? series = null,Object? hosts = null,Object? processes = null,Object? nodes = null,Object? profiles = null,Object? rules = null,Object? ruleHits = null,Object? since = null,}) {
  return _then(_TrafficStatsResult(
up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,proxyUp: null == proxyUp ? _self.proxyUp : proxyUp // ignore: cast_nullable_to_non_nullable
as int,proxyDown: null == proxyDown ? _self.proxyDown : proxyDown // ignore: cast_nullable_to_non_nullable
as int,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsPoint>,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,processes: null == processes ? _self._processes : processes // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<TrafficStatsItem>,ruleHits: null == ruleHits ? _self.ruleHits : ruleHits // ignore: cast_nullable_to_non_nullable
as int,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
