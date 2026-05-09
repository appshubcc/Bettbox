// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../clash_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProxyGroup {

 String get name;@JsonKey(fromJson: GroupType.parseProfileType) GroupType get type;@JsonKey(fromJson: _parseStringList) List<String>? get proxies;@JsonKey(fromJson: _parseStringList) List<String>? get use;@JsonKey(fromJson: _parseInt) int? get interval;@JsonKey(fromJson: _parseBool) bool? get lazy; String? get url;@JsonKey(fromJson: _parseInt) int? get timeout;@JsonKey(name: 'max-failed-times', fromJson: _parseInt) int? get maxFailedTimes; String? get filter;@JsonKey(name: 'expected-filter') String? get excludeFilter;@JsonKey(name: 'exclude-type') String? get excludeType;@JsonKey(name: 'expected-status') dynamic get expectedStatus;@JsonKey(fromJson: _parseBool) bool? get hidden; String? get icon;@JsonKey(fromJson: _parseInt) int? get tolerance;
/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyGroupCopyWith<ProxyGroup> get copyWith => _$ProxyGroupCopyWithImpl<ProxyGroup>(this as ProxyGroup, _$identity);

  /// Serializes this ProxyGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyGroup&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.proxies, proxies)&&const DeepCollectionEquality().equals(other.use, use)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.url, url) || other.url == url)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.maxFailedTimes, maxFailedTimes) || other.maxFailedTimes == maxFailedTimes)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.excludeFilter, excludeFilter) || other.excludeFilter == excludeFilter)&&(identical(other.excludeType, excludeType) || other.excludeType == excludeType)&&const DeepCollectionEquality().equals(other.expectedStatus, expectedStatus)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.tolerance, tolerance) || other.tolerance == tolerance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,const DeepCollectionEquality().hash(proxies),const DeepCollectionEquality().hash(use),interval,lazy,url,timeout,maxFailedTimes,filter,excludeFilter,excludeType,const DeepCollectionEquality().hash(expectedStatus),hidden,icon,tolerance);

@override
String toString() {
  return 'ProxyGroup(name: $name, type: $type, proxies: $proxies, use: $use, interval: $interval, lazy: $lazy, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, hidden: $hidden, icon: $icon, tolerance: $tolerance)';
}


}

/// @nodoc
abstract mixin class $ProxyGroupCopyWith<$Res>  {
  factory $ProxyGroupCopyWith(ProxyGroup value, $Res Function(ProxyGroup) _then) = _$ProxyGroupCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(fromJson: GroupType.parseProfileType) GroupType type,@JsonKey(fromJson: _parseStringList) List<String>? proxies,@JsonKey(fromJson: _parseStringList) List<String>? use,@JsonKey(fromJson: _parseInt) int? interval,@JsonKey(fromJson: _parseBool) bool? lazy, String? url,@JsonKey(fromJson: _parseInt) int? timeout,@JsonKey(name: 'max-failed-times', fromJson: _parseInt) int? maxFailedTimes, String? filter,@JsonKey(name: 'expected-filter') String? excludeFilter,@JsonKey(name: 'exclude-type') String? excludeType,@JsonKey(name: 'expected-status') dynamic expectedStatus,@JsonKey(fromJson: _parseBool) bool? hidden, String? icon,@JsonKey(fromJson: _parseInt) int? tolerance
});




}
/// @nodoc
class _$ProxyGroupCopyWithImpl<$Res>
    implements $ProxyGroupCopyWith<$Res> {
  _$ProxyGroupCopyWithImpl(this._self, this._then);

  final ProxyGroup _self;
  final $Res Function(ProxyGroup) _then;

/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? proxies = freezed,Object? use = freezed,Object? interval = freezed,Object? lazy = freezed,Object? url = freezed,Object? timeout = freezed,Object? maxFailedTimes = freezed,Object? filter = freezed,Object? excludeFilter = freezed,Object? excludeType = freezed,Object? expectedStatus = freezed,Object? hidden = freezed,Object? icon = freezed,Object? tolerance = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: freezed == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<String>?,use: freezed == use ? _self.use : use // ignore: cast_nullable_to_non_nullable
as List<String>?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,lazy: freezed == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,maxFailedTimes: freezed == maxFailedTimes ? _self.maxFailedTimes : maxFailedTimes // ignore: cast_nullable_to_non_nullable
as int?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String?,excludeFilter: freezed == excludeFilter ? _self.excludeFilter : excludeFilter // ignore: cast_nullable_to_non_nullable
as String?,excludeType: freezed == excludeType ? _self.excludeType : excludeType // ignore: cast_nullable_to_non_nullable
as String?,expectedStatus: freezed == expectedStatus ? _self.expectedStatus : expectedStatus // ignore: cast_nullable_to_non_nullable
as dynamic,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,tolerance: freezed == tolerance ? _self.tolerance : tolerance // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxyGroup].
extension ProxyGroupPatterns on ProxyGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyGroup value)  $default,){
final _that = this;
switch (_that) {
case _ProxyGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(fromJson: GroupType.parseProfileType)  GroupType type, @JsonKey(fromJson: _parseStringList)  List<String>? proxies, @JsonKey(fromJson: _parseStringList)  List<String>? use, @JsonKey(fromJson: _parseInt)  int? interval, @JsonKey(fromJson: _parseBool)  bool? lazy,  String? url, @JsonKey(fromJson: _parseInt)  int? timeout, @JsonKey(name: 'max-failed-times', fromJson: _parseInt)  int? maxFailedTimes,  String? filter, @JsonKey(name: 'expected-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  dynamic expectedStatus, @JsonKey(fromJson: _parseBool)  bool? hidden,  String? icon, @JsonKey(fromJson: _parseInt)  int? tolerance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.hidden,_that.icon,_that.tolerance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(fromJson: GroupType.parseProfileType)  GroupType type, @JsonKey(fromJson: _parseStringList)  List<String>? proxies, @JsonKey(fromJson: _parseStringList)  List<String>? use, @JsonKey(fromJson: _parseInt)  int? interval, @JsonKey(fromJson: _parseBool)  bool? lazy,  String? url, @JsonKey(fromJson: _parseInt)  int? timeout, @JsonKey(name: 'max-failed-times', fromJson: _parseInt)  int? maxFailedTimes,  String? filter, @JsonKey(name: 'expected-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  dynamic expectedStatus, @JsonKey(fromJson: _parseBool)  bool? hidden,  String? icon, @JsonKey(fromJson: _parseInt)  int? tolerance)  $default,) {final _that = this;
switch (_that) {
case _ProxyGroup():
return $default(_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.hidden,_that.icon,_that.tolerance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(fromJson: GroupType.parseProfileType)  GroupType type, @JsonKey(fromJson: _parseStringList)  List<String>? proxies, @JsonKey(fromJson: _parseStringList)  List<String>? use, @JsonKey(fromJson: _parseInt)  int? interval, @JsonKey(fromJson: _parseBool)  bool? lazy,  String? url, @JsonKey(fromJson: _parseInt)  int? timeout, @JsonKey(name: 'max-failed-times', fromJson: _parseInt)  int? maxFailedTimes,  String? filter, @JsonKey(name: 'expected-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  dynamic expectedStatus, @JsonKey(fromJson: _parseBool)  bool? hidden,  String? icon, @JsonKey(fromJson: _parseInt)  int? tolerance)?  $default,) {final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.hidden,_that.icon,_that.tolerance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxyGroup implements ProxyGroup {
  const _ProxyGroup({required this.name, @JsonKey(fromJson: GroupType.parseProfileType) required this.type, @JsonKey(fromJson: _parseStringList) final  List<String>? proxies, @JsonKey(fromJson: _parseStringList) final  List<String>? use, @JsonKey(fromJson: _parseInt) this.interval, @JsonKey(fromJson: _parseBool) this.lazy, this.url, @JsonKey(fromJson: _parseInt) this.timeout, @JsonKey(name: 'max-failed-times', fromJson: _parseInt) this.maxFailedTimes, this.filter, @JsonKey(name: 'expected-filter') this.excludeFilter, @JsonKey(name: 'exclude-type') this.excludeType, @JsonKey(name: 'expected-status') this.expectedStatus, @JsonKey(fromJson: _parseBool) this.hidden, this.icon, @JsonKey(fromJson: _parseInt) this.tolerance}): _proxies = proxies,_use = use;
  factory _ProxyGroup.fromJson(Map<String, dynamic> json) => _$ProxyGroupFromJson(json);

@override final  String name;
@override@JsonKey(fromJson: GroupType.parseProfileType) final  GroupType type;
 final  List<String>? _proxies;
@override@JsonKey(fromJson: _parseStringList) List<String>? get proxies {
  final value = _proxies;
  if (value == null) return null;
  if (_proxies is EqualUnmodifiableListView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _use;
@override@JsonKey(fromJson: _parseStringList) List<String>? get use {
  final value = _use;
  if (value == null) return null;
  if (_use is EqualUnmodifiableListView) return _use;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(fromJson: _parseInt) final  int? interval;
@override@JsonKey(fromJson: _parseBool) final  bool? lazy;
@override final  String? url;
@override@JsonKey(fromJson: _parseInt) final  int? timeout;
@override@JsonKey(name: 'max-failed-times', fromJson: _parseInt) final  int? maxFailedTimes;
@override final  String? filter;
@override@JsonKey(name: 'expected-filter') final  String? excludeFilter;
@override@JsonKey(name: 'exclude-type') final  String? excludeType;
@override@JsonKey(name: 'expected-status') final  dynamic expectedStatus;
@override@JsonKey(fromJson: _parseBool) final  bool? hidden;
@override final  String? icon;
@override@JsonKey(fromJson: _parseInt) final  int? tolerance;

/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyGroupCopyWith<_ProxyGroup> get copyWith => __$ProxyGroupCopyWithImpl<_ProxyGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyGroup&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._proxies, _proxies)&&const DeepCollectionEquality().equals(other._use, _use)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.url, url) || other.url == url)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.maxFailedTimes, maxFailedTimes) || other.maxFailedTimes == maxFailedTimes)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.excludeFilter, excludeFilter) || other.excludeFilter == excludeFilter)&&(identical(other.excludeType, excludeType) || other.excludeType == excludeType)&&const DeepCollectionEquality().equals(other.expectedStatus, expectedStatus)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.tolerance, tolerance) || other.tolerance == tolerance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_use),interval,lazy,url,timeout,maxFailedTimes,filter,excludeFilter,excludeType,const DeepCollectionEquality().hash(expectedStatus),hidden,icon,tolerance);

@override
String toString() {
  return 'ProxyGroup(name: $name, type: $type, proxies: $proxies, use: $use, interval: $interval, lazy: $lazy, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, hidden: $hidden, icon: $icon, tolerance: $tolerance)';
}


}

/// @nodoc
abstract mixin class _$ProxyGroupCopyWith<$Res> implements $ProxyGroupCopyWith<$Res> {
  factory _$ProxyGroupCopyWith(_ProxyGroup value, $Res Function(_ProxyGroup) _then) = __$ProxyGroupCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(fromJson: GroupType.parseProfileType) GroupType type,@JsonKey(fromJson: _parseStringList) List<String>? proxies,@JsonKey(fromJson: _parseStringList) List<String>? use,@JsonKey(fromJson: _parseInt) int? interval,@JsonKey(fromJson: _parseBool) bool? lazy, String? url,@JsonKey(fromJson: _parseInt) int? timeout,@JsonKey(name: 'max-failed-times', fromJson: _parseInt) int? maxFailedTimes, String? filter,@JsonKey(name: 'expected-filter') String? excludeFilter,@JsonKey(name: 'exclude-type') String? excludeType,@JsonKey(name: 'expected-status') dynamic expectedStatus,@JsonKey(fromJson: _parseBool) bool? hidden, String? icon,@JsonKey(fromJson: _parseInt) int? tolerance
});




}
/// @nodoc
class __$ProxyGroupCopyWithImpl<$Res>
    implements _$ProxyGroupCopyWith<$Res> {
  __$ProxyGroupCopyWithImpl(this._self, this._then);

  final _ProxyGroup _self;
  final $Res Function(_ProxyGroup) _then;

/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? proxies = freezed,Object? use = freezed,Object? interval = freezed,Object? lazy = freezed,Object? url = freezed,Object? timeout = freezed,Object? maxFailedTimes = freezed,Object? filter = freezed,Object? excludeFilter = freezed,Object? excludeType = freezed,Object? expectedStatus = freezed,Object? hidden = freezed,Object? icon = freezed,Object? tolerance = freezed,}) {
  return _then(_ProxyGroup(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: freezed == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<String>?,use: freezed == use ? _self._use : use // ignore: cast_nullable_to_non_nullable
as List<String>?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,lazy: freezed == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,maxFailedTimes: freezed == maxFailedTimes ? _self.maxFailedTimes : maxFailedTimes // ignore: cast_nullable_to_non_nullable
as int?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String?,excludeFilter: freezed == excludeFilter ? _self.excludeFilter : excludeFilter // ignore: cast_nullable_to_non_nullable
as String?,excludeType: freezed == excludeType ? _self.excludeType : excludeType // ignore: cast_nullable_to_non_nullable
as String?,expectedStatus: freezed == expectedStatus ? _self.expectedStatus : expectedStatus // ignore: cast_nullable_to_non_nullable
as dynamic,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,tolerance: freezed == tolerance ? _self.tolerance : tolerance // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RuleProvider {

 String get name;
/// Create a copy of RuleProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleProviderCopyWith<RuleProvider> get copyWith => _$RuleProviderCopyWithImpl<RuleProvider>(this as RuleProvider, _$identity);

  /// Serializes this RuleProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuleProvider&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'RuleProvider(name: $name)';
}


}

/// @nodoc
abstract mixin class $RuleProviderCopyWith<$Res>  {
  factory $RuleProviderCopyWith(RuleProvider value, $Res Function(RuleProvider) _then) = _$RuleProviderCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$RuleProviderCopyWithImpl<$Res>
    implements $RuleProviderCopyWith<$Res> {
  _$RuleProviderCopyWithImpl(this._self, this._then);

  final RuleProvider _self;
  final $Res Function(RuleProvider) _then;

/// Create a copy of RuleProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RuleProvider].
extension RuleProviderPatterns on RuleProvider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RuleProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RuleProvider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RuleProvider value)  $default,){
final _that = this;
switch (_that) {
case _RuleProvider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RuleProvider value)?  $default,){
final _that = this;
switch (_that) {
case _RuleProvider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RuleProvider() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _RuleProvider():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _RuleProvider() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RuleProvider implements RuleProvider {
  const _RuleProvider({required this.name});
  factory _RuleProvider.fromJson(Map<String, dynamic> json) => _$RuleProviderFromJson(json);

@override final  String name;

/// Create a copy of RuleProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuleProviderCopyWith<_RuleProvider> get copyWith => __$RuleProviderCopyWithImpl<_RuleProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuleProviderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuleProvider&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'RuleProvider(name: $name)';
}


}

/// @nodoc
abstract mixin class _$RuleProviderCopyWith<$Res> implements $RuleProviderCopyWith<$Res> {
  factory _$RuleProviderCopyWith(_RuleProvider value, $Res Function(_RuleProvider) _then) = __$RuleProviderCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$RuleProviderCopyWithImpl<$Res>
    implements _$RuleProviderCopyWith<$Res> {
  __$RuleProviderCopyWithImpl(this._self, this._then);

  final _RuleProvider _self;
  final $Res Function(_RuleProvider) _then;

/// Create a copy of RuleProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_RuleProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Sniffer {

 bool get enable;@JsonKey(name: 'override-destination') bool get overrideDest; List<String> get sniffing;@JsonKey(name: 'force-domain') List<String> get forceDomain;@JsonKey(name: 'skip-src-address') List<String> get skipSrcAddress;@JsonKey(name: 'skip-dst-address') List<String> get skipDstAddress;@JsonKey(name: 'skip-domain') List<String> get skipDomain;@JsonKey(name: 'port-whitelist') List<String> get port;@JsonKey(name: 'force-dns-mapping') bool get forceDnsMapping;@JsonKey(name: 'parse-pure-ip') bool get parsePureIp; Map<String, SnifferConfig> get sniff;
/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnifferCopyWith<Sniffer> get copyWith => _$SnifferCopyWithImpl<Sniffer>(this as Sniffer, _$identity);

  /// Serializes this Sniffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sniffer&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest)&&const DeepCollectionEquality().equals(other.sniffing, sniffing)&&const DeepCollectionEquality().equals(other.forceDomain, forceDomain)&&const DeepCollectionEquality().equals(other.skipSrcAddress, skipSrcAddress)&&const DeepCollectionEquality().equals(other.skipDstAddress, skipDstAddress)&&const DeepCollectionEquality().equals(other.skipDomain, skipDomain)&&const DeepCollectionEquality().equals(other.port, port)&&(identical(other.forceDnsMapping, forceDnsMapping) || other.forceDnsMapping == forceDnsMapping)&&(identical(other.parsePureIp, parsePureIp) || other.parsePureIp == parsePureIp)&&const DeepCollectionEquality().equals(other.sniff, sniff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,overrideDest,const DeepCollectionEquality().hash(sniffing),const DeepCollectionEquality().hash(forceDomain),const DeepCollectionEquality().hash(skipSrcAddress),const DeepCollectionEquality().hash(skipDstAddress),const DeepCollectionEquality().hash(skipDomain),const DeepCollectionEquality().hash(port),forceDnsMapping,parsePureIp,const DeepCollectionEquality().hash(sniff));

@override
String toString() {
  return 'Sniffer(enable: $enable, overrideDest: $overrideDest, sniffing: $sniffing, forceDomain: $forceDomain, skipSrcAddress: $skipSrcAddress, skipDstAddress: $skipDstAddress, skipDomain: $skipDomain, port: $port, forceDnsMapping: $forceDnsMapping, parsePureIp: $parsePureIp, sniff: $sniff)';
}


}

/// @nodoc
abstract mixin class $SnifferCopyWith<$Res>  {
  factory $SnifferCopyWith(Sniffer value, $Res Function(Sniffer) _then) = _$SnifferCopyWithImpl;
@useResult
$Res call({
 bool enable,@JsonKey(name: 'override-destination') bool overrideDest, List<String> sniffing,@JsonKey(name: 'force-domain') List<String> forceDomain,@JsonKey(name: 'skip-src-address') List<String> skipSrcAddress,@JsonKey(name: 'skip-dst-address') List<String> skipDstAddress,@JsonKey(name: 'skip-domain') List<String> skipDomain,@JsonKey(name: 'port-whitelist') List<String> port,@JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,@JsonKey(name: 'parse-pure-ip') bool parsePureIp, Map<String, SnifferConfig> sniff
});




}
/// @nodoc
class _$SnifferCopyWithImpl<$Res>
    implements $SnifferCopyWith<$Res> {
  _$SnifferCopyWithImpl(this._self, this._then);

  final Sniffer _self;
  final $Res Function(Sniffer) _then;

/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? overrideDest = null,Object? sniffing = null,Object? forceDomain = null,Object? skipSrcAddress = null,Object? skipDstAddress = null,Object? skipDomain = null,Object? port = null,Object? forceDnsMapping = null,Object? parsePureIp = null,Object? sniff = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,overrideDest: null == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool,sniffing: null == sniffing ? _self.sniffing : sniffing // ignore: cast_nullable_to_non_nullable
as List<String>,forceDomain: null == forceDomain ? _self.forceDomain : forceDomain // ignore: cast_nullable_to_non_nullable
as List<String>,skipSrcAddress: null == skipSrcAddress ? _self.skipSrcAddress : skipSrcAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDstAddress: null == skipDstAddress ? _self.skipDstAddress : skipDstAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDomain: null == skipDomain ? _self.skipDomain : skipDomain // ignore: cast_nullable_to_non_nullable
as List<String>,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as List<String>,forceDnsMapping: null == forceDnsMapping ? _self.forceDnsMapping : forceDnsMapping // ignore: cast_nullable_to_non_nullable
as bool,parsePureIp: null == parsePureIp ? _self.parsePureIp : parsePureIp // ignore: cast_nullable_to_non_nullable
as bool,sniff: null == sniff ? _self.sniff : sniff // ignore: cast_nullable_to_non_nullable
as Map<String, SnifferConfig>,
  ));
}

}


