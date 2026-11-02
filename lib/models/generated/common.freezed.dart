// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavigationItem {

 Icon get icon; PageLabel get label; String? get description; WidgetBuilder get builder; bool get keep; String? get path; List<NavigationItemMode> get modes;
/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationItemCopyWith<NavigationItem> get copyWith => _$NavigationItemCopyWithImpl<NavigationItem>(this as NavigationItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NavigationItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationItem&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.builder, _this.builder) || other.builder == _this.builder)&&(identical(other.keep, _this.keep) || other.keep == _this.keep)&&(identical(other.path, _this.path) || other.path == _this.path)&&const DeepCollectionEquality().equals(other.modes, _this.modes));
}


@override
int get hashCode {
  final _this = this as NavigationItem;
  return Object.hash(runtimeType,_this.icon,_this.label,_this.description,_this.builder,_this.keep,_this.path,const DeepCollectionEquality().hash(_this.modes));
}

@override
String toString() {
  final _this = this as NavigationItem;
  return 'NavigationItem(icon: ${_this.icon}, label: ${_this.label}, description: ${_this.description}, builder: ${_this.builder}, keep: ${_this.keep}, path: ${_this.path}, modes: ${_this.modes})';
}


}

/// @nodoc
abstract mixin class $NavigationItemCopyWith<$Res>  {
  factory $NavigationItemCopyWith(NavigationItem value, $Res Function(NavigationItem) _then) = _$NavigationItemCopyWithImpl;
@useResult
$Res call({
 Icon icon, PageLabel label, String? description, WidgetBuilder builder, bool keep, String? path, List<NavigationItemMode> modes
});




}
/// @nodoc
class _$NavigationItemCopyWithImpl<$Res>
    implements $NavigationItemCopyWith<$Res> {
  _$NavigationItemCopyWithImpl(this._self, this._then);

  final NavigationItem _self;
  final $Res Function(NavigationItem) _then;

/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? label = null,Object? description = freezed,Object? builder = null,Object? keep = null,Object? path = freezed,Object? modes = null,}) {
  return _then(NavigationItem(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as Icon,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as PageLabel,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,builder: null == builder ? _self.builder : builder // ignore: cast_nullable_to_non_nullable
as WidgetBuilder,keep: null == keep ? _self.keep : keep // ignore: cast_nullable_to_non_nullable
as bool,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,modes: null == modes ? _self.modes : modes // ignore: cast_nullable_to_non_nullable
as List<NavigationItemMode>,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationItem].
extension NavigationItemPatterns on NavigationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationItem value)  $default,){
final _that = this;
switch (_that) {
case _NavigationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Icon icon,  PageLabel label,  String? description,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
return $default(_that.icon,_that.label,_that.description,_that.builder,_that.keep,_that.path,_that.modes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Icon icon,  PageLabel label,  String? description,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)  $default,) {final _that = this;
switch (_that) {
case _NavigationItem():
return $default(_that.icon,_that.label,_that.description,_that.builder,_that.keep,_that.path,_that.modes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Icon icon,  PageLabel label,  String? description,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)?  $default,) {final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
return $default(_that.icon,_that.label,_that.description,_that.builder,_that.keep,_that.path,_that.modes);case _:
  return null;

}
}

}

/// @nodoc


class _NavigationItem implements NavigationItem {
  const _NavigationItem({required this.icon, required this.label, this.description, required this.builder, this.keep = true, this.path,  List<NavigationItemMode> modes = const [NavigationItemMode.mobile, NavigationItemMode.desktop]}): _modes = modes;
  

@override final  Icon icon;
@override final  PageLabel label;
@override final  String? description;
@override final  WidgetBuilder builder;
@override@JsonKey() final  bool keep;
@override final  String? path;
 final  List<NavigationItemMode> _modes;
@override@JsonKey() List<NavigationItemMode> get modes {
  if (_modes is EqualUnmodifiableListView) return _modes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modes);
}


/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationItemCopyWith<_NavigationItem> get copyWith => __$NavigationItemCopyWithImpl<_NavigationItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationItem&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.builder, builder) || other.builder == builder)&&(identical(other.keep, keep) || other.keep == keep)&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.modes, _modes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,icon,label,description,builder,keep,path,const DeepCollectionEquality().hash(_modes));
}

@override
String toString() {
    return 'NavigationItem(icon: $icon, label: $label, description: $description, builder: $builder, keep: $keep, path: $path, modes: $modes)';
}


}

/// @nodoc
abstract mixin class _$NavigationItemCopyWith<$Res> implements $NavigationItemCopyWith<$Res> {
  factory _$NavigationItemCopyWith(_NavigationItem value, $Res Function(_NavigationItem) _then) = __$NavigationItemCopyWithImpl;
@override @useResult
$Res call({
 Icon icon, PageLabel label, String? description, WidgetBuilder builder, bool keep, String? path, List<NavigationItemMode> modes
});




}
/// @nodoc
class __$NavigationItemCopyWithImpl<$Res>
    implements _$NavigationItemCopyWith<$Res> {
  __$NavigationItemCopyWithImpl(this._self, this._then);

  final _NavigationItem _self;
  final $Res Function(_NavigationItem) _then;

/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? label = null,Object? description = freezed,Object? builder = null,Object? keep = null,Object? path = freezed,Object? modes = null,}) {
  return _then(_NavigationItem(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as Icon,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as PageLabel,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,builder: null == builder ? _self.builder : builder // ignore: cast_nullable_to_non_nullable
as WidgetBuilder,keep: null == keep ? _self.keep : keep // ignore: cast_nullable_to_non_nullable
as bool,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,modes: null == modes ? _self._modes : modes // ignore: cast_nullable_to_non_nullable
as List<NavigationItemMode>,
  ));
}


}


/// @nodoc
mixin _$Package {

 String get packageName; String get label; bool get system; bool get internet; int get firstInstallTime; int get lastUpdateTime;
/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageCopyWith<Package> get copyWith => _$PackageCopyWithImpl<Package>(this as Package, _$identity);

  /// Serializes this Package to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Package;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Package&&(identical(other.packageName, _this.packageName) || other.packageName == _this.packageName)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.system, _this.system) || other.system == _this.system)&&(identical(other.internet, _this.internet) || other.internet == _this.internet)&&(identical(other.firstInstallTime, _this.firstInstallTime) || other.firstInstallTime == _this.firstInstallTime)&&(identical(other.lastUpdateTime, _this.lastUpdateTime) || other.lastUpdateTime == _this.lastUpdateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Package;
  return Object.hash(runtimeType,_this.packageName,_this.label,_this.system,_this.internet,_this.firstInstallTime,_this.lastUpdateTime);
}

@override
String toString() {
  final _this = this as Package;
  return 'Package(packageName: ${_this.packageName}, label: ${_this.label}, system: ${_this.system}, internet: ${_this.internet}, firstInstallTime: ${_this.firstInstallTime}, lastUpdateTime: ${_this.lastUpdateTime})';
}


}

/// @nodoc
abstract mixin class $PackageCopyWith<$Res>  {
  factory $PackageCopyWith(Package value, $Res Function(Package) _then) = _$PackageCopyWithImpl;
@useResult
$Res call({
 String packageName, String label, bool system, bool internet, int firstInstallTime, int lastUpdateTime
});




}
/// @nodoc
class _$PackageCopyWithImpl<$Res>
    implements $PackageCopyWith<$Res> {
  _$PackageCopyWithImpl(this._self, this._then);

  final Package _self;
  final $Res Function(Package) _then;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? label = null,Object? system = null,Object? internet = null,Object? firstInstallTime = null,Object? lastUpdateTime = null,}) {
  return _then(Package(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as bool,internet: null == internet ? _self.internet : internet // ignore: cast_nullable_to_non_nullable
as bool,firstInstallTime: null == firstInstallTime ? _self.firstInstallTime : firstInstallTime // ignore: cast_nullable_to_non_nullable
as int,lastUpdateTime: null == lastUpdateTime ? _self.lastUpdateTime : lastUpdateTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Package].
extension PackagePatterns on Package {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Package value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Package() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Package value)  $default,){
final _that = this;
switch (_that) {
case _Package():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Package value)?  $default,){
final _that = this;
switch (_that) {
case _Package() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packageName,  String label,  bool system,  bool internet,  int firstInstallTime,  int lastUpdateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Package() when $default != null:
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.firstInstallTime,_that.lastUpdateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packageName,  String label,  bool system,  bool internet,  int firstInstallTime,  int lastUpdateTime)  $default,) {final _that = this;
switch (_that) {
case _Package():
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.firstInstallTime,_that.lastUpdateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packageName,  String label,  bool system,  bool internet,  int firstInstallTime,  int lastUpdateTime)?  $default,) {final _that = this;
switch (_that) {
case _Package() when $default != null:
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.firstInstallTime,_that.lastUpdateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Package implements Package {
  const _Package({required this.packageName, required this.label, required this.system, required this.internet, this.firstInstallTime = 0, this.lastUpdateTime = 0});
  factory _Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);

@override final  String packageName;
@override final  String label;
@override final  bool system;
@override final  bool internet;
@override@JsonKey() final  int firstInstallTime;
@override@JsonKey() final  int lastUpdateTime;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageCopyWith<_Package> get copyWith => __$PackageCopyWithImpl<_Package>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Package&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.label, label) || other.label == label)&&(identical(other.system, system) || other.system == system)&&(identical(other.internet, internet) || other.internet == internet)&&(identical(other.firstInstallTime, firstInstallTime) || other.firstInstallTime == firstInstallTime)&&(identical(other.lastUpdateTime, lastUpdateTime) || other.lastUpdateTime == lastUpdateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,packageName,label,system,internet,firstInstallTime,lastUpdateTime);
}

@override
String toString() {
    return 'Package(packageName: $packageName, label: $label, system: $system, internet: $internet, firstInstallTime: $firstInstallTime, lastUpdateTime: $lastUpdateTime)';
}


}

