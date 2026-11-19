// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NodeBinding {

 String? get front; List<String> get groups; bool get all;
/// Create a copy of NodeBinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NodeBindingCopyWith<NodeBinding> get copyWith => _$NodeBindingCopyWithImpl<NodeBinding>(this as NodeBinding, _$identity);

  /// Serializes this NodeBinding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NodeBinding;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NodeBinding&&(identical(other.front, _this.front) || other.front == _this.front)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&(identical(other.all, _this.all) || other.all == _this.all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NodeBinding;
  return Object.hash(runtimeType,_this.front,const DeepCollectionEquality().hash(_this.groups),_this.all);
}

@override
String toString() {
  final _this = this as NodeBinding;
  return 'NodeBinding(front: ${_this.front}, groups: ${_this.groups}, all: ${_this.all})';
}


}

/// @nodoc
abstract mixin class $NodeBindingCopyWith<$Res>  {
  factory $NodeBindingCopyWith(NodeBinding value, $Res Function(NodeBinding) _then) = _$NodeBindingCopyWithImpl;
@useResult
$Res call({
 String? front, List<String> groups, bool all
});




}
/// @nodoc
class _$NodeBindingCopyWithImpl<$Res>
    implements $NodeBindingCopyWith<$Res> {
  _$NodeBindingCopyWithImpl(this._self, this._then);

  final NodeBinding _self;
  final $Res Function(NodeBinding) _then;

/// Create a copy of NodeBinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? front = freezed,Object? groups = null,Object? all = null,}) {
  return _then(NodeBinding(
front: freezed == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as String?,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NodeBinding].
extension NodeBindingPatterns on NodeBinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NodeBinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NodeBinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NodeBinding value)  $default,){
final _that = this;
switch (_that) {
case _NodeBinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NodeBinding value)?  $default,){
final _that = this;
switch (_that) {
case _NodeBinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? front,  List<String> groups,  bool all)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NodeBinding() when $default != null:
return $default(_that.front,_that.groups,_that.all);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? front,  List<String> groups,  bool all)  $default,) {final _that = this;
switch (_that) {
case _NodeBinding():
return $default(_that.front,_that.groups,_that.all);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? front,  List<String> groups,  bool all)?  $default,) {final _that = this;
switch (_that) {
case _NodeBinding() when $default != null:
return $default(_that.front,_that.groups,_that.all);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NodeBinding implements NodeBinding {
  const _NodeBinding({this.front,  List<String> groups = const [], this.all = false}): _groups = groups;
  factory _NodeBinding.fromJson(Map<String, dynamic> json) => _$NodeBindingFromJson(json);

@override final  String? front;
 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  bool all;

/// Create a copy of NodeBinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NodeBindingCopyWith<_NodeBinding> get copyWith => __$NodeBindingCopyWithImpl<_NodeBinding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NodeBindingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NodeBinding&&(identical(other.front, front) || other.front == front)&&const DeepCollectionEquality().equals(other.groups, _groups)&&(identical(other.all, all) || other.all == all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,front,const DeepCollectionEquality().hash(_groups),all);
}

@override
String toString() {
    return 'NodeBinding(front: $front, groups: $groups, all: $all)';
}


}

/// @nodoc
abstract mixin class _$NodeBindingCopyWith<$Res> implements $NodeBindingCopyWith<$Res> {
  factory _$NodeBindingCopyWith(_NodeBinding value, $Res Function(_NodeBinding) _then) = __$NodeBindingCopyWithImpl;
@override @useResult
$Res call({
 String? front, List<String> groups, bool all
});




}
/// @nodoc
class __$NodeBindingCopyWithImpl<$Res>
    implements _$NodeBindingCopyWith<$Res> {
  __$NodeBindingCopyWithImpl(this._self, this._then);

  final _NodeBinding _self;
  final $Res Function(_NodeBinding) _then;

/// Create a copy of NodeBinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? front = freezed,Object? groups = null,Object? all = null,}) {
  return _then(_NodeBinding(
front: freezed == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as String?,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ProxyNode {

 String get id; Map<String, dynamic> get proxy; bool get enable;@JsonKey(unknownEnumValue: NodeRole.landing) NodeRole get role; bool get managedEnable; NodeBinding get managed; Map<String, NodeBinding> get bindings; String? get warpId; String? get warpToken;
/// Create a copy of ProxyNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyNodeCopyWith<ProxyNode> get copyWith => _$ProxyNodeCopyWithImpl<ProxyNode>(this as ProxyNode, _$identity);

  /// Serializes this ProxyNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxyNode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyNode&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.proxy, _this.proxy)&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.managedEnable, _this.managedEnable) || other.managedEnable == _this.managedEnable)&&(identical(other.managed, _this.managed) || other.managed == _this.managed)&&const DeepCollectionEquality().equals(other.bindings, _this.bindings)&&(identical(other.warpId, _this.warpId) || other.warpId == _this.warpId)&&(identical(other.warpToken, _this.warpToken) || other.warpToken == _this.warpToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxyNode;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.proxy),_this.enable,_this.role,_this.managedEnable,_this.managed,const DeepCollectionEquality().hash(_this.bindings),_this.warpId,_this.warpToken);
}

@override
String toString() {
  final _this = this as ProxyNode;
  return 'ProxyNode(id: ${_this.id}, proxy: ${_this.proxy}, enable: ${_this.enable}, role: ${_this.role}, managedEnable: ${_this.managedEnable}, managed: ${_this.managed}, bindings: ${_this.bindings}, warpId: ${_this.warpId}, warpToken: ${_this.warpToken})';
}


}

/// @nodoc
abstract mixin class $ProxyNodeCopyWith<$Res>  {
  factory $ProxyNodeCopyWith(ProxyNode value, $Res Function(ProxyNode) _then) = _$ProxyNodeCopyWithImpl;
@useResult
$Res call({
 String id, Map<String, dynamic> proxy, bool enable,@JsonKey(unknownEnumValue: NodeRole.landing) NodeRole role, bool managedEnable, NodeBinding managed, Map<String, NodeBinding> bindings, String? warpId, String? warpToken
});


$NodeBindingCopyWith<$Res> get managed;

}
/// @nodoc
class _$ProxyNodeCopyWithImpl<$Res>
    implements $ProxyNodeCopyWith<$Res> {
  _$ProxyNodeCopyWithImpl(this._self, this._then);

  final ProxyNode _self;
  final $Res Function(ProxyNode) _then;

/// Create a copy of ProxyNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proxy = null,Object? enable = null,Object? role = null,Object? managedEnable = null,Object? managed = null,Object? bindings = null,Object? warpId = freezed,Object? warpToken = freezed,}) {
  return _then(ProxyNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proxy: null == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as NodeRole,managedEnable: null == managedEnable ? _self.managedEnable : managedEnable // ignore: cast_nullable_to_non_nullable
as bool,managed: null == managed ? _self.managed : managed // ignore: cast_nullable_to_non_nullable
as NodeBinding,bindings: null == bindings ? _self.bindings : bindings // ignore: cast_nullable_to_non_nullable
as Map<String, NodeBinding>,warpId: freezed == warpId ? _self.warpId : warpId // ignore: cast_nullable_to_non_nullable
as String?,warpToken: freezed == warpToken ? _self.warpToken : warpToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ProxyNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NodeBindingCopyWith<$Res> get managed {
  
  return $NodeBindingCopyWith<$Res>(_self.managed, (value) {
    return _then(_self.copyWith(managed: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProxyNode].
extension ProxyNodePatterns on ProxyNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyNode value)  $default,){
final _that = this;
switch (_that) {
case _ProxyNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyNode value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Map<String, dynamic> proxy,  bool enable, @JsonKey(unknownEnumValue: NodeRole.landing)  NodeRole role,  bool managedEnable,  NodeBinding managed,  Map<String, NodeBinding> bindings,  String? warpId,  String? warpToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyNode() when $default != null:
return $default(_that.id,_that.proxy,_that.enable,_that.role,_that.managedEnable,_that.managed,_that.bindings,_that.warpId,_that.warpToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Map<String, dynamic> proxy,  bool enable, @JsonKey(unknownEnumValue: NodeRole.landing)  NodeRole role,  bool managedEnable,  NodeBinding managed,  Map<String, NodeBinding> bindings,  String? warpId,  String? warpToken)  $default,) {final _that = this;
switch (_that) {
case _ProxyNode():
return $default(_that.id,_that.proxy,_that.enable,_that.role,_that.managedEnable,_that.managed,_that.bindings,_that.warpId,_that.warpToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Map<String, dynamic> proxy,  bool enable, @JsonKey(unknownEnumValue: NodeRole.landing)  NodeRole role,  bool managedEnable,  NodeBinding managed,  Map<String, NodeBinding> bindings,  String? warpId,  String? warpToken)?  $default,) {final _that = this;
switch (_that) {
case _ProxyNode() when $default != null:
return $default(_that.id,_that.proxy,_that.enable,_that.role,_that.managedEnable,_that.managed,_that.bindings,_that.warpId,_that.warpToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxyNode implements ProxyNode {
  const _ProxyNode({required this.id, required  Map<String, dynamic> proxy, this.enable = true, @JsonKey(unknownEnumValue: NodeRole.landing) this.role = NodeRole.landing, this.managedEnable = true, this.managed = const NodeBinding(all: true),  Map<String, NodeBinding> bindings = const {}, this.warpId, this.warpToken}): _proxy = proxy,_bindings = bindings;
  factory _ProxyNode.fromJson(Map<String, dynamic> json) => _$ProxyNodeFromJson(json);

@override final  String id;
 final  Map<String, dynamic> _proxy;
@override Map<String, dynamic> get proxy {
  if (_proxy is EqualUnmodifiableMapView) return _proxy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_proxy);
}

@override@JsonKey() final  bool enable;
@override@JsonKey(unknownEnumValue: NodeRole.landing) final  NodeRole role;
@override@JsonKey() final  bool managedEnable;
@override@JsonKey() final  NodeBinding managed;
 final  Map<String, NodeBinding> _bindings;
@override@JsonKey() Map<String, NodeBinding> get bindings {
  if (_bindings is EqualUnmodifiableMapView) return _bindings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bindings);
}

@override final  String? warpId;
@override final  String? warpToken;

/// Create a copy of ProxyNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyNodeCopyWith<_ProxyNode> get copyWith => __$ProxyNodeCopyWithImpl<_ProxyNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyNodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyNode&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.proxy, _proxy)&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.role, role) || other.role == role)&&(identical(other.managedEnable, managedEnable) || other.managedEnable == managedEnable)&&(identical(other.managed, managed) || other.managed == managed)&&const DeepCollectionEquality().equals(other.bindings, _bindings)&&(identical(other.warpId, warpId) || other.warpId == warpId)&&(identical(other.warpToken, warpToken) || other.warpToken == warpToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_proxy),enable,role,managedEnable,managed,const DeepCollectionEquality().hash(_bindings),warpId,warpToken);
}

@override
String toString() {
    return 'ProxyNode(id: $id, proxy: $proxy, enable: $enable, role: $role, managedEnable: $managedEnable, managed: $managed, bindings: $bindings, warpId: $warpId, warpToken: $warpToken)';
}


}

/// @nodoc
abstract mixin class _$ProxyNodeCopyWith<$Res> implements $ProxyNodeCopyWith<$Res> {
  factory _$ProxyNodeCopyWith(_ProxyNode value, $Res Function(_ProxyNode) _then) = __$ProxyNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, Map<String, dynamic> proxy, bool enable,@JsonKey(unknownEnumValue: NodeRole.landing) NodeRole role, bool managedEnable, NodeBinding managed, Map<String, NodeBinding> bindings, String? warpId, String? warpToken
});


@override $NodeBindingCopyWith<$Res> get managed;

}
/// @nodoc
class __$ProxyNodeCopyWithImpl<$Res>
    implements _$ProxyNodeCopyWith<$Res> {
  __$ProxyNodeCopyWithImpl(this._self, this._then);

  final _ProxyNode _self;
  final $Res Function(_ProxyNode) _then;

/// Create a copy of ProxyNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proxy = null,Object? enable = null,Object? role = null,Object? managedEnable = null,Object? managed = null,Object? bindings = null,Object? warpId = freezed,Object? warpToken = freezed,}) {
  return _then(_ProxyNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proxy: null == proxy ? _self._proxy : proxy // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as NodeRole,managedEnable: null == managedEnable ? _self.managedEnable : managedEnable // ignore: cast_nullable_to_non_nullable
as bool,managed: null == managed ? _self.managed : managed // ignore: cast_nullable_to_non_nullable
as NodeBinding,bindings: null == bindings ? _self._bindings : bindings // ignore: cast_nullable_to_non_nullable
as Map<String, NodeBinding>,warpId: freezed == warpId ? _self.warpId : warpId // ignore: cast_nullable_to_non_nullable
as String?,warpToken: freezed == warpToken ? _self.warpToken : warpToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProxyNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NodeBindingCopyWith<$Res> get managed {
  
  return $NodeBindingCopyWith<$Res>(_self.managed, (value) {
    return _then(_self.copyWith(managed: value));
  });
}
}

// dart format on