/// Adds pattern-matching-related methods to [Sniffer].
extension SnifferPatterns on Sniffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sniffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sniffer value)  $default,){
final _that = this;
switch (_that) {
case _Sniffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sniffer value)?  $default,){
final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest,  List<String> sniffing, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'port-whitelist')  List<String> port, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp,  Map<String, SnifferConfig> sniff)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
return $default(_that.enable,_that.overrideDest,_that.sniffing,_that.forceDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.skipDomain,_that.port,_that.forceDnsMapping,_that.parsePureIp,_that.sniff);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest,  List<String> sniffing, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'port-whitelist')  List<String> port, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp,  Map<String, SnifferConfig> sniff)  $default,) {final _that = this;
switch (_that) {
case _Sniffer():
return $default(_that.enable,_that.overrideDest,_that.sniffing,_that.forceDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.skipDomain,_that.port,_that.forceDnsMapping,_that.parsePureIp,_that.sniff);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest,  List<String> sniffing, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'port-whitelist')  List<String> port, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp,  Map<String, SnifferConfig> sniff)?  $default,) {final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
return $default(_that.enable,_that.overrideDest,_that.sniffing,_that.forceDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.skipDomain,_that.port,_that.forceDnsMapping,_that.parsePureIp,_that.sniff);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sniffer implements Sniffer {
  const _Sniffer({this.enable = true, @JsonKey(name: 'override-destination') this.overrideDest = false, final  List<String> sniffing = const [], @JsonKey(name: 'force-domain') final  List<String> forceDomain = const ['+.v2ex.com'], @JsonKey(name: 'skip-src-address') final  List<String> skipSrcAddress = const ['192.168.0.3/32'], @JsonKey(name: 'skip-dst-address') final  List<String> skipDstAddress = const ['91.108.56.0/22', '91.108.4.0/22', '91.108.8.0/22', '91.108.16.0/22', '91.108.12.0/22', '149.154.160.0/20', '91.105.192.0/23', '91.108.20.0/22', '185.76.151.0/24', '2001:b28:f23d::/48', '2001:b28:f23f::/48', '2001:67c:4e8::/48', '2001:b28:f23c::/48', '2a0a:f280::/32'], @JsonKey(name: 'skip-domain') final  List<String> skipDomain = const ['Mijia Cloud', '+.push.apple.com'], @JsonKey(name: 'port-whitelist') final  List<String> port = const [], @JsonKey(name: 'force-dns-mapping') this.forceDnsMapping = true, @JsonKey(name: 'parse-pure-ip') this.parsePureIp = true, final  Map<String, SnifferConfig> sniff = const {'HTTP' : SnifferConfig(ports: ['80', '8080-8880'], overrideDest: true), 'TLS' : SnifferConfig(ports: ['443', '8443']), 'QUIC' : SnifferConfig(ports: ['443', '8443'])}}): _sniffing = sniffing,_forceDomain = forceDomain,_skipSrcAddress = skipSrcAddress,_skipDstAddress = skipDstAddress,_skipDomain = skipDomain,_port = port,_sniff = sniff;
  factory _Sniffer.fromJson(Map<String, dynamic> json) => _$SnifferFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey(name: 'override-destination') final  bool overrideDest;
 final  List<String> _sniffing;
@override@JsonKey() List<String> get sniffing {
  if (_sniffing is EqualUnmodifiableListView) return _sniffing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sniffing);
}

 final  List<String> _forceDomain;
@override@JsonKey(name: 'force-domain') List<String> get forceDomain {
  if (_forceDomain is EqualUnmodifiableListView) return _forceDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forceDomain);
}

 final  List<String> _skipSrcAddress;
@override@JsonKey(name: 'skip-src-address') List<String> get skipSrcAddress {
  if (_skipSrcAddress is EqualUnmodifiableListView) return _skipSrcAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipSrcAddress);
}

 final  List<String> _skipDstAddress;
@override@JsonKey(name: 'skip-dst-address') List<String> get skipDstAddress {
  if (_skipDstAddress is EqualUnmodifiableListView) return _skipDstAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipDstAddress);
}

 final  List<String> _skipDomain;
@override@JsonKey(name: 'skip-domain') List<String> get skipDomain {
  if (_skipDomain is EqualUnmodifiableListView) return _skipDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipDomain);
}

 final  List<String> _port;
@override@JsonKey(name: 'port-whitelist') List<String> get port {
  if (_port is EqualUnmodifiableListView) return _port;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_port);
}

@override@JsonKey(name: 'force-dns-mapping') final  bool forceDnsMapping;
@override@JsonKey(name: 'parse-pure-ip') final  bool parsePureIp;
 final  Map<String, SnifferConfig> _sniff;
@override@JsonKey() Map<String, SnifferConfig> get sniff {
  if (_sniff is EqualUnmodifiableMapView) return _sniff;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sniff);
}


/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnifferCopyWith<_Sniffer> get copyWith => __$SnifferCopyWithImpl<_Sniffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnifferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sniffer&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest)&&const DeepCollectionEquality().equals(other._sniffing, _sniffing)&&const DeepCollectionEquality().equals(other._forceDomain, _forceDomain)&&const DeepCollectionEquality().equals(other._skipSrcAddress, _skipSrcAddress)&&const DeepCollectionEquality().equals(other._skipDstAddress, _skipDstAddress)&&const DeepCollectionEquality().equals(other._skipDomain, _skipDomain)&&const DeepCollectionEquality().equals(other._port, _port)&&(identical(other.forceDnsMapping, forceDnsMapping) || other.forceDnsMapping == forceDnsMapping)&&(identical(other.parsePureIp, parsePureIp) || other.parsePureIp == parsePureIp)&&const DeepCollectionEquality().equals(other._sniff, _sniff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,overrideDest,const DeepCollectionEquality().hash(_sniffing),const DeepCollectionEquality().hash(_forceDomain),const DeepCollectionEquality().hash(_skipSrcAddress),const DeepCollectionEquality().hash(_skipDstAddress),const DeepCollectionEquality().hash(_skipDomain),const DeepCollectionEquality().hash(_port),forceDnsMapping,parsePureIp,const DeepCollectionEquality().hash(_sniff));

@override
String toString() {
  return 'Sniffer(enable: $enable, overrideDest: $overrideDest, sniffing: $sniffing, forceDomain: $forceDomain, skipSrcAddress: $skipSrcAddress, skipDstAddress: $skipDstAddress, skipDomain: $skipDomain, port: $port, forceDnsMapping: $forceDnsMapping, parsePureIp: $parsePureIp, sniff: $sniff)';
}


}

/// @nodoc
abstract mixin class _$SnifferCopyWith<$Res> implements $SnifferCopyWith<$Res> {
  factory _$SnifferCopyWith(_Sniffer value, $Res Function(_Sniffer) _then) = __$SnifferCopyWithImpl;
@override @useResult
$Res call({
 bool enable,@JsonKey(name: 'override-destination') bool overrideDest, List<String> sniffing,@JsonKey(name: 'force-domain') List<String> forceDomain,@JsonKey(name: 'skip-src-address') List<String> skipSrcAddress,@JsonKey(name: 'skip-dst-address') List<String> skipDstAddress,@JsonKey(name: 'skip-domain') List<String> skipDomain,@JsonKey(name: 'port-whitelist') List<String> port,@JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,@JsonKey(name: 'parse-pure-ip') bool parsePureIp, Map<String, SnifferConfig> sniff
});




}
/// @nodoc
class __$SnifferCopyWithImpl<$Res>
    implements _$SnifferCopyWith<$Res> {
  __$SnifferCopyWithImpl(this._self, this._then);

  final _Sniffer _self;
  final $Res Function(_Sniffer) _then;

/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? overrideDest = null,Object? sniffing = null,Object? forceDomain = null,Object? skipSrcAddress = null,Object? skipDstAddress = null,Object? skipDomain = null,Object? port = null,Object? forceDnsMapping = null,Object? parsePureIp = null,Object? sniff = null,}) {
  return _then(_Sniffer(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,overrideDest: null == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool,sniffing: null == sniffing ? _self._sniffing : sniffing // ignore: cast_nullable_to_non_nullable
as List<String>,forceDomain: null == forceDomain ? _self._forceDomain : forceDomain // ignore: cast_nullable_to_non_nullable
as List<String>,skipSrcAddress: null == skipSrcAddress ? _self._skipSrcAddress : skipSrcAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDstAddress: null == skipDstAddress ? _self._skipDstAddress : skipDstAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDomain: null == skipDomain ? _self._skipDomain : skipDomain // ignore: cast_nullable_to_non_nullable
as List<String>,port: null == port ? _self._port : port // ignore: cast_nullable_to_non_nullable
as List<String>,forceDnsMapping: null == forceDnsMapping ? _self.forceDnsMapping : forceDnsMapping // ignore: cast_nullable_to_non_nullable
as bool,parsePureIp: null == parsePureIp ? _self.parsePureIp : parsePureIp // ignore: cast_nullable_to_non_nullable
as bool,sniff: null == sniff ? _self._sniff : sniff // ignore: cast_nullable_to_non_nullable
as Map<String, SnifferConfig>,
  ));
}


}


/// @nodoc
mixin _$TunnelEntry {

 String get id; List<String>? get network; String? get address; String? get target; String? get proxyName;
/// Create a copy of TunnelEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunnelEntryCopyWith<TunnelEntry> get copyWith => _$TunnelEntryCopyWithImpl<TunnelEntry>(this as TunnelEntry, _$identity);

  /// Serializes this TunnelEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelEntry&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.network, network)&&(identical(other.address, address) || other.address == address)&&(identical(other.target, target) || other.target == target)&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(network),address,target,proxyName);

@override
String toString() {
  return 'TunnelEntry(id: $id, network: $network, address: $address, target: $target, proxyName: $proxyName)';
}


}