/// @nodoc
abstract mixin class _$PackageCopyWith<$Res> implements $PackageCopyWith<$Res> {
  factory _$PackageCopyWith(_Package value, $Res Function(_Package) _then) = __$PackageCopyWithImpl;
@override @useResult
$Res call({
 String packageName, String label, bool system, bool internet, int firstInstallTime, int lastUpdateTime
});




}
/// @nodoc
class __$PackageCopyWithImpl<$Res>
    implements _$PackageCopyWith<$Res> {
  __$PackageCopyWithImpl(this._self, this._then);

  final _Package _self;
  final $Res Function(_Package) _then;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? label = null,Object? system = null,Object? internet = null,Object? firstInstallTime = null,Object? lastUpdateTime = null,}) {
  return _then(_Package(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as bool,internet: null == internet ? _self.internet : internet // ignore: cast_nullable_to_non_nullable
as bool,firstInstallTime: null == firstInstallTime ? _self.firstInstallTime : firstInstallTime // ignore: cast_nullable_to_non_nullable
as int,lastUpdateTime: null == lastUpdateTime ? _self.lastUpdateTime : lastUpdateTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Metadata {

 int get uid; String get network; String get type; String get sourceIP; String get sourcePort; String get destinationIP; String get destinationPort; String get host; String get sniffHost; String get inboundName; String get inboundPort; String get inboundUser; DnsMode? get dnsMode; String get process; String get processPath; String get remoteDestination; List<String> get sourceGeoIP; List<String> get destinationGeoIP; String get destinationIPASN; String get sourceIPASN; String get specialRules; String get specialProxy;
/// Create a copy of Metadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetadataCopyWith<Metadata> get copyWith => _$MetadataCopyWithImpl<Metadata>(this as Metadata, _$identity);

  /// Serializes this Metadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Metadata;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Metadata&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.network, _this.network) || other.network == _this.network)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.sourceIP, _this.sourceIP) || other.sourceIP == _this.sourceIP)&&(identical(other.sourcePort, _this.sourcePort) || other.sourcePort == _this.sourcePort)&&(identical(other.destinationIP, _this.destinationIP) || other.destinationIP == _this.destinationIP)&&(identical(other.destinationPort, _this.destinationPort) || other.destinationPort == _this.destinationPort)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.sniffHost, _this.sniffHost) || other.sniffHost == _this.sniffHost)&&(identical(other.inboundName, _this.inboundName) || other.inboundName == _this.inboundName)&&(identical(other.inboundPort, _this.inboundPort) || other.inboundPort == _this.inboundPort)&&(identical(other.inboundUser, _this.inboundUser) || other.inboundUser == _this.inboundUser)&&(identical(other.dnsMode, _this.dnsMode) || other.dnsMode == _this.dnsMode)&&(identical(other.process, _this.process) || other.process == _this.process)&&(identical(other.processPath, _this.processPath) || other.processPath == _this.processPath)&&(identical(other.remoteDestination, _this.remoteDestination) || other.remoteDestination == _this.remoteDestination)&&const DeepCollectionEquality().equals(other.sourceGeoIP, _this.sourceGeoIP)&&const DeepCollectionEquality().equals(other.destinationGeoIP, _this.destinationGeoIP)&&(identical(other.destinationIPASN, _this.destinationIPASN) || other.destinationIPASN == _this.destinationIPASN)&&(identical(other.sourceIPASN, _this.sourceIPASN) || other.sourceIPASN == _this.sourceIPASN)&&(identical(other.specialRules, _this.specialRules) || other.specialRules == _this.specialRules)&&(identical(other.specialProxy, _this.specialProxy) || other.specialProxy == _this.specialProxy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Metadata;
  return Object.hashAll([runtimeType,_this.uid,_this.network,_this.type,_this.sourceIP,_this.sourcePort,_this.destinationIP,_this.destinationPort,_this.host,_this.sniffHost,_this.inboundName,_this.inboundPort,_this.inboundUser,_this.dnsMode,_this.process,_this.processPath,_this.remoteDestination,const DeepCollectionEquality().hash(_this.sourceGeoIP),const DeepCollectionEquality().hash(_this.destinationGeoIP),_this.destinationIPASN,_this.sourceIPASN,_this.specialRules,_this.specialProxy]);
}

@override
String toString() {
  final _this = this as Metadata;
  return 'Metadata(uid: ${_this.uid}, network: ${_this.network}, type: ${_this.type}, sourceIP: ${_this.sourceIP}, sourcePort: ${_this.sourcePort}, destinationIP: ${_this.destinationIP}, destinationPort: ${_this.destinationPort}, host: ${_this.host}, sniffHost: ${_this.sniffHost}, inboundName: ${_this.inboundName}, inboundPort: ${_this.inboundPort}, inboundUser: ${_this.inboundUser}, dnsMode: ${_this.dnsMode}, process: ${_this.process}, processPath: ${_this.processPath}, remoteDestination: ${_this.remoteDestination}, sourceGeoIP: ${_this.sourceGeoIP}, destinationGeoIP: ${_this.destinationGeoIP}, destinationIPASN: ${_this.destinationIPASN}, sourceIPASN: ${_this.sourceIPASN}, specialRules: ${_this.specialRules}, specialProxy: ${_this.specialProxy})';
}


}

/// @nodoc
abstract mixin class $MetadataCopyWith<$Res>  {
  factory $MetadataCopyWith(Metadata value, $Res Function(Metadata) _then) = _$MetadataCopyWithImpl;
@useResult
$Res call({
 int uid, String network, String type, String sourceIP, String sourcePort, String destinationIP, String destinationPort, String host, String sniffHost, String inboundName, String inboundPort, String inboundUser, DnsMode? dnsMode, String process, String processPath, String remoteDestination, List<String> sourceGeoIP, List<String> destinationGeoIP, String destinationIPASN, String sourceIPASN, String specialRules, String specialProxy
});




}
/// @nodoc
class _$MetadataCopyWithImpl<$Res>
    implements $MetadataCopyWith<$Res> {
  _$MetadataCopyWithImpl(this._self, this._then);

  final Metadata _self;
  final $Res Function(Metadata) _then;

/// Create a copy of Metadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? network = null,Object? type = null,Object? sourceIP = null,Object? sourcePort = null,Object? destinationIP = null,Object? destinationPort = null,Object? host = null,Object? sniffHost = null,Object? inboundName = null,Object? inboundPort = null,Object? inboundUser = null,Object? dnsMode = freezed,Object? process = null,Object? processPath = null,Object? remoteDestination = null,Object? sourceGeoIP = null,Object? destinationGeoIP = null,Object? destinationIPASN = null,Object? sourceIPASN = null,Object? specialRules = null,Object? specialProxy = null,}) {
  return _then(Metadata(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,sourceIP: null == sourceIP ? _self.sourceIP : sourceIP // ignore: cast_nullable_to_non_nullable
as String,sourcePort: null == sourcePort ? _self.sourcePort : sourcePort // ignore: cast_nullable_to_non_nullable
as String,destinationIP: null == destinationIP ? _self.destinationIP : destinationIP // ignore: cast_nullable_to_non_nullable
as String,destinationPort: null == destinationPort ? _self.destinationPort : destinationPort // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,sniffHost: null == sniffHost ? _self.sniffHost : sniffHost // ignore: cast_nullable_to_non_nullable
as String,inboundName: null == inboundName ? _self.inboundName : inboundName // ignore: cast_nullable_to_non_nullable
as String,inboundPort: null == inboundPort ? _self.inboundPort : inboundPort // ignore: cast_nullable_to_non_nullable
as String,inboundUser: null == inboundUser ? _self.inboundUser : inboundUser // ignore: cast_nullable_to_non_nullable
as String,dnsMode: freezed == dnsMode ? _self.dnsMode : dnsMode // ignore: cast_nullable_to_non_nullable
as DnsMode?,process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,processPath: null == processPath ? _self.processPath : processPath // ignore: cast_nullable_to_non_nullable
as String,remoteDestination: null == remoteDestination ? _self.remoteDestination : remoteDestination // ignore: cast_nullable_to_non_nullable
as String,sourceGeoIP: null == sourceGeoIP ? _self.sourceGeoIP : sourceGeoIP // ignore: cast_nullable_to_non_nullable
as List<String>,destinationGeoIP: null == destinationGeoIP ? _self.destinationGeoIP : destinationGeoIP // ignore: cast_nullable_to_non_nullable
as List<String>,destinationIPASN: null == destinationIPASN ? _self.destinationIPASN : destinationIPASN // ignore: cast_nullable_to_non_nullable
as String,sourceIPASN: null == sourceIPASN ? _self.sourceIPASN : sourceIPASN // ignore: cast_nullable_to_non_nullable
as String,specialRules: null == specialRules ? _self.specialRules : specialRules // ignore: cast_nullable_to_non_nullable
as String,specialProxy: null == specialProxy ? _self.specialProxy : specialProxy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Metadata].
extension MetadataPatterns on Metadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Metadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Metadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Metadata value)  $default,){
final _that = this;
switch (_that) {
case _Metadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Metadata value)?  $default,){
final _that = this;
switch (_that) {
case _Metadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int uid,  String network,  String type,  String sourceIP,  String sourcePort,  String destinationIP,  String destinationPort,  String host,  String sniffHost,  String inboundName,  String inboundPort,  String inboundUser,  DnsMode? dnsMode,  String process,  String processPath,  String remoteDestination,  List<String> sourceGeoIP,  List<String> destinationGeoIP,  String destinationIPASN,  String sourceIPASN,  String specialRules,  String specialProxy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Metadata() when $default != null:
return $default(_that.uid,_that.network,_that.type,_that.sourceIP,_that.sourcePort,_that.destinationIP,_that.destinationPort,_that.host,_that.sniffHost,_that.inboundName,_that.inboundPort,_that.inboundUser,_that.dnsMode,_that.process,_that.processPath,_that.remoteDestination,_that.sourceGeoIP,_that.destinationGeoIP,_that.destinationIPASN,_that.sourceIPASN,_that.specialRules,_that.specialProxy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int uid,  String network,  String type,  String sourceIP,  String sourcePort,  String destinationIP,  String destinationPort,  String host,  String sniffHost,  String inboundName,  String inboundPort,  String inboundUser,  DnsMode? dnsMode,  String process,  String processPath,  String remoteDestination,  List<String> sourceGeoIP,  List<String> destinationGeoIP,  String destinationIPASN,  String sourceIPASN,  String specialRules,  String specialProxy)  $default,) {final _that = this;
switch (_that) {
case _Metadata():
return $default(_that.uid,_that.network,_that.type,_that.sourceIP,_that.sourcePort,_that.destinationIP,_that.destinationPort,_that.host,_that.sniffHost,_that.inboundName,_that.inboundPort,_that.inboundUser,_that.dnsMode,_that.process,_that.processPath,_that.remoteDestination,_that.sourceGeoIP,_that.destinationGeoIP,_that.destinationIPASN,_that.sourceIPASN,_that.specialRules,_that.specialProxy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int uid,  String network,  String type,  String sourceIP,  String sourcePort,  String destinationIP,  String destinationPort,  String host,  String sniffHost,  String inboundName,  String inboundPort,  String inboundUser,  DnsMode? dnsMode,  String process,  String processPath,  String remoteDestination,  List<String> sourceGeoIP,  List<String> destinationGeoIP,  String destinationIPASN,  String sourceIPASN,  String specialRules,  String specialProxy)?  $default,) {final _that = this;
switch (_that) {
case _Metadata() when $default != null:
return $default(_that.uid,_that.network,_that.type,_that.sourceIP,_that.sourcePort,_that.destinationIP,_that.destinationPort,_that.host,_that.sniffHost,_that.inboundName,_that.inboundPort,_that.inboundUser,_that.dnsMode,_that.process,_that.processPath,_that.remoteDestination,_that.sourceGeoIP,_that.destinationGeoIP,_that.destinationIPASN,_that.sourceIPASN,_that.specialRules,_that.specialProxy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Metadata implements Metadata {
  const _Metadata({this.uid = 0, this.network = '', this.type = '', this.sourceIP = '', this.sourcePort = '', this.destinationIP = '', this.destinationPort = '', this.host = '', this.sniffHost = '', this.inboundName = '', this.inboundPort = '', this.inboundUser = '', this.dnsMode, this.process = '', this.processPath = '', this.remoteDestination = '',  List<String> sourceGeoIP = const [],  List<String> destinationGeoIP = const [], this.destinationIPASN = '', this.sourceIPASN = '', this.specialRules = '', this.specialProxy = ''}): _sourceGeoIP = sourceGeoIP,_destinationGeoIP = destinationGeoIP;
  factory _Metadata.fromJson(Map<String, dynamic> json) => _$MetadataFromJson(json);

@override@JsonKey() final  int uid;
@override@JsonKey() final  String network;
@override@JsonKey() final  String type;
@override@JsonKey() final  String sourceIP;
@override@JsonKey() final  String sourcePort;
@override@JsonKey() final  String destinationIP;
@override@JsonKey() final  String destinationPort;
@override@JsonKey() final  String host;
@override@JsonKey() final  String sniffHost;
@override@JsonKey() final  String inboundName;
@override@JsonKey() final  String inboundPort;
@override@JsonKey() final  String inboundUser;
@override final  DnsMode? dnsMode;
@override@JsonKey() final  String process;
@override@JsonKey() final  String processPath;
@override@JsonKey() final  String remoteDestination;
 final  List<String> _sourceGeoIP;
@override@JsonKey() List<String> get sourceGeoIP {
  if (_sourceGeoIP is EqualUnmodifiableListView) return _sourceGeoIP;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceGeoIP);
}

 final  List<String> _destinationGeoIP;
@override@JsonKey() List<String> get destinationGeoIP {
  if (_destinationGeoIP is EqualUnmodifiableListView) return _destinationGeoIP;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_destinationGeoIP);
}

@override@JsonKey() final  String destinationIPASN;
@override@JsonKey() final  String sourceIPASN;
@override@JsonKey() final  String specialRules;
@override@JsonKey() final  String specialProxy;

/// Create a copy of Metadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetadataCopyWith<_Metadata> get copyWith => __$MetadataCopyWithImpl<_Metadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetadataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Metadata&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.network, network) || other.network == network)&&(identical(other.type, type) || other.type == type)&&(identical(other.sourceIP, sourceIP) || other.sourceIP == sourceIP)&&(identical(other.sourcePort, sourcePort) || other.sourcePort == sourcePort)&&(identical(other.destinationIP, destinationIP) || other.destinationIP == destinationIP)&&(identical(other.destinationPort, destinationPort) || other.destinationPort == destinationPort)&&(identical(other.host, host) || other.host == host)&&(identical(other.sniffHost, sniffHost) || other.sniffHost == sniffHost)&&(identical(other.inboundName, inboundName) || other.inboundName == inboundName)&&(identical(other.inboundPort, inboundPort) || other.inboundPort == inboundPort)&&(identical(other.inboundUser, inboundUser) || other.inboundUser == inboundUser)&&(identical(other.dnsMode, dnsMode) || other.dnsMode == dnsMode)&&(identical(other.process, process) || other.process == process)&&(identical(other.processPath, processPath) || other.processPath == processPath)&&(identical(other.remoteDestination, remoteDestination) || other.remoteDestination == remoteDestination)&&const DeepCollectionEquality().equals(other.sourceGeoIP, _sourceGeoIP)&&const DeepCollectionEquality().equals(other.destinationGeoIP, _destinationGeoIP)&&(identical(other.destinationIPASN, destinationIPASN) || other.destinationIPASN == destinationIPASN)&&(identical(other.sourceIPASN, sourceIPASN) || other.sourceIPASN == sourceIPASN)&&(identical(other.specialRules, specialRules) || other.specialRules == specialRules)&&(identical(other.specialProxy, specialProxy) || other.specialProxy == specialProxy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,uid,network,type,sourceIP,sourcePort,destinationIP,destinationPort,host,sniffHost,inboundName,inboundPort,inboundUser,dnsMode,process,processPath,remoteDestination,const DeepCollectionEquality().hash(_sourceGeoIP),const DeepCollectionEquality().hash(_destinationGeoIP),destinationIPASN,sourceIPASN,specialRules,specialProxy]);
}

@override
String toString() {
    return 'Metadata(uid: $uid, network: $network, type: $type, sourceIP: $sourceIP, sourcePort: $sourcePort, destinationIP: $destinationIP, destinationPort: $destinationPort, host: $host, sniffHost: $sniffHost, inboundName: $inboundName, inboundPort: $inboundPort, inboundUser: $inboundUser, dnsMode: $dnsMode, process: $process, processPath: $processPath, remoteDestination: $remoteDestination, sourceGeoIP: $sourceGeoIP, destinationGeoIP: $destinationGeoIP, destinationIPASN: $destinationIPASN, sourceIPASN: $sourceIPASN, specialRules: $specialRules, specialProxy: $specialProxy)';
}


}

/// @nodoc
abstract mixin class _$MetadataCopyWith<$Res> implements $MetadataCopyWith<$Res> {
  factory _$MetadataCopyWith(_Metadata value, $Res Function(_Metadata) _then) = __$MetadataCopyWithImpl;
@override @useResult
$Res call({
 int uid, String network, String type, String sourceIP, String sourcePort, String destinationIP, String destinationPort, String host, String sniffHost, String inboundName, String inboundPort, String inboundUser, DnsMode? dnsMode, String process, String processPath, String remoteDestination, List<String> sourceGeoIP, List<String> destinationGeoIP, String destinationIPASN, String sourceIPASN, String specialRules, String specialProxy
});




}
/// @nodoc
class __$MetadataCopyWithImpl<$Res>
    implements _$MetadataCopyWith<$Res> {
  __$MetadataCopyWithImpl(this._self, this._then);

  final _Metadata _self;
  final $Res Function(_Metadata) _then;

/// Create a copy of Metadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? network = null,Object? type = null,Object? sourceIP = null,Object? sourcePort = null,Object? destinationIP = null,Object? destinationPort = null,Object? host = null,Object? sniffHost = null,Object? inboundName = null,Object? inboundPort = null,Object? inboundUser = null,Object? dnsMode = freezed,Object? process = null,Object? processPath = null,Object? remoteDestination = null,Object? sourceGeoIP = null,Object? destinationGeoIP = null,Object? destinationIPASN = null,Object? sourceIPASN = null,Object? specialRules = null,Object? specialProxy = null,}) {
  return _then(_Metadata(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,sourceIP: null == sourceIP ? _self.sourceIP : sourceIP // ignore: cast_nullable_to_non_nullable
as String,sourcePort: null == sourcePort ? _self.sourcePort : sourcePort // ignore: cast_nullable_to_non_nullable
as String,destinationIP: null == destinationIP ? _self.destinationIP : destinationIP // ignore: cast_nullable_to_non_nullable
as String,destinationPort: null == destinationPort ? _self.destinationPort : destinationPort // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,sniffHost: null == sniffHost ? _self.sniffHost : sniffHost // ignore: cast_nullable_to_non_nullable
as String,inboundName: null == inboundName ? _self.inboundName : inboundName // ignore: cast_nullable_to_non_nullable
as String,inboundPort: null == inboundPort ? _self.inboundPort : inboundPort // ignore: cast_nullable_to_non_nullable
as String,inboundUser: null == inboundUser ? _self.inboundUser : inboundUser // ignore: cast_nullable_to_non_nullable
as String,dnsMode: freezed == dnsMode ? _self.dnsMode : dnsMode // ignore: cast_nullable_to_non_nullable
as DnsMode?,process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,processPath: null == processPath ? _self.processPath : processPath // ignore: cast_nullable_to_non_nullable
as String,remoteDestination: null == remoteDestination ? _self.remoteDestination : remoteDestination // ignore: cast_nullable_to_non_nullable
as String,sourceGeoIP: null == sourceGeoIP ? _self._sourceGeoIP : sourceGeoIP // ignore: cast_nullable_to_non_nullable
as List<String>,destinationGeoIP: null == destinationGeoIP ? _self._destinationGeoIP : destinationGeoIP // ignore: cast_nullable_to_non_nullable
as List<String>,destinationIPASN: null == destinationIPASN ? _self.destinationIPASN : destinationIPASN // ignore: cast_nullable_to_non_nullable
as String,sourceIPASN: null == sourceIPASN ? _self.sourceIPASN : sourceIPASN // ignore: cast_nullable_to_non_nullable
as String,specialRules: null == specialRules ? _self.specialRules : specialRules // ignore: cast_nullable_to_non_nullable
as String,specialProxy: null == specialProxy ? _self.specialProxy : specialProxy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TrackerInfo {

 String get id; int get upload; int get download; DateTime get start; Metadata get metadata; List<String> get chains; String get rule; String get rulePayload; int? get downloadSpeed; int? get uploadSpeed;
/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackerInfoCopyWith<TrackerInfo> get copyWith => _$TrackerInfoCopyWithImpl<TrackerInfo>(this as TrackerInfo, _$identity);

  /// Serializes this TrackerInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrackerInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackerInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.upload, _this.upload) || other.upload == _this.upload)&&(identical(other.download, _this.download) || other.download == _this.download)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.metadata, _this.metadata) || other.metadata == _this.metadata)&&const DeepCollectionEquality().equals(other.chains, _this.chains)&&(identical(other.rule, _this.rule) || other.rule == _this.rule)&&(identical(other.rulePayload, _this.rulePayload) || other.rulePayload == _this.rulePayload)&&(identical(other.downloadSpeed, _this.downloadSpeed) || other.downloadSpeed == _this.downloadSpeed)&&(identical(other.uploadSpeed, _this.uploadSpeed) || other.uploadSpeed == _this.uploadSpeed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrackerInfo;
  return Object.hash(runtimeType,_this.id,_this.upload,_this.download,_this.start,_this.metadata,const DeepCollectionEquality().hash(_this.chains),_this.rule,_this.rulePayload,_this.downloadSpeed,_this.uploadSpeed);
}

@override
String toString() {
  final _this = this as TrackerInfo;
  return 'TrackerInfo(id: ${_this.id}, upload: ${_this.upload}, download: ${_this.download}, start: ${_this.start}, metadata: ${_this.metadata}, chains: ${_this.chains}, rule: ${_this.rule}, rulePayload: ${_this.rulePayload}, downloadSpeed: ${_this.downloadSpeed}, uploadSpeed: ${_this.uploadSpeed})';
}


}

/// @nodoc
abstract mixin class $TrackerInfoCopyWith<$Res>  {
  factory $TrackerInfoCopyWith(TrackerInfo value, $Res Function(TrackerInfo) _then) = _$TrackerInfoCopyWithImpl;
@useResult
$Res call({
 String id, int upload, int download, DateTime start, Metadata metadata, List<String> chains, String rule, String rulePayload, int? downloadSpeed, int? uploadSpeed
});


$MetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class _$TrackerInfoCopyWithImpl<$Res>
    implements $TrackerInfoCopyWith<$Res> {
  _$TrackerInfoCopyWithImpl(this._self, this._then);

  final TrackerInfo _self;
  final $Res Function(TrackerInfo) _then;

/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? upload = null,Object? download = null,Object? start = null,Object? metadata = null,Object? chains = null,Object? rule = null,Object? rulePayload = null,Object? downloadSpeed = freezed,Object? uploadSpeed = freezed,}) {
  return _then(TrackerInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Metadata,chains: null == chains ? _self.chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,rulePayload: null == rulePayload ? _self.rulePayload : rulePayload // ignore: cast_nullable_to_non_nullable
as String,downloadSpeed: freezed == downloadSpeed ? _self.downloadSpeed : downloadSpeed // ignore: cast_nullable_to_non_nullable
as int?,uploadSpeed: freezed == uploadSpeed ? _self.uploadSpeed : uploadSpeed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataCopyWith<$Res> get metadata {
  
  return $MetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrackerInfo].
extension TrackerInfoPatterns on TrackerInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackerInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackerInfo value)  $default,){
final _that = this;
switch (_that) {
case _TrackerInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TrackerInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int upload,  int download,  DateTime start,  Metadata metadata,  List<String> chains,  String rule,  String rulePayload,  int? downloadSpeed,  int? uploadSpeed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackerInfo() when $default != null:
return $default(_that.id,_that.upload,_that.download,_that.start,_that.metadata,_that.chains,_that.rule,_that.rulePayload,_that.downloadSpeed,_that.uploadSpeed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int upload,  int download,  DateTime start,  Metadata metadata,  List<String> chains,  String rule,  String rulePayload,  int? downloadSpeed,  int? uploadSpeed)  $default,) {final _that = this;
switch (_that) {
case _TrackerInfo():
return $default(_that.id,_that.upload,_that.download,_that.start,_that.metadata,_that.chains,_that.rule,_that.rulePayload,_that.downloadSpeed,_that.uploadSpeed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int upload,  int download,  DateTime start,  Metadata metadata,  List<String> chains,  String rule,  String rulePayload,  int? downloadSpeed,  int? uploadSpeed)?  $default,) {final _that = this;
switch (_that) {
case _TrackerInfo() when $default != null:
return $default(_that.id,_that.upload,_that.download,_that.start,_that.metadata,_that.chains,_that.rule,_that.rulePayload,_that.downloadSpeed,_that.uploadSpeed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackerInfo implements TrackerInfo {
  const _TrackerInfo({required this.id, this.upload = 0, this.download = 0, required this.start, required this.metadata, required  List<String> chains, required this.rule, required this.rulePayload, this.downloadSpeed, this.uploadSpeed}): _chains = chains;
  factory _TrackerInfo.fromJson(Map<String, dynamic> json) => _$TrackerInfoFromJson(json);

@override final  String id;
@override@JsonKey() final  int upload;
@override@JsonKey() final  int download;
@override final  DateTime start;
@override final  Metadata metadata;
 final  List<String> _chains;
@override List<String> get chains {
  if (_chains is EqualUnmodifiableListView) return _chains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chains);
}

@override final  String rule;
@override final  String rulePayload;
@override final  int? downloadSpeed;
@override final  int? uploadSpeed;

/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackerInfoCopyWith<_TrackerInfo> get copyWith => __$TrackerInfoCopyWithImpl<_TrackerInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackerInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.start, start) || other.start == start)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&const DeepCollectionEquality().equals(other.chains, _chains)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.rulePayload, rulePayload) || other.rulePayload == rulePayload)&&(identical(other.downloadSpeed, downloadSpeed) || other.downloadSpeed == downloadSpeed)&&(identical(other.uploadSpeed, uploadSpeed) || other.uploadSpeed == uploadSpeed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,upload,download,start,metadata,const DeepCollectionEquality().hash(_chains),rule,rulePayload,downloadSpeed,uploadSpeed);
}

@override
String toString() {
    return 'TrackerInfo(id: $id, upload: $upload, download: $download, start: $start, metadata: $metadata, chains: $chains, rule: $rule, rulePayload: $rulePayload, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed)';
}


}

/// @nodoc
abstract mixin class _$TrackerInfoCopyWith<$Res> implements $TrackerInfoCopyWith<$Res> {
  factory _$TrackerInfoCopyWith(_TrackerInfo value, $Res Function(_TrackerInfo) _then) = __$TrackerInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, int upload, int download, DateTime start, Metadata metadata, List<String> chains, String rule, String rulePayload, int? downloadSpeed, int? uploadSpeed
});


@override $MetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class __$TrackerInfoCopyWithImpl<$Res>
    implements _$TrackerInfoCopyWith<$Res> {
  __$TrackerInfoCopyWithImpl(this._self, this._then);

  final _TrackerInfo _self;
  final $Res Function(_TrackerInfo) _then;

/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? upload = null,Object? download = null,Object? start = null,Object? metadata = null,Object? chains = null,Object? rule = null,Object? rulePayload = null,Object? downloadSpeed = freezed,Object? uploadSpeed = freezed,}) {
  return _then(_TrackerInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Metadata,chains: null == chains ? _self._chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,rulePayload: null == rulePayload ? _self.rulePayload : rulePayload // ignore: cast_nullable_to_non_nullable
as String,downloadSpeed: freezed == downloadSpeed ? _self.downloadSpeed : downloadSpeed // ignore: cast_nullable_to_non_nullable
as int?,uploadSpeed: freezed == uploadSpeed ? _self.uploadSpeed : uploadSpeed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataCopyWith<$Res> get metadata {
  
  return $MetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// @nodoc
mixin _$Log {

@JsonKey(name: 'LogLevel') LogLevel get logLevel;@JsonKey(name: 'Payload') String get payload;@JsonKey(fromJson: _logTime) DateTime get time;@JsonKey(includeFromJson: false, includeToJson: false) LogSource get source;@JsonKey(includeFromJson: false, includeToJson: false) String? get module;
/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogCopyWith<Log> get copyWith => _$LogCopyWithImpl<Log>(this as Log, _$identity);

  /// Serializes this Log to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Log;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Log&&(identical(other.logLevel, _this.logLevel) || other.logLevel == _this.logLevel)&&(identical(other.payload, _this.payload) || other.payload == _this.payload)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.module, _this.module) || other.module == _this.module));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Log;
  return Object.hash(runtimeType,_this.logLevel,_this.payload,_this.time,_this.source,_this.module);
}

@override
String toString() {
  final _this = this as Log;
  return 'Log(logLevel: ${_this.logLevel}, payload: ${_this.payload}, time: ${_this.time}, source: ${_this.source}, module: ${_this.module})';
}


}

/// @nodoc
abstract mixin class $LogCopyWith<$Res>  {
  factory $LogCopyWith(Log value, $Res Function(Log) _then) = _$LogCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'LogLevel') LogLevel logLevel,@JsonKey(name: 'Payload') String payload,@JsonKey(fromJson: _logTime) DateTime time,@JsonKey(includeFromJson: false, includeToJson: false) LogSource source,@JsonKey(includeFromJson: false, includeToJson: false) String? module
});




}
/// @nodoc
class _$LogCopyWithImpl<$Res>
    implements $LogCopyWith<$Res> {
  _$LogCopyWithImpl(this._self, this._then);

  final Log _self;
  final $Res Function(Log) _then;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logLevel = null,Object? payload = null,Object? time = null,Object? source = null,Object? module = freezed,}) {
  return _then(Log(
logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LogSource,module: freezed == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Log].
extension LogPatterns on Log {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Log value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Log() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Log value)  $default,){
final _that = this;
switch (_that) {
case _Log():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Log value)?  $default,){
final _that = this;
switch (_that) {
case _Log() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logTime)  DateTime time, @JsonKey(includeFromJson: false, includeToJson: false)  LogSource source, @JsonKey(includeFromJson: false, includeToJson: false)  String? module)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Log() when $default != null:
return $default(_that.logLevel,_that.payload,_that.time,_that.source,_that.module);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logTime)  DateTime time, @JsonKey(includeFromJson: false, includeToJson: false)  LogSource source, @JsonKey(includeFromJson: false, includeToJson: false)  String? module)  $default,) {final _that = this;
switch (_that) {
case _Log():
return $default(_that.logLevel,_that.payload,_that.time,_that.source,_that.module);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logTime)  DateTime time, @JsonKey(includeFromJson: false, includeToJson: false)  LogSource source, @JsonKey(includeFromJson: false, includeToJson: false)  String? module)?  $default,) {final _that = this;
switch (_that) {
case _Log() when $default != null:
return $default(_that.logLevel,_that.payload,_that.time,_that.source,_that.module);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Log implements Log {
  const _Log({@JsonKey(name: 'LogLevel') this.logLevel = LogLevel.error, @JsonKey(name: 'Payload') this.payload = '', @JsonKey(fromJson: _logTime) required this.time, @JsonKey(includeFromJson: false, includeToJson: false) this.source = LogSource.core, @JsonKey(includeFromJson: false, includeToJson: false) this.module});
  factory _Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

@override@JsonKey(name: 'LogLevel') final  LogLevel logLevel;
@override@JsonKey(name: 'Payload') final  String payload;
@override@JsonKey(fromJson: _logTime) final  DateTime time;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  LogSource source;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  String? module;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogCopyWith<_Log> get copyWith => __$LogCopyWithImpl<_Log>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Log&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.time, time) || other.time == time)&&(identical(other.source, source) || other.source == source)&&(identical(other.module, module) || other.module == module));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,logLevel,payload,time,source,module);
}

