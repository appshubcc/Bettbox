// ignore_for_file: invalid_annotation_target

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/node.freezed.dart';
part 'generated/node.g.dart';

@freezed
abstract class NodeBinding with _$NodeBinding {
  const factory NodeBinding({
    String? front,
    @Default([]) List<String> groups,
    @Default(false) bool all,
  }) = _NodeBinding;

  factory NodeBinding.fromJson(Map<String, Object?> json) =>
      _$NodeBindingFromJson(json);
}

@freezed
abstract class ProxyNode with _$ProxyNode {
  const factory ProxyNode({
    required String id,
    required Map<String, dynamic> proxy,
    @Default(true) bool enable,
    @JsonKey(unknownEnumValue: NodeRole.landing)
    @Default(NodeRole.landing)
    NodeRole role,
    @Default(true) bool managedEnable,
    @Default(NodeBinding(all: true)) NodeBinding managed,
    @Default({}) Map<String, NodeBinding> bindings,
    String? warpId,
    String? warpToken,
  }) = _ProxyNode;

  static ProxyNode fromImport(Map<String, dynamic> proxy, Set<String> names) {
    final id = utils.uuidV4;
    final imported = _withUniqueName(proxy, names);
    final type = imported['type']?.toString().toLowerCase();
    if (meshNodeTypes.contains(type)) {
      imported.putIfAbsent('state-dir', () => 'nodes/$type/$id');
    }
    return ProxyNode(id: id, proxy: imported);
  }

  factory ProxyNode.fromJson(Map<String, Object?> json) =>
      _$ProxyNodeFromJson(json);
}

const meshNodeTypes = {'easytier', 'tailscale', 'zerotier'};

Map<String, dynamic> _withUniqueName(
  Map<String, dynamic> proxy,
  Set<String> names,
) {
  final base = proxy['name']?.toString() ?? '';
  var name = base;
  for (var index = 2; !names.add(name); index++) {
    name = '$base $index';
  }
  return {...proxy, 'name': name};
}

extension ProxyNodeExt on ProxyNode {
  ProxyNode withUpdatedProxy(Map<String, dynamic> proxy, Set<String> names) =>
      copyWith(proxy: _withUniqueName(proxy, names));

  String get name => this.proxy['name']?.toString() ?? id;

  String get type => this.proxy['type']?.toString() ?? '';

  String get typeLabel => type.toUpperCase();

  bool get isLanding => role == NodeRole.landing;

  bool get isMesh => meshNodeTypes.contains(type.toLowerCase());

  NodeBinding? bindingOf(String profileId, {required bool managed}) {
    if (!managed) return bindings[profileId];
    return managedEnable ? this.managed : null;
  }

  bool activeOf(String profileId, {required bool managed}) =>
      enable && bindingOf(profileId, managed: managed) != null;

  Map<String, dynamic>? patchOf(String profileId, {required bool managed}) {
    final binding = bindingOf(profileId, managed: managed);
    if (!enable || binding == null) return null;
    final all = managed && binding.all;
    return {
      'proxy': this.proxy,
      'dialer': isLanding ? binding.front ?? '' : '',
      'groups': all
          ? [managedDefaultGroup, managedManualGroup]
          : binding.groups,
      if (all) 'beside': managedDefaultGroup,
      if (all && !isLanding) 'regions': true,
      if (isLanding) 'landing': true,
    };
  }
}

extension ProxyNodesExt on List<ProxyNode> {
  List<Map<String, dynamic>> patchOf(
    String profileId, {
    required bool managed,
  }) => [for (final node in this) ?node.patchOf(profileId, managed: managed)];

  List<String> get regionNodeNames => [
    for (final node in this)
      if (node.enable &&
          node.managedEnable &&
          node.managed.all &&
          !node.isLanding)
        node.name,
  ];
}