/// @nodoc
abstract mixin class $TunnelEntryCopyWith<$Res>  {
  factory $TunnelEntryCopyWith(TunnelEntry value, $Res Function(TunnelEntry) _then) = _$TunnelEntryCopyWithImpl;
@useResult
$Res call({
 String id, List<String>? network, String? address, String? target, String? proxyName
});




}
/// @nodoc
class _$TunnelEntryCopyWithImpl<$Res>
    implements $TunnelEntryCopyWith<$Res> {
  _$TunnelEntryCopyWithImpl(this._self, this._then);

  final TunnelEntry _self;
  final $Res Function(TunnelEntry) _then;

/// Create a copy of TunnelEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? network = freezed,Object? address = freezed,Object? target = freezed,Object? proxyName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as List<String>?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String?,proxyName: freezed == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TunnelEntry].
extension TunnelEntryPatterns on TunnelEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TunnelEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TunnelEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TunnelEntry value)  $default,){
final _that = this;
switch (_that) {
case _TunnelEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TunnelEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TunnelEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String>? network,  String? address,  String? target,  String? proxyName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TunnelEntry() when $default != null:
return $default(_that.id,_that.network,_that.address,_that.target,_that.proxyName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String>? network,  String? address,  String? target,  String? proxyName)  $default,) {final _that = this;
switch (_that) {
case _TunnelEntry():
return $default(_that.id,_that.network,_that.address,_that.target,_that.proxyName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String>? network,  String? address,  String? target,  String? proxyName)?  $default,) {final _that = this;
switch (_that) {
case _TunnelEntry() when $default != null:
return $default(_that.id,_that.network,_that.address,_that.target,_that.proxyName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TunnelEntry implements TunnelEntry {
  const _TunnelEntry({required this.id, final  List<String>? network, this.address, this.target, this.proxyName}): _network = network;
  factory _TunnelEntry.fromJson(Map<String, dynamic> json) => _$TunnelEntryFromJson(json);

@override final  String id;
 final  List<String>? _network;
@override List<String>? get network {
  final value = _network;
  if (value == null) return null;
  if (_network is EqualUnmodifiableListView) return _network;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? address;
@override final  String? target;
@override final  String? proxyName;

/// Create a copy of TunnelEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunnelEntryCopyWith<_TunnelEntry> get copyWith => __$TunnelEntryCopyWithImpl<_TunnelEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TunnelEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TunnelEntry&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._network, _network)&&(identical(other.address, address) || other.address == address)&&(identical(other.target, target) || other.target == target)&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_network),address,target,proxyName);

@override
String toString() {
  return 'TunnelEntry(id: $id, network: $network, address: $address, target: $target, proxyName: $proxyName)';
}


}

/// @nodoc
abstract mixin class _$TunnelEntryCopyWith<$Res> implements $TunnelEntryCopyWith<$Res> {
  factory _$TunnelEntryCopyWith(_TunnelEntry value, $Res Function(_TunnelEntry) _then) = __$TunnelEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String>? network, String? address, String? target, String? proxyName
});




}
/// @nodoc
class __$TunnelEntryCopyWithImpl<$Res>
    implements _$TunnelEntryCopyWith<$Res> {
  __$TunnelEntryCopyWithImpl(this._self, this._then);

  final _TunnelEntry _self;
  final $Res Function(_TunnelEntry) _then;

/// Create a copy of TunnelEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? network = freezed,Object? address = freezed,Object? target = freezed,Object? proxyName = freezed,}) {
  return _then(_TunnelEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,network: freezed == network ? _self._network : network // ignore: cast_nullable_to_non_nullable
as List<String>?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String?,proxyName: freezed == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnifferConfig {

@JsonKey(fromJson: _formJsonPorts) List<String> get ports;@JsonKey(name: 'override-destination') bool? get overrideDest;
/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnifferConfigCopyWith<SnifferConfig> get copyWith => _$SnifferConfigCopyWithImpl<SnifferConfig>(this as SnifferConfig, _$identity);

  /// Serializes this SnifferConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnifferConfig&&const DeepCollectionEquality().equals(other.ports, ports)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ports),overrideDest);

@override
String toString() {
  return 'SnifferConfig(ports: $ports, overrideDest: $overrideDest)';
}


}

/// @nodoc
abstract mixin class $SnifferConfigCopyWith<$Res>  {
  factory $SnifferConfigCopyWith(SnifferConfig value, $Res Function(SnifferConfig) _then) = _$SnifferConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _formJsonPorts) List<String> ports,@JsonKey(name: 'override-destination') bool? overrideDest
});




}
/// @nodoc
class _$SnifferConfigCopyWithImpl<$Res>
    implements $SnifferConfigCopyWith<$Res> {
  _$SnifferConfigCopyWithImpl(this._self, this._then);

  final SnifferConfig _self;
  final $Res Function(SnifferConfig) _then;

/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ports = null,Object? overrideDest = freezed,}) {
  return _then(_self.copyWith(
ports: null == ports ? _self.ports : ports // ignore: cast_nullable_to_non_nullable
as List<String>,overrideDest: freezed == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnifferConfig].
extension SnifferConfigPatterns on SnifferConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnifferConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnifferConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnifferConfig value)  $default,){
final _that = this;
switch (_that) {
case _SnifferConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnifferConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SnifferConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination')  bool? overrideDest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnifferConfig() when $default != null:
return $default(_that.ports,_that.overrideDest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination')  bool? overrideDest)  $default,) {final _that = this;
switch (_that) {
case _SnifferConfig():
return $default(_that.ports,_that.overrideDest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination')  bool? overrideDest)?  $default,) {final _that = this;
switch (_that) {
case _SnifferConfig() when $default != null:
return $default(_that.ports,_that.overrideDest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnifferConfig implements SnifferConfig {
  const _SnifferConfig({@JsonKey(fromJson: _formJsonPorts) final  List<String> ports = const [], @JsonKey(name: 'override-destination') this.overrideDest}): _ports = ports;
  factory _SnifferConfig.fromJson(Map<String, dynamic> json) => _$SnifferConfigFromJson(json);

 final  List<String> _ports;
@override@JsonKey(fromJson: _formJsonPorts) List<String> get ports {
  if (_ports is EqualUnmodifiableListView) return _ports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ports);
}

@override@JsonKey(name: 'override-destination') final  bool? overrideDest;

/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnifferConfigCopyWith<_SnifferConfig> get copyWith => __$SnifferConfigCopyWithImpl<_SnifferConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnifferConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnifferConfig&&const DeepCollectionEquality().equals(other._ports, _ports)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ports),overrideDest);

@override
String toString() {
  return 'SnifferConfig(ports: $ports, overrideDest: $overrideDest)';
}


}

/// @nodoc
abstract mixin class _$SnifferConfigCopyWith<$Res> implements $SnifferConfigCopyWith<$Res> {
  factory _$SnifferConfigCopyWith(_SnifferConfig value, $Res Function(_SnifferConfig) _then) = __$SnifferConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _formJsonPorts) List<String> ports,@JsonKey(name: 'override-destination') bool? overrideDest
});




}
/// @nodoc
class __$SnifferConfigCopyWithImpl<$Res>
    implements _$SnifferConfigCopyWith<$Res> {
  __$SnifferConfigCopyWithImpl(this._self, this._then);

  final _SnifferConfig _self;
  final $Res Function(_SnifferConfig) _then;

/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ports = null,Object? overrideDest = freezed,}) {
  return _then(_SnifferConfig(
ports: null == ports ? _self._ports : ports // ignore: cast_nullable_to_non_nullable
as List<String>,overrideDest: freezed == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$Tun {

 bool get enable; String get device;@JsonKey(name: 'auto-route') bool get autoRoute; TunStack get stack;@JsonKey(name: 'dns-hijack') List<String> get dnsHijack;@JsonKey(name: 'route-address') List<String> get routeAddress;@JsonKey(name: 'route-exclude-address') List<String> get routeExcludeAddress;@JsonKey(name: 'strict-route') bool get strictRoute;@JsonKey(name: 'disable-icmp-forwarding') bool get disableIcmpForwarding; int get mtu;@JsonKey(name: 'endpoint-independent-nat') bool get endpointIndependentNat;
/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunCopyWith<Tun> get copyWith => _$TunCopyWithImpl<Tun>(this as Tun, _$identity);

  /// Serializes this Tun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tun&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.device, device) || other.device == device)&&(identical(other.autoRoute, autoRoute) || other.autoRoute == autoRoute)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other.dnsHijack, dnsHijack)&&const DeepCollectionEquality().equals(other.routeAddress, routeAddress)&&const DeepCollectionEquality().equals(other.routeExcludeAddress, routeExcludeAddress)&&(identical(other.strictRoute, strictRoute) || other.strictRoute == strictRoute)&&(identical(other.disableIcmpForwarding, disableIcmpForwarding) || other.disableIcmpForwarding == disableIcmpForwarding)&&(identical(other.mtu, mtu) || other.mtu == mtu)&&(identical(other.endpointIndependentNat, endpointIndependentNat) || other.endpointIndependentNat == endpointIndependentNat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,device,autoRoute,stack,const DeepCollectionEquality().hash(dnsHijack),const DeepCollectionEquality().hash(routeAddress),const DeepCollectionEquality().hash(routeExcludeAddress),strictRoute,disableIcmpForwarding,mtu,endpointIndependentNat);

@override
String toString() {
  return 'Tun(enable: $enable, device: $device, autoRoute: $autoRoute, stack: $stack, dnsHijack: $dnsHijack, routeAddress: $routeAddress, routeExcludeAddress: $routeExcludeAddress, strictRoute: $strictRoute, disableIcmpForwarding: $disableIcmpForwarding, mtu: $mtu, endpointIndependentNat: $endpointIndependentNat)';
}


}

/// @nodoc
abstract mixin class $TunCopyWith<$Res>  {
  factory $TunCopyWith(Tun value, $Res Function(Tun) _then) = _$TunCopyWithImpl;
@useResult
$Res call({
 bool enable, String device,@JsonKey(name: 'auto-route') bool autoRoute, TunStack stack,@JsonKey(name: 'dns-hijack') List<String> dnsHijack,@JsonKey(name: 'route-address') List<String> routeAddress,@JsonKey(name: 'route-exclude-address') List<String> routeExcludeAddress,@JsonKey(name: 'strict-route') bool strictRoute,@JsonKey(name: 'disable-icmp-forwarding') bool disableIcmpForwarding, int mtu,@JsonKey(name: 'endpoint-independent-nat') bool endpointIndependentNat
});




}
/// @nodoc
class _$TunCopyWithImpl<$Res>
    implements $TunCopyWith<$Res> {
  _$TunCopyWithImpl(this._self, this._then);

  final Tun _self;
  final $Res Function(Tun) _then;

/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? device = null,Object? autoRoute = null,Object? stack = null,Object? dnsHijack = null,Object? routeAddress = null,Object? routeExcludeAddress = null,Object? strictRoute = null,Object? disableIcmpForwarding = null,Object? mtu = null,Object? endpointIndependentNat = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,autoRoute: null == autoRoute ? _self.autoRoute : autoRoute // ignore: cast_nullable_to_non_nullable
as bool,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,dnsHijack: null == dnsHijack ? _self.dnsHijack : dnsHijack // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self.routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,routeExcludeAddress: null == routeExcludeAddress ? _self.routeExcludeAddress : routeExcludeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,strictRoute: null == strictRoute ? _self.strictRoute : strictRoute // ignore: cast_nullable_to_non_nullable
as bool,disableIcmpForwarding: null == disableIcmpForwarding ? _self.disableIcmpForwarding : disableIcmpForwarding // ignore: cast_nullable_to_non_nullable
as bool,mtu: null == mtu ? _self.mtu : mtu // ignore: cast_nullable_to_non_nullable
as int,endpointIndependentNat: null == endpointIndependentNat ? _self.endpointIndependentNat : endpointIndependentNat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Tun].
extension TunPatterns on Tun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tun value)  $default,){
final _that = this;
switch (_that) {
case _Tun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tun value)?  $default,){
final _that = this;
switch (_that) {
case _Tun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress, @JsonKey(name: 'route-exclude-address')  List<String> routeExcludeAddress, @JsonKey(name: 'strict-route')  bool strictRoute, @JsonKey(name: 'disable-icmp-forwarding')  bool disableIcmpForwarding,  int mtu, @JsonKey(name: 'endpoint-independent-nat')  bool endpointIndependentNat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress,_that.routeExcludeAddress,_that.strictRoute,_that.disableIcmpForwarding,_that.mtu,_that.endpointIndependentNat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress, @JsonKey(name: 'route-exclude-address')  List<String> routeExcludeAddress, @JsonKey(name: 'strict-route')  bool strictRoute, @JsonKey(name: 'disable-icmp-forwarding')  bool disableIcmpForwarding,  int mtu, @JsonKey(name: 'endpoint-independent-nat')  bool endpointIndependentNat)  $default,) {final _that = this;
switch (_that) {
case _Tun():
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress,_that.routeExcludeAddress,_that.strictRoute,_that.disableIcmpForwarding,_that.mtu,_that.endpointIndependentNat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress, @JsonKey(name: 'route-exclude-address')  List<String> routeExcludeAddress, @JsonKey(name: 'strict-route')  bool strictRoute, @JsonKey(name: 'disable-icmp-forwarding')  bool disableIcmpForwarding,  int mtu, @JsonKey(name: 'endpoint-independent-nat')  bool endpointIndependentNat)?  $default,) {final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress,_that.routeExcludeAddress,_that.strictRoute,_that.disableIcmpForwarding,_that.mtu,_that.endpointIndependentNat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tun implements Tun {
  const _Tun({this.enable = false, this.device = tunDeviceName, @JsonKey(name: 'auto-route') this.autoRoute = false, this.stack = TunStack.system, @JsonKey(name: 'dns-hijack') final  List<String> dnsHijack = const ['any:53'], @JsonKey(name: 'route-address') final  List<String> routeAddress = const [], @JsonKey(name: 'route-exclude-address') final  List<String> routeExcludeAddress = const [], @JsonKey(name: 'strict-route') this.strictRoute = false, @JsonKey(name: 'disable-icmp-forwarding') this.disableIcmpForwarding = true, this.mtu = 4064, @JsonKey(name: 'endpoint-independent-nat') this.endpointIndependentNat = false}): _dnsHijack = dnsHijack,_routeAddress = routeAddress,_routeExcludeAddress = routeExcludeAddress;
  factory _Tun.fromJson(Map<String, dynamic> json) => _$TunFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String device;
@override@JsonKey(name: 'auto-route') final  bool autoRoute;
@override@JsonKey() final  TunStack stack;
 final  List<String> _dnsHijack;
@override@JsonKey(name: 'dns-hijack') List<String> get dnsHijack {
  if (_dnsHijack is EqualUnmodifiableListView) return _dnsHijack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dnsHijack);
}

 final  List<String> _routeAddress;
@override@JsonKey(name: 'route-address') List<String> get routeAddress {
  if (_routeAddress is EqualUnmodifiableListView) return _routeAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeAddress);
}

 final  List<String> _routeExcludeAddress;
@override@JsonKey(name: 'route-exclude-address') List<String> get routeExcludeAddress {
  if (_routeExcludeAddress is EqualUnmodifiableListView) return _routeExcludeAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeExcludeAddress);
}

@override@JsonKey(name: 'strict-route') final  bool strictRoute;
@override@JsonKey(name: 'disable-icmp-forwarding') final  bool disableIcmpForwarding;
@override@JsonKey() final  int mtu;
@override@JsonKey(name: 'endpoint-independent-nat') final  bool endpointIndependentNat;

/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunCopyWith<_Tun> get copyWith => __$TunCopyWithImpl<_Tun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tun&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.device, device) || other.device == device)&&(identical(other.autoRoute, autoRoute) || other.autoRoute == autoRoute)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other._dnsHijack, _dnsHijack)&&const DeepCollectionEquality().equals(other._routeAddress, _routeAddress)&&const DeepCollectionEquality().equals(other._routeExcludeAddress, _routeExcludeAddress)&&(identical(other.strictRoute, strictRoute) || other.strictRoute == strictRoute)&&(identical(other.disableIcmpForwarding, disableIcmpForwarding) || other.disableIcmpForwarding == disableIcmpForwarding)&&(identical(other.mtu, mtu) || other.mtu == mtu)&&(identical(other.endpointIndependentNat, endpointIndependentNat) || other.endpointIndependentNat == endpointIndependentNat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,device,autoRoute,stack,const DeepCollectionEquality().hash(_dnsHijack),const DeepCollectionEquality().hash(_routeAddress),const DeepCollectionEquality().hash(_routeExcludeAddress),strictRoute,disableIcmpForwarding,mtu,endpointIndependentNat);

@override
String toString() {
  return 'Tun(enable: $enable, device: $device, autoRoute: $autoRoute, stack: $stack, dnsHijack: $dnsHijack, routeAddress: $routeAddress, routeExcludeAddress: $routeExcludeAddress, strictRoute: $strictRoute, disableIcmpForwarding: $disableIcmpForwarding, mtu: $mtu, endpointIndependentNat: $endpointIndependentNat)';
}


}