@override
String toString() {
    return 'Log(logLevel: $logLevel, payload: $payload, time: $time, source: $source, module: $module)';
}


}

/// @nodoc
abstract mixin class _$LogCopyWith<$Res> implements $LogCopyWith<$Res> {
  factory _$LogCopyWith(_Log value, $Res Function(_Log) _then) = __$LogCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'LogLevel') LogLevel logLevel,@JsonKey(name: 'Payload') String payload,@JsonKey(fromJson: _logTime) DateTime time,@JsonKey(includeFromJson: false, includeToJson: false) LogSource source,@JsonKey(includeFromJson: false, includeToJson: false) String? module
});




}
/// @nodoc
class __$LogCopyWithImpl<$Res>
    implements _$LogCopyWith<$Res> {
  __$LogCopyWithImpl(this._self, this._then);

  final _Log _self;
  final $Res Function(_Log) _then;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logLevel = null,Object? payload = null,Object? time = null,Object? source = null,Object? module = freezed,}) {
  return _then(_Log(
logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LogSource,module: freezed == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LogsFilterState {

 LogSource? get source; Set<LogLevel> get levels; String? get module; String get query;
/// Create a copy of LogsFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogsFilterStateCopyWith<LogsFilterState> get copyWith => _$LogsFilterStateCopyWithImpl<LogsFilterState>(this as LogsFilterState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LogsFilterState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogsFilterState&&(identical(other.source, _this.source) || other.source == _this.source)&&const DeepCollectionEquality().equals(other.levels, _this.levels)&&(identical(other.module, _this.module) || other.module == _this.module)&&(identical(other.query, _this.query) || other.query == _this.query));
}


@override
int get hashCode {
  final _this = this as LogsFilterState;
  return Object.hash(runtimeType,_this.source,const DeepCollectionEquality().hash(_this.levels),_this.module,_this.query);
}

@override
String toString() {
  final _this = this as LogsFilterState;
  return 'LogsFilterState(source: ${_this.source}, levels: ${_this.levels}, module: ${_this.module}, query: ${_this.query})';
}


}

/// @nodoc
abstract mixin class $LogsFilterStateCopyWith<$Res>  {
  factory $LogsFilterStateCopyWith(LogsFilterState value, $Res Function(LogsFilterState) _then) = _$LogsFilterStateCopyWithImpl;
@useResult
$Res call({
 LogSource? source, Set<LogLevel> levels, String? module, String query
});




}
/// @nodoc
class _$LogsFilterStateCopyWithImpl<$Res>
    implements $LogsFilterStateCopyWith<$Res> {
  _$LogsFilterStateCopyWithImpl(this._self, this._then);

  final LogsFilterState _self;
  final $Res Function(LogsFilterState) _then;

/// Create a copy of LogsFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = freezed,Object? levels = null,Object? module = freezed,Object? query = null,}) {
  return _then(LogsFilterState(
source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LogSource?,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as Set<LogLevel>,module: freezed == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LogsFilterState].
extension LogsFilterStatePatterns on LogsFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogsFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogsFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogsFilterState value)  $default,){
final _that = this;
switch (_that) {
case _LogsFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogsFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _LogsFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LogSource? source,  Set<LogLevel> levels,  String? module,  String query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogsFilterState() when $default != null:
return $default(_that.source,_that.levels,_that.module,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LogSource? source,  Set<LogLevel> levels,  String? module,  String query)  $default,) {final _that = this;
switch (_that) {
case _LogsFilterState():
return $default(_that.source,_that.levels,_that.module,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LogSource? source,  Set<LogLevel> levels,  String? module,  String query)?  $default,) {final _that = this;
switch (_that) {
case _LogsFilterState() when $default != null:
return $default(_that.source,_that.levels,_that.module,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _LogsFilterState implements LogsFilterState {
  const _LogsFilterState({this.source,  Set<LogLevel> levels = const {}, this.module, this.query = ''}): _levels = levels;
  

@override final  LogSource? source;
 final  Set<LogLevel> _levels;
@override@JsonKey() Set<LogLevel> get levels {
  if (_levels is EqualUnmodifiableSetView) return _levels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_levels);
}

@override final  String? module;
@override@JsonKey() final  String query;

/// Create a copy of LogsFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogsFilterStateCopyWith<_LogsFilterState> get copyWith => __$LogsFilterStateCopyWithImpl<_LogsFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogsFilterState&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.levels, _levels)&&(identical(other.module, module) || other.module == module)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode {
    return Object.hash(runtimeType,source,const DeepCollectionEquality().hash(_levels),module,query);
}

@override
String toString() {
    return 'LogsFilterState(source: $source, levels: $levels, module: $module, query: $query)';
}


}

/// @nodoc
abstract mixin class _$LogsFilterStateCopyWith<$Res> implements $LogsFilterStateCopyWith<$Res> {
  factory _$LogsFilterStateCopyWith(_LogsFilterState value, $Res Function(_LogsFilterState) _then) = __$LogsFilterStateCopyWithImpl;
@override @useResult
$Res call({
 LogSource? source, Set<LogLevel> levels, String? module, String query
});




}
/// @nodoc
class __$LogsFilterStateCopyWithImpl<$Res>
    implements _$LogsFilterStateCopyWith<$Res> {
  __$LogsFilterStateCopyWithImpl(this._self, this._then);

  final _LogsFilterState _self;
  final $Res Function(_LogsFilterState) _then;

/// Create a copy of LogsFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = freezed,Object? levels = null,Object? module = freezed,Object? query = null,}) {
  return _then(_LogsFilterState(
source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LogSource?,levels: null == levels ? _self._levels : levels // ignore: cast_nullable_to_non_nullable
as Set<LogLevel>,module: freezed == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LogsState {

 List<Log> get logs; List<String> get keywords; String get query; bool get autoScrollToEnd;
/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogsStateCopyWith<LogsState> get copyWith => _$LogsStateCopyWithImpl<LogsState>(this as LogsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LogsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogsState&&const DeepCollectionEquality().equals(other.logs, _this.logs)&&const DeepCollectionEquality().equals(other.keywords, _this.keywords)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.autoScrollToEnd, _this.autoScrollToEnd) || other.autoScrollToEnd == _this.autoScrollToEnd));
}


@override
int get hashCode {
  final _this = this as LogsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.logs),const DeepCollectionEquality().hash(_this.keywords),_this.query,_this.autoScrollToEnd);
}

@override
String toString() {
  final _this = this as LogsState;
  return 'LogsState(logs: ${_this.logs}, keywords: ${_this.keywords}, query: ${_this.query}, autoScrollToEnd: ${_this.autoScrollToEnd})';
}


}

/// @nodoc
abstract mixin class $LogsStateCopyWith<$Res>  {
  factory $LogsStateCopyWith(LogsState value, $Res Function(LogsState) _then) = _$LogsStateCopyWithImpl;
@useResult
$Res call({
 List<Log> logs, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class _$LogsStateCopyWithImpl<$Res>
    implements $LogsStateCopyWith<$Res> {
  _$LogsStateCopyWithImpl(this._self, this._then);

  final LogsState _self;
  final $Res Function(LogsState) _then;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logs = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(LogsState(
logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<Log>,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LogsState].
extension LogsStatePatterns on LogsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogsState value)  $default,){
final _that = this;
switch (_that) {
case _LogsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogsState value)?  $default,){
final _that = this;
switch (_that) {
case _LogsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogsState() when $default != null:
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)  $default,) {final _that = this;
switch (_that) {
case _LogsState():
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,) {final _that = this;
switch (_that) {
case _LogsState() when $default != null:
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
  return null;

}
}

}

/// @nodoc


class _LogsState implements LogsState {
  const _LogsState({ List<Log> logs = const [],  List<String> keywords = const [], this.query = '', this.autoScrollToEnd = false}): _logs = logs,_keywords = keywords;
  

 final  List<Log> _logs;
@override@JsonKey() List<Log> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

 final  List<String> _keywords;
@override@JsonKey() List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  bool autoScrollToEnd;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogsStateCopyWith<_LogsState> get copyWith => __$LogsStateCopyWithImpl<_LogsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogsState&&const DeepCollectionEquality().equals(other.logs, _logs)&&const DeepCollectionEquality().equals(other.keywords, _keywords)&&(identical(other.query, query) || other.query == query)&&(identical(other.autoScrollToEnd, autoScrollToEnd) || other.autoScrollToEnd == autoScrollToEnd));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_logs),const DeepCollectionEquality().hash(_keywords),query,autoScrollToEnd);
}

@override
String toString() {
    return 'LogsState(logs: $logs, keywords: $keywords, query: $query, autoScrollToEnd: $autoScrollToEnd)';
}


}

/// @nodoc
abstract mixin class _$LogsStateCopyWith<$Res> implements $LogsStateCopyWith<$Res> {
  factory _$LogsStateCopyWith(_LogsState value, $Res Function(_LogsState) _then) = __$LogsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Log> logs, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class __$LogsStateCopyWithImpl<$Res>
    implements _$LogsStateCopyWith<$Res> {
  __$LogsStateCopyWithImpl(this._self, this._then);

  final _LogsState _self;
  final $Res Function(_LogsState) _then;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logs = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(_LogsState(
logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<Log>,keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$TrackerInfosState {

 List<TrackerInfo> get trackerInfos; List<String> get keywords; String get query; bool get autoScrollToEnd;
/// Create a copy of TrackerInfosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackerInfosStateCopyWith<TrackerInfosState> get copyWith => _$TrackerInfosStateCopyWithImpl<TrackerInfosState>(this as TrackerInfosState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrackerInfosState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackerInfosState&&const DeepCollectionEquality().equals(other.trackerInfos, _this.trackerInfos)&&const DeepCollectionEquality().equals(other.keywords, _this.keywords)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.autoScrollToEnd, _this.autoScrollToEnd) || other.autoScrollToEnd == _this.autoScrollToEnd));
}


@override
int get hashCode {
  final _this = this as TrackerInfosState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.trackerInfos),const DeepCollectionEquality().hash(_this.keywords),_this.query,_this.autoScrollToEnd);
}

@override
String toString() {
  final _this = this as TrackerInfosState;
  return 'TrackerInfosState(trackerInfos: ${_this.trackerInfos}, keywords: ${_this.keywords}, query: ${_this.query}, autoScrollToEnd: ${_this.autoScrollToEnd})';
}


}

/// @nodoc
abstract mixin class $TrackerInfosStateCopyWith<$Res>  {
  factory $TrackerInfosStateCopyWith(TrackerInfosState value, $Res Function(TrackerInfosState) _then) = _$TrackerInfosStateCopyWithImpl;
@useResult
$Res call({
 List<TrackerInfo> trackerInfos, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class _$TrackerInfosStateCopyWithImpl<$Res>
    implements $TrackerInfosStateCopyWith<$Res> {
  _$TrackerInfosStateCopyWithImpl(this._self, this._then);

  final TrackerInfosState _self;
  final $Res Function(TrackerInfosState) _then;

/// Create a copy of TrackerInfosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trackerInfos = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(TrackerInfosState(
trackerInfos: null == trackerInfos ? _self.trackerInfos : trackerInfos // ignore: cast_nullable_to_non_nullable
as List<TrackerInfo>,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackerInfosState].
extension TrackerInfosStatePatterns on TrackerInfosState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackerInfosState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackerInfosState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackerInfosState value)  $default,){
final _that = this;
switch (_that) {
case _TrackerInfosState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackerInfosState value)?  $default,){
final _that = this;
switch (_that) {
case _TrackerInfosState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TrackerInfo> trackerInfos,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackerInfosState() when $default != null:
return $default(_that.trackerInfos,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TrackerInfo> trackerInfos,  List<String> keywords,  String query,  bool autoScrollToEnd)  $default,) {final _that = this;
switch (_that) {
case _TrackerInfosState():
return $default(_that.trackerInfos,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TrackerInfo> trackerInfos,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,) {final _that = this;
switch (_that) {
case _TrackerInfosState() when $default != null:
return $default(_that.trackerInfos,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
  return null;

}
}

}

/// @nodoc


class _TrackerInfosState implements TrackerInfosState {
  const _TrackerInfosState({ List<TrackerInfo> trackerInfos = const [],  List<String> keywords = const [], this.query = '', this.autoScrollToEnd = false}): _trackerInfos = trackerInfos,_keywords = keywords;
  

 final  List<TrackerInfo> _trackerInfos;
@override@JsonKey() List<TrackerInfo> get trackerInfos {
  if (_trackerInfos is EqualUnmodifiableListView) return _trackerInfos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trackerInfos);
}

 final  List<String> _keywords;
@override@JsonKey() List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  bool autoScrollToEnd;

/// Create a copy of TrackerInfosState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackerInfosStateCopyWith<_TrackerInfosState> get copyWith => __$TrackerInfosStateCopyWithImpl<_TrackerInfosState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackerInfosState&&const DeepCollectionEquality().equals(other.trackerInfos, _trackerInfos)&&const DeepCollectionEquality().equals(other.keywords, _keywords)&&(identical(other.query, query) || other.query == query)&&(identical(other.autoScrollToEnd, autoScrollToEnd) || other.autoScrollToEnd == autoScrollToEnd));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_trackerInfos),const DeepCollectionEquality().hash(_keywords),query,autoScrollToEnd);
}

@override
String toString() {
    return 'TrackerInfosState(trackerInfos: $trackerInfos, keywords: $keywords, query: $query, autoScrollToEnd: $autoScrollToEnd)';
}


}

/// @nodoc
abstract mixin class _$TrackerInfosStateCopyWith<$Res> implements $TrackerInfosStateCopyWith<$Res> {
  factory _$TrackerInfosStateCopyWith(_TrackerInfosState value, $Res Function(_TrackerInfosState) _then) = __$TrackerInfosStateCopyWithImpl;
@override @useResult
$Res call({
 List<TrackerInfo> trackerInfos, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class __$TrackerInfosStateCopyWithImpl<$Res>
    implements _$TrackerInfosStateCopyWith<$Res> {
  __$TrackerInfosStateCopyWithImpl(this._self, this._then);

  final _TrackerInfosState _self;
  final $Res Function(_TrackerInfosState) _then;

/// Create a copy of TrackerInfosState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trackerInfos = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(_TrackerInfosState(
trackerInfos: null == trackerInfos ? _self._trackerInfos : trackerInfos // ignore: cast_nullable_to_non_nullable
as List<TrackerInfo>,keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DAV {

 String get uri; String get user; String get password; String get fileName; bool get autoBackup;
/// Create a copy of DAV
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DAVCopyWith<DAV> get copyWith => _$DAVCopyWithImpl<DAV>(this as DAV, _$identity);

  /// Serializes this DAV to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DAV;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DAV&&(identical(other.uri, _this.uri) || other.uri == _this.uri)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.autoBackup, _this.autoBackup) || other.autoBackup == _this.autoBackup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DAV;
  return Object.hash(runtimeType,_this.uri,_this.user,_this.password,_this.fileName,_this.autoBackup);
}

@override
String toString() {
  final _this = this as DAV;
  return 'DAV(uri: ${_this.uri}, user: ${_this.user}, password: ${_this.password}, fileName: ${_this.fileName}, autoBackup: ${_this.autoBackup})';
}


}

/// @nodoc
abstract mixin class $DAVCopyWith<$Res>  {
  factory $DAVCopyWith(DAV value, $Res Function(DAV) _then) = _$DAVCopyWithImpl;
@useResult
$Res call({
 String uri, String user, String password, String fileName, bool autoBackup
});




}
/// @nodoc
class _$DAVCopyWithImpl<$Res>
    implements $DAVCopyWith<$Res> {
  _$DAVCopyWithImpl(this._self, this._then);

  final DAV _self;
  final $Res Function(DAV) _then;

/// Create a copy of DAV
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? user = null,Object? password = null,Object? fileName = null,Object? autoBackup = null,}) {
  return _then(DAV(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,autoBackup: null == autoBackup ? _self.autoBackup : autoBackup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DAV].
extension DAVPatterns on DAV {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DAV value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DAV() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DAV value)  $default,){
final _that = this;
switch (_that) {
case _DAV():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DAV value)?  $default,){
final _that = this;
switch (_that) {
case _DAV() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String user,  String password,  String fileName,  bool autoBackup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DAV() when $default != null:
return $default(_that.uri,_that.user,_that.password,_that.fileName,_that.autoBackup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String user,  String password,  String fileName,  bool autoBackup)  $default,) {final _that = this;
switch (_that) {
case _DAV():
return $default(_that.uri,_that.user,_that.password,_that.fileName,_that.autoBackup);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String user,  String password,  String fileName,  bool autoBackup)?  $default,) {final _that = this;
switch (_that) {
case _DAV() when $default != null:
return $default(_that.uri,_that.user,_that.password,_that.fileName,_that.autoBackup);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DAV implements DAV {
  const _DAV({required this.uri, required this.user, required this.password, this.fileName = defaultDavFileName, this.autoBackup = false});
  factory _DAV.fromJson(Map<String, dynamic> json) => _$DAVFromJson(json);

@override final  String uri;
@override final  String user;
@override final  String password;
@override@JsonKey() final  String fileName;
@override@JsonKey() final  bool autoBackup;

/// Create a copy of DAV
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DAVCopyWith<_DAV> get copyWith => __$DAVCopyWithImpl<_DAV>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DAVToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DAV&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.user, user) || other.user == user)&&(identical(other.password, password) || other.password == password)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.autoBackup, autoBackup) || other.autoBackup == autoBackup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uri,user,password,fileName,autoBackup);
}

@override
String toString() {
    return 'DAV(uri: $uri, user: $user, password: $password, fileName: $fileName, autoBackup: $autoBackup)';
}


}

/// @nodoc
abstract mixin class _$DAVCopyWith<$Res> implements $DAVCopyWith<$Res> {
  factory _$DAVCopyWith(_DAV value, $Res Function(_DAV) _then) = __$DAVCopyWithImpl;
@override @useResult
$Res call({
 String uri, String user, String password, String fileName, bool autoBackup
});




}
/// @nodoc
class __$DAVCopyWithImpl<$Res>
    implements _$DAVCopyWith<$Res> {
  __$DAVCopyWithImpl(this._self, this._then);

  final _DAV _self;
  final $Res Function(_DAV) _then;

/// Create a copy of DAV
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? user = null,Object? password = null,Object? fileName = null,Object? autoBackup = null,}) {
  return _then(_DAV(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,autoBackup: null == autoBackup ? _self.autoBackup : autoBackup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$FileInfo {

 int get size; DateTime get lastModified;
/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileInfoCopyWith<FileInfo> get copyWith => _$FileInfoCopyWithImpl<FileInfo>(this as FileInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FileInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileInfo&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.lastModified, _this.lastModified) || other.lastModified == _this.lastModified));
}


@override
int get hashCode {
  final _this = this as FileInfo;
  return Object.hash(runtimeType,_this.size,_this.lastModified);
}

@override
String toString() {
  final _this = this as FileInfo;
  return 'FileInfo(size: ${_this.size}, lastModified: ${_this.lastModified})';
}


}

/// @nodoc
abstract mixin class $FileInfoCopyWith<$Res>  {
  factory $FileInfoCopyWith(FileInfo value, $Res Function(FileInfo) _then) = _$FileInfoCopyWithImpl;
@useResult
$Res call({
 int size, DateTime lastModified
});




}
/// @nodoc
class _$FileInfoCopyWithImpl<$Res>
    implements $FileInfoCopyWith<$Res> {
  _$FileInfoCopyWithImpl(this._self, this._then);

  final FileInfo _self;
  final $Res Function(FileInfo) _then;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? size = null,Object? lastModified = null,}) {
  return _then(FileInfo(
size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FileInfo].
extension FileInfoPatterns on FileInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileInfo value)  $default,){
final _that = this;
switch (_that) {
case _FileInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int size,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
return $default(_that.size,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int size,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _FileInfo():
return $default(_that.size,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int size,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
return $default(_that.size,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc


class _FileInfo implements FileInfo {
  const _FileInfo({required this.size, required this.lastModified});
  

@override final  int size;
@override final  DateTime lastModified;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileInfoCopyWith<_FileInfo> get copyWith => __$FileInfoCopyWithImpl<_FileInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileInfo&&(identical(other.size, size) || other.size == size)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}


@override
int get hashCode {
    return Object.hash(runtimeType,size,lastModified);
}

@override
String toString() {
    return 'FileInfo(size: $size, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$FileInfoCopyWith<$Res> implements $FileInfoCopyWith<$Res> {
  factory _$FileInfoCopyWith(_FileInfo value, $Res Function(_FileInfo) _then) = __$FileInfoCopyWithImpl;
@override @useResult
$Res call({
 int size, DateTime lastModified
});




}
/// @nodoc
class __$FileInfoCopyWithImpl<$Res>
    implements _$FileInfoCopyWith<$Res> {
  __$FileInfoCopyWithImpl(this._self, this._then);

  final _FileInfo _self;
  final $Res Function(_FileInfo) _then;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? size = null,Object? lastModified = null,}) {
  return _then(_FileInfo(
size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$NetworkInfo {

 String get type;@JsonKey(name: 'interface') String get interfaceName; String get ip; String get gateway; List<String> get dns;
/// Create a copy of NetworkInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkInfoCopyWith<NetworkInfo> get copyWith => _$NetworkInfoCopyWithImpl<NetworkInfo>(this as NetworkInfo, _$identity);

  /// Serializes this NetworkInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NetworkInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkInfo&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.interfaceName, _this.interfaceName) || other.interfaceName == _this.interfaceName)&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&(identical(other.gateway, _this.gateway) || other.gateway == _this.gateway)&&const DeepCollectionEquality().equals(other.dns, _this.dns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NetworkInfo;
  return Object.hash(runtimeType,_this.type,_this.interfaceName,_this.ip,_this.gateway,const DeepCollectionEquality().hash(_this.dns));
}

@override
String toString() {
  final _this = this as NetworkInfo;
  return 'NetworkInfo(type: ${_this.type}, interfaceName: ${_this.interfaceName}, ip: ${_this.ip}, gateway: ${_this.gateway}, dns: ${_this.dns})';
}


}

/// @nodoc
abstract mixin class $NetworkInfoCopyWith<$Res>  {
  factory $NetworkInfoCopyWith(NetworkInfo value, $Res Function(NetworkInfo) _then) = _$NetworkInfoCopyWithImpl;
@useResult
$Res call({
 String type,@JsonKey(name: 'interface') String interfaceName, String ip, String gateway, List<String> dns
});




}
/// @nodoc
class _$NetworkInfoCopyWithImpl<$Res>
    implements $NetworkInfoCopyWith<$Res> {
  _$NetworkInfoCopyWithImpl(this._self, this._then);

  final NetworkInfo _self;
  final $Res Function(NetworkInfo) _then;

/// Create a copy of NetworkInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? interfaceName = null,Object? ip = null,Object? gateway = null,Object? dns = null,}) {
  return _then(NetworkInfo(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,interfaceName: null == interfaceName ? _self.interfaceName : interfaceName // ignore: cast_nullable_to_non_nullable
as String,ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,gateway: null == gateway ? _self.gateway : gateway // ignore: cast_nullable_to_non_nullable
as String,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkInfo].
extension NetworkInfoPatterns on NetworkInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkInfo value)  $default,){
final _that = this;
switch (_that) {
case _NetworkInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkInfo value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type, @JsonKey(name: 'interface')  String interfaceName,  String ip,  String gateway,  List<String> dns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkInfo() when $default != null:
return $default(_that.type,_that.interfaceName,_that.ip,_that.gateway,_that.dns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type, @JsonKey(name: 'interface')  String interfaceName,  String ip,  String gateway,  List<String> dns)  $default,) {final _that = this;
switch (_that) {
case _NetworkInfo():
return $default(_that.type,_that.interfaceName,_that.ip,_that.gateway,_that.dns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type, @JsonKey(name: 'interface')  String interfaceName,  String ip,  String gateway,  List<String> dns)?  $default,) {final _that = this;
switch (_that) {
case _NetworkInfo() when $default != null:
return $default(_that.type,_that.interfaceName,_that.ip,_that.gateway,_that.dns);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetworkInfo implements NetworkInfo {
  const _NetworkInfo({this.type = '', @JsonKey(name: 'interface') this.interfaceName = '', this.ip = '', this.gateway = '',  List<String> dns = const []}): _dns = dns;
  factory _NetworkInfo.fromJson(Map<String, dynamic> json) => _$NetworkInfoFromJson(json);

@override@JsonKey() final  String type;
@override@JsonKey(name: 'interface') final  String interfaceName;
@override@JsonKey() final  String ip;
@override@JsonKey() final  String gateway;
 final  List<String> _dns;
@override@JsonKey() List<String> get dns {
  if (_dns is EqualUnmodifiableListView) return _dns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dns);
}


/// Create a copy of NetworkInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkInfoCopyWith<_NetworkInfo> get copyWith => __$NetworkInfoCopyWithImpl<_NetworkInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkInfo&&(identical(other.type, type) || other.type == type)&&(identical(other.interfaceName, interfaceName) || other.interfaceName == interfaceName)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.gateway, gateway) || other.gateway == gateway)&&const DeepCollectionEquality().equals(other.dns, _dns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,interfaceName,ip,gateway,const DeepCollectionEquality().hash(_dns));
}

@override
String toString() {
    return 'NetworkInfo(type: $type, interfaceName: $interfaceName, ip: $ip, gateway: $gateway, dns: $dns)';
}


}

/// @nodoc
abstract mixin class _$NetworkInfoCopyWith<$Res> implements $NetworkInfoCopyWith<$Res> {
  factory _$NetworkInfoCopyWith(_NetworkInfo value, $Res Function(_NetworkInfo) _then) = __$NetworkInfoCopyWithImpl;
@override @useResult
$Res call({
 String type,@JsonKey(name: 'interface') String interfaceName, String ip, String gateway, List<String> dns
});




}
/// @nodoc
class __$NetworkInfoCopyWithImpl<$Res>
    implements _$NetworkInfoCopyWith<$Res> {
  __$NetworkInfoCopyWithImpl(this._self, this._then);

  final _NetworkInfo _self;
  final $Res Function(_NetworkInfo) _then;

/// Create a copy of NetworkInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? interfaceName = null,Object? ip = null,Object? gateway = null,Object? dns = null,}) {
  return _then(_NetworkInfo(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,interfaceName: null == interfaceName ? _self.interfaceName : interfaceName // ignore: cast_nullable_to_non_nullable
as String,ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,gateway: null == gateway ? _self.gateway : gateway // ignore: cast_nullable_to_non_nullable
as String,dns: null == dns ? _self._dns : dns // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CoreInterface {

 String get name; List<String> get addresses;
/// Create a copy of CoreInterface
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreInterfaceCopyWith<CoreInterface> get copyWith => _$CoreInterfaceCopyWithImpl<CoreInterface>(this as CoreInterface, _$identity);

  /// Serializes this CoreInterface to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoreInterface;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreInterface&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.addresses, _this.addresses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoreInterface;
  return Object.hash(runtimeType,_this.name,const DeepCollectionEquality().hash(_this.addresses));
}

@override
String toString() {
  final _this = this as CoreInterface;
  return 'CoreInterface(name: ${_this.name}, addresses: ${_this.addresses})';
}


}

/// @nodoc
abstract mixin class $CoreInterfaceCopyWith<$Res>  {
  factory $CoreInterfaceCopyWith(CoreInterface value, $Res Function(CoreInterface) _then) = _$CoreInterfaceCopyWithImpl;
@useResult
$Res call({
 String name, List<String> addresses
});




}
/// @nodoc
class _$CoreInterfaceCopyWithImpl<$Res>
    implements $CoreInterfaceCopyWith<$Res> {
  _$CoreInterfaceCopyWithImpl(this._self, this._then);

  final CoreInterface _self;
  final $Res Function(CoreInterface) _then;

/// Create a copy of CoreInterface
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? addresses = null,}) {
  return _then(CoreInterface(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreInterface].
extension CoreInterfacePatterns on CoreInterface {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreInterface value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreInterface() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreInterface value)  $default,){
final _that = this;
switch (_that) {
case _CoreInterface():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreInterface value)?  $default,){
final _that = this;
switch (_that) {
case _CoreInterface() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<String> addresses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreInterface() when $default != null:
return $default(_that.name,_that.addresses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<String> addresses)  $default,) {final _that = this;
switch (_that) {
case _CoreInterface():
return $default(_that.name,_that.addresses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<String> addresses)?  $default,) {final _that = this;
switch (_that) {
case _CoreInterface() when $default != null:
return $default(_that.name,_that.addresses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreInterface implements CoreInterface {
  const _CoreInterface({required this.name,  List<String> addresses = const []}): _addresses = addresses;
  factory _CoreInterface.fromJson(Map<String, dynamic> json) => _$CoreInterfaceFromJson(json);

@override final  String name;
 final  List<String> _addresses;
@override@JsonKey() List<String> get addresses {
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addresses);
}


/// Create a copy of CoreInterface
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreInterfaceCopyWith<_CoreInterface> get copyWith => __$CoreInterfaceCopyWithImpl<_CoreInterface>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreInterfaceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreInterface&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.addresses, _addresses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_addresses));
}

@override
String toString() {
    return 'CoreInterface(name: $name, addresses: $addresses)';
}


}

/// @nodoc
abstract mixin class _$CoreInterfaceCopyWith<$Res> implements $CoreInterfaceCopyWith<$Res> {
  factory _$CoreInterfaceCopyWith(_CoreInterface value, $Res Function(_CoreInterface) _then) = __$CoreInterfaceCopyWithImpl;
@override @useResult
$Res call({
 String name, List<String> addresses
});




}
/// @nodoc
class __$CoreInterfaceCopyWithImpl<$Res>
    implements _$CoreInterfaceCopyWith<$Res> {
  __$CoreInterfaceCopyWithImpl(this._self, this._then);

  final _CoreInterface _self;
  final $Res Function(_CoreInterface) _then;

/// Create a copy of CoreInterface
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? addresses = null,}) {
  return _then(_CoreInterface(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$VersionInfo {

 String get clashName; String get version;
/// Create a copy of VersionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersionInfoCopyWith<VersionInfo> get copyWith => _$VersionInfoCopyWithImpl<VersionInfo>(this as VersionInfo, _$identity);

  /// Serializes this VersionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VersionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersionInfo&&(identical(other.clashName, _this.clashName) || other.clashName == _this.clashName)&&(identical(other.version, _this.version) || other.version == _this.version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VersionInfo;
  return Object.hash(runtimeType,_this.clashName,_this.version);
}

@override
String toString() {
  final _this = this as VersionInfo;
  return 'VersionInfo(clashName: ${_this.clashName}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $VersionInfoCopyWith<$Res>  {
  factory $VersionInfoCopyWith(VersionInfo value, $Res Function(VersionInfo) _then) = _$VersionInfoCopyWithImpl;
@useResult
$Res call({
 String clashName, String version
});




}
/// @nodoc
class _$VersionInfoCopyWithImpl<$Res>
    implements $VersionInfoCopyWith<$Res> {
  _$VersionInfoCopyWithImpl(this._self, this._then);

  final VersionInfo _self;
  final $Res Function(VersionInfo) _then;

/// Create a copy of VersionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clashName = null,Object? version = null,}) {
  return _then(VersionInfo(
clashName: null == clashName ? _self.clashName : clashName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VersionInfo].
extension VersionInfoPatterns on VersionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersionInfo value)  $default,){
final _that = this;
switch (_that) {
case _VersionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VersionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clashName,  String version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersionInfo() when $default != null:
return $default(_that.clashName,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clashName,  String version)  $default,) {final _that = this;
switch (_that) {
case _VersionInfo():
return $default(_that.clashName,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clashName,  String version)?  $default,) {final _that = this;
switch (_that) {
case _VersionInfo() when $default != null:
return $default(_that.clashName,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VersionInfo implements VersionInfo {
  const _VersionInfo({this.clashName = '', this.version = ''});
  factory _VersionInfo.fromJson(Map<String, dynamic> json) => _$VersionInfoFromJson(json);

@override@JsonKey() final  String clashName;
@override@JsonKey() final  String version;

/// Create a copy of VersionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersionInfoCopyWith<_VersionInfo> get copyWith => __$VersionInfoCopyWithImpl<_VersionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VersionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersionInfo&&(identical(other.clashName, clashName) || other.clashName == clashName)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,clashName,version);
}

@override
String toString() {
    return 'VersionInfo(clashName: $clashName, version: $version)';
}


}

/// @nodoc
abstract mixin class _$VersionInfoCopyWith<$Res> implements $VersionInfoCopyWith<$Res> {
  factory _$VersionInfoCopyWith(_VersionInfo value, $Res Function(_VersionInfo) _then) = __$VersionInfoCopyWithImpl;
@override @useResult
$Res call({
 String clashName, String version
});




}
/// @nodoc
class __$VersionInfoCopyWithImpl<$Res>
    implements _$VersionInfoCopyWith<$Res> {
  __$VersionInfoCopyWithImpl(this._self, this._then);

  final _VersionInfo _self;
  final $Res Function(_VersionInfo) _then;

/// Create a copy of VersionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clashName = null,Object? version = null,}) {
  return _then(_VersionInfo(
clashName: null == clashName ? _self.clashName : clashName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Proxy {

 String get name; String get type; String? get now;
/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyCopyWith<Proxy> get copyWith => _$ProxyCopyWithImpl<Proxy>(this as Proxy, _$identity);

  /// Serializes this Proxy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Proxy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Proxy&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.now, _this.now) || other.now == _this.now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Proxy;
  return Object.hash(runtimeType,_this.name,_this.type,_this.now);
}

@override
String toString() {
  final _this = this as Proxy;
  return 'Proxy(name: ${_this.name}, type: ${_this.type}, now: ${_this.now})';
}


}

/// @nodoc
abstract mixin class $ProxyCopyWith<$Res>  {
  factory $ProxyCopyWith(Proxy value, $Res Function(Proxy) _then) = _$ProxyCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? now
});




}
/// @nodoc
class _$ProxyCopyWithImpl<$Res>
    implements $ProxyCopyWith<$Res> {
  _$ProxyCopyWithImpl(this._self, this._then);

  final Proxy _self;
  final $Res Function(Proxy) _then;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? now = freezed,}) {
  return _then(Proxy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Proxy].
extension ProxyPatterns on Proxy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Proxy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Proxy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Proxy value)  $default,){
final _that = this;
switch (_that) {
case _Proxy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Proxy value)?  $default,){
final _that = this;
switch (_that) {
case _Proxy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? now)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that.name,_that.type,_that.now);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? now)  $default,) {final _that = this;
switch (_that) {
case _Proxy():
return $default(_that.name,_that.type,_that.now);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? now)?  $default,) {final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that.name,_that.type,_that.now);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Proxy implements Proxy {
  const _Proxy({required this.name, required this.type, this.now});
  factory _Proxy.fromJson(Map<String, dynamic> json) => _$ProxyFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? now;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyCopyWith<_Proxy> get copyWith => __$ProxyCopyWithImpl<_Proxy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Proxy&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.now, now) || other.now == now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type,now);
}

@override
String toString() {
    return 'Proxy(name: $name, type: $type, now: $now)';
}


}

/// @nodoc
abstract mixin class _$ProxyCopyWith<$Res> implements $ProxyCopyWith<$Res> {
  factory _$ProxyCopyWith(_Proxy value, $Res Function(_Proxy) _then) = __$ProxyCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? now
});




}
/// @nodoc
class __$ProxyCopyWithImpl<$Res>
    implements _$ProxyCopyWith<$Res> {
  __$ProxyCopyWithImpl(this._self, this._then);

  final _Proxy _self;
  final $Res Function(_Proxy) _then;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? now = freezed,}) {
  return _then(_Proxy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Group {

 GroupType get type; List<Proxy> get all; String? get now; bool? get hidden; String? get testUrl; String get icon; String get name;
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCopyWith<Group> get copyWith => _$GroupCopyWithImpl<Group>(this as Group, _$identity);

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Group;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Group&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.all, _this.all)&&(identical(other.now, _this.now) || other.now == _this.now)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.testUrl, _this.testUrl) || other.testUrl == _this.testUrl)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Group;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.all),_this.now,_this.hidden,_this.testUrl,_this.icon,_this.name);
}

@override
String toString() {
  final _this = this as Group;
  return 'Group(type: ${_this.type}, all: ${_this.all}, now: ${_this.now}, hidden: ${_this.hidden}, testUrl: ${_this.testUrl}, icon: ${_this.icon}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res>  {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) = _$GroupCopyWithImpl;
@useResult
$Res call({
 GroupType type, List<Proxy> all, String? now, bool? hidden, String? testUrl, String icon, String name
});




}
/// @nodoc
class _$GroupCopyWithImpl<$Res>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? all = null,Object? now = freezed,Object? hidden = freezed,Object? testUrl = freezed,Object? icon = null,Object? name = null,}) {
  return _then(Group(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as List<Proxy>,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Group value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Group value)  $default,){
final _that = this;
switch (_that) {
case _Group():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Group value)?  $default,){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)  $default,) {final _that = this;
switch (_that) {
case _Group():
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Group implements Group {
  const _Group({required this.type,  List<Proxy> all = const [], this.now, this.hidden, this.testUrl, this.icon = '', required this.name}): _all = all;
  factory _Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

@override final  GroupType type;
 final  List<Proxy> _all;
@override@JsonKey() List<Proxy> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}

@override final  String? now;
@override final  bool? hidden;
@override final  String? testUrl;
@override@JsonKey() final  String icon;
@override final  String name;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCopyWith<_Group> get copyWith => __$GroupCopyWithImpl<_Group>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Group&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.all, _all)&&(identical(other.now, now) || other.now == now)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_all),now,hidden,testUrl,icon,name);
}

@override
String toString() {
    return 'Group(type: $type, all: $all, now: $now, hidden: $hidden, testUrl: $testUrl, icon: $icon, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) = __$GroupCopyWithImpl;
@override @useResult
$Res call({
 GroupType type, List<Proxy> all, String? now, bool? hidden, String? testUrl, String icon, String name
});




}
/// @nodoc
class __$GroupCopyWithImpl<$Res>
    implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? all = null,Object? now = freezed,Object? hidden = freezed,Object? testUrl = freezed,Object? icon = null,Object? name = null,}) {
  return _then(_Group(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<Proxy>,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ColorSchemes {

 ColorScheme? get lightColorScheme; ColorScheme? get darkColorScheme;
/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorSchemesCopyWith<ColorSchemes> get copyWith => _$ColorSchemesCopyWithImpl<ColorSchemes>(this as ColorSchemes, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ColorSchemes;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorSchemes&&(identical(other.lightColorScheme, _this.lightColorScheme) || other.lightColorScheme == _this.lightColorScheme)&&(identical(other.darkColorScheme, _this.darkColorScheme) || other.darkColorScheme == _this.darkColorScheme));
}


@override
int get hashCode {
  final _this = this as ColorSchemes;
  return Object.hash(runtimeType,_this.lightColorScheme,_this.darkColorScheme);
}

@override
String toString() {
  final _this = this as ColorSchemes;
  return 'ColorSchemes(lightColorScheme: ${_this.lightColorScheme}, darkColorScheme: ${_this.darkColorScheme})';
}


}

/// @nodoc
abstract mixin class $ColorSchemesCopyWith<$Res>  {
  factory $ColorSchemesCopyWith(ColorSchemes value, $Res Function(ColorSchemes) _then) = _$ColorSchemesCopyWithImpl;
@useResult
$Res call({
 ColorScheme? lightColorScheme, ColorScheme? darkColorScheme
});




}
/// @nodoc
class _$ColorSchemesCopyWithImpl<$Res>
    implements $ColorSchemesCopyWith<$Res> {
  _$ColorSchemesCopyWithImpl(this._self, this._then);

  final ColorSchemes _self;
  final $Res Function(ColorSchemes) _then;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lightColorScheme = freezed,Object? darkColorScheme = freezed,}) {
  return _then(ColorSchemes(
lightColorScheme: freezed == lightColorScheme ? _self.lightColorScheme : lightColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,darkColorScheme: freezed == darkColorScheme ? _self.darkColorScheme : darkColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,
  ));
}

}


/// Adds pattern-matching-related methods to [ColorSchemes].
extension ColorSchemesPatterns on ColorSchemes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColorSchemes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColorSchemes value)  $default,){
final _that = this;
switch (_that) {
case _ColorSchemes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColorSchemes value)?  $default,){
final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)  $default,) {final _that = this;
switch (_that) {
case _ColorSchemes():
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)?  $default,) {final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
  return null;

}
}

}