/// @nodoc
abstract mixin class _$TunCopyWith<$Res> implements $TunCopyWith<$Res> {
  factory _$TunCopyWith(_Tun value, $Res Function(_Tun) _then) = __$TunCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String device,@JsonKey(name: 'auto-route') bool autoRoute, TunStack stack,@JsonKey(name: 'dns-hijack') List<String> dnsHijack,@JsonKey(name: 'route-address') List<String> routeAddress,@JsonKey(name: 'route-exclude-address') List<String> routeExcludeAddress,@JsonKey(name: 'strict-route') bool strictRoute,@JsonKey(name: 'disable-icmp-forwarding') bool disableIcmpForwarding, int mtu,@JsonKey(name: 'endpoint-independent-nat') bool endpointIndependentNat
});




}
/// @nodoc
class __$TunCopyWithImpl<$Res>
    implements _$TunCopyWith<$Res> {
  __$TunCopyWithImpl(this._self, this._then);

  final _Tun _self;
  final $Res Function(_Tun) _then;

/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? device = null,Object? autoRoute = null,Object? stack = null,Object? dnsHijack = null,Object? routeAddress = null,Object? routeExcludeAddress = null,Object? strictRoute = null,Object? disableIcmpForwarding = null,Object? mtu = null,Object? endpointIndependentNat = null,}) {
  return _then(_Tun(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,autoRoute: null == autoRoute ? _self.autoRoute : autoRoute // ignore: cast_nullable_to_non_nullable
as bool,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,dnsHijack: null == dnsHijack ? _self._dnsHijack : dnsHijack // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self._routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,routeExcludeAddress: null == routeExcludeAddress ? _self._routeExcludeAddress : routeExcludeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,strictRoute: null == strictRoute ? _self.strictRoute : strictRoute // ignore: cast_nullable_to_non_nullable
as bool,disableIcmpForwarding: null == disableIcmpForwarding ? _self.disableIcmpForwarding : disableIcmpForwarding // ignore: cast_nullable_to_non_nullable
as bool,mtu: null == mtu ? _self.mtu : mtu // ignore: cast_nullable_to_non_nullable
as int,endpointIndependentNat: null == endpointIndependentNat ? _self.endpointIndependentNat : endpointIndependentNat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$FallbackFilter {

 bool get geoip;@JsonKey(name: 'geoip-code') String get geoipCode; List<String> get geosite; List<String> get ipcidr; List<String> get domain;
/// Create a copy of FallbackFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FallbackFilterCopyWith<FallbackFilter> get copyWith => _$FallbackFilterCopyWithImpl<FallbackFilter>(this as FallbackFilter, _$identity);

  /// Serializes this FallbackFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FallbackFilter&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geoipCode, geoipCode) || other.geoipCode == geoipCode)&&const DeepCollectionEquality().equals(other.geosite, geosite)&&const DeepCollectionEquality().equals(other.ipcidr, ipcidr)&&const DeepCollectionEquality().equals(other.domain, domain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,geoip,geoipCode,const DeepCollectionEquality().hash(geosite),const DeepCollectionEquality().hash(ipcidr),const DeepCollectionEquality().hash(domain));

@override
String toString() {
  return 'FallbackFilter(geoip: $geoip, geoipCode: $geoipCode, geosite: $geosite, ipcidr: $ipcidr, domain: $domain)';
}


}

/// @nodoc
abstract mixin class $FallbackFilterCopyWith<$Res>  {
  factory $FallbackFilterCopyWith(FallbackFilter value, $Res Function(FallbackFilter) _then) = _$FallbackFilterCopyWithImpl;
@useResult
$Res call({
 bool geoip,@JsonKey(name: 'geoip-code') String geoipCode, List<String> geosite, List<String> ipcidr, List<String> domain
});




}
/// @nodoc
class _$FallbackFilterCopyWithImpl<$Res>
    implements $FallbackFilterCopyWith<$Res> {
  _$FallbackFilterCopyWithImpl(this._self, this._then);

  final FallbackFilter _self;
  final $Res Function(FallbackFilter) _then;

/// Create a copy of FallbackFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? geoip = null,Object? geoipCode = null,Object? geosite = null,Object? ipcidr = null,Object? domain = null,}) {
  return _then(_self.copyWith(
geoip: null == geoip ? _self.geoip : geoip // ignore: cast_nullable_to_non_nullable
as bool,geoipCode: null == geoipCode ? _self.geoipCode : geoipCode // ignore: cast_nullable_to_non_nullable
as String,geosite: null == geosite ? _self.geosite : geosite // ignore: cast_nullable_to_non_nullable
as List<String>,ipcidr: null == ipcidr ? _self.ipcidr : ipcidr // ignore: cast_nullable_to_non_nullable
as List<String>,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FallbackFilter].
extension FallbackFilterPatterns on FallbackFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FallbackFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FallbackFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FallbackFilter value)  $default,){
final _that = this;
switch (_that) {
case _FallbackFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FallbackFilter value)?  $default,){
final _that = this;
switch (_that) {
case _FallbackFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool geoip, @JsonKey(name: 'geoip-code')  String geoipCode,  List<String> geosite,  List<String> ipcidr,  List<String> domain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FallbackFilter() when $default != null:
return $default(_that.geoip,_that.geoipCode,_that.geosite,_that.ipcidr,_that.domain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool geoip, @JsonKey(name: 'geoip-code')  String geoipCode,  List<String> geosite,  List<String> ipcidr,  List<String> domain)  $default,) {final _that = this;
switch (_that) {
case _FallbackFilter():
return $default(_that.geoip,_that.geoipCode,_that.geosite,_that.ipcidr,_that.domain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool geoip, @JsonKey(name: 'geoip-code')  String geoipCode,  List<String> geosite,  List<String> ipcidr,  List<String> domain)?  $default,) {final _that = this;
switch (_that) {
case _FallbackFilter() when $default != null:
return $default(_that.geoip,_that.geoipCode,_that.geosite,_that.ipcidr,_that.domain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FallbackFilter implements FallbackFilter {
  const _FallbackFilter({this.geoip = false, @JsonKey(name: 'geoip-code') this.geoipCode = 'CN', final  List<String> geosite = const [], final  List<String> ipcidr = const [], final  List<String> domain = const []}): _geosite = geosite,_ipcidr = ipcidr,_domain = domain;
  factory _FallbackFilter.fromJson(Map<String, dynamic> json) => _$FallbackFilterFromJson(json);

@override@JsonKey() final  bool geoip;
@override@JsonKey(name: 'geoip-code') final  String geoipCode;
 final  List<String> _geosite;
@override@JsonKey() List<String> get geosite {
  if (_geosite is EqualUnmodifiableListView) return _geosite;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_geosite);
}

 final  List<String> _ipcidr;
@override@JsonKey() List<String> get ipcidr {
  if (_ipcidr is EqualUnmodifiableListView) return _ipcidr;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ipcidr);
}

 final  List<String> _domain;
@override@JsonKey() List<String> get domain {
  if (_domain is EqualUnmodifiableListView) return _domain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_domain);
}


/// Create a copy of FallbackFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FallbackFilterCopyWith<_FallbackFilter> get copyWith => __$FallbackFilterCopyWithImpl<_FallbackFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FallbackFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FallbackFilter&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geoipCode, geoipCode) || other.geoipCode == geoipCode)&&const DeepCollectionEquality().equals(other._geosite, _geosite)&&const DeepCollectionEquality().equals(other._ipcidr, _ipcidr)&&const DeepCollectionEquality().equals(other._domain, _domain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,geoip,geoipCode,const DeepCollectionEquality().hash(_geosite),const DeepCollectionEquality().hash(_ipcidr),const DeepCollectionEquality().hash(_domain));

@override
String toString() {
  return 'FallbackFilter(geoip: $geoip, geoipCode: $geoipCode, geosite: $geosite, ipcidr: $ipcidr, domain: $domain)';
}


}

/// @nodoc
abstract mixin class _$FallbackFilterCopyWith<$Res> implements $FallbackFilterCopyWith<$Res> {
  factory _$FallbackFilterCopyWith(_FallbackFilter value, $Res Function(_FallbackFilter) _then) = __$FallbackFilterCopyWithImpl;
@override @useResult
$Res call({
 bool geoip,@JsonKey(name: 'geoip-code') String geoipCode, List<String> geosite, List<String> ipcidr, List<String> domain
});




}
/// @nodoc
class __$FallbackFilterCopyWithImpl<$Res>
    implements _$FallbackFilterCopyWith<$Res> {
  __$FallbackFilterCopyWithImpl(this._self, this._then);

  final _FallbackFilter _self;
  final $Res Function(_FallbackFilter) _then;

/// Create a copy of FallbackFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? geoip = null,Object? geoipCode = null,Object? geosite = null,Object? ipcidr = null,Object? domain = null,}) {
  return _then(_FallbackFilter(
geoip: null == geoip ? _self.geoip : geoip // ignore: cast_nullable_to_non_nullable
as bool,geoipCode: null == geoipCode ? _self.geoipCode : geoipCode // ignore: cast_nullable_to_non_nullable
as String,geosite: null == geosite ? _self._geosite : geosite // ignore: cast_nullable_to_non_nullable
as List<String>,ipcidr: null == ipcidr ? _self._ipcidr : ipcidr // ignore: cast_nullable_to_non_nullable
as List<String>,domain: null == domain ? _self._domain : domain // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Dns {

 bool get enable; String get listen;@JsonKey(name: 'prefer-h3') bool get preferH3;@JsonKey(name: 'cache-algorithm') CacheAlgorithm get cacheAlgorithm;@JsonKey(name: 'use-hosts') bool get useHosts;@JsonKey(name: 'use-system-hosts') bool get useSystemHosts;@JsonKey(name: 'respect-rules') bool get respectRules; bool get ipv6;@JsonKey(name: 'default-nameserver') List<String> get defaultNameserver;@JsonKey(name: 'enhanced-mode') DnsMode get enhancedMode;@JsonKey(name: 'fake-ip-range') String get fakeIpRange;@JsonKey(name: 'fake-ip-range-v6') String get fakeIpRangeV6;@JsonKey(name: 'fake-ip-filter-mode') FilterMode get fakeIpFilterMode;@JsonKey(name: 'fake-ip-filter') List<String> get fakeIpFilter;@JsonKey(name: 'fake-ip-ttl') int get fakeIpTtl;@JsonKey(name: 'nameserver-policy') Map<String, String> get nameserverPolicy; List<String> get nameserver; List<String> get fallback;@JsonKey(name: 'proxy-server-nameserver') List<String> get proxyServerNameserver;@JsonKey(name: 'direct-nameserver') List<String> get directNameserver;@JsonKey(name: 'direct-nameserver-follow-policy') bool get directNameserverFollowPolicy;@JsonKey(name: 'fallback-filter') FallbackFilter get fallbackFilter;
/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DnsCopyWith<Dns> get copyWith => _$DnsCopyWithImpl<Dns>(this as Dns, _$identity);

  /// Serializes this Dns to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dns&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.listen, listen) || other.listen == listen)&&(identical(other.preferH3, preferH3) || other.preferH3 == preferH3)&&(identical(other.cacheAlgorithm, cacheAlgorithm) || other.cacheAlgorithm == cacheAlgorithm)&&(identical(other.useHosts, useHosts) || other.useHosts == useHosts)&&(identical(other.useSystemHosts, useSystemHosts) || other.useSystemHosts == useSystemHosts)&&(identical(other.respectRules, respectRules) || other.respectRules == respectRules)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&const DeepCollectionEquality().equals(other.defaultNameserver, defaultNameserver)&&(identical(other.enhancedMode, enhancedMode) || other.enhancedMode == enhancedMode)&&(identical(other.fakeIpRange, fakeIpRange) || other.fakeIpRange == fakeIpRange)&&(identical(other.fakeIpRangeV6, fakeIpRangeV6) || other.fakeIpRangeV6 == fakeIpRangeV6)&&(identical(other.fakeIpFilterMode, fakeIpFilterMode) || other.fakeIpFilterMode == fakeIpFilterMode)&&const DeepCollectionEquality().equals(other.fakeIpFilter, fakeIpFilter)&&(identical(other.fakeIpTtl, fakeIpTtl) || other.fakeIpTtl == fakeIpTtl)&&const DeepCollectionEquality().equals(other.nameserverPolicy, nameserverPolicy)&&const DeepCollectionEquality().equals(other.nameserver, nameserver)&&const DeepCollectionEquality().equals(other.fallback, fallback)&&const DeepCollectionEquality().equals(other.proxyServerNameserver, proxyServerNameserver)&&const DeepCollectionEquality().equals(other.directNameserver, directNameserver)&&(identical(other.directNameserverFollowPolicy, directNameserverFollowPolicy) || other.directNameserverFollowPolicy == directNameserverFollowPolicy)&&(identical(other.fallbackFilter, fallbackFilter) || other.fallbackFilter == fallbackFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,enable,listen,preferH3,cacheAlgorithm,useHosts,useSystemHosts,respectRules,ipv6,const DeepCollectionEquality().hash(defaultNameserver),enhancedMode,fakeIpRange,fakeIpRangeV6,fakeIpFilterMode,const DeepCollectionEquality().hash(fakeIpFilter),fakeIpTtl,const DeepCollectionEquality().hash(nameserverPolicy),const DeepCollectionEquality().hash(nameserver),const DeepCollectionEquality().hash(fallback),const DeepCollectionEquality().hash(proxyServerNameserver),const DeepCollectionEquality().hash(directNameserver),directNameserverFollowPolicy,fallbackFilter]);

@override
String toString() {
  return 'Dns(enable: $enable, listen: $listen, preferH3: $preferH3, cacheAlgorithm: $cacheAlgorithm, useHosts: $useHosts, useSystemHosts: $useSystemHosts, respectRules: $respectRules, ipv6: $ipv6, defaultNameserver: $defaultNameserver, enhancedMode: $enhancedMode, fakeIpRange: $fakeIpRange, fakeIpRangeV6: $fakeIpRangeV6, fakeIpFilterMode: $fakeIpFilterMode, fakeIpFilter: $fakeIpFilter, fakeIpTtl: $fakeIpTtl, nameserverPolicy: $nameserverPolicy, nameserver: $nameserver, fallback: $fallback, proxyServerNameserver: $proxyServerNameserver, directNameserver: $directNameserver, directNameserverFollowPolicy: $directNameserverFollowPolicy, fallbackFilter: $fallbackFilter)';
}


}

/// @nodoc
abstract mixin class $DnsCopyWith<$Res>  {
  factory $DnsCopyWith(Dns value, $Res Function(Dns) _then) = _$DnsCopyWithImpl;
@useResult
$Res call({
 bool enable, String listen,@JsonKey(name: 'prefer-h3') bool preferH3,@JsonKey(name: 'cache-algorithm') CacheAlgorithm cacheAlgorithm,@JsonKey(name: 'use-hosts') bool useHosts,@JsonKey(name: 'use-system-hosts') bool useSystemHosts,@JsonKey(name: 'respect-rules') bool respectRules, bool ipv6,@JsonKey(name: 'default-nameserver') List<String> defaultNameserver,@JsonKey(name: 'enhanced-mode') DnsMode enhancedMode,@JsonKey(name: 'fake-ip-range') String fakeIpRange,@JsonKey(name: 'fake-ip-range-v6') String fakeIpRangeV6,@JsonKey(name: 'fake-ip-filter-mode') FilterMode fakeIpFilterMode,@JsonKey(name: 'fake-ip-filter') List<String> fakeIpFilter,@JsonKey(name: 'fake-ip-ttl') int fakeIpTtl,@JsonKey(name: 'nameserver-policy') Map<String, String> nameserverPolicy, List<String> nameserver, List<String> fallback,@JsonKey(name: 'proxy-server-nameserver') List<String> proxyServerNameserver,@JsonKey(name: 'direct-nameserver') List<String> directNameserver,@JsonKey(name: 'direct-nameserver-follow-policy') bool directNameserverFollowPolicy,@JsonKey(name: 'fallback-filter') FallbackFilter fallbackFilter
});


$FallbackFilterCopyWith<$Res> get fallbackFilter;

}
/// @nodoc
class _$DnsCopyWithImpl<$Res>
    implements $DnsCopyWith<$Res> {
  _$DnsCopyWithImpl(this._self, this._then);

  final Dns _self;
  final $Res Function(Dns) _then;

/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? listen = null,Object? preferH3 = null,Object? cacheAlgorithm = null,Object? useHosts = null,Object? useSystemHosts = null,Object? respectRules = null,Object? ipv6 = null,Object? defaultNameserver = null,Object? enhancedMode = null,Object? fakeIpRange = null,Object? fakeIpRangeV6 = null,Object? fakeIpFilterMode = null,Object? fakeIpFilter = null,Object? fakeIpTtl = null,Object? nameserverPolicy = null,Object? nameserver = null,Object? fallback = null,Object? proxyServerNameserver = null,Object? directNameserver = null,Object? directNameserverFollowPolicy = null,Object? fallbackFilter = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,listen: null == listen ? _self.listen : listen // ignore: cast_nullable_to_non_nullable
as String,preferH3: null == preferH3 ? _self.preferH3 : preferH3 // ignore: cast_nullable_to_non_nullable
as bool,cacheAlgorithm: null == cacheAlgorithm ? _self.cacheAlgorithm : cacheAlgorithm // ignore: cast_nullable_to_non_nullable
as CacheAlgorithm,useHosts: null == useHosts ? _self.useHosts : useHosts // ignore: cast_nullable_to_non_nullable
as bool,useSystemHosts: null == useSystemHosts ? _self.useSystemHosts : useSystemHosts // ignore: cast_nullable_to_non_nullable
as bool,respectRules: null == respectRules ? _self.respectRules : respectRules // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,defaultNameserver: null == defaultNameserver ? _self.defaultNameserver : defaultNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,enhancedMode: null == enhancedMode ? _self.enhancedMode : enhancedMode // ignore: cast_nullable_to_non_nullable
as DnsMode,fakeIpRange: null == fakeIpRange ? _self.fakeIpRange : fakeIpRange // ignore: cast_nullable_to_non_nullable
as String,fakeIpRangeV6: null == fakeIpRangeV6 ? _self.fakeIpRangeV6 : fakeIpRangeV6 // ignore: cast_nullable_to_non_nullable
as String,fakeIpFilterMode: null == fakeIpFilterMode ? _self.fakeIpFilterMode : fakeIpFilterMode // ignore: cast_nullable_to_non_nullable
as FilterMode,fakeIpFilter: null == fakeIpFilter ? _self.fakeIpFilter : fakeIpFilter // ignore: cast_nullable_to_non_nullable
as List<String>,fakeIpTtl: null == fakeIpTtl ? _self.fakeIpTtl : fakeIpTtl // ignore: cast_nullable_to_non_nullable
as int,nameserverPolicy: null == nameserverPolicy ? _self.nameserverPolicy : nameserverPolicy // ignore: cast_nullable_to_non_nullable
as Map<String, String>,nameserver: null == nameserver ? _self.nameserver : nameserver // ignore: cast_nullable_to_non_nullable
as List<String>,fallback: null == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as List<String>,proxyServerNameserver: null == proxyServerNameserver ? _self.proxyServerNameserver : proxyServerNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,directNameserver: null == directNameserver ? _self.directNameserver : directNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,directNameserverFollowPolicy: null == directNameserverFollowPolicy ? _self.directNameserverFollowPolicy : directNameserverFollowPolicy // ignore: cast_nullable_to_non_nullable
as bool,fallbackFilter: null == fallbackFilter ? _self.fallbackFilter : fallbackFilter // ignore: cast_nullable_to_non_nullable
as FallbackFilter,
  ));
}
/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FallbackFilterCopyWith<$Res> get fallbackFilter {
  
  return $FallbackFilterCopyWith<$Res>(_self.fallbackFilter, (value) {
    return _then(_self.copyWith(fallbackFilter: value));
  });
}
}


/// Adds pattern-matching-related methods to [Dns].
extension DnsPatterns on Dns {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dns value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dns() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dns value)  $default,){
final _that = this;
switch (_that) {
case _Dns():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dns value)?  $default,){
final _that = this;
switch (_that) {
case _Dns() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String listen, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'cache-algorithm')  CacheAlgorithm cacheAlgorithm, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-range-v6')  String fakeIpRangeV6, @JsonKey(name: 'fake-ip-filter-mode')  FilterMode fakeIpFilterMode, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'fake-ip-ttl')  int fakeIpTtl, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'direct-nameserver')  List<String> directNameserver, @JsonKey(name: 'direct-nameserver-follow-policy')  bool directNameserverFollowPolicy, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dns() when $default != null:
return $default(_that.enable,_that.listen,_that.preferH3,_that.cacheAlgorithm,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpRangeV6,_that.fakeIpFilterMode,_that.fakeIpFilter,_that.fakeIpTtl,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.proxyServerNameserver,_that.directNameserver,_that.directNameserverFollowPolicy,_that.fallbackFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String listen, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'cache-algorithm')  CacheAlgorithm cacheAlgorithm, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-range-v6')  String fakeIpRangeV6, @JsonKey(name: 'fake-ip-filter-mode')  FilterMode fakeIpFilterMode, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'fake-ip-ttl')  int fakeIpTtl, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'direct-nameserver')  List<String> directNameserver, @JsonKey(name: 'direct-nameserver-follow-policy')  bool directNameserverFollowPolicy, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)  $default,) {final _that = this;
switch (_that) {
case _Dns():
return $default(_that.enable,_that.listen,_that.preferH3,_that.cacheAlgorithm,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpRangeV6,_that.fakeIpFilterMode,_that.fakeIpFilter,_that.fakeIpTtl,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.proxyServerNameserver,_that.directNameserver,_that.directNameserverFollowPolicy,_that.fallbackFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String listen, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'cache-algorithm')  CacheAlgorithm cacheAlgorithm, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-range-v6')  String fakeIpRangeV6, @JsonKey(name: 'fake-ip-filter-mode')  FilterMode fakeIpFilterMode, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'fake-ip-ttl')  int fakeIpTtl, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'direct-nameserver')  List<String> directNameserver, @JsonKey(name: 'direct-nameserver-follow-policy')  bool directNameserverFollowPolicy, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)?  $default,) {final _that = this;
switch (_that) {
case _Dns() when $default != null:
return $default(_that.enable,_that.listen,_that.preferH3,_that.cacheAlgorithm,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpRangeV6,_that.fakeIpFilterMode,_that.fakeIpFilter,_that.fakeIpTtl,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.proxyServerNameserver,_that.directNameserver,_that.directNameserverFollowPolicy,_that.fallbackFilter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dns implements Dns {
  const _Dns({this.enable = true, this.listen = '0.0.0.0:1053', @JsonKey(name: 'prefer-h3') this.preferH3 = false, @JsonKey(name: 'cache-algorithm') this.cacheAlgorithm = CacheAlgorithm.arc, @JsonKey(name: 'use-hosts') this.useHosts = true, @JsonKey(name: 'use-system-hosts') this.useSystemHosts = true, @JsonKey(name: 'respect-rules') this.respectRules = false, this.ipv6 = false, @JsonKey(name: 'default-nameserver') final  List<String> defaultNameserver = const ['114.114.114.114'], @JsonKey(name: 'enhanced-mode') this.enhancedMode = DnsMode.fakeIp, @JsonKey(name: 'fake-ip-range') this.fakeIpRange = '198.18.0.1/15', @JsonKey(name: 'fake-ip-range-v6') this.fakeIpRangeV6 = 'fc00::/18', @JsonKey(name: 'fake-ip-filter-mode') this.fakeIpFilterMode = FilterMode.blacklist, @JsonKey(name: 'fake-ip-filter') final  List<String> fakeIpFilter = const ['*', 'geosite:private', 'geosite:category-ntp', 'geosite:geolocation-cn', 'geosite:connectivity-check'], @JsonKey(name: 'fake-ip-ttl') this.fakeIpTtl = 1, @JsonKey(name: 'nameserver-policy') final  Map<String, String> nameserverPolicy = const {'+.internal.crop.com' : '10.0.0.1', 'geosite:cn' : '119.29.29.29', 'geosite:private' : 'system', '*' : 'system'}, final  List<String> nameserver = const ['1.1.1.1'], final  List<String> fallback = const [], @JsonKey(name: 'proxy-server-nameserver') final  List<String> proxyServerNameserver = const ['https://doh.pub/dns-query#DIRECT'], @JsonKey(name: 'direct-nameserver') final  List<String> directNameserver = const [], @JsonKey(name: 'direct-nameserver-follow-policy') this.directNameserverFollowPolicy = false, @JsonKey(name: 'fallback-filter') this.fallbackFilter = const FallbackFilter()}): _defaultNameserver = defaultNameserver,_fakeIpFilter = fakeIpFilter,_nameserverPolicy = nameserverPolicy,_nameserver = nameserver,_fallback = fallback,_proxyServerNameserver = proxyServerNameserver,_directNameserver = directNameserver;
  factory _Dns.fromJson(Map<String, dynamic> json) => _$DnsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String listen;
@override@JsonKey(name: 'prefer-h3') final  bool preferH3;
@override@JsonKey(name: 'cache-algorithm') final  CacheAlgorithm cacheAlgorithm;
@override@JsonKey(name: 'use-hosts') final  bool useHosts;
@override@JsonKey(name: 'use-system-hosts') final  bool useSystemHosts;
@override@JsonKey(name: 'respect-rules') final  bool respectRules;
@override@JsonKey() final  bool ipv6;
 final  List<String> _defaultNameserver;
@override@JsonKey(name: 'default-nameserver') List<String> get defaultNameserver {
  if (_defaultNameserver is EqualUnmodifiableListView) return _defaultNameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultNameserver);
}

@override@JsonKey(name: 'enhanced-mode') final  DnsMode enhancedMode;
@override@JsonKey(name: 'fake-ip-range') final  String fakeIpRange;
@override@JsonKey(name: 'fake-ip-range-v6') final  String fakeIpRangeV6;
@override@JsonKey(name: 'fake-ip-filter-mode') final  FilterMode fakeIpFilterMode;
 final  List<String> _fakeIpFilter;
@override@JsonKey(name: 'fake-ip-filter') List<String> get fakeIpFilter {
  if (_fakeIpFilter is EqualUnmodifiableListView) return _fakeIpFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fakeIpFilter);
}

@override@JsonKey(name: 'fake-ip-ttl') final  int fakeIpTtl;
 final  Map<String, String> _nameserverPolicy;
@override@JsonKey(name: 'nameserver-policy') Map<String, String> get nameserverPolicy {
  if (_nameserverPolicy is EqualUnmodifiableMapView) return _nameserverPolicy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nameserverPolicy);
}

 final  List<String> _nameserver;
@override@JsonKey() List<String> get nameserver {
  if (_nameserver is EqualUnmodifiableListView) return _nameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nameserver);
}

 final  List<String> _fallback;
@override@JsonKey() List<String> get fallback {
  if (_fallback is EqualUnmodifiableListView) return _fallback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fallback);
}

 final  List<String> _proxyServerNameserver;
@override@JsonKey(name: 'proxy-server-nameserver') List<String> get proxyServerNameserver {
  if (_proxyServerNameserver is EqualUnmodifiableListView) return _proxyServerNameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyServerNameserver);
}

 final  List<String> _directNameserver;
@override@JsonKey(name: 'direct-nameserver') List<String> get directNameserver {
  if (_directNameserver is EqualUnmodifiableListView) return _directNameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_directNameserver);
}

@override@JsonKey(name: 'direct-nameserver-follow-policy') final  bool directNameserverFollowPolicy;
@override@JsonKey(name: 'fallback-filter') final  FallbackFilter fallbackFilter;

/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DnsCopyWith<_Dns> get copyWith => __$DnsCopyWithImpl<_Dns>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DnsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dns&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.listen, listen) || other.listen == listen)&&(identical(other.preferH3, preferH3) || other.preferH3 == preferH3)&&(identical(other.cacheAlgorithm, cacheAlgorithm) || other.cacheAlgorithm == cacheAlgorithm)&&(identical(other.useHosts, useHosts) || other.useHosts == useHosts)&&(identical(other.useSystemHosts, useSystemHosts) || other.useSystemHosts == useSystemHosts)&&(identical(other.respectRules, respectRules) || other.respectRules == respectRules)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&const DeepCollectionEquality().equals(other._defaultNameserver, _defaultNameserver)&&(identical(other.enhancedMode, enhancedMode) || other.enhancedMode == enhancedMode)&&(identical(other.fakeIpRange, fakeIpRange) || other.fakeIpRange == fakeIpRange)&&(identical(other.fakeIpRangeV6, fakeIpRangeV6) || other.fakeIpRangeV6 == fakeIpRangeV6)&&(identical(other.fakeIpFilterMode, fakeIpFilterMode) || other.fakeIpFilterMode == fakeIpFilterMode)&&const DeepCollectionEquality().equals(other._fakeIpFilter, _fakeIpFilter)&&(identical(other.fakeIpTtl, fakeIpTtl) || other.fakeIpTtl == fakeIpTtl)&&const DeepCollectionEquality().equals(other._nameserverPolicy, _nameserverPolicy)&&const DeepCollectionEquality().equals(other._nameserver, _nameserver)&&const DeepCollectionEquality().equals(other._fallback, _fallback)&&const DeepCollectionEquality().equals(other._proxyServerNameserver, _proxyServerNameserver)&&const DeepCollectionEquality().equals(other._directNameserver, _directNameserver)&&(identical(other.directNameserverFollowPolicy, directNameserverFollowPolicy) || other.directNameserverFollowPolicy == directNameserverFollowPolicy)&&(identical(other.fallbackFilter, fallbackFilter) || other.fallbackFilter == fallbackFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,enable,listen,preferH3,cacheAlgorithm,useHosts,useSystemHosts,respectRules,ipv6,const DeepCollectionEquality().hash(_defaultNameserver),enhancedMode,fakeIpRange,fakeIpRangeV6,fakeIpFilterMode,const DeepCollectionEquality().hash(_fakeIpFilter),fakeIpTtl,const DeepCollectionEquality().hash(_nameserverPolicy),const DeepCollectionEquality().hash(_nameserver),const DeepCollectionEquality().hash(_fallback),const DeepCollectionEquality().hash(_proxyServerNameserver),const DeepCollectionEquality().hash(_directNameserver),directNameserverFollowPolicy,fallbackFilter]);

@override
String toString() {
  return 'Dns(enable: $enable, listen: $listen, preferH3: $preferH3, cacheAlgorithm: $cacheAlgorithm, useHosts: $useHosts, useSystemHosts: $useSystemHosts, respectRules: $respectRules, ipv6: $ipv6, defaultNameserver: $defaultNameserver, enhancedMode: $enhancedMode, fakeIpRange: $fakeIpRange, fakeIpRangeV6: $fakeIpRangeV6, fakeIpFilterMode: $fakeIpFilterMode, fakeIpFilter: $fakeIpFilter, fakeIpTtl: $fakeIpTtl, nameserverPolicy: $nameserverPolicy, nameserver: $nameserver, fallback: $fallback, proxyServerNameserver: $proxyServerNameserver, directNameserver: $directNameserver, directNameserverFollowPolicy: $directNameserverFollowPolicy, fallbackFilter: $fallbackFilter)';
}


}

/// @nodoc
abstract mixin class _$DnsCopyWith<$Res> implements $DnsCopyWith<$Res> {
  factory _$DnsCopyWith(_Dns value, $Res Function(_Dns) _then) = __$DnsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String listen,@JsonKey(name: 'prefer-h3') bool preferH3,@JsonKey(name: 'cache-algorithm') CacheAlgorithm cacheAlgorithm,@JsonKey(name: 'use-hosts') bool useHosts,@JsonKey(name: 'use-system-hosts') bool useSystemHosts,@JsonKey(name: 'respect-rules') bool respectRules, bool ipv6,@JsonKey(name: 'default-nameserver') List<String> defaultNameserver,@JsonKey(name: 'enhanced-mode') DnsMode enhancedMode,@JsonKey(name: 'fake-ip-range') String fakeIpRange,@JsonKey(name: 'fake-ip-range-v6') String fakeIpRangeV6,@JsonKey(name: 'fake-ip-filter-mode') FilterMode fakeIpFilterMode,@JsonKey(name: 'fake-ip-filter') List<String> fakeIpFilter,@JsonKey(name: 'fake-ip-ttl') int fakeIpTtl,@JsonKey(name: 'nameserver-policy') Map<String, String> nameserverPolicy, List<String> nameserver, List<String> fallback,@JsonKey(name: 'proxy-server-nameserver') List<String> proxyServerNameserver,@JsonKey(name: 'direct-nameserver') List<String> directNameserver,@JsonKey(name: 'direct-nameserver-follow-policy') bool directNameserverFollowPolicy,@JsonKey(name: 'fallback-filter') FallbackFilter fallbackFilter
});


@override $FallbackFilterCopyWith<$Res> get fallbackFilter;

}
/// @nodoc
class __$DnsCopyWithImpl<$Res>
    implements _$DnsCopyWith<$Res> {
  __$DnsCopyWithImpl(this._self, this._then);

  final _Dns _self;
  final $Res Function(_Dns) _then;

/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? listen = null,Object? preferH3 = null,Object? cacheAlgorithm = null,Object? useHosts = null,Object? useSystemHosts = null,Object? respectRules = null,Object? ipv6 = null,Object? defaultNameserver = null,Object? enhancedMode = null,Object? fakeIpRange = null,Object? fakeIpRangeV6 = null,Object? fakeIpFilterMode = null,Object? fakeIpFilter = null,Object? fakeIpTtl = null,Object? nameserverPolicy = null,Object? nameserver = null,Object? fallback = null,Object? proxyServerNameserver = null,Object? directNameserver = null,Object? directNameserverFollowPolicy = null,Object? fallbackFilter = null,}) {
  return _then(_Dns(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,listen: null == listen ? _self.listen : listen // ignore: cast_nullable_to_non_nullable
as String,preferH3: null == preferH3 ? _self.preferH3 : preferH3 // ignore: cast_nullable_to_non_nullable
as bool,cacheAlgorithm: null == cacheAlgorithm ? _self.cacheAlgorithm : cacheAlgorithm // ignore: cast_nullable_to_non_nullable
as CacheAlgorithm,useHosts: null == useHosts ? _self.useHosts : useHosts // ignore: cast_nullable_to_non_nullable
as bool,useSystemHosts: null == useSystemHosts ? _self.useSystemHosts : useSystemHosts // ignore: cast_nullable_to_non_nullable
as bool,respectRules: null == respectRules ? _self.respectRules : respectRules // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,defaultNameserver: null == defaultNameserver ? _self._defaultNameserver : defaultNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,enhancedMode: null == enhancedMode ? _self.enhancedMode : enhancedMode // ignore: cast_nullable_to_non_nullable
as DnsMode,fakeIpRange: null == fakeIpRange ? _self.fakeIpRange : fakeIpRange // ignore: cast_nullable_to_non_nullable
as String,fakeIpRangeV6: null == fakeIpRangeV6 ? _self.fakeIpRangeV6 : fakeIpRangeV6 // ignore: cast_nullable_to_non_nullable
as String,fakeIpFilterMode: null == fakeIpFilterMode ? _self.fakeIpFilterMode : fakeIpFilterMode // ignore: cast_nullable_to_non_nullable
as FilterMode,fakeIpFilter: null == fakeIpFilter ? _self._fakeIpFilter : fakeIpFilter // ignore: cast_nullable_to_non_nullable
as List<String>,fakeIpTtl: null == fakeIpTtl ? _self.fakeIpTtl : fakeIpTtl // ignore: cast_nullable_to_non_nullable
as int,nameserverPolicy: null == nameserverPolicy ? _self._nameserverPolicy : nameserverPolicy // ignore: cast_nullable_to_non_nullable
as Map<String, String>,nameserver: null == nameserver ? _self._nameserver : nameserver // ignore: cast_nullable_to_non_nullable
as List<String>,fallback: null == fallback ? _self._fallback : fallback // ignore: cast_nullable_to_non_nullable
as List<String>,proxyServerNameserver: null == proxyServerNameserver ? _self._proxyServerNameserver : proxyServerNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,directNameserver: null == directNameserver ? _self._directNameserver : directNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,directNameserverFollowPolicy: null == directNameserverFollowPolicy ? _self.directNameserverFollowPolicy : directNameserverFollowPolicy // ignore: cast_nullable_to_non_nullable
as bool,fallbackFilter: null == fallbackFilter ? _self.fallbackFilter : fallbackFilter // ignore: cast_nullable_to_non_nullable
as FallbackFilter,
  ));
}

/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FallbackFilterCopyWith<$Res> get fallbackFilter {
  
  return $FallbackFilterCopyWith<$Res>(_self.fallbackFilter, (value) {
    return _then(_self.copyWith(fallbackFilter: value));
  });
}
}


/// @nodoc
mixin _$Ntp {

 bool get enable;@JsonKey(name: 'write-to-system') bool get writeToSystem; String get server; int get port; int get interval;
/// Create a copy of Ntp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NtpCopyWith<Ntp> get copyWith => _$NtpCopyWithImpl<Ntp>(this as Ntp, _$identity);

  /// Serializes this Ntp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ntp&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.writeToSystem, writeToSystem) || other.writeToSystem == writeToSystem)&&(identical(other.server, server) || other.server == server)&&(identical(other.port, port) || other.port == port)&&(identical(other.interval, interval) || other.interval == interval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,writeToSystem,server,port,interval);

@override
String toString() {
  return 'Ntp(enable: $enable, writeToSystem: $writeToSystem, server: $server, port: $port, interval: $interval)';
}


}