/// @nodoc


class _ColorSchemes implements ColorSchemes {
  const _ColorSchemes({this.lightColorScheme, this.darkColorScheme});
  

@override final  ColorScheme? lightColorScheme;
@override final  ColorScheme? darkColorScheme;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColorSchemesCopyWith<_ColorSchemes> get copyWith => __$ColorSchemesCopyWithImpl<_ColorSchemes>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColorSchemes&&(identical(other.lightColorScheme, lightColorScheme) || other.lightColorScheme == lightColorScheme)&&(identical(other.darkColorScheme, darkColorScheme) || other.darkColorScheme == darkColorScheme));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lightColorScheme,darkColorScheme);
}

@override
String toString() {
    return 'ColorSchemes(lightColorScheme: $lightColorScheme, darkColorScheme: $darkColorScheme)';
}


}

/// @nodoc
abstract mixin class _$ColorSchemesCopyWith<$Res> implements $ColorSchemesCopyWith<$Res> {
  factory _$ColorSchemesCopyWith(_ColorSchemes value, $Res Function(_ColorSchemes) _then) = __$ColorSchemesCopyWithImpl;
@override @useResult
$Res call({
 ColorScheme? lightColorScheme, ColorScheme? darkColorScheme
});




}
/// @nodoc
class __$ColorSchemesCopyWithImpl<$Res>
    implements _$ColorSchemesCopyWith<$Res> {
  __$ColorSchemesCopyWithImpl(this._self, this._then);

  final _ColorSchemes _self;
  final $Res Function(_ColorSchemes) _then;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lightColorScheme = freezed,Object? darkColorScheme = freezed,}) {
  return _then(_ColorSchemes(
lightColorScheme: freezed == lightColorScheme ? _self.lightColorScheme : lightColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,darkColorScheme: freezed == darkColorScheme ? _self.darkColorScheme : darkColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,
  ));
}


}


/// @nodoc
mixin _$IpRiskCheck {

 IpRiskGroup get group; String get name; bool? get hit;
/// Create a copy of IpRiskCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpRiskCheckCopyWith<IpRiskCheck> get copyWith => _$IpRiskCheckCopyWithImpl<IpRiskCheck>(this as IpRiskCheck, _$identity);

  /// Serializes this IpRiskCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IpRiskCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpRiskCheck&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.hit, _this.hit) || other.hit == _this.hit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IpRiskCheck;
  return Object.hash(runtimeType,_this.group,_this.name,_this.hit);
}

@override
String toString() {
  final _this = this as IpRiskCheck;
  return 'IpRiskCheck(group: ${_this.group}, name: ${_this.name}, hit: ${_this.hit})';
}


}

/// @nodoc
abstract mixin class $IpRiskCheckCopyWith<$Res>  {
  factory $IpRiskCheckCopyWith(IpRiskCheck value, $Res Function(IpRiskCheck) _then) = _$IpRiskCheckCopyWithImpl;
@useResult
$Res call({
 IpRiskGroup group, String name, bool? hit
});




}
/// @nodoc
class _$IpRiskCheckCopyWithImpl<$Res>
    implements $IpRiskCheckCopyWith<$Res> {
  _$IpRiskCheckCopyWithImpl(this._self, this._then);

  final IpRiskCheck _self;
  final $Res Function(IpRiskCheck) _then;

/// Create a copy of IpRiskCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? group = null,Object? name = null,Object? hit = freezed,}) {
  return _then(IpRiskCheck(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as IpRiskGroup,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hit: freezed == hit ? _self.hit : hit // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [IpRiskCheck].
extension IpRiskCheckPatterns on IpRiskCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpRiskCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpRiskCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpRiskCheck value)  $default,){
final _that = this;
switch (_that) {
case _IpRiskCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpRiskCheck value)?  $default,){
final _that = this;
switch (_that) {
case _IpRiskCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IpRiskGroup group,  String name,  bool? hit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpRiskCheck() when $default != null:
return $default(_that.group,_that.name,_that.hit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IpRiskGroup group,  String name,  bool? hit)  $default,) {final _that = this;
switch (_that) {
case _IpRiskCheck():
return $default(_that.group,_that.name,_that.hit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IpRiskGroup group,  String name,  bool? hit)?  $default,) {final _that = this;
switch (_that) {
case _IpRiskCheck() when $default != null:
return $default(_that.group,_that.name,_that.hit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpRiskCheck implements IpRiskCheck {
  const _IpRiskCheck({required this.group, required this.name, this.hit});
  factory _IpRiskCheck.fromJson(Map<String, dynamic> json) => _$IpRiskCheckFromJson(json);

@override final  IpRiskGroup group;
@override final  String name;
@override final  bool? hit;

/// Create a copy of IpRiskCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpRiskCheckCopyWith<_IpRiskCheck> get copyWith => __$IpRiskCheckCopyWithImpl<_IpRiskCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpRiskCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpRiskCheck&&(identical(other.group, group) || other.group == group)&&(identical(other.name, name) || other.name == name)&&(identical(other.hit, hit) || other.hit == hit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,group,name,hit);
}

@override
String toString() {
    return 'IpRiskCheck(group: $group, name: $name, hit: $hit)';
}


}

/// @nodoc
abstract mixin class _$IpRiskCheckCopyWith<$Res> implements $IpRiskCheckCopyWith<$Res> {
  factory _$IpRiskCheckCopyWith(_IpRiskCheck value, $Res Function(_IpRiskCheck) _then) = __$IpRiskCheckCopyWithImpl;
@override @useResult
$Res call({
 IpRiskGroup group, String name, bool? hit
});




}
/// @nodoc
class __$IpRiskCheckCopyWithImpl<$Res>
    implements _$IpRiskCheckCopyWith<$Res> {
  __$IpRiskCheckCopyWithImpl(this._self, this._then);

  final _IpRiskCheck _self;
  final $Res Function(_IpRiskCheck) _then;

/// Create a copy of IpRiskCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? group = null,Object? name = null,Object? hit = freezed,}) {
  return _then(_IpRiskCheck(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as IpRiskGroup,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hit: freezed == hit ? _self.hit : hit // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$IpRiskNote {

 bool? get direct; String get isp; IpRiskAmount? get amount; IpRiskShare? get share; String get operatorName; IpRiskLevel? get operatorLevel; String get ownerName; IpRiskLevel? get ownerLevel; IpRiskConnection? get connection; IpRiskLevel? get warning;
/// Create a copy of IpRiskNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpRiskNoteCopyWith<IpRiskNote> get copyWith => _$IpRiskNoteCopyWithImpl<IpRiskNote>(this as IpRiskNote, _$identity);

  /// Serializes this IpRiskNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IpRiskNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpRiskNote&&(identical(other.direct, _this.direct) || other.direct == _this.direct)&&(identical(other.isp, _this.isp) || other.isp == _this.isp)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.share, _this.share) || other.share == _this.share)&&(identical(other.operatorName, _this.operatorName) || other.operatorName == _this.operatorName)&&(identical(other.operatorLevel, _this.operatorLevel) || other.operatorLevel == _this.operatorLevel)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName)&&(identical(other.ownerLevel, _this.ownerLevel) || other.ownerLevel == _this.ownerLevel)&&(identical(other.connection, _this.connection) || other.connection == _this.connection)&&(identical(other.warning, _this.warning) || other.warning == _this.warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IpRiskNote;
  return Object.hash(runtimeType,_this.direct,_this.isp,_this.amount,_this.share,_this.operatorName,_this.operatorLevel,_this.ownerName,_this.ownerLevel,_this.connection,_this.warning);
}

@override
String toString() {
  final _this = this as IpRiskNote;
  return 'IpRiskNote(direct: ${_this.direct}, isp: ${_this.isp}, amount: ${_this.amount}, share: ${_this.share}, operatorName: ${_this.operatorName}, operatorLevel: ${_this.operatorLevel}, ownerName: ${_this.ownerName}, ownerLevel: ${_this.ownerLevel}, connection: ${_this.connection}, warning: ${_this.warning})';
}


}

/// @nodoc
abstract mixin class $IpRiskNoteCopyWith<$Res>  {
  factory $IpRiskNoteCopyWith(IpRiskNote value, $Res Function(IpRiskNote) _then) = _$IpRiskNoteCopyWithImpl;
@useResult
$Res call({
 bool? direct, String isp, IpRiskAmount? amount, IpRiskShare? share, String operatorName, IpRiskLevel? operatorLevel, String ownerName, IpRiskLevel? ownerLevel, IpRiskConnection? connection, IpRiskLevel? warning
});




}
/// @nodoc
class _$IpRiskNoteCopyWithImpl<$Res>
    implements $IpRiskNoteCopyWith<$Res> {
  _$IpRiskNoteCopyWithImpl(this._self, this._then);

  final IpRiskNote _self;
  final $Res Function(IpRiskNote) _then;

/// Create a copy of IpRiskNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? direct = freezed,Object? isp = null,Object? amount = freezed,Object? share = freezed,Object? operatorName = null,Object? operatorLevel = freezed,Object? ownerName = null,Object? ownerLevel = freezed,Object? connection = freezed,Object? warning = freezed,}) {
  return _then(IpRiskNote(
direct: freezed == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as bool?,isp: null == isp ? _self.isp : isp // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as IpRiskAmount?,share: freezed == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as IpRiskShare?,operatorName: null == operatorName ? _self.operatorName : operatorName // ignore: cast_nullable_to_non_nullable
as String,operatorLevel: freezed == operatorLevel ? _self.operatorLevel : operatorLevel // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,ownerLevel: freezed == ownerLevel ? _self.ownerLevel : ownerLevel // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as IpRiskConnection?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,
  ));
}

}


/// Adds pattern-matching-related methods to [IpRiskNote].
extension IpRiskNotePatterns on IpRiskNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpRiskNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpRiskNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpRiskNote value)  $default,){
final _that = this;
switch (_that) {
case _IpRiskNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpRiskNote value)?  $default,){
final _that = this;
switch (_that) {
case _IpRiskNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? direct,  String isp,  IpRiskAmount? amount,  IpRiskShare? share,  String operatorName,  IpRiskLevel? operatorLevel,  String ownerName,  IpRiskLevel? ownerLevel,  IpRiskConnection? connection,  IpRiskLevel? warning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpRiskNote() when $default != null:
return $default(_that.direct,_that.isp,_that.amount,_that.share,_that.operatorName,_that.operatorLevel,_that.ownerName,_that.ownerLevel,_that.connection,_that.warning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? direct,  String isp,  IpRiskAmount? amount,  IpRiskShare? share,  String operatorName,  IpRiskLevel? operatorLevel,  String ownerName,  IpRiskLevel? ownerLevel,  IpRiskConnection? connection,  IpRiskLevel? warning)  $default,) {final _that = this;
switch (_that) {
case _IpRiskNote():
return $default(_that.direct,_that.isp,_that.amount,_that.share,_that.operatorName,_that.operatorLevel,_that.ownerName,_that.ownerLevel,_that.connection,_that.warning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? direct,  String isp,  IpRiskAmount? amount,  IpRiskShare? share,  String operatorName,  IpRiskLevel? operatorLevel,  String ownerName,  IpRiskLevel? ownerLevel,  IpRiskConnection? connection,  IpRiskLevel? warning)?  $default,) {final _that = this;
switch (_that) {
case _IpRiskNote() when $default != null:
return $default(_that.direct,_that.isp,_that.amount,_that.share,_that.operatorName,_that.operatorLevel,_that.ownerName,_that.ownerLevel,_that.connection,_that.warning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpRiskNote implements IpRiskNote {
  const _IpRiskNote({this.direct, this.isp = '', this.amount, this.share, this.operatorName = '', this.operatorLevel, this.ownerName = '', this.ownerLevel, this.connection, this.warning});
  factory _IpRiskNote.fromJson(Map<String, dynamic> json) => _$IpRiskNoteFromJson(json);

@override final  bool? direct;
@override@JsonKey() final  String isp;
@override final  IpRiskAmount? amount;
@override final  IpRiskShare? share;
@override@JsonKey() final  String operatorName;
@override final  IpRiskLevel? operatorLevel;
@override@JsonKey() final  String ownerName;
@override final  IpRiskLevel? ownerLevel;
@override final  IpRiskConnection? connection;
@override final  IpRiskLevel? warning;

/// Create a copy of IpRiskNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpRiskNoteCopyWith<_IpRiskNote> get copyWith => __$IpRiskNoteCopyWithImpl<_IpRiskNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpRiskNoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpRiskNote&&(identical(other.direct, direct) || other.direct == direct)&&(identical(other.isp, isp) || other.isp == isp)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.share, share) || other.share == share)&&(identical(other.operatorName, operatorName) || other.operatorName == operatorName)&&(identical(other.operatorLevel, operatorLevel) || other.operatorLevel == operatorLevel)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.ownerLevel, ownerLevel) || other.ownerLevel == ownerLevel)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.warning, warning) || other.warning == warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,direct,isp,amount,share,operatorName,operatorLevel,ownerName,ownerLevel,connection,warning);
}

@override
String toString() {
    return 'IpRiskNote(direct: $direct, isp: $isp, amount: $amount, share: $share, operatorName: $operatorName, operatorLevel: $operatorLevel, ownerName: $ownerName, ownerLevel: $ownerLevel, connection: $connection, warning: $warning)';
}


}

/// @nodoc
abstract mixin class _$IpRiskNoteCopyWith<$Res> implements $IpRiskNoteCopyWith<$Res> {
  factory _$IpRiskNoteCopyWith(_IpRiskNote value, $Res Function(_IpRiskNote) _then) = __$IpRiskNoteCopyWithImpl;
@override @useResult
$Res call({
 bool? direct, String isp, IpRiskAmount? amount, IpRiskShare? share, String operatorName, IpRiskLevel? operatorLevel, String ownerName, IpRiskLevel? ownerLevel, IpRiskConnection? connection, IpRiskLevel? warning
});




}
/// @nodoc
class __$IpRiskNoteCopyWithImpl<$Res>
    implements _$IpRiskNoteCopyWith<$Res> {
  __$IpRiskNoteCopyWithImpl(this._self, this._then);

  final _IpRiskNote _self;
  final $Res Function(_IpRiskNote) _then;

/// Create a copy of IpRiskNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? direct = freezed,Object? isp = null,Object? amount = freezed,Object? share = freezed,Object? operatorName = null,Object? operatorLevel = freezed,Object? ownerName = null,Object? ownerLevel = freezed,Object? connection = freezed,Object? warning = freezed,}) {
  return _then(_IpRiskNote(
direct: freezed == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as bool?,isp: null == isp ? _self.isp : isp // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as IpRiskAmount?,share: freezed == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as IpRiskShare?,operatorName: null == operatorName ? _self.operatorName : operatorName // ignore: cast_nullable_to_non_nullable
as String,operatorLevel: freezed == operatorLevel ? _self.operatorLevel : operatorLevel // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,ownerLevel: freezed == ownerLevel ? _self.ownerLevel : ownerLevel // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as IpRiskConnection?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,
  ));
}


}


/// @nodoc
mixin _$IpRisk {

 String get ip; int get score; IpRiskLevel get level; String get hostname; String get asn; String get isp; String get organization; String get country; String get countryCode; String get region; String get city; List<IpRiskCheck> get checks; IpRiskNote? get note;
/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpRiskCopyWith<IpRisk> get copyWith => _$IpRiskCopyWithImpl<IpRisk>(this as IpRisk, _$identity);

  /// Serializes this IpRisk to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IpRisk;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpRisk&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.hostname, _this.hostname) || other.hostname == _this.hostname)&&(identical(other.asn, _this.asn) || other.asn == _this.asn)&&(identical(other.isp, _this.isp) || other.isp == _this.isp)&&(identical(other.organization, _this.organization) || other.organization == _this.organization)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.countryCode, _this.countryCode) || other.countryCode == _this.countryCode)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.city, _this.city) || other.city == _this.city)&&const DeepCollectionEquality().equals(other.checks, _this.checks)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IpRisk;
  return Object.hash(runtimeType,_this.ip,_this.score,_this.level,_this.hostname,_this.asn,_this.isp,_this.organization,_this.country,_this.countryCode,_this.region,_this.city,const DeepCollectionEquality().hash(_this.checks),_this.note);
}

@override
String toString() {
  final _this = this as IpRisk;
  return 'IpRisk(ip: ${_this.ip}, score: ${_this.score}, level: ${_this.level}, hostname: ${_this.hostname}, asn: ${_this.asn}, isp: ${_this.isp}, organization: ${_this.organization}, country: ${_this.country}, countryCode: ${_this.countryCode}, region: ${_this.region}, city: ${_this.city}, checks: ${_this.checks}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $IpRiskCopyWith<$Res>  {
  factory $IpRiskCopyWith(IpRisk value, $Res Function(IpRisk) _then) = _$IpRiskCopyWithImpl;
@useResult
$Res call({
 String ip, int score, IpRiskLevel level, String hostname, String asn, String isp, String organization, String country, String countryCode, String region, String city, List<IpRiskCheck> checks, IpRiskNote? note
});


$IpRiskNoteCopyWith<$Res>? get note;

}
/// @nodoc
class _$IpRiskCopyWithImpl<$Res>
    implements $IpRiskCopyWith<$Res> {
  _$IpRiskCopyWithImpl(this._self, this._then);

  final IpRisk _self;
  final $Res Function(IpRisk) _then;

/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? score = null,Object? level = null,Object? hostname = null,Object? asn = null,Object? isp = null,Object? organization = null,Object? country = null,Object? countryCode = null,Object? region = null,Object? city = null,Object? checks = null,Object? note = freezed,}) {
  return _then(IpRisk(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as IpRiskLevel,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,asn: null == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as String,isp: null == isp ? _self.isp : isp // ignore: cast_nullable_to_non_nullable
as String,organization: null == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as List<IpRiskCheck>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as IpRiskNote?,
  ));
}
/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IpRiskNoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $IpRiskNoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}


/// Adds pattern-matching-related methods to [IpRisk].
extension IpRiskPatterns on IpRisk {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpRisk value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpRisk() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpRisk value)  $default,){
final _that = this;
switch (_that) {
case _IpRisk():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpRisk value)?  $default,){
final _that = this;
switch (_that) {
case _IpRisk() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  int score,  IpRiskLevel level,  String hostname,  String asn,  String isp,  String organization,  String country,  String countryCode,  String region,  String city,  List<IpRiskCheck> checks,  IpRiskNote? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpRisk() when $default != null:
return $default(_that.ip,_that.score,_that.level,_that.hostname,_that.asn,_that.isp,_that.organization,_that.country,_that.countryCode,_that.region,_that.city,_that.checks,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  int score,  IpRiskLevel level,  String hostname,  String asn,  String isp,  String organization,  String country,  String countryCode,  String region,  String city,  List<IpRiskCheck> checks,  IpRiskNote? note)  $default,) {final _that = this;
switch (_that) {
case _IpRisk():
return $default(_that.ip,_that.score,_that.level,_that.hostname,_that.asn,_that.isp,_that.organization,_that.country,_that.countryCode,_that.region,_that.city,_that.checks,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  int score,  IpRiskLevel level,  String hostname,  String asn,  String isp,  String organization,  String country,  String countryCode,  String region,  String city,  List<IpRiskCheck> checks,  IpRiskNote? note)?  $default,) {final _that = this;
switch (_that) {
case _IpRisk() when $default != null:
return $default(_that.ip,_that.score,_that.level,_that.hostname,_that.asn,_that.isp,_that.organization,_that.country,_that.countryCode,_that.region,_that.city,_that.checks,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpRisk implements IpRisk {
  const _IpRisk({required this.ip, required this.score, required this.level, this.hostname = '', this.asn = '', this.isp = '', this.organization = '', this.country = '', this.countryCode = '', this.region = '', this.city = '',  List<IpRiskCheck> checks = const [], this.note}): _checks = checks;
  factory _IpRisk.fromJson(Map<String, dynamic> json) => _$IpRiskFromJson(json);

@override final  String ip;
@override final  int score;
@override final  IpRiskLevel level;
@override@JsonKey() final  String hostname;
@override@JsonKey() final  String asn;
@override@JsonKey() final  String isp;
@override@JsonKey() final  String organization;
@override@JsonKey() final  String country;
@override@JsonKey() final  String countryCode;
@override@JsonKey() final  String region;
@override@JsonKey() final  String city;
 final  List<IpRiskCheck> _checks;
@override@JsonKey() List<IpRiskCheck> get checks {
  if (_checks is EqualUnmodifiableListView) return _checks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checks);
}

@override final  IpRiskNote? note;

/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpRiskCopyWith<_IpRisk> get copyWith => __$IpRiskCopyWithImpl<_IpRisk>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpRiskToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpRisk&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.score, score) || other.score == score)&&(identical(other.level, level) || other.level == level)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.asn, asn) || other.asn == asn)&&(identical(other.isp, isp) || other.isp == isp)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.country, country) || other.country == country)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.region, region) || other.region == region)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.checks, _checks)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ip,score,level,hostname,asn,isp,organization,country,countryCode,region,city,const DeepCollectionEquality().hash(_checks),note);
}