/// @nodoc
abstract mixin class $NtpCopyWith<$Res>  {
  factory $NtpCopyWith(Ntp value, $Res Function(Ntp) _then) = _$NtpCopyWithImpl;
@useResult
$Res call({
 bool enable,@JsonKey(name: 'write-to-system') bool writeToSystem, String server, int port, int interval
});




}
/// @nodoc
class _$NtpCopyWithImpl<$Res>
    implements $NtpCopyWith<$Res> {
  _$NtpCopyWithImpl(this._self, this._then);

  final Ntp _self;
  final $Res Function(Ntp) _then;

/// Create a copy of Ntp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? writeToSystem = null,Object? server = null,Object? port = null,Object? interval = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,writeToSystem: null == writeToSystem ? _self.writeToSystem : writeToSystem // ignore: cast_nullable_to_non_nullable
as bool,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Ntp].
extension NtpPatterns on Ntp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ntp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ntp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ntp value)  $default,){
final _that = this;
switch (_that) {
case _Ntp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ntp value)?  $default,){
final _that = this;
switch (_that) {
case _Ntp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable, @JsonKey(name: 'write-to-system')  bool writeToSystem,  String server,  int port,  int interval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ntp() when $default != null:
return $default(_that.enable,_that.writeToSystem,_that.server,_that.port,_that.interval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable, @JsonKey(name: 'write-to-system')  bool writeToSystem,  String server,  int port,  int interval)  $default,) {final _that = this;
switch (_that) {
case _Ntp():
return $default(_that.enable,_that.writeToSystem,_that.server,_that.port,_that.interval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable, @JsonKey(name: 'write-to-system')  bool writeToSystem,  String server,  int port,  int interval)?  $default,) {final _that = this;
switch (_that) {
case _Ntp() when $default != null:
return $default(_that.enable,_that.writeToSystem,_that.server,_that.port,_that.interval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ntp implements Ntp {
  const _Ntp({this.enable = true, @JsonKey(name: 'write-to-system') this.writeToSystem = false, this.server = 'ntp.aliyun.com', this.port = 123, this.interval = 60});
  factory _Ntp.fromJson(Map<String, dynamic> json) => _$NtpFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey(name: 'write-to-system') final  bool writeToSystem;
@override@JsonKey() final  String server;
@override@JsonKey() final  int port;
@override@JsonKey() final  int interval;

/// Create a copy of Ntp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NtpCopyWith<_Ntp> get copyWith => __$NtpCopyWithImpl<_Ntp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NtpToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ntp&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.writeToSystem, writeToSystem) || other.writeToSystem == writeToSystem)&&(identical(other.server, server) || other.server == server)&&(identical(other.port, port) || other.port == port)&&(identical(other.interval, interval) || other.interval == interval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,writeToSystem,server,port,interval);

@override
String toString() {
  return 'Ntp(enable: $enable, writeToSystem: $writeToSystem, server: $server, port: $port, interval: $interval)';
}


}

/// @nodoc
abstract mixin class _$NtpCopyWith<$Res> implements $NtpCopyWith<$Res> {
  factory _$NtpCopyWith(_Ntp value, $Res Function(_Ntp) _then) = __$NtpCopyWithImpl;
@override @useResult
$Res call({
 bool enable,@JsonKey(name: 'write-to-system') bool writeToSystem, String server, int port, int interval
});




}
/// @nodoc
class __$NtpCopyWithImpl<$Res>
    implements _$NtpCopyWith<$Res> {
  __$NtpCopyWithImpl(this._self, this._then);

  final _Ntp _self;
  final $Res Function(_Ntp) _then;

/// Create a copy of Ntp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? writeToSystem = null,Object? server = null,Object? port = null,Object? interval = null,}) {
  return _then(_Ntp(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,writeToSystem: null == writeToSystem ? _self.writeToSystem : writeToSystem // ignore: cast_nullable_to_non_nullable
as bool,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Experimental {

@JsonKey(name: 'quic-go-disable-gso') bool get quicGoDisableGso;@JsonKey(name: 'quic-go-disable-ecn') bool get quicGoDisableEcn;@JsonKey(name: 'dialer-ip4p-convert') bool get dialerIp4pConvert;
/// Create a copy of Experimental
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExperimentalCopyWith<Experimental> get copyWith => _$ExperimentalCopyWithImpl<Experimental>(this as Experimental, _$identity);

  /// Serializes this Experimental to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Experimental&&(identical(other.quicGoDisableGso, quicGoDisableGso) || other.quicGoDisableGso == quicGoDisableGso)&&(identical(other.quicGoDisableEcn, quicGoDisableEcn) || other.quicGoDisableEcn == quicGoDisableEcn)&&(identical(other.dialerIp4pConvert, dialerIp4pConvert) || other.dialerIp4pConvert == dialerIp4pConvert));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quicGoDisableGso,quicGoDisableEcn,dialerIp4pConvert);

@override
String toString() {
  return 'Experimental(quicGoDisableGso: $quicGoDisableGso, quicGoDisableEcn: $quicGoDisableEcn, dialerIp4pConvert: $dialerIp4pConvert)';
}


}

/// @nodoc
abstract mixin class $ExperimentalCopyWith<$Res>  {
  factory $ExperimentalCopyWith(Experimental value, $Res Function(Experimental) _then) = _$ExperimentalCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'quic-go-disable-gso') bool quicGoDisableGso,@JsonKey(name: 'quic-go-disable-ecn') bool quicGoDisableEcn,@JsonKey(name: 'dialer-ip4p-convert') bool dialerIp4pConvert
});




}
/// @nodoc
class _$ExperimentalCopyWithImpl<$Res>
    implements $ExperimentalCopyWith<$Res> {
  _$ExperimentalCopyWithImpl(this._self, this._then);

  final Experimental _self;
  final $Res Function(Experimental) _then;

/// Create a copy of Experimental
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quicGoDisableGso = null,Object? quicGoDisableEcn = null,Object? dialerIp4pConvert = null,}) {
  return _then(_self.copyWith(
quicGoDisableGso: null == quicGoDisableGso ? _self.quicGoDisableGso : quicGoDisableGso // ignore: cast_nullable_to_non_nullable
as bool,quicGoDisableEcn: null == quicGoDisableEcn ? _self.quicGoDisableEcn : quicGoDisableEcn // ignore: cast_nullable_to_non_nullable
as bool,dialerIp4pConvert: null == dialerIp4pConvert ? _self.dialerIp4pConvert : dialerIp4pConvert // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Experimental].
extension ExperimentalPatterns on Experimental {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Experimental value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Experimental() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Experimental value)  $default,){
final _that = this;
switch (_that) {
case _Experimental():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Experimental value)?  $default,){
final _that = this;
switch (_that) {
case _Experimental() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'quic-go-disable-gso')  bool quicGoDisableGso, @JsonKey(name: 'quic-go-disable-ecn')  bool quicGoDisableEcn, @JsonKey(name: 'dialer-ip4p-convert')  bool dialerIp4pConvert)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Experimental() when $default != null:
return $default(_that.quicGoDisableGso,_that.quicGoDisableEcn,_that.dialerIp4pConvert);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'quic-go-disable-gso')  bool quicGoDisableGso, @JsonKey(name: 'quic-go-disable-ecn')  bool quicGoDisableEcn, @JsonKey(name: 'dialer-ip4p-convert')  bool dialerIp4pConvert)  $default,) {final _that = this;
switch (_that) {
case _Experimental():
return $default(_that.quicGoDisableGso,_that.quicGoDisableEcn,_that.dialerIp4pConvert);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'quic-go-disable-gso')  bool quicGoDisableGso, @JsonKey(name: 'quic-go-disable-ecn')  bool quicGoDisableEcn, @JsonKey(name: 'dialer-ip4p-convert')  bool dialerIp4pConvert)?  $default,) {final _that = this;
switch (_that) {
case _Experimental() when $default != null:
return $default(_that.quicGoDisableGso,_that.quicGoDisableEcn,_that.dialerIp4pConvert);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Experimental implements Experimental {
  const _Experimental({@JsonKey(name: 'quic-go-disable-gso') this.quicGoDisableGso = true, @JsonKey(name: 'quic-go-disable-ecn') this.quicGoDisableEcn = true, @JsonKey(name: 'dialer-ip4p-convert') this.dialerIp4pConvert = false});
  factory _Experimental.fromJson(Map<String, dynamic> json) => _$ExperimentalFromJson(json);

@override@JsonKey(name: 'quic-go-disable-gso') final  bool quicGoDisableGso;
@override@JsonKey(name: 'quic-go-disable-ecn') final  bool quicGoDisableEcn;
@override@JsonKey(name: 'dialer-ip4p-convert') final  bool dialerIp4pConvert;

/// Create a copy of Experimental
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExperimentalCopyWith<_Experimental> get copyWith => __$ExperimentalCopyWithImpl<_Experimental>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExperimentalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Experimental&&(identical(other.quicGoDisableGso, quicGoDisableGso) || other.quicGoDisableGso == quicGoDisableGso)&&(identical(other.quicGoDisableEcn, quicGoDisableEcn) || other.quicGoDisableEcn == quicGoDisableEcn)&&(identical(other.dialerIp4pConvert, dialerIp4pConvert) || other.dialerIp4pConvert == dialerIp4pConvert));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quicGoDisableGso,quicGoDisableEcn,dialerIp4pConvert);

@override
String toString() {
  return 'Experimental(quicGoDisableGso: $quicGoDisableGso, quicGoDisableEcn: $quicGoDisableEcn, dialerIp4pConvert: $dialerIp4pConvert)';
}


}

/// @nodoc
abstract mixin class _$ExperimentalCopyWith<$Res> implements $ExperimentalCopyWith<$Res> {
  factory _$ExperimentalCopyWith(_Experimental value, $Res Function(_Experimental) _then) = __$ExperimentalCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'quic-go-disable-gso') bool quicGoDisableGso,@JsonKey(name: 'quic-go-disable-ecn') bool quicGoDisableEcn,@JsonKey(name: 'dialer-ip4p-convert') bool dialerIp4pConvert
});




}
/// @nodoc
class __$ExperimentalCopyWithImpl<$Res>
    implements _$ExperimentalCopyWith<$Res> {
  __$ExperimentalCopyWithImpl(this._self, this._then);

  final _Experimental _self;
  final $Res Function(_Experimental) _then;

/// Create a copy of Experimental
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quicGoDisableGso = null,Object? quicGoDisableEcn = null,Object? dialerIp4pConvert = null,}) {
  return _then(_Experimental(
quicGoDisableGso: null == quicGoDisableGso ? _self.quicGoDisableGso : quicGoDisableGso // ignore: cast_nullable_to_non_nullable
as bool,quicGoDisableEcn: null == quicGoDisableEcn ? _self.quicGoDisableEcn : quicGoDisableEcn // ignore: cast_nullable_to_non_nullable
as bool,dialerIp4pConvert: null == dialerIp4pConvert ? _self.dialerIp4pConvert : dialerIp4pConvert // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$GeoXUrl {

 String get mmdb; String get asn; String get geoip; String get geosite;
/// Create a copy of GeoXUrl
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeoXUrlCopyWith<GeoXUrl> get copyWith => _$GeoXUrlCopyWithImpl<GeoXUrl>(this as GeoXUrl, _$identity);

  /// Serializes this GeoXUrl to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeoXUrl&&(identical(other.mmdb, mmdb) || other.mmdb == mmdb)&&(identical(other.asn, asn) || other.asn == asn)&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geosite, geosite) || other.geosite == geosite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mmdb,asn,geoip,geosite);

@override
String toString() {
  return 'GeoXUrl(mmdb: $mmdb, asn: $asn, geoip: $geoip, geosite: $geosite)';
}


}

/// @nodoc
abstract mixin class $GeoXUrlCopyWith<$Res>  {
  factory $GeoXUrlCopyWith(GeoXUrl value, $Res Function(GeoXUrl) _then) = _$GeoXUrlCopyWithImpl;
@useResult
$Res call({
 String mmdb, String asn, String geoip, String geosite
});




}
/// @nodoc
class _$GeoXUrlCopyWithImpl<$Res>
    implements $GeoXUrlCopyWith<$Res> {
  _$GeoXUrlCopyWithImpl(this._self, this._then);

  final GeoXUrl _self;
  final $Res Function(GeoXUrl) _then;

/// Create a copy of GeoXUrl
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mmdb = null,Object? asn = null,Object? geoip = null,Object? geosite = null,}) {
  return _then(_self.copyWith(
mmdb: null == mmdb ? _self.mmdb : mmdb // ignore: cast_nullable_to_non_nullable
as String,asn: null == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as String,geoip: null == geoip ? _self.geoip : geoip // ignore: cast_nullable_to_non_nullable
as String,geosite: null == geosite ? _self.geosite : geosite // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeoXUrl].
extension GeoXUrlPatterns on GeoXUrl {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeoXUrl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeoXUrl() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeoXUrl value)  $default,){
final _that = this;
switch (_that) {
case _GeoXUrl():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeoXUrl value)?  $default,){
final _that = this;
switch (_that) {
case _GeoXUrl() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mmdb,  String asn,  String geoip,  String geosite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeoXUrl() when $default != null:
return $default(_that.mmdb,_that.asn,_that.geoip,_that.geosite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mmdb,  String asn,  String geoip,  String geosite)  $default,) {final _that = this;
switch (_that) {
case _GeoXUrl():
return $default(_that.mmdb,_that.asn,_that.geoip,_that.geosite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mmdb,  String asn,  String geoip,  String geosite)?  $default,) {final _that = this;
switch (_that) {
case _GeoXUrl() when $default != null:
return $default(_that.mmdb,_that.asn,_that.geoip,_that.geosite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeoXUrl implements GeoXUrl {
  const _GeoXUrl({this.mmdb = 'https://fastly.jsdelivr.net/gh/appshubcc/bett-rules@release/geoip.metadb', this.asn = 'https://fastly.jsdelivr.net/gh/appshubcc/bett-rules@release/GeoLite2-ASN.mmdb', this.geoip = 'https://fastly.jsdelivr.net/gh/appshubcc/bett-rules@release/geoip.dat', this.geosite = 'https://fastly.jsdelivr.net/gh/appshubcc/bett-rules@release/geosite.dat'});
  factory _GeoXUrl.fromJson(Map<String, dynamic> json) => _$GeoXUrlFromJson(json);

@override@JsonKey() final  String mmdb;
@override@JsonKey() final  String asn;
@override@JsonKey() final  String geoip;
@override@JsonKey() final  String geosite;

/// Create a copy of GeoXUrl
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeoXUrlCopyWith<_GeoXUrl> get copyWith => __$GeoXUrlCopyWithImpl<_GeoXUrl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeoXUrlToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeoXUrl&&(identical(other.mmdb, mmdb) || other.mmdb == mmdb)&&(identical(other.asn, asn) || other.asn == asn)&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geosite, geosite) || other.geosite == geosite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mmdb,asn,geoip,geosite);

@override
String toString() {
  return 'GeoXUrl(mmdb: $mmdb, asn: $asn, geoip: $geoip, geosite: $geosite)';
}


}

/// @nodoc
abstract mixin class _$GeoXUrlCopyWith<$Res> implements $GeoXUrlCopyWith<$Res> {
  factory _$GeoXUrlCopyWith(_GeoXUrl value, $Res Function(_GeoXUrl) _then) = __$GeoXUrlCopyWithImpl;
@override @useResult
$Res call({
 String mmdb, String asn, String geoip, String geosite
});




}
/// @nodoc
class __$GeoXUrlCopyWithImpl<$Res>
    implements _$GeoXUrlCopyWith<$Res> {
  __$GeoXUrlCopyWithImpl(this._self, this._then);

  final _GeoXUrl _self;
  final $Res Function(_GeoXUrl) _then;

/// Create a copy of GeoXUrl
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mmdb = null,Object? asn = null,Object? geoip = null,Object? geosite = null,}) {
  return _then(_GeoXUrl(
mmdb: null == mmdb ? _self.mmdb : mmdb // ignore: cast_nullable_to_non_nullable
as String,asn: null == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as String,geoip: null == geoip ? _self.geoip : geoip // ignore: cast_nullable_to_non_nullable
as String,geosite: null == geosite ? _self.geosite : geosite // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ParsedRule {

 RuleAction get ruleAction; String? get content; String? get ruleTarget; String? get ruleProvider; String? get subRule; bool get noResolve; bool get src;
/// Create a copy of ParsedRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedRuleCopyWith<ParsedRule> get copyWith => _$ParsedRuleCopyWithImpl<ParsedRule>(this as ParsedRule, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedRule&&(identical(other.ruleAction, ruleAction) || other.ruleAction == ruleAction)&&(identical(other.content, content) || other.content == content)&&(identical(other.ruleTarget, ruleTarget) || other.ruleTarget == ruleTarget)&&(identical(other.ruleProvider, ruleProvider) || other.ruleProvider == ruleProvider)&&(identical(other.subRule, subRule) || other.subRule == subRule)&&(identical(other.noResolve, noResolve) || other.noResolve == noResolve)&&(identical(other.src, src) || other.src == src));
}


@override
int get hashCode => Object.hash(runtimeType,ruleAction,content,ruleTarget,ruleProvider,subRule,noResolve,src);

@override
String toString() {
  return 'ParsedRule(ruleAction: $ruleAction, content: $content, ruleTarget: $ruleTarget, ruleProvider: $ruleProvider, subRule: $subRule, noResolve: $noResolve, src: $src)';
}


}

/// @nodoc
abstract mixin class $ParsedRuleCopyWith<$Res>  {
  factory $ParsedRuleCopyWith(ParsedRule value, $Res Function(ParsedRule) _then) = _$ParsedRuleCopyWithImpl;
@useResult
$Res call({
 RuleAction ruleAction, String? content, String? ruleTarget, String? ruleProvider, String? subRule, bool noResolve, bool src
});




}
/// @nodoc
class _$ParsedRuleCopyWithImpl<$Res>
    implements $ParsedRuleCopyWith<$Res> {
  _$ParsedRuleCopyWithImpl(this._self, this._then);

  final ParsedRule _self;
  final $Res Function(ParsedRule) _then;

/// Create a copy of ParsedRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ruleAction = null,Object? content = freezed,Object? ruleTarget = freezed,Object? ruleProvider = freezed,Object? subRule = freezed,Object? noResolve = null,Object? src = null,}) {
  return _then(_self.copyWith(
ruleAction: null == ruleAction ? _self.ruleAction : ruleAction // ignore: cast_nullable_to_non_nullable
as RuleAction,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,ruleTarget: freezed == ruleTarget ? _self.ruleTarget : ruleTarget // ignore: cast_nullable_to_non_nullable
as String?,ruleProvider: freezed == ruleProvider ? _self.ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as String?,subRule: freezed == subRule ? _self.subRule : subRule // ignore: cast_nullable_to_non_nullable
as String?,noResolve: null == noResolve ? _self.noResolve : noResolve // ignore: cast_nullable_to_non_nullable
as bool,src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedRule].
extension ParsedRulePatterns on ParsedRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedRule value)  $default,){
final _that = this;
switch (_that) {
case _ParsedRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedRule value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedRule() when $default != null:
return $default(_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src)  $default,) {final _that = this;
switch (_that) {
case _ParsedRule():
return $default(_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src)?  $default,) {final _that = this;
switch (_that) {
case _ParsedRule() when $default != null:
return $default(_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src);case _:
  return null;

}
}

}

/// @nodoc


class _ParsedRule implements ParsedRule {
  const _ParsedRule({required this.ruleAction, this.content, this.ruleTarget, this.ruleProvider, this.subRule, this.noResolve = false, this.src = false});
  

@override final  RuleAction ruleAction;
@override final  String? content;
@override final  String? ruleTarget;
@override final  String? ruleProvider;
@override final  String? subRule;
@override@JsonKey() final  bool noResolve;
@override@JsonKey() final  bool src;

/// Create a copy of ParsedRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedRuleCopyWith<_ParsedRule> get copyWith => __$ParsedRuleCopyWithImpl<_ParsedRule>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedRule&&(identical(other.ruleAction, ruleAction) || other.ruleAction == ruleAction)&&(identical(other.content, content) || other.content == content)&&(identical(other.ruleTarget, ruleTarget) || other.ruleTarget == ruleTarget)&&(identical(other.ruleProvider, ruleProvider) || other.ruleProvider == ruleProvider)&&(identical(other.subRule, subRule) || other.subRule == subRule)&&(identical(other.noResolve, noResolve) || other.noResolve == noResolve)&&(identical(other.src, src) || other.src == src));
}


@override
int get hashCode => Object.hash(runtimeType,ruleAction,content,ruleTarget,ruleProvider,subRule,noResolve,src);

@override
String toString() {
  return 'ParsedRule(ruleAction: $ruleAction, content: $content, ruleTarget: $ruleTarget, ruleProvider: $ruleProvider, subRule: $subRule, noResolve: $noResolve, src: $src)';
}


}

/// @nodoc
abstract mixin class _$ParsedRuleCopyWith<$Res> implements $ParsedRuleCopyWith<$Res> {
  factory _$ParsedRuleCopyWith(_ParsedRule value, $Res Function(_ParsedRule) _then) = __$ParsedRuleCopyWithImpl;
@override @useResult
$Res call({
 RuleAction ruleAction, String? content, String? ruleTarget, String? ruleProvider, String? subRule, bool noResolve, bool src
});




}
/// @nodoc
class __$ParsedRuleCopyWithImpl<$Res>
    implements _$ParsedRuleCopyWith<$Res> {
  __$ParsedRuleCopyWithImpl(this._self, this._then);

  final _ParsedRule _self;
  final $Res Function(_ParsedRule) _then;

/// Create a copy of ParsedRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ruleAction = null,Object? content = freezed,Object? ruleTarget = freezed,Object? ruleProvider = freezed,Object? subRule = freezed,Object? noResolve = null,Object? src = null,}) {
  return _then(_ParsedRule(
ruleAction: null == ruleAction ? _self.ruleAction : ruleAction // ignore: cast_nullable_to_non_nullable
as RuleAction,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,ruleTarget: freezed == ruleTarget ? _self.ruleTarget : ruleTarget // ignore: cast_nullable_to_non_nullable
as String?,ruleProvider: freezed == ruleProvider ? _self.ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as String?,subRule: freezed == subRule ? _self.subRule : subRule // ignore: cast_nullable_to_non_nullable
as String?,noResolve: null == noResolve ? _self.noResolve : noResolve // ignore: cast_nullable_to_non_nullable
as bool,src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Rule {

 String get id; String get value;
/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleCopyWith<Rule> get copyWith => _$RuleCopyWithImpl<Rule>(this as Rule, _$identity);

  /// Serializes this Rule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rule&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value);

@override
String toString() {
  return 'Rule(id: $id, value: $value)';
}


}

/// @nodoc
abstract mixin class $RuleCopyWith<$Res>  {
  factory $RuleCopyWith(Rule value, $Res Function(Rule) _then) = _$RuleCopyWithImpl;
@useResult
$Res call({
 String id, String value
});




}
/// @nodoc
class _$RuleCopyWithImpl<$Res>
    implements $RuleCopyWith<$Res> {
  _$RuleCopyWithImpl(this._self, this._then);

  final Rule _self;
  final $Res Function(Rule) _then;

/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? value = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Rule].
extension RulePatterns on Rule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Rule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Rule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Rule value)  $default,){
final _that = this;
switch (_that) {
case _Rule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Rule value)?  $default,){
final _that = this;
switch (_that) {
case _Rule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that.id,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String value)  $default,) {final _that = this;
switch (_that) {
case _Rule():
return $default(_that.id,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String value)?  $default,) {final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that.id,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Rule implements Rule {
  const _Rule({required this.id, required this.value});
  factory _Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);

@override final  String id;
@override final  String value;

/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuleCopyWith<_Rule> get copyWith => __$RuleCopyWithImpl<_Rule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rule&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value);

@override
String toString() {
  return 'Rule(id: $id, value: $value)';
}


}

/// @nodoc
abstract mixin class _$RuleCopyWith<$Res> implements $RuleCopyWith<$Res> {
  factory _$RuleCopyWith(_Rule value, $Res Function(_Rule) _then) = __$RuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String value
});




}
/// @nodoc
class __$RuleCopyWithImpl<$Res>
    implements _$RuleCopyWith<$Res> {
  __$RuleCopyWithImpl(this._self, this._then);

  final _Rule _self;
  final $Res Function(_Rule) _then;

/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? value = null,}) {
  return _then(_Rule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SubRule {

 String get name;
/// Create a copy of SubRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubRuleCopyWith<SubRule> get copyWith => _$SubRuleCopyWithImpl<SubRule>(this as SubRule, _$identity);

  /// Serializes this SubRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubRule&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'SubRule(name: $name)';
}


}

/// @nodoc
abstract mixin class $SubRuleCopyWith<$Res>  {
  factory $SubRuleCopyWith(SubRule value, $Res Function(SubRule) _then) = _$SubRuleCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$SubRuleCopyWithImpl<$Res>
    implements $SubRuleCopyWith<$Res> {
  _$SubRuleCopyWithImpl(this._self, this._then);

  final SubRule _self;
  final $Res Function(SubRule) _then;

/// Create a copy of SubRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubRule].
extension SubRulePatterns on SubRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubRule value)  $default,){
final _that = this;
switch (_that) {
case _SubRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubRule value)?  $default,){
final _that = this;
switch (_that) {
case _SubRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubRule() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _SubRule():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _SubRule() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubRule implements SubRule {
  const _SubRule({required this.name});
  factory _SubRule.fromJson(Map<String, dynamic> json) => _$SubRuleFromJson(json);

@override final  String name;

/// Create a copy of SubRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubRuleCopyWith<_SubRule> get copyWith => __$SubRuleCopyWithImpl<_SubRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubRule&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'SubRule(name: $name)';
}


}

/// @nodoc
abstract mixin class _$SubRuleCopyWith<$Res> implements $SubRuleCopyWith<$Res> {
  factory _$SubRuleCopyWith(_SubRule value, $Res Function(_SubRule) _then) = __$SubRuleCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$SubRuleCopyWithImpl<$Res>
    implements _$SubRuleCopyWith<$Res> {
  __$SubRuleCopyWithImpl(this._self, this._then);

  final _SubRule _self;
  final $Res Function(_SubRule) _then;

/// Create a copy of SubRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_SubRule(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ClashConfigSnippet {

@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups;@JsonKey(fromJson: _genRule, name: 'rules') List<Rule> get rule;@JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) List<RuleProvider> get ruleProvider;@JsonKey(name: 'sub-rules', fromJson: _genSubRules) List<SubRule> get subRules;
/// Create a copy of ClashConfigSnippet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClashConfigSnippetCopyWith<ClashConfigSnippet> get copyWith => _$ClashConfigSnippetCopyWithImpl<ClashConfigSnippet>(this as ClashConfigSnippet, _$identity);

  /// Serializes this ClashConfigSnippet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClashConfigSnippet&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups)&&const DeepCollectionEquality().equals(other.rule, rule)&&const DeepCollectionEquality().equals(other.ruleProvider, ruleProvider)&&const DeepCollectionEquality().equals(other.subRules, subRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(proxyGroups),const DeepCollectionEquality().hash(rule),const DeepCollectionEquality().hash(ruleProvider),const DeepCollectionEquality().hash(subRules));

@override
String toString() {
  return 'ClashConfigSnippet(proxyGroups: $proxyGroups, rule: $rule, ruleProvider: $ruleProvider, subRules: $subRules)';
}


}

/// @nodoc
abstract mixin class $ClashConfigSnippetCopyWith<$Res>  {
  factory $ClashConfigSnippetCopyWith(ClashConfigSnippet value, $Res Function(ClashConfigSnippet) _then) = _$ClashConfigSnippetCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,@JsonKey(fromJson: _genRule, name: 'rules') List<Rule> rule,@JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) List<RuleProvider> ruleProvider,@JsonKey(name: 'sub-rules', fromJson: _genSubRules) List<SubRule> subRules
});




}
/// @nodoc
class _$ClashConfigSnippetCopyWithImpl<$Res>
    implements $ClashConfigSnippetCopyWith<$Res> {
  _$ClashConfigSnippetCopyWithImpl(this._self, this._then);

  final ClashConfigSnippet _self;
  final $Res Function(ClashConfigSnippet) _then;

/// Create a copy of ClashConfigSnippet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyGroups = null,Object? rule = null,Object? ruleProvider = null,Object? subRules = null,}) {
  return _then(_self.copyWith(
proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as List<Rule>,ruleProvider: null == ruleProvider ? _self.ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as List<RuleProvider>,subRules: null == subRules ? _self.subRules : subRules // ignore: cast_nullable_to_non_nullable
as List<SubRule>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClashConfigSnippet].
extension ClashConfigSnippetPatterns on ClashConfigSnippet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClashConfigSnippet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClashConfigSnippet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClashConfigSnippet value)  $default,){
final _that = this;
switch (_that) {
case _ClashConfigSnippet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClashConfigSnippet value)?  $default,){
final _that = this;
switch (_that) {
case _ClashConfigSnippet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRule, name: 'rules')  List<Rule> rule, @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders)  List<RuleProvider> ruleProvider, @JsonKey(name: 'sub-rules', fromJson: _genSubRules)  List<SubRule> subRules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClashConfigSnippet() when $default != null:
return $default(_that.proxyGroups,_that.rule,_that.ruleProvider,_that.subRules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRule, name: 'rules')  List<Rule> rule, @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders)  List<RuleProvider> ruleProvider, @JsonKey(name: 'sub-rules', fromJson: _genSubRules)  List<SubRule> subRules)  $default,) {final _that = this;
switch (_that) {
case _ClashConfigSnippet():
return $default(_that.proxyGroups,_that.rule,_that.ruleProvider,_that.subRules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRule, name: 'rules')  List<Rule> rule, @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders)  List<RuleProvider> ruleProvider, @JsonKey(name: 'sub-rules', fromJson: _genSubRules)  List<SubRule> subRules)?  $default,) {final _that = this;
switch (_that) {
case _ClashConfigSnippet() when $default != null:
return $default(_that.proxyGroups,_that.rule,_that.ruleProvider,_that.subRules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClashConfigSnippet implements ClashConfigSnippet {
  const _ClashConfigSnippet({@JsonKey(name: 'proxy-groups') final  List<ProxyGroup> proxyGroups = const [], @JsonKey(fromJson: _genRule, name: 'rules') final  List<Rule> rule = const [], @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) final  List<RuleProvider> ruleProvider = const [], @JsonKey(name: 'sub-rules', fromJson: _genSubRules) final  List<SubRule> subRules = const []}): _proxyGroups = proxyGroups,_rule = rule,_ruleProvider = ruleProvider,_subRules = subRules;
  factory _ClashConfigSnippet.fromJson(Map<String, dynamic> json) => _$ClashConfigSnippetFromJson(json);

 final  List<ProxyGroup> _proxyGroups;
@override@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}

 final  List<Rule> _rule;
@override@JsonKey(fromJson: _genRule, name: 'rules') List<Rule> get rule {
  if (_rule is EqualUnmodifiableListView) return _rule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rule);
}

 final  List<RuleProvider> _ruleProvider;
@override@JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) List<RuleProvider> get ruleProvider {
  if (_ruleProvider is EqualUnmodifiableListView) return _ruleProvider;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ruleProvider);
}

 final  List<SubRule> _subRules;