@override
String toString() {
    return 'IpRisk(ip: $ip, score: $score, level: $level, hostname: $hostname, asn: $asn, isp: $isp, organization: $organization, country: $country, countryCode: $countryCode, region: $region, city: $city, checks: $checks, note: $note)';
}


}

/// @nodoc
abstract mixin class _$IpRiskCopyWith<$Res> implements $IpRiskCopyWith<$Res> {
  factory _$IpRiskCopyWith(_IpRisk value, $Res Function(_IpRisk) _then) = __$IpRiskCopyWithImpl;
@override @useResult
$Res call({
 String ip, int score, IpRiskLevel level, String hostname, String asn, String isp, String organization, String country, String countryCode, String region, String city, List<IpRiskCheck> checks, IpRiskNote? note
});


@override $IpRiskNoteCopyWith<$Res>? get note;

}
/// @nodoc
class __$IpRiskCopyWithImpl<$Res>
    implements _$IpRiskCopyWith<$Res> {
  __$IpRiskCopyWithImpl(this._self, this._then);

  final _IpRisk _self;
  final $Res Function(_IpRisk) _then;

/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? score = null,Object? level = null,Object? hostname = null,Object? asn = null,Object? isp = null,Object? organization = null,Object? country = null,Object? countryCode = null,Object? region = null,Object? city = null,Object? checks = null,Object? note = freezed,}) {
  return _then(_IpRisk(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as IpRiskLevel,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,asn: null == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as String,isp: null == isp ? _self.isp : isp // ignore: cast_nullable_to_non_nullable
as String,organization: null == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self._checks : checks // ignore: cast_nullable_to_non_nullable
as List<IpRiskCheck>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as IpRiskNote?,
  ));
}

/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IpRiskNoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $IpRiskNoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}


/// @nodoc
mixin _$HotKeyAction {

 HotAction get action; int? get key; Set<KeyboardModifier> get modifiers;
/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotKeyActionCopyWith<HotKeyAction> get copyWith => _$HotKeyActionCopyWithImpl<HotKeyAction>(this as HotKeyAction, _$identity);

  /// Serializes this HotKeyAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HotKeyAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotKeyAction&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.key, _this.key) || other.key == _this.key)&&const DeepCollectionEquality().equals(other.modifiers, _this.modifiers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HotKeyAction;
  return Object.hash(runtimeType,_this.action,_this.key,const DeepCollectionEquality().hash(_this.modifiers));
}

@override
String toString() {
  final _this = this as HotKeyAction;
  return 'HotKeyAction(action: ${_this.action}, key: ${_this.key}, modifiers: ${_this.modifiers})';
}


}

/// @nodoc
abstract mixin class $HotKeyActionCopyWith<$Res>  {
  factory $HotKeyActionCopyWith(HotKeyAction value, $Res Function(HotKeyAction) _then) = _$HotKeyActionCopyWithImpl;
@useResult
$Res call({
 HotAction action, int? key, Set<KeyboardModifier> modifiers
});




}
/// @nodoc
class _$HotKeyActionCopyWithImpl<$Res>
    implements $HotKeyActionCopyWith<$Res> {
  _$HotKeyActionCopyWithImpl(this._self, this._then);

  final HotKeyAction _self;
  final $Res Function(HotKeyAction) _then;

/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? key = freezed,Object? modifiers = null,}) {
  return _then(HotKeyAction(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as HotAction,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as int?,modifiers: null == modifiers ? _self.modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as Set<KeyboardModifier>,
  ));
}

}


/// Adds pattern-matching-related methods to [HotKeyAction].
extension HotKeyActionPatterns on HotKeyAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotKeyAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotKeyAction value)  $default,){
final _that = this;
switch (_that) {
case _HotKeyAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotKeyAction value)?  $default,){
final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
return $default(_that.action,_that.key,_that.modifiers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)  $default,) {final _that = this;
switch (_that) {
case _HotKeyAction():
return $default(_that.action,_that.key,_that.modifiers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)?  $default,) {final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
return $default(_that.action,_that.key,_that.modifiers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HotKeyAction implements HotKeyAction {
  const _HotKeyAction({required this.action, this.key,  Set<KeyboardModifier> modifiers = const {}}): _modifiers = modifiers;
  factory _HotKeyAction.fromJson(Map<String, dynamic> json) => _$HotKeyActionFromJson(json);

@override final  HotAction action;
@override final  int? key;
 final  Set<KeyboardModifier> _modifiers;
@override@JsonKey() Set<KeyboardModifier> get modifiers {
  if (_modifiers is EqualUnmodifiableSetView) return _modifiers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_modifiers);
}


/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotKeyActionCopyWith<_HotKeyAction> get copyWith => __$HotKeyActionCopyWithImpl<_HotKeyAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HotKeyActionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotKeyAction&&(identical(other.action, action) || other.action == action)&&(identical(other.key, key) || other.key == key)&&const DeepCollectionEquality().equals(other.modifiers, _modifiers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,action,key,const DeepCollectionEquality().hash(_modifiers));
}

@override
String toString() {
    return 'HotKeyAction(action: $action, key: $key, modifiers: $modifiers)';
}


}

/// @nodoc
abstract mixin class _$HotKeyActionCopyWith<$Res> implements $HotKeyActionCopyWith<$Res> {
  factory _$HotKeyActionCopyWith(_HotKeyAction value, $Res Function(_HotKeyAction) _then) = __$HotKeyActionCopyWithImpl;
@override @useResult
$Res call({
 HotAction action, int? key, Set<KeyboardModifier> modifiers
});




}
/// @nodoc
class __$HotKeyActionCopyWithImpl<$Res>
    implements _$HotKeyActionCopyWith<$Res> {
  __$HotKeyActionCopyWithImpl(this._self, this._then);

  final _HotKeyAction _self;
  final $Res Function(_HotKeyAction) _then;

/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? key = freezed,Object? modifiers = null,}) {
  return _then(_HotKeyAction(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as HotAction,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as int?,modifiers: null == modifiers ? _self._modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as Set<KeyboardModifier>,
  ));
}


}

/// @nodoc
mixin _$Field {

 String get label; String get value; Validator? get validator;
/// Create a copy of Field
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldCopyWith<Field> get copyWith => _$FieldCopyWithImpl<Field>(this as Field, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Field;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Field&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.validator, _this.validator) || other.validator == _this.validator));
}


@override
int get hashCode {
  final _this = this as Field;
  return Object.hash(runtimeType,_this.label,_this.value,_this.validator);
}

@override
String toString() {
  final _this = this as Field;
  return 'Field(label: ${_this.label}, value: ${_this.value}, validator: ${_this.validator})';
}


}

/// @nodoc
abstract mixin class $FieldCopyWith<$Res>  {
  factory $FieldCopyWith(Field value, $Res Function(Field) _then) = _$FieldCopyWithImpl;
@useResult
$Res call({
 String label, String value, Validator? validator
});




}
/// @nodoc
class _$FieldCopyWithImpl<$Res>
    implements $FieldCopyWith<$Res> {
  _$FieldCopyWithImpl(this._self, this._then);

  final Field _self;
  final $Res Function(Field) _then;

/// Create a copy of Field
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,Object? validator = freezed,}) {
  return _then(Field(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,validator: freezed == validator ? _self.validator : validator // ignore: cast_nullable_to_non_nullable
as Validator?,
  ));
}

}


/// Adds pattern-matching-related methods to [Field].
extension FieldPatterns on Field {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Field value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Field() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Field value)  $default,){
final _that = this;
switch (_that) {
case _Field():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Field value)?  $default,){
final _that = this;
switch (_that) {
case _Field() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String value,  Validator? validator)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Field() when $default != null:
return $default(_that.label,_that.value,_that.validator);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String value,  Validator? validator)  $default,) {final _that = this;
switch (_that) {
case _Field():
return $default(_that.label,_that.value,_that.validator);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String value,  Validator? validator)?  $default,) {final _that = this;
switch (_that) {
case _Field() when $default != null:
return $default(_that.label,_that.value,_that.validator);case _:
  return null;

}
}

}

/// @nodoc


class _Field implements Field {
  const _Field({required this.label, required this.value, this.validator});
  

@override final  String label;
@override final  String value;
@override final  Validator? validator;

/// Create a copy of Field
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldCopyWith<_Field> get copyWith => __$FieldCopyWithImpl<_Field>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Field&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.validator, validator) || other.validator == validator));
}


@override
int get hashCode {
    return Object.hash(runtimeType,label,value,validator);
}

@override
String toString() {
    return 'Field(label: $label, value: $value, validator: $validator)';
}


}

/// @nodoc
abstract mixin class _$FieldCopyWith<$Res> implements $FieldCopyWith<$Res> {
  factory _$FieldCopyWith(_Field value, $Res Function(_Field) _then) = __$FieldCopyWithImpl;
@override @useResult
$Res call({
 String label, String value, Validator? validator
});




}
/// @nodoc
class __$FieldCopyWithImpl<$Res>
    implements _$FieldCopyWith<$Res> {
  __$FieldCopyWithImpl(this._self, this._then);

  final _Field _self;
  final $Res Function(_Field) _then;

/// Create a copy of Field
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,Object? validator = freezed,}) {
  return _then(_Field(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,validator: freezed == validator ? _self.validator : validator // ignore: cast_nullable_to_non_nullable
as Validator?,
  ));
}


}


/// @nodoc
mixin _$TextPainterParams {

 String? get text; double? get fontSize; double get textScaleFactor; double get maxWidth; int? get maxLines;
/// Create a copy of TextPainterParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextPainterParamsCopyWith<TextPainterParams> get copyWith => _$TextPainterParamsCopyWithImpl<TextPainterParams>(this as TextPainterParams, _$identity);

  /// Serializes this TextPainterParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextPainterParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextPainterParams&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.fontSize, _this.fontSize) || other.fontSize == _this.fontSize)&&(identical(other.textScaleFactor, _this.textScaleFactor) || other.textScaleFactor == _this.textScaleFactor)&&(identical(other.maxWidth, _this.maxWidth) || other.maxWidth == _this.maxWidth)&&(identical(other.maxLines, _this.maxLines) || other.maxLines == _this.maxLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextPainterParams;
  return Object.hash(runtimeType,_this.text,_this.fontSize,_this.textScaleFactor,_this.maxWidth,_this.maxLines);
}

@override
String toString() {
  final _this = this as TextPainterParams;
  return 'TextPainterParams(text: ${_this.text}, fontSize: ${_this.fontSize}, textScaleFactor: ${_this.textScaleFactor}, maxWidth: ${_this.maxWidth}, maxLines: ${_this.maxLines})';
}


}

/// @nodoc
abstract mixin class $TextPainterParamsCopyWith<$Res>  {
  factory $TextPainterParamsCopyWith(TextPainterParams value, $Res Function(TextPainterParams) _then) = _$TextPainterParamsCopyWithImpl;
@useResult
$Res call({
 String? text, double? fontSize, double textScaleFactor, double maxWidth, int? maxLines
});




}
/// @nodoc
class _$TextPainterParamsCopyWithImpl<$Res>
    implements $TextPainterParamsCopyWith<$Res> {
  _$TextPainterParamsCopyWithImpl(this._self, this._then);

  final TextPainterParams _self;
  final $Res Function(TextPainterParams) _then;

/// Create a copy of TextPainterParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? fontSize = freezed,Object? textScaleFactor = null,Object? maxWidth = null,Object? maxLines = freezed,}) {
  return _then(TextPainterParams(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,fontSize: freezed == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double?,textScaleFactor: null == textScaleFactor ? _self.textScaleFactor : textScaleFactor // ignore: cast_nullable_to_non_nullable
as double,maxWidth: null == maxWidth ? _self.maxWidth : maxWidth // ignore: cast_nullable_to_non_nullable
as double,maxLines: freezed == maxLines ? _self.maxLines : maxLines // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TextPainterParams].
extension TextPainterParamsPatterns on TextPainterParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextPainterParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextPainterParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextPainterParams value)  $default,){
final _that = this;
switch (_that) {
case _TextPainterParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextPainterParams value)?  $default,){
final _that = this;
switch (_that) {
case _TextPainterParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? text,  double? fontSize,  double textScaleFactor,  double maxWidth,  int? maxLines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextPainterParams() when $default != null:
return $default(_that.text,_that.fontSize,_that.textScaleFactor,_that.maxWidth,_that.maxLines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? text,  double? fontSize,  double textScaleFactor,  double maxWidth,  int? maxLines)  $default,) {final _that = this;
switch (_that) {
case _TextPainterParams():
return $default(_that.text,_that.fontSize,_that.textScaleFactor,_that.maxWidth,_that.maxLines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? text,  double? fontSize,  double textScaleFactor,  double maxWidth,  int? maxLines)?  $default,) {final _that = this;
switch (_that) {
case _TextPainterParams() when $default != null:
return $default(_that.text,_that.fontSize,_that.textScaleFactor,_that.maxWidth,_that.maxLines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextPainterParams implements TextPainterParams {
  const _TextPainterParams({required this.text, required this.fontSize, required this.textScaleFactor, this.maxWidth = double.infinity, this.maxLines});
  factory _TextPainterParams.fromJson(Map<String, dynamic> json) => _$TextPainterParamsFromJson(json);

@override final  String? text;
@override final  double? fontSize;
@override final  double textScaleFactor;
@override@JsonKey() final  double maxWidth;
@override final  int? maxLines;

/// Create a copy of TextPainterParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextPainterParamsCopyWith<_TextPainterParams> get copyWith => __$TextPainterParamsCopyWithImpl<_TextPainterParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextPainterParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextPainterParams&&(identical(other.text, text) || other.text == text)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.textScaleFactor, textScaleFactor) || other.textScaleFactor == textScaleFactor)&&(identical(other.maxWidth, maxWidth) || other.maxWidth == maxWidth)&&(identical(other.maxLines, maxLines) || other.maxLines == maxLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,fontSize,textScaleFactor,maxWidth,maxLines);
}

@override
String toString() {
    return 'TextPainterParams(text: $text, fontSize: $fontSize, textScaleFactor: $textScaleFactor, maxWidth: $maxWidth, maxLines: $maxLines)';
}


}

/// @nodoc
abstract mixin class _$TextPainterParamsCopyWith<$Res> implements $TextPainterParamsCopyWith<$Res> {
  factory _$TextPainterParamsCopyWith(_TextPainterParams value, $Res Function(_TextPainterParams) _then) = __$TextPainterParamsCopyWithImpl;
@override @useResult
$Res call({
 String? text, double? fontSize, double textScaleFactor, double maxWidth, int? maxLines
});




}
/// @nodoc
class __$TextPainterParamsCopyWithImpl<$Res>
    implements _$TextPainterParamsCopyWith<$Res> {
  __$TextPainterParamsCopyWithImpl(this._self, this._then);

  final _TextPainterParams _self;
  final $Res Function(_TextPainterParams) _then;

/// Create a copy of TextPainterParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? fontSize = freezed,Object? textScaleFactor = null,Object? maxWidth = null,Object? maxLines = freezed,}) {
  return _then(_TextPainterParams(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,fontSize: freezed == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double?,textScaleFactor: null == textScaleFactor ? _self.textScaleFactor : textScaleFactor // ignore: cast_nullable_to_non_nullable
as double,maxWidth: null == maxWidth ? _self.maxWidth : maxWidth // ignore: cast_nullable_to_non_nullable
as double,maxLines: freezed == maxLines ? _self.maxLines : maxLines // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$Result<T> {

 T? get data; ResultType get type; String get message; bool get needRestart;
/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultCopyWith<T, Result<T>> get copyWith => _$ResultCopyWithImpl<T, Result<T>>(this as Result<T>, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Result<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<T>&&const DeepCollectionEquality().equals(other.data, _this.data)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.needRestart, _this.needRestart) || other.needRestart == _this.needRestart));
}


@override
int get hashCode {
  final _this = this as Result<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data),_this.type,_this.message,_this.needRestart);
}

@override
String toString() {
  final _this = this as Result<T>;
  return 'Result<$T>(data: ${_this.data}, type: ${_this.type}, message: ${_this.message}, needRestart: ${_this.needRestart})';
}


}

/// @nodoc
abstract mixin class $ResultCopyWith<T,$Res>  {
  factory $ResultCopyWith(Result<T> value, $Res Function(Result<T>) _then) = _$ResultCopyWithImpl;
@useResult
$Res call({
 T? data, ResultType type, String message, bool needRestart
});




}
/// @nodoc
class _$ResultCopyWithImpl<T,$Res>
    implements $ResultCopyWith<T, $Res> {
  _$ResultCopyWithImpl(this._self, this._then);

  final Result<T> _self;
  final $Res Function(Result<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? type = null,Object? message = null,Object? needRestart = null,}) {
  return _then(Result(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ResultType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,needRestart: null == needRestart ? _self.needRestart : needRestart // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T> on Result<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Result<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Result<T> value)  $default,){
final _that = this;
switch (_that) {
case _Result():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Result<T> value)?  $default,){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T? data,  ResultType type,  String message,  bool needRestart)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.data,_that.type,_that.message,_that.needRestart);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T? data,  ResultType type,  String message,  bool needRestart)  $default,) {final _that = this;
switch (_that) {
case _Result():
return $default(_that.data,_that.type,_that.message,_that.needRestart);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T? data,  ResultType type,  String message,  bool needRestart)?  $default,) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.data,_that.type,_that.message,_that.needRestart);case _:
  return null;

}
}

}