@override@JsonKey(name: 'sub-rules', fromJson: _genSubRules) List<SubRule> get subRules {
  if (_subRules is EqualUnmodifiableListView) return _subRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subRules);
}


/// Create a copy of ClashConfigSnippet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClashConfigSnippetCopyWith<_ClashConfigSnippet> get copyWith => __$ClashConfigSnippetCopyWithImpl<_ClashConfigSnippet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClashConfigSnippetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClashConfigSnippet&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other._rule, _rule)&&const DeepCollectionEquality().equals(other._ruleProvider, _ruleProvider)&&const DeepCollectionEquality().equals(other._subRules, _subRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_rule),const DeepCollectionEquality().hash(_ruleProvider),const DeepCollectionEquality().hash(_subRules));

@override
String toString() {
  return 'ClashConfigSnippet(proxyGroups: $proxyGroups, rule: $rule, ruleProvider: $ruleProvider, subRules: $subRules)';
}


}

/// @nodoc
abstract mixin class _$ClashConfigSnippetCopyWith<$Res> implements $ClashConfigSnippetCopyWith<$Res> {
  factory _$ClashConfigSnippetCopyWith(_ClashConfigSnippet value, $Res Function(_ClashConfigSnippet) _then) = __$ClashConfigSnippetCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,@JsonKey(fromJson: _genRule, name: 'rules') List<Rule> rule,@JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) List<RuleProvider> ruleProvider,@JsonKey(name: 'sub-rules', fromJson: _genSubRules) List<SubRule> subRules
});




}
/// @nodoc
class __$ClashConfigSnippetCopyWithImpl<$Res>
    implements _$ClashConfigSnippetCopyWith<$Res> {
  __$ClashConfigSnippetCopyWithImpl(this._self, this._then);

  final _ClashConfigSnippet _self;
  final $Res Function(_ClashConfigSnippet) _then;

/// Create a copy of ClashConfigSnippet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyGroups = null,Object? rule = null,Object? ruleProvider = null,Object? subRules = null,}) {
  return _then(_ClashConfigSnippet(
proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rule: null == rule ? _self._rule : rule // ignore: cast_nullable_to_non_nullable
as List<Rule>,ruleProvider: null == ruleProvider ? _self._ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as List<RuleProvider>,subRules: null == subRules ? _self._subRules : subRules // ignore: cast_nullable_to_non_nullable
as List<SubRule>,
  ));
}


}


/// @nodoc
mixin _$ClashConfig {

@JsonKey(name: 'mixed-port') int get mixedPort;@JsonKey(name: 'socks-port') int get socksPort;@JsonKey(name: 'port') int get port;@JsonKey(name: 'redir-port') int get redirPort;@JsonKey(name: 'tproxy-port') int get tproxyPort; Mode get mode;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'log-level') LogLevel get logLevel; bool get ipv6;@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode get findProcessMode;@JsonKey(name: 'keep-alive-interval') int get keepAliveInterval;@JsonKey(name: 'unified-delay') bool get unifiedDelay;@JsonKey(name: 'tcp-concurrent') bool get tcpConcurrent;@JsonKey(fromJson: Tun.safeFormJson) Tun get tun;@JsonKey(fromJson: Dns.safeDnsFromJson) Dns get dns;@JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp get ntp;@JsonKey(fromJson: Sniffer.safeSnifferFromJson) Sniffer get sniffer; List<TunnelEntry> get tunnels;@JsonKey(fromJson: Experimental.safeExperimentalFromJson) Experimental get experimental;@JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) GeoXUrl get geoXUrl;@JsonKey(name: 'geodata-loader') GeodataLoader get geodataLoader;@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups; List<String> get rule;@JsonKey(name: 'global-ua') String? get globalUa;@JsonKey(name: 'external-controller') ExternalControllerStatus get externalController; String? get secret;@JsonKey(name: 'external-ui-name') String? get externalUiName;@JsonKey(name: 'external-ui-url') String? get externalUiUrl; HostsMap get hosts;
/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<ClashConfig> get copyWith => _$ClashConfigCopyWithImpl<ClashConfig>(this as ClashConfig, _$identity);

  /// Serializes this ClashConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClashConfig&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.socksPort, socksPort) || other.socksPort == socksPort)&&(identical(other.port, port) || other.port == port)&&(identical(other.redirPort, redirPort) || other.redirPort == redirPort)&&(identical(other.tproxyPort, tproxyPort) || other.tproxyPort == tproxyPort)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.keepAliveInterval, keepAliveInterval) || other.keepAliveInterval == keepAliveInterval)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.dns, dns) || other.dns == dns)&&(identical(other.ntp, ntp) || other.ntp == ntp)&&(identical(other.sniffer, sniffer) || other.sniffer == sniffer)&&const DeepCollectionEquality().equals(other.tunnels, tunnels)&&(identical(other.experimental, experimental) || other.experimental == experimental)&&(identical(other.geoXUrl, geoXUrl) || other.geoXUrl == geoXUrl)&&(identical(other.geodataLoader, geodataLoader) || other.geodataLoader == geodataLoader)&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups)&&const DeepCollectionEquality().equals(other.rule, rule)&&(identical(other.globalUa, globalUa) || other.globalUa == globalUa)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.externalUiName, externalUiName) || other.externalUiName == externalUiName)&&(identical(other.externalUiUrl, externalUiUrl) || other.externalUiUrl == externalUiUrl)&&const DeepCollectionEquality().equals(other.hosts, hosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,mixedPort,socksPort,port,redirPort,tproxyPort,mode,allowLan,logLevel,ipv6,findProcessMode,keepAliveInterval,unifiedDelay,tcpConcurrent,tun,dns,ntp,sniffer,const DeepCollectionEquality().hash(tunnels),experimental,geoXUrl,geodataLoader,const DeepCollectionEquality().hash(proxyGroups),const DeepCollectionEquality().hash(rule),globalUa,externalController,secret,externalUiName,externalUiUrl,const DeepCollectionEquality().hash(hosts)]);

@override
String toString() {
  return 'ClashConfig(mixedPort: $mixedPort, socksPort: $socksPort, port: $port, redirPort: $redirPort, tproxyPort: $tproxyPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, findProcessMode: $findProcessMode, keepAliveInterval: $keepAliveInterval, unifiedDelay: $unifiedDelay, tcpConcurrent: $tcpConcurrent, tun: $tun, dns: $dns, ntp: $ntp, sniffer: $sniffer, tunnels: $tunnels, experimental: $experimental, geoXUrl: $geoXUrl, geodataLoader: $geodataLoader, proxyGroups: $proxyGroups, rule: $rule, globalUa: $globalUa, externalController: $externalController, secret: $secret, externalUiName: $externalUiName, externalUiUrl: $externalUiUrl, hosts: $hosts)';
}


}

/// @nodoc
abstract mixin class $ClashConfigCopyWith<$Res>  {
  factory $ClashConfigCopyWith(ClashConfig value, $Res Function(ClashConfig) _then) = _$ClashConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'socks-port') int socksPort,@JsonKey(name: 'port') int port,@JsonKey(name: 'redir-port') int redirPort,@JsonKey(name: 'tproxy-port') int tproxyPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode findProcessMode,@JsonKey(name: 'keep-alive-interval') int keepAliveInterval,@JsonKey(name: 'unified-delay') bool unifiedDelay,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp ntp,@JsonKey(fromJson: Sniffer.safeSnifferFromJson) Sniffer sniffer, List<TunnelEntry> tunnels,@JsonKey(fromJson: Experimental.safeExperimentalFromJson) Experimental experimental,@JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) GeoXUrl geoXUrl,@JsonKey(name: 'geodata-loader') GeodataLoader geodataLoader,@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups, List<String> rule,@JsonKey(name: 'global-ua') String? globalUa,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, String? secret,@JsonKey(name: 'external-ui-name') String? externalUiName,@JsonKey(name: 'external-ui-url') String? externalUiUrl, HostsMap hosts
});