/// @nodoc


class _Result<T> implements Result<T> {
  const _Result({required this.data, required this.type, required this.message, this.needRestart = false});
  

@override final  T? data;
@override final  ResultType type;
@override final  String message;
@override@JsonKey() final  bool needRestart;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultCopyWith<T, _Result<T>> get copyWith => __$ResultCopyWithImpl<T, _Result<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Result<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message)&&(identical(other.needRestart, needRestart) || other.needRestart == needRestart));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data),type,message,needRestart);
}

@override
String toString() {
    return 'Result<$T>(data: $data, type: $type, message: $message, needRestart: $needRestart)';
}


}

/// @nodoc
abstract mixin class _$ResultCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory _$ResultCopyWith(_Result<T> value, $Res Function(_Result<T>) _then) = __$ResultCopyWithImpl;
@override @useResult
$Res call({
 T? data, ResultType type, String message, bool needRestart
});




}
/// @nodoc
class __$ResultCopyWithImpl<T,$Res>
    implements _$ResultCopyWith<T, $Res> {
  __$ResultCopyWithImpl(this._self, this._then);

  final _Result<T> _self;
  final $Res Function(_Result<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? type = null,Object? message = null,Object? needRestart = null,}) {
  return _then(_Result<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ResultType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,needRestart: null == needRestart ? _self.needRestart : needRestart // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Script {

 String get id; String get label; String get content; String? get url;@JsonKey(name: 'custom-options') Map<String, bool>? get customOptions; String? get digest; bool get compatible; bool? get volatile;
/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptCopyWith<Script> get copyWith => _$ScriptCopyWithImpl<Script>(this as Script, _$identity);

  /// Serializes this Script to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Script;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Script&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.url, _this.url) || other.url == _this.url)&&const DeepCollectionEquality().equals(other.customOptions, _this.customOptions)&&(identical(other.digest, _this.digest) || other.digest == _this.digest)&&(identical(other.compatible, _this.compatible) || other.compatible == _this.compatible)&&(identical(other.volatile, _this.volatile) || other.volatile == _this.volatile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Script;
  return Object.hash(runtimeType,_this.id,_this.label,_this.content,_this.url,const DeepCollectionEquality().hash(_this.customOptions),_this.digest,_this.compatible,_this.volatile);
}

@override
String toString() {
  final _this = this as Script;
  return 'Script(id: ${_this.id}, label: ${_this.label}, content: ${_this.content}, url: ${_this.url}, customOptions: ${_this.customOptions}, digest: ${_this.digest}, compatible: ${_this.compatible}, volatile: ${_this.volatile})';
}


}