$TunCopyWith<$Res> get tun;$DnsCopyWith<$Res> get dns;$NtpCopyWith<$Res> get ntp;$SnifferCopyWith<$Res> get sniffer;$ExperimentalCopyWith<$Res> get experimental;$GeoXUrlCopyWith<$Res> get geoXUrl;

}
/// @nodoc
class _$ClashConfigCopyWithImpl<$Res>
    implements $ClashConfigCopyWith<$Res> {
  _$ClashConfigCopyWithImpl(this._self, this._then);

  final ClashConfig _self;
  final $Res Function(ClashConfig) _then;

/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mixedPort = null,Object? socksPort = null,Object? port = null,Object? redirPort = null,Object? tproxyPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? findProcessMode = null,Object? keepAliveInterval = null,Object? unifiedDelay = null,Object? tcpConcurrent = null,Object? tun = null,Object? dns = null,Object? ntp = null,Object? sniffer = null,Object? tunnels = null,Object? experimental = null,Object? geoXUrl = null,Object? geodataLoader = null,Object? proxyGroups = null,Object? rule = null,Object? globalUa = freezed,Object? externalController = null,Object? secret = freezed,Object? externalUiName = freezed,Object? externalUiUrl = freezed,Object? hosts = null,}) {
  return _then(_self.copyWith(
mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,socksPort: null == socksPort ? _self.socksPort : socksPort // ignore: cast_nullable_to_non_nullable
as int,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,redirPort: null == redirPort ? _self.redirPort : redirPort // ignore: cast_nullable_to_non_nullable
as int,tproxyPort: null == tproxyPort ? _self.tproxyPort : tproxyPort // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,keepAliveInterval: null == keepAliveInterval ? _self.keepAliveInterval : keepAliveInterval // ignore: cast_nullable_to_non_nullable
as int,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,ntp: null == ntp ? _self.ntp : ntp // ignore: cast_nullable_to_non_nullable
as Ntp,sniffer: null == sniffer ? _self.sniffer : sniffer // ignore: cast_nullable_to_non_nullable
as Sniffer,tunnels: null == tunnels ? _self.tunnels : tunnels // ignore: cast_nullable_to_non_nullable
as List<TunnelEntry>,experimental: null == experimental ? _self.experimental : experimental // ignore: cast_nullable_to_non_nullable
as Experimental,geoXUrl: null == geoXUrl ? _self.geoXUrl : geoXUrl // ignore: cast_nullable_to_non_nullable
as GeoXUrl,geodataLoader: null == geodataLoader ? _self.geodataLoader : geodataLoader // ignore: cast_nullable_to_non_nullable
as GeodataLoader,proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as List<String>,globalUa: freezed == globalUa ? _self.globalUa : globalUa // ignore: cast_nullable_to_non_nullable
as String?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,secret: freezed == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String?,externalUiName: freezed == externalUiName ? _self.externalUiName : externalUiName // ignore: cast_nullable_to_non_nullable
as String?,externalUiUrl: freezed == externalUiUrl ? _self.externalUiUrl : externalUiUrl // ignore: cast_nullable_to_non_nullable
as String?,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
as HostsMap,
  ));
}
/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NtpCopyWith<$Res> get ntp {
  
  return $NtpCopyWith<$Res>(_self.ntp, (value) {
    return _then(_self.copyWith(ntp: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnifferCopyWith<$Res> get sniffer {
  
  return $SnifferCopyWith<$Res>(_self.sniffer, (value) {
    return _then(_self.copyWith(sniffer: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExperimentalCopyWith<$Res> get experimental {
  
  return $ExperimentalCopyWith<$Res>(_self.experimental, (value) {
    return _then(_self.copyWith(experimental: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoXUrlCopyWith<$Res> get geoXUrl {
  
  return $GeoXUrlCopyWith<$Res>(_self.geoXUrl, (value) {
    return _then(_self.copyWith(geoXUrl: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClashConfig].
extension ClashConfigPatterns on ClashConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClashConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClashConfig value)  $default,){
final _that = this;
switch (_that) {
case _ClashConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClashConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(fromJson: Ntp.safeNtpFromJson)  Ntp ntp, @JsonKey(fromJson: Sniffer.safeSnifferFromJson)  Sniffer sniffer,  List<TunnelEntry> tunnels, @JsonKey(fromJson: Experimental.safeExperimentalFromJson)  Experimental experimental, @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson)  GeoXUrl geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups,  List<String> rule, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String? secret, @JsonKey(name: 'external-ui-name')  String? externalUiName, @JsonKey(name: 'external-ui-url')  String? externalUiUrl,  HostsMap hosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.ntp,_that.sniffer,_that.tunnels,_that.experimental,_that.geoXUrl,_that.geodataLoader,_that.proxyGroups,_that.rule,_that.globalUa,_that.externalController,_that.secret,_that.externalUiName,_that.externalUiUrl,_that.hosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(fromJson: Ntp.safeNtpFromJson)  Ntp ntp, @JsonKey(fromJson: Sniffer.safeSnifferFromJson)  Sniffer sniffer,  List<TunnelEntry> tunnels, @JsonKey(fromJson: Experimental.safeExperimentalFromJson)  Experimental experimental, @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson)  GeoXUrl geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups,  List<String> rule, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String? secret, @JsonKey(name: 'external-ui-name')  String? externalUiName, @JsonKey(name: 'external-ui-url')  String? externalUiUrl,  HostsMap hosts)  $default,) {final _that = this;
switch (_that) {
case _ClashConfig():
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.ntp,_that.sniffer,_that.tunnels,_that.experimental,_that.geoXUrl,_that.geodataLoader,_that.proxyGroups,_that.rule,_that.globalUa,_that.externalController,_that.secret,_that.externalUiName,_that.externalUiUrl,_that.hosts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(fromJson: Ntp.safeNtpFromJson)  Ntp ntp, @JsonKey(fromJson: Sniffer.safeSnifferFromJson)  Sniffer sniffer,  List<TunnelEntry> tunnels, @JsonKey(fromJson: Experimental.safeExperimentalFromJson)  Experimental experimental, @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson)  GeoXUrl geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups,  List<String> rule, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String? secret, @JsonKey(name: 'external-ui-name')  String? externalUiName, @JsonKey(name: 'external-ui-url')  String? externalUiUrl,  HostsMap hosts)?  $default,) {final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.ntp,_that.sniffer,_that.tunnels,_that.experimental,_that.geoXUrl,_that.geodataLoader,_that.proxyGroups,_that.rule,_that.globalUa,_that.externalController,_that.secret,_that.externalUiName,_that.externalUiUrl,_that.hosts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClashConfig implements ClashConfig {
  const _ClashConfig({@JsonKey(name: 'mixed-port') this.mixedPort = defaultMixedPort, @JsonKey(name: 'socks-port') this.socksPort = 0, @JsonKey(name: 'port') this.port = 0, @JsonKey(name: 'redir-port') this.redirPort = 0, @JsonKey(name: 'tproxy-port') this.tproxyPort = 0, this.mode = Mode.rule, @JsonKey(name: 'allow-lan') this.allowLan = false, @JsonKey(name: 'log-level') this.logLevel = LogLevel.error, this.ipv6 = false, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) this.findProcessMode = FindProcessMode.off, @JsonKey(name: 'keep-alive-interval') this.keepAliveInterval = defaultKeepAliveInterval, @JsonKey(name: 'unified-delay') this.unifiedDelay = true, @JsonKey(name: 'tcp-concurrent') this.tcpConcurrent = true, @JsonKey(fromJson: Tun.safeFormJson) this.tun = defaultTun, @JsonKey(fromJson: Dns.safeDnsFromJson) this.dns = defaultDns, @JsonKey(fromJson: Ntp.safeNtpFromJson) this.ntp = defaultNtp, @JsonKey(fromJson: Sniffer.safeSnifferFromJson) this.sniffer = defaultSniffer, final  List<TunnelEntry> tunnels = defaultTunnel, @JsonKey(fromJson: Experimental.safeExperimentalFromJson) this.experimental = defaultExperimental, @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) this.geoXUrl = defaultGeoXUrl, @JsonKey(name: 'geodata-loader') this.geodataLoader = GeodataLoader.memconservative, @JsonKey(name: 'proxy-groups') final  List<ProxyGroup> proxyGroups = const [], final  List<String> rule = const [], @JsonKey(name: 'global-ua') this.globalUa, @JsonKey(name: 'external-controller') this.externalController = ExternalControllerStatus.close, this.secret, @JsonKey(name: 'external-ui-name') this.externalUiName, @JsonKey(name: 'external-ui-url') this.externalUiUrl, final  HostsMap hosts = const {}}): _tunnels = tunnels,_proxyGroups = proxyGroups,_rule = rule,_hosts = hosts;
  factory _ClashConfig.fromJson(Map<String, dynamic> json) => _$ClashConfigFromJson(json);

@override@JsonKey(name: 'mixed-port') final  int mixedPort;
@override@JsonKey(name: 'socks-port') final  int socksPort;
@override@JsonKey(name: 'port') final  int port;
@override@JsonKey(name: 'redir-port') final  int redirPort;
@override@JsonKey(name: 'tproxy-port') final  int tproxyPort;
@override@JsonKey() final  Mode mode;
@override@JsonKey(name: 'allow-lan') final  bool allowLan;
@override@JsonKey(name: 'log-level') final  LogLevel logLevel;
@override@JsonKey() final  bool ipv6;
@override@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) final  FindProcessMode findProcessMode;
@override@JsonKey(name: 'keep-alive-interval') final  int keepAliveInterval;
@override@JsonKey(name: 'unified-delay') final  bool unifiedDelay;
@override@JsonKey(name: 'tcp-concurrent') final  bool tcpConcurrent;
@override@JsonKey(fromJson: Tun.safeFormJson) final  Tun tun;
@override@JsonKey(fromJson: Dns.safeDnsFromJson) final  Dns dns;
@override@JsonKey(fromJson: Ntp.safeNtpFromJson) final  Ntp ntp;
@override@JsonKey(fromJson: Sniffer.safeSnifferFromJson) final  Sniffer sniffer;
 final  List<TunnelEntry> _tunnels;
@override@JsonKey() List<TunnelEntry> get tunnels {
  if (_tunnels is EqualUnmodifiableListView) return _tunnels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tunnels);
}

@override@JsonKey(fromJson: Experimental.safeExperimentalFromJson) final  Experimental experimental;
@override@JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) final  GeoXUrl geoXUrl;
@override@JsonKey(name: 'geodata-loader') final  GeodataLoader geodataLoader;
 final  List<ProxyGroup> _proxyGroups;
@override@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}

 final  List<String> _rule;
@override@JsonKey() List<String> get rule {
  if (_rule is EqualUnmodifiableListView) return _rule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rule);
}

@override@JsonKey(name: 'global-ua') final  String? globalUa;
@override@JsonKey(name: 'external-controller') final  ExternalControllerStatus externalController;
@override final  String? secret;
@override@JsonKey(name: 'external-ui-name') final  String? externalUiName;
@override@JsonKey(name: 'external-ui-url') final  String? externalUiUrl;
 final  HostsMap _hosts;
@override@JsonKey() HostsMap get hosts {
  if (_hosts is EqualUnmodifiableMapView) return _hosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hosts);
}


/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClashConfigCopyWith<_ClashConfig> get copyWith => __$ClashConfigCopyWithImpl<_ClashConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClashConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClashConfig&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.socksPort, socksPort) || other.socksPort == socksPort)&&(identical(other.port, port) || other.port == port)&&(identical(other.redirPort, redirPort) || other.redirPort == redirPort)&&(identical(other.tproxyPort, tproxyPort) || other.tproxyPort == tproxyPort)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.keepAliveInterval, keepAliveInterval) || other.keepAliveInterval == keepAliveInterval)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.dns, dns) || other.dns == dns)&&(identical(other.ntp, ntp) || other.ntp == ntp)&&(identical(other.sniffer, sniffer) || other.sniffer == sniffer)&&const DeepCollectionEquality().equals(other._tunnels, _tunnels)&&(identical(other.experimental, experimental) || other.experimental == experimental)&&(identical(other.geoXUrl, geoXUrl) || other.geoXUrl == geoXUrl)&&(identical(other.geodataLoader, geodataLoader) || other.geodataLoader == geodataLoader)&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other._rule, _rule)&&(identical(other.globalUa, globalUa) || other.globalUa == globalUa)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.externalUiName, externalUiName) || other.externalUiName == externalUiName)&&(identical(other.externalUiUrl, externalUiUrl) || other.externalUiUrl == externalUiUrl)&&const DeepCollectionEquality().equals(other._hosts, _hosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,mixedPort,socksPort,port,redirPort,tproxyPort,mode,allowLan,logLevel,ipv6,findProcessMode,keepAliveInterval,unifiedDelay,tcpConcurrent,tun,dns,ntp,sniffer,const DeepCollectionEquality().hash(_tunnels),experimental,geoXUrl,geodataLoader,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_rule),globalUa,externalController,secret,externalUiName,externalUiUrl,const DeepCollectionEquality().hash(_hosts)]);

@override
String toString() {
  return 'ClashConfig(mixedPort: $mixedPort, socksPort: $socksPort, port: $port, redirPort: $redirPort, tproxyPort: $tproxyPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, findProcessMode: $findProcessMode, keepAliveInterval: $keepAliveInterval, unifiedDelay: $unifiedDelay, tcpConcurrent: $tcpConcurrent, tun: $tun, dns: $dns, ntp: $ntp, sniffer: $sniffer, tunnels: $tunnels, experimental: $experimental, geoXUrl: $geoXUrl, geodataLoader: $geodataLoader, proxyGroups: $proxyGroups, rule: $rule, globalUa: $globalUa, externalController: $externalController, secret: $secret, externalUiName: $externalUiName, externalUiUrl: $externalUiUrl, hosts: $hosts)';
}


}

/// @nodoc
abstract mixin class _$ClashConfigCopyWith<$Res> implements $ClashConfigCopyWith<$Res> {
  factory _$ClashConfigCopyWith(_ClashConfig value, $Res Function(_ClashConfig) _then) = __$ClashConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'socks-port') int socksPort,@JsonKey(name: 'port') int port,@JsonKey(name: 'redir-port') int redirPort,@JsonKey(name: 'tproxy-port') int tproxyPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode findProcessMode,@JsonKey(name: 'keep-alive-interval') int keepAliveInterval,@JsonKey(name: 'unified-delay') bool unifiedDelay,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp ntp,@JsonKey(fromJson: Sniffer.safeSnifferFromJson) Sniffer sniffer, List<TunnelEntry> tunnels,@JsonKey(fromJson: Experimental.safeExperimentalFromJson) Experimental experimental,@JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) GeoXUrl geoXUrl,@JsonKey(name: 'geodata-loader') GeodataLoader geodataLoader,@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups, List<String> rule,@JsonKey(name: 'global-ua') String? globalUa,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, String? secret,@JsonKey(name: 'external-ui-name') String? externalUiName,@JsonKey(name: 'external-ui-url') String? externalUiUrl, HostsMap hosts
});


@override $TunCopyWith<$Res> get tun;@override $DnsCopyWith<$Res> get dns;@override $NtpCopyWith<$Res> get ntp;@override $SnifferCopyWith<$Res> get sniffer;@override $ExperimentalCopyWith<$Res> get experimental;@override $GeoXUrlCopyWith<$Res> get geoXUrl;

}
/// @nodoc
class __$ClashConfigCopyWithImpl<$Res>
    implements _$ClashConfigCopyWith<$Res> {
  __$ClashConfigCopyWithImpl(this._self, this._then);

  final _ClashConfig _self;
  final $Res Function(_ClashConfig) _then;

/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mixedPort = null,Object? socksPort = null,Object? port = null,Object? redirPort = null,Object? tproxyPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? findProcessMode = null,Object? keepAliveInterval = null,Object? unifiedDelay = null,Object? tcpConcurrent = null,Object? tun = null,Object? dns = null,Object? ntp = null,Object? sniffer = null,Object? tunnels = null,Object? experimental = null,Object? geoXUrl = null,Object? geodataLoader = null,Object? proxyGroups = null,Object? rule = null,Object? globalUa = freezed,Object? externalController = null,Object? secret = freezed,Object? externalUiName = freezed,Object? externalUiUrl = freezed,Object? hosts = null,}) {
  return _then(_ClashConfig(
mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,socksPort: null == socksPort ? _self.socksPort : socksPort // ignore: cast_nullable_to_non_nullable
as int,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,redirPort: null == redirPort ? _self.redirPort : redirPort // ignore: cast_nullable_to_non_nullable
as int,tproxyPort: null == tproxyPort ? _self.tproxyPort : tproxyPort // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,keepAliveInterval: null == keepAliveInterval ? _self.keepAliveInterval : keepAliveInterval // ignore: cast_nullable_to_non_nullable
as int,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,ntp: null == ntp ? _self.ntp : ntp // ignore: cast_nullable_to_non_nullable
as Ntp,sniffer: null == sniffer ? _self.sniffer : sniffer // ignore: cast_nullable_to_non_nullable
as Sniffer,tunnels: null == tunnels ? _self._tunnels : tunnels // ignore: cast_nullable_to_non_nullable
as List<TunnelEntry>,experimental: null == experimental ? _self.experimental : experimental // ignore: cast_nullable_to_non_nullable
as Experimental,geoXUrl: null == geoXUrl ? _self.geoXUrl : geoXUrl // ignore: cast_nullable_to_non_nullable
as GeoXUrl,geodataLoader: null == geodataLoader ? _self.geodataLoader : geodataLoader // ignore: cast_nullable_to_non_nullable
as GeodataLoader,proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rule: null == rule ? _self._rule : rule // ignore: cast_nullable_to_non_nullable
as List<String>,globalUa: freezed == globalUa ? _self.globalUa : globalUa // ignore: cast_nullable_to_non_nullable
as String?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,secret: freezed == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String?,externalUiName: freezed == externalUiName ? _self.externalUiName : externalUiName // ignore: cast_nullable_to_non_nullable
as String?,externalUiUrl: freezed == externalUiUrl ? _self.externalUiUrl : externalUiUrl // ignore: cast_nullable_to_non_nullable
as String?,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
as HostsMap,
  ));
}

/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NtpCopyWith<$Res> get ntp {
  
  return $NtpCopyWith<$Res>(_self.ntp, (value) {
    return _then(_self.copyWith(ntp: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnifferCopyWith<$Res> get sniffer {
  
  return $SnifferCopyWith<$Res>(_self.sniffer, (value) {
    return _then(_self.copyWith(sniffer: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExperimentalCopyWith<$Res> get experimental {
  
  return $ExperimentalCopyWith<$Res>(_self.experimental, (value) {
    return _then(_self.copyWith(experimental: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoXUrlCopyWith<$Res> get geoXUrl {
  
  return $GeoXUrlCopyWith<$Res>(_self.geoXUrl, (value) {
    return _then(_self.copyWith(geoXUrl: value));
  });
}
}

// dart format on