/// @nodoc
abstract mixin class $ScriptCopyWith<$Res>  {
  factory $ScriptCopyWith(Script value, $Res Function(Script) _then) = _$ScriptCopyWithImpl;
@useResult
$Res call({
 String id, String label, String content, String? url,@JsonKey(name: 'custom-options') Map<String, bool>? customOptions, String? digest, bool compatible, bool? volatile
});




}
/// @nodoc
class _$ScriptCopyWithImpl<$Res>
    implements $ScriptCopyWith<$Res> {
  _$ScriptCopyWithImpl(this._self, this._then);

  final Script _self;
  final $Res Function(Script) _then;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? content = null,Object? url = freezed,Object? customOptions = freezed,Object? digest = freezed,Object? compatible = null,Object? volatile = freezed,}) {
  return _then(Script(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,customOptions: freezed == customOptions ? _self.customOptions : customOptions // ignore: cast_nullable_to_non_nullable
as Map<String, bool>?,digest: freezed == digest ? _self.digest : digest // ignore: cast_nullable_to_non_nullable
as String?,compatible: null == compatible ? _self.compatible : compatible // ignore: cast_nullable_to_non_nullable
as bool,volatile: freezed == volatile ? _self.volatile : volatile // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [Script].
extension ScriptPatterns on Script {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Script value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Script() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Script value)  $default,){
final _that = this;
switch (_that) {
case _Script():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Script value)?  $default,){
final _that = this;
switch (_that) {
case _Script() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String content,  String? url, @JsonKey(name: 'custom-options')  Map<String, bool>? customOptions,  String? digest,  bool compatible,  bool? volatile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Script() when $default != null:
return $default(_that.id,_that.label,_that.content,_that.url,_that.customOptions,_that.digest,_that.compatible,_that.volatile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String content,  String? url, @JsonKey(name: 'custom-options')  Map<String, bool>? customOptions,  String? digest,  bool compatible,  bool? volatile)  $default,) {final _that = this;
switch (_that) {
case _Script():
return $default(_that.id,_that.label,_that.content,_that.url,_that.customOptions,_that.digest,_that.compatible,_that.volatile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String content,  String? url, @JsonKey(name: 'custom-options')  Map<String, bool>? customOptions,  String? digest,  bool compatible,  bool? volatile)?  $default,) {final _that = this;
switch (_that) {
case _Script() when $default != null:
return $default(_that.id,_that.label,_that.content,_that.url,_that.customOptions,_that.digest,_that.compatible,_that.volatile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Script implements Script {
  const _Script({required this.id, required this.label, this.content = '', this.url, @JsonKey(name: 'custom-options')  Map<String, bool>? customOptions, this.digest, this.compatible = false, this.volatile}): _customOptions = customOptions;
  factory _Script.fromJson(Map<String, dynamic> json) => _$ScriptFromJson(json);

@override final  String id;
@override final  String label;
@override@JsonKey() final  String content;
@override final  String? url;
 final  Map<String, bool>? _customOptions;
@override@JsonKey(name: 'custom-options') Map<String, bool>? get customOptions {
  final value = _customOptions;
  if (value == null) return null;
  if (_customOptions is EqualUnmodifiableMapView) return _customOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? digest;
@override@JsonKey() final  bool compatible;
@override final  bool? volatile;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptCopyWith<_Script> get copyWith => __$ScriptCopyWithImpl<_Script>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Script&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.content, content) || other.content == content)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.customOptions, _customOptions)&&(identical(other.digest, digest) || other.digest == digest)&&(identical(other.compatible, compatible) || other.compatible == compatible)&&(identical(other.volatile, volatile) || other.volatile == volatile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,content,url,const DeepCollectionEquality().hash(_customOptions),digest,compatible,volatile);
}

@override
String toString() {
    return 'Script(id: $id, label: $label, content: $content, url: $url, customOptions: $customOptions, digest: $digest, compatible: $compatible, volatile: $volatile)';
}


}

/// @nodoc
abstract mixin class _$ScriptCopyWith<$Res> implements $ScriptCopyWith<$Res> {
  factory _$ScriptCopyWith(_Script value, $Res Function(_Script) _then) = __$ScriptCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String content, String? url,@JsonKey(name: 'custom-options') Map<String, bool>? customOptions, String? digest, bool compatible, bool? volatile
});




}
/// @nodoc
class __$ScriptCopyWithImpl<$Res>
    implements _$ScriptCopyWith<$Res> {
  __$ScriptCopyWithImpl(this._self, this._then);

  final _Script _self;
  final $Res Function(_Script) _then;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? content = null,Object? url = freezed,Object? customOptions = freezed,Object? digest = freezed,Object? compatible = null,Object? volatile = freezed,}) {
  return _then(_Script(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,customOptions: freezed == customOptions ? _self._customOptions : customOptions // ignore: cast_nullable_to_non_nullable
as Map<String, bool>?,digest: freezed == digest ? _self.digest : digest // ignore: cast_nullable_to_non_nullable
as String?,compatible: null == compatible ? _self.compatible : compatible // ignore: cast_nullable_to_non_nullable
as bool,volatile: freezed == volatile ? _self.volatile : volatile // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$RouteRuleSet {

 String get tag; String get type; String? get name; String? get icon; int? get count;
/// Create a copy of RouteRuleSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteRuleSetCopyWith<RouteRuleSet> get copyWith => _$RouteRuleSetCopyWithImpl<RouteRuleSet>(this as RouteRuleSet, _$identity);

  /// Serializes this RouteRuleSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteRuleSet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteRuleSet&&(identical(other.tag, _this.tag) || other.tag == _this.tag)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.count, _this.count) || other.count == _this.count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteRuleSet;
  return Object.hash(runtimeType,_this.tag,_this.type,_this.name,_this.icon,_this.count);
}

@override
String toString() {
  final _this = this as RouteRuleSet;
  return 'RouteRuleSet(tag: ${_this.tag}, type: ${_this.type}, name: ${_this.name}, icon: ${_this.icon}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $RouteRuleSetCopyWith<$Res>  {
  factory $RouteRuleSetCopyWith(RouteRuleSet value, $Res Function(RouteRuleSet) _then) = _$RouteRuleSetCopyWithImpl;
@useResult
$Res call({
 String tag, String type, String? name, String? icon, int? count
});




}
/// @nodoc
class _$RouteRuleSetCopyWithImpl<$Res>
    implements $RouteRuleSetCopyWith<$Res> {
  _$RouteRuleSetCopyWithImpl(this._self, this._then);

  final RouteRuleSet _self;
  final $Res Function(RouteRuleSet) _then;

/// Create a copy of RouteRuleSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tag = null,Object? type = null,Object? name = freezed,Object? icon = freezed,Object? count = freezed,}) {
  return _then(RouteRuleSet(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteRuleSet].
extension RouteRuleSetPatterns on RouteRuleSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteRuleSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteRuleSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteRuleSet value)  $default,){
final _that = this;
switch (_that) {
case _RouteRuleSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteRuleSet value)?  $default,){
final _that = this;
switch (_that) {
case _RouteRuleSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tag,  String type,  String? name,  String? icon,  int? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteRuleSet() when $default != null:
return $default(_that.tag,_that.type,_that.name,_that.icon,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tag,  String type,  String? name,  String? icon,  int? count)  $default,) {final _that = this;
switch (_that) {
case _RouteRuleSet():
return $default(_that.tag,_that.type,_that.name,_that.icon,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tag,  String type,  String? name,  String? icon,  int? count)?  $default,) {final _that = this;
switch (_that) {
case _RouteRuleSet() when $default != null:
return $default(_that.tag,_that.type,_that.name,_that.icon,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteRuleSet implements RouteRuleSet {
  const _RouteRuleSet({required this.tag, this.type = 'geosite', this.name, this.icon, this.count});
  factory _RouteRuleSet.fromJson(Map<String, dynamic> json) => _$RouteRuleSetFromJson(json);

@override final  String tag;
@override@JsonKey() final  String type;
@override final  String? name;
@override final  String? icon;
@override final  int? count;

/// Create a copy of RouteRuleSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteRuleSetCopyWith<_RouteRuleSet> get copyWith => __$RouteRuleSetCopyWithImpl<_RouteRuleSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteRuleSetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteRuleSet&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tag,type,name,icon,count);
}

@override
String toString() {
    return 'RouteRuleSet(tag: $tag, type: $type, name: $name, icon: $icon, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RouteRuleSetCopyWith<$Res> implements $RouteRuleSetCopyWith<$Res> {
  factory _$RouteRuleSetCopyWith(_RouteRuleSet value, $Res Function(_RouteRuleSet) _then) = __$RouteRuleSetCopyWithImpl;
@override @useResult
$Res call({
 String tag, String type, String? name, String? icon, int? count
});




}
/// @nodoc
class __$RouteRuleSetCopyWithImpl<$Res>
    implements _$RouteRuleSetCopyWith<$Res> {
  __$RouteRuleSetCopyWithImpl(this._self, this._then);

  final _RouteRuleSet _self;
  final $Res Function(_RouteRuleSet) _then;

/// Create a copy of RouteRuleSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? type = null,Object? name = freezed,Object? icon = freezed,Object? count = freezed,}) {
  return _then(_RouteRuleSet(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RouteService {

 String get name; String? get icon; List<String> get sets; List<String> get keywords; List<String> get groups;@JsonKey(unknownEnumValue: RouteCategory.other) RouteCategory get category;
/// Create a copy of RouteService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteServiceCopyWith<RouteService> get copyWith => _$RouteServiceCopyWithImpl<RouteService>(this as RouteService, _$identity);

  /// Serializes this RouteService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteService;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteService&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&const DeepCollectionEquality().equals(other.sets, _this.sets)&&const DeepCollectionEquality().equals(other.keywords, _this.keywords)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&(identical(other.category, _this.category) || other.category == _this.category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteService;
  return Object.hash(runtimeType,_this.name,_this.icon,const DeepCollectionEquality().hash(_this.sets),const DeepCollectionEquality().hash(_this.keywords),const DeepCollectionEquality().hash(_this.groups),_this.category);
}

@override
String toString() {
  final _this = this as RouteService;
  return 'RouteService(name: ${_this.name}, icon: ${_this.icon}, sets: ${_this.sets}, keywords: ${_this.keywords}, groups: ${_this.groups}, category: ${_this.category})';
}


}

/// @nodoc
abstract mixin class $RouteServiceCopyWith<$Res>  {
  factory $RouteServiceCopyWith(RouteService value, $Res Function(RouteService) _then) = _$RouteServiceCopyWithImpl;
@useResult
$Res call({
 String name, String? icon, List<String> sets, List<String> keywords, List<String> groups,@JsonKey(unknownEnumValue: RouteCategory.other) RouteCategory category
});




}
/// @nodoc
class _$RouteServiceCopyWithImpl<$Res>
    implements $RouteServiceCopyWith<$Res> {
  _$RouteServiceCopyWithImpl(this._self, this._then);

  final RouteService _self;
  final $Res Function(RouteService) _then;

/// Create a copy of RouteService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? icon = freezed,Object? sets = null,Object? keywords = null,Object? groups = null,Object? category = null,}) {
  return _then(RouteService(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<String>,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as RouteCategory,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteService].
extension RouteServicePatterns on RouteService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteService value)  $default,){
final _that = this;
switch (_that) {
case _RouteService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteService value)?  $default,){
final _that = this;
switch (_that) {
case _RouteService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? icon,  List<String> sets,  List<String> keywords,  List<String> groups, @JsonKey(unknownEnumValue: RouteCategory.other)  RouteCategory category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteService() when $default != null:
return $default(_that.name,_that.icon,_that.sets,_that.keywords,_that.groups,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? icon,  List<String> sets,  List<String> keywords,  List<String> groups, @JsonKey(unknownEnumValue: RouteCategory.other)  RouteCategory category)  $default,) {final _that = this;
switch (_that) {
case _RouteService():
return $default(_that.name,_that.icon,_that.sets,_that.keywords,_that.groups,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? icon,  List<String> sets,  List<String> keywords,  List<String> groups, @JsonKey(unknownEnumValue: RouteCategory.other)  RouteCategory category)?  $default,) {final _that = this;
switch (_that) {
case _RouteService() when $default != null:
return $default(_that.name,_that.icon,_that.sets,_that.keywords,_that.groups,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteService implements RouteService {
  const _RouteService({required this.name, this.icon,  List<String> sets = const [],  List<String> keywords = const [],  List<String> groups = const [], @JsonKey(unknownEnumValue: RouteCategory.other) this.category = RouteCategory.other}): _sets = sets,_keywords = keywords,_groups = groups;
  factory _RouteService.fromJson(Map<String, dynamic> json) => _$RouteServiceFromJson(json);

@override final  String name;
@override final  String? icon;
 final  List<String> _sets;
@override@JsonKey() List<String> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

 final  List<String> _keywords;
@override@JsonKey() List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey(unknownEnumValue: RouteCategory.other) final  RouteCategory category;

/// Create a copy of RouteService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteServiceCopyWith<_RouteService> get copyWith => __$RouteServiceCopyWithImpl<_RouteService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteServiceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteService&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.sets, _sets)&&const DeepCollectionEquality().equals(other.keywords, _keywords)&&const DeepCollectionEquality().equals(other.groups, _groups)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,icon,const DeepCollectionEquality().hash(_sets),const DeepCollectionEquality().hash(_keywords),const DeepCollectionEquality().hash(_groups),category);
}

@override
String toString() {
    return 'RouteService(name: $name, icon: $icon, sets: $sets, keywords: $keywords, groups: $groups, category: $category)';
}


}

/// @nodoc
abstract mixin class _$RouteServiceCopyWith<$Res> implements $RouteServiceCopyWith<$Res> {
  factory _$RouteServiceCopyWith(_RouteService value, $Res Function(_RouteService) _then) = __$RouteServiceCopyWithImpl;
@override @useResult
$Res call({
 String name, String? icon, List<String> sets, List<String> keywords, List<String> groups,@JsonKey(unknownEnumValue: RouteCategory.other) RouteCategory category
});




}
/// @nodoc
class __$RouteServiceCopyWithImpl<$Res>
    implements _$RouteServiceCopyWith<$Res> {
  __$RouteServiceCopyWithImpl(this._self, this._then);

  final _RouteService _self;
  final $Res Function(_RouteService) _then;

/// Create a copy of RouteService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? icon = freezed,Object? sets = null,Object? keywords = null,Object? groups = null,Object? category = null,}) {
  return _then(_RouteService(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<String>,keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as RouteCategory,
  ));
}


}


/// @nodoc
mixin _$RouteRegion {

 String get name; String? get icon;@JsonKey(name: 'default') bool get preset;
/// Create a copy of RouteRegion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteRegionCopyWith<RouteRegion> get copyWith => _$RouteRegionCopyWithImpl<RouteRegion>(this as RouteRegion, _$identity);

  /// Serializes this RouteRegion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteRegion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteRegion&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.preset, _this.preset) || other.preset == _this.preset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteRegion;
  return Object.hash(runtimeType,_this.name,_this.icon,_this.preset);
}

@override
String toString() {
  final _this = this as RouteRegion;
  return 'RouteRegion(name: ${_this.name}, icon: ${_this.icon}, preset: ${_this.preset})';
}


}

/// @nodoc
abstract mixin class $RouteRegionCopyWith<$Res>  {
  factory $RouteRegionCopyWith(RouteRegion value, $Res Function(RouteRegion) _then) = _$RouteRegionCopyWithImpl;
@useResult
$Res call({
 String name, String? icon,@JsonKey(name: 'default') bool preset
});




}
/// @nodoc
class _$RouteRegionCopyWithImpl<$Res>
    implements $RouteRegionCopyWith<$Res> {
  _$RouteRegionCopyWithImpl(this._self, this._then);

  final RouteRegion _self;
  final $Res Function(RouteRegion) _then;

/// Create a copy of RouteRegion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? icon = freezed,Object? preset = null,}) {
  return _then(RouteRegion(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteRegion].
extension RouteRegionPatterns on RouteRegion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteRegion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteRegion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteRegion value)  $default,){
final _that = this;
switch (_that) {
case _RouteRegion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteRegion value)?  $default,){
final _that = this;
switch (_that) {
case _RouteRegion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? icon, @JsonKey(name: 'default')  bool preset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteRegion() when $default != null:
return $default(_that.name,_that.icon,_that.preset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? icon, @JsonKey(name: 'default')  bool preset)  $default,) {final _that = this;
switch (_that) {
case _RouteRegion():
return $default(_that.name,_that.icon,_that.preset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? icon, @JsonKey(name: 'default')  bool preset)?  $default,) {final _that = this;
switch (_that) {
case _RouteRegion() when $default != null:
return $default(_that.name,_that.icon,_that.preset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteRegion implements RouteRegion {
  const _RouteRegion({required this.name, this.icon, @JsonKey(name: 'default') this.preset = false});
  factory _RouteRegion.fromJson(Map<String, dynamic> json) => _$RouteRegionFromJson(json);

@override final  String name;
@override final  String? icon;
@override@JsonKey(name: 'default') final  bool preset;

/// Create a copy of RouteRegion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteRegionCopyWith<_RouteRegion> get copyWith => __$RouteRegionCopyWithImpl<_RouteRegion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteRegionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteRegion&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.preset, preset) || other.preset == preset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,icon,preset);
}

@override
String toString() {
    return 'RouteRegion(name: $name, icon: $icon, preset: $preset)';
}


}

/// @nodoc
abstract mixin class _$RouteRegionCopyWith<$Res> implements $RouteRegionCopyWith<$Res> {
  factory _$RouteRegionCopyWith(_RouteRegion value, $Res Function(_RouteRegion) _then) = __$RouteRegionCopyWithImpl;
@override @useResult
$Res call({
 String name, String? icon,@JsonKey(name: 'default') bool preset
});




}
/// @nodoc
class __$RouteRegionCopyWithImpl<$Res>
    implements _$RouteRegionCopyWith<$Res> {
  __$RouteRegionCopyWithImpl(this._self, this._then);

  final _RouteRegion _self;
  final $Res Function(_RouteRegion) _then;

/// Create a copy of RouteRegion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? icon = freezed,Object? preset = null,}) {
  return _then(_RouteRegion(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RouteCatalog {

 List<String> get targets; List<String> get reserved; List<RouteRegion> get regions; Map<String, RouteCategory> get groupCategories; List<String> get icons; List<RouteService> get services; List<RouteRuleSet> get sets;
/// Create a copy of RouteCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteCatalogCopyWith<RouteCatalog> get copyWith => _$RouteCatalogCopyWithImpl<RouteCatalog>(this as RouteCatalog, _$identity);

  /// Serializes this RouteCatalog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteCatalog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteCatalog&&const DeepCollectionEquality().equals(other.targets, _this.targets)&&const DeepCollectionEquality().equals(other.reserved, _this.reserved)&&const DeepCollectionEquality().equals(other.regions, _this.regions)&&const DeepCollectionEquality().equals(other.groupCategories, _this.groupCategories)&&const DeepCollectionEquality().equals(other.icons, _this.icons)&&const DeepCollectionEquality().equals(other.services, _this.services)&&const DeepCollectionEquality().equals(other.sets, _this.sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteCatalog;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.targets),const DeepCollectionEquality().hash(_this.reserved),const DeepCollectionEquality().hash(_this.regions),const DeepCollectionEquality().hash(_this.groupCategories),const DeepCollectionEquality().hash(_this.icons),const DeepCollectionEquality().hash(_this.services),const DeepCollectionEquality().hash(_this.sets));
}

@override
String toString() {
  final _this = this as RouteCatalog;
  return 'RouteCatalog(targets: ${_this.targets}, reserved: ${_this.reserved}, regions: ${_this.regions}, groupCategories: ${_this.groupCategories}, icons: ${_this.icons}, services: ${_this.services}, sets: ${_this.sets})';
}


}

/// @nodoc
abstract mixin class $RouteCatalogCopyWith<$Res>  {
  factory $RouteCatalogCopyWith(RouteCatalog value, $Res Function(RouteCatalog) _then) = _$RouteCatalogCopyWithImpl;
@useResult
$Res call({
 List<String> targets, List<String> reserved, List<RouteRegion> regions, Map<String, RouteCategory> groupCategories, List<String> icons, List<RouteService> services, List<RouteRuleSet> sets
});




}
/// @nodoc
class _$RouteCatalogCopyWithImpl<$Res>
    implements $RouteCatalogCopyWith<$Res> {
  _$RouteCatalogCopyWithImpl(this._self, this._then);

  final RouteCatalog _self;
  final $Res Function(RouteCatalog) _then;

/// Create a copy of RouteCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targets = null,Object? reserved = null,Object? regions = null,Object? groupCategories = null,Object? icons = null,Object? services = null,Object? sets = null,}) {
  return _then(RouteCatalog(
targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as List<String>,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as List<String>,regions: null == regions ? _self.regions : regions // ignore: cast_nullable_to_non_nullable
as List<RouteRegion>,groupCategories: null == groupCategories ? _self.groupCategories : groupCategories // ignore: cast_nullable_to_non_nullable
as Map<String, RouteCategory>,icons: null == icons ? _self.icons : icons // ignore: cast_nullable_to_non_nullable
as List<String>,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<RouteService>,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<RouteRuleSet>,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteCatalog].
extension RouteCatalogPatterns on RouteCatalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteCatalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteCatalog value)  $default,){
final _that = this;
switch (_that) {
case _RouteCatalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _RouteCatalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> targets,  List<String> reserved,  List<RouteRegion> regions,  Map<String, RouteCategory> groupCategories,  List<String> icons,  List<RouteService> services,  List<RouteRuleSet> sets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteCatalog() when $default != null:
return $default(_that.targets,_that.reserved,_that.regions,_that.groupCategories,_that.icons,_that.services,_that.sets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> targets,  List<String> reserved,  List<RouteRegion> regions,  Map<String, RouteCategory> groupCategories,  List<String> icons,  List<RouteService> services,  List<RouteRuleSet> sets)  $default,) {final _that = this;
switch (_that) {
case _RouteCatalog():
return $default(_that.targets,_that.reserved,_that.regions,_that.groupCategories,_that.icons,_that.services,_that.sets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> targets,  List<String> reserved,  List<RouteRegion> regions,  Map<String, RouteCategory> groupCategories,  List<String> icons,  List<RouteService> services,  List<RouteRuleSet> sets)?  $default,) {final _that = this;
switch (_that) {
case _RouteCatalog() when $default != null:
return $default(_that.targets,_that.reserved,_that.regions,_that.groupCategories,_that.icons,_that.services,_that.sets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteCatalog implements RouteCatalog {
  const _RouteCatalog({ List<String> targets = const [],  List<String> reserved = const [],  List<RouteRegion> regions = const [],  Map<String, RouteCategory> groupCategories = const {},  List<String> icons = const [],  List<RouteService> services = const [],  List<RouteRuleSet> sets = const []}): _targets = targets,_reserved = reserved,_regions = regions,_groupCategories = groupCategories,_icons = icons,_services = services,_sets = sets;
  factory _RouteCatalog.fromJson(Map<String, dynamic> json) => _$RouteCatalogFromJson(json);

 final  List<String> _targets;
@override@JsonKey() List<String> get targets {
  if (_targets is EqualUnmodifiableListView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targets);
}

 final  List<String> _reserved;
@override@JsonKey() List<String> get reserved {
  if (_reserved is EqualUnmodifiableListView) return _reserved;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reserved);
}

 final  List<RouteRegion> _regions;
@override@JsonKey() List<RouteRegion> get regions {
  if (_regions is EqualUnmodifiableListView) return _regions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_regions);
}

 final  Map<String, RouteCategory> _groupCategories;
@override@JsonKey() Map<String, RouteCategory> get groupCategories {
  if (_groupCategories is EqualUnmodifiableMapView) return _groupCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupCategories);
}

 final  List<String> _icons;
@override@JsonKey() List<String> get icons {
  if (_icons is EqualUnmodifiableListView) return _icons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_icons);
}

 final  List<RouteService> _services;
@override@JsonKey() List<RouteService> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

 final  List<RouteRuleSet> _sets;
@override@JsonKey() List<RouteRuleSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}


/// Create a copy of RouteCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteCatalogCopyWith<_RouteCatalog> get copyWith => __$RouteCatalogCopyWithImpl<_RouteCatalog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteCatalogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteCatalog&&const DeepCollectionEquality().equals(other.targets, _targets)&&const DeepCollectionEquality().equals(other.reserved, _reserved)&&const DeepCollectionEquality().equals(other.regions, _regions)&&const DeepCollectionEquality().equals(other.groupCategories, _groupCategories)&&const DeepCollectionEquality().equals(other.icons, _icons)&&const DeepCollectionEquality().equals(other.services, _services)&&const DeepCollectionEquality().equals(other.sets, _sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_targets),const DeepCollectionEquality().hash(_reserved),const DeepCollectionEquality().hash(_regions),const DeepCollectionEquality().hash(_groupCategories),const DeepCollectionEquality().hash(_icons),const DeepCollectionEquality().hash(_services),const DeepCollectionEquality().hash(_sets));
}

@override
String toString() {
    return 'RouteCatalog(targets: $targets, reserved: $reserved, regions: $regions, groupCategories: $groupCategories, icons: $icons, services: $services, sets: $sets)';
}


}

/// @nodoc
abstract mixin class _$RouteCatalogCopyWith<$Res> implements $RouteCatalogCopyWith<$Res> {
  factory _$RouteCatalogCopyWith(_RouteCatalog value, $Res Function(_RouteCatalog) _then) = __$RouteCatalogCopyWithImpl;
@override @useResult
$Res call({
 List<String> targets, List<String> reserved, List<RouteRegion> regions, Map<String, RouteCategory> groupCategories, List<String> icons, List<RouteService> services, List<RouteRuleSet> sets
});




}
/// @nodoc
class __$RouteCatalogCopyWithImpl<$Res>
    implements _$RouteCatalogCopyWith<$Res> {
  __$RouteCatalogCopyWithImpl(this._self, this._then);

  final _RouteCatalog _self;
  final $Res Function(_RouteCatalog) _then;

/// Create a copy of RouteCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targets = null,Object? reserved = null,Object? regions = null,Object? groupCategories = null,Object? icons = null,Object? services = null,Object? sets = null,}) {
  return _then(_RouteCatalog(
targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as List<String>,reserved: null == reserved ? _self._reserved : reserved // ignore: cast_nullable_to_non_nullable
as List<String>,regions: null == regions ? _self._regions : regions // ignore: cast_nullable_to_non_nullable
as List<RouteRegion>,groupCategories: null == groupCategories ? _self._groupCategories : groupCategories // ignore: cast_nullable_to_non_nullable
as Map<String, RouteCategory>,icons: null == icons ? _self._icons : icons // ignore: cast_nullable_to_non_nullable
as List<String>,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<RouteService>,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<RouteRuleSet>,
  ));
}


}


/// @nodoc
mixin _$IconSetIcon {

 String get name; String get url;
/// Create a copy of IconSetIcon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IconSetIconCopyWith<IconSetIcon> get copyWith => _$IconSetIconCopyWithImpl<IconSetIcon>(this as IconSetIcon, _$identity);

  /// Serializes this IconSetIcon to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IconSetIcon;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IconSetIcon&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IconSetIcon;
  return Object.hash(runtimeType,_this.name,_this.url);
}

@override
String toString() {
  final _this = this as IconSetIcon;
  return 'IconSetIcon(name: ${_this.name}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $IconSetIconCopyWith<$Res>  {
  factory $IconSetIconCopyWith(IconSetIcon value, $Res Function(IconSetIcon) _then) = _$IconSetIconCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$IconSetIconCopyWithImpl<$Res>
    implements $IconSetIconCopyWith<$Res> {
  _$IconSetIconCopyWithImpl(this._self, this._then);

  final IconSetIcon _self;
  final $Res Function(IconSetIcon) _then;

/// Create a copy of IconSetIcon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(IconSetIcon(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IconSetIcon].
extension IconSetIconPatterns on IconSetIcon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IconSetIcon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IconSetIcon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IconSetIcon value)  $default,){
final _that = this;
switch (_that) {
case _IconSetIcon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IconSetIcon value)?  $default,){
final _that = this;
switch (_that) {
case _IconSetIcon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IconSetIcon() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url)  $default,) {final _that = this;
switch (_that) {
case _IconSetIcon():
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url)?  $default,) {final _that = this;
switch (_that) {
case _IconSetIcon() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IconSetIcon implements IconSetIcon {
  const _IconSetIcon({required this.name, required this.url});
  factory _IconSetIcon.fromJson(Map<String, dynamic> json) => _$IconSetIconFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of IconSetIcon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IconSetIconCopyWith<_IconSetIcon> get copyWith => __$IconSetIconCopyWithImpl<_IconSetIcon>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IconSetIconToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IconSetIcon&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,url);
}

@override
String toString() {
    return 'IconSetIcon(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$IconSetIconCopyWith<$Res> implements $IconSetIconCopyWith<$Res> {
  factory _$IconSetIconCopyWith(_IconSetIcon value, $Res Function(_IconSetIcon) _then) = __$IconSetIconCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$IconSetIconCopyWithImpl<$Res>
    implements _$IconSetIconCopyWith<$Res> {
  __$IconSetIconCopyWithImpl(this._self, this._then);

  final _IconSetIcon _self;
  final $Res Function(_IconSetIcon) _then;

/// Create a copy of IconSetIcon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_IconSetIcon(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$IconSet {

 String get id; String get name; String get url; List<IconSetIcon> get icons; DateTime? get lastUpdateTime;
/// Create a copy of IconSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IconSetCopyWith<IconSet> get copyWith => _$IconSetCopyWithImpl<IconSet>(this as IconSet, _$identity);

  /// Serializes this IconSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IconSet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IconSet&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url)&&const DeepCollectionEquality().equals(other.icons, _this.icons)&&(identical(other.lastUpdateTime, _this.lastUpdateTime) || other.lastUpdateTime == _this.lastUpdateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IconSet;
  return Object.hash(runtimeType,_this.id,_this.name,_this.url,const DeepCollectionEquality().hash(_this.icons),_this.lastUpdateTime);
}

@override
String toString() {
  final _this = this as IconSet;
  return 'IconSet(id: ${_this.id}, name: ${_this.name}, url: ${_this.url}, icons: ${_this.icons}, lastUpdateTime: ${_this.lastUpdateTime})';
}


}

/// @nodoc
abstract mixin class $IconSetCopyWith<$Res>  {
  factory $IconSetCopyWith(IconSet value, $Res Function(IconSet) _then) = _$IconSetCopyWithImpl;
@useResult
$Res call({
 String id, String name, String url, List<IconSetIcon> icons, DateTime? lastUpdateTime
});




}
/// @nodoc
class _$IconSetCopyWithImpl<$Res>
    implements $IconSetCopyWith<$Res> {
  _$IconSetCopyWithImpl(this._self, this._then);

  final IconSet _self;
  final $Res Function(IconSet) _then;

/// Create a copy of IconSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? url = null,Object? icons = null,Object? lastUpdateTime = freezed,}) {
  return _then(IconSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,icons: null == icons ? _self.icons : icons // ignore: cast_nullable_to_non_nullable
as List<IconSetIcon>,lastUpdateTime: freezed == lastUpdateTime ? _self.lastUpdateTime : lastUpdateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [IconSet].
extension IconSetPatterns on IconSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IconSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IconSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IconSet value)  $default,){
final _that = this;
switch (_that) {
case _IconSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IconSet value)?  $default,){
final _that = this;
switch (_that) {
case _IconSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String url,  List<IconSetIcon> icons,  DateTime? lastUpdateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IconSet() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.icons,_that.lastUpdateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String url,  List<IconSetIcon> icons,  DateTime? lastUpdateTime)  $default,) {final _that = this;
switch (_that) {
case _IconSet():
return $default(_that.id,_that.name,_that.url,_that.icons,_that.lastUpdateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String url,  List<IconSetIcon> icons,  DateTime? lastUpdateTime)?  $default,) {final _that = this;
switch (_that) {
case _IconSet() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.icons,_that.lastUpdateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IconSet implements IconSet {
  const _IconSet({required this.id, required this.name, this.url = '',  List<IconSetIcon> icons = const [], this.lastUpdateTime}): _icons = icons;
  factory _IconSet.fromJson(Map<String, dynamic> json) => _$IconSetFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String url;
 final  List<IconSetIcon> _icons;
@override@JsonKey() List<IconSetIcon> get icons {
  if (_icons is EqualUnmodifiableListView) return _icons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_icons);
}

@override final  DateTime? lastUpdateTime;

/// Create a copy of IconSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IconSetCopyWith<_IconSet> get copyWith => __$IconSetCopyWithImpl<_IconSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IconSetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IconSet&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.icons, _icons)&&(identical(other.lastUpdateTime, lastUpdateTime) || other.lastUpdateTime == lastUpdateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,url,const DeepCollectionEquality().hash(_icons),lastUpdateTime);
}

@override
String toString() {
    return 'IconSet(id: $id, name: $name, url: $url, icons: $icons, lastUpdateTime: $lastUpdateTime)';
}


}

/// @nodoc
abstract mixin class _$IconSetCopyWith<$Res> implements $IconSetCopyWith<$Res> {
  factory _$IconSetCopyWith(_IconSet value, $Res Function(_IconSet) _then) = __$IconSetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String url, List<IconSetIcon> icons, DateTime? lastUpdateTime
});




}
/// @nodoc
class __$IconSetCopyWithImpl<$Res>
    implements _$IconSetCopyWith<$Res> {
  __$IconSetCopyWithImpl(this._self, this._then);

  final _IconSet _self;
  final $Res Function(_IconSet) _then;

/// Create a copy of IconSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? url = null,Object? icons = null,Object? lastUpdateTime = freezed,}) {
  return _then(_IconSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,icons: null == icons ? _self._icons : icons // ignore: cast_nullable_to_non_nullable
as List<IconSetIcon>,lastUpdateTime: freezed == lastUpdateTime ? _self.lastUpdateTime : lastUpdateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
