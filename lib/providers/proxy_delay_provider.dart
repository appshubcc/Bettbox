import 'dart:async';
import 'dart:convert';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/proxy_delay_provider.g.dart';

enum DelayTestState { idle, testing, done }

/// 每个代理组的完整状态，delays 和 testState 都由 Riverpod 统一管理，
/// 不再使用实例变量，避免 Riverpod rebuild 时数据丢失。
class GroupDelayState {
  final DelayTestState testState;
  final Map<String, int> delays;

  const GroupDelayState({this.testState = DelayTestState.idle, this.delays = const {}});

  GroupDelayState copyWith({DelayTestState? testState, Map<String, int>? delays}) {
    return GroupDelayState(testState: testState ?? this.testState, delays: delays ?? this.delays);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupDelayState && testState == other.testState && _mapEquals(delays, other.delays);

  @override
  int get hashCode => testState.hashCode ^ delays.hashCode;

  static bool _mapEquals(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (a[k] != b[k]) return false;
    }
    return true;
  }
}

@riverpod
class ProxyDelayNotifier extends _$ProxyDelayNotifier {
  @override
  Map<String, GroupDelayState> build() => {};

  DelayTestState getGroupState(String groupName) => state[groupName]?.testState ?? DelayTestState.idle;

  /// 返回该组所有节点的延迟 map，key=节点名，value=ms（-1 表示 timeout）
  Map<String, int> getGroupDelays(String groupName) => state[groupName]?.delays ?? {};

  bool _isDirectNode(Map<String, dynamic>? nodeInfo, String nodeName) {
    final type = (nodeInfo?['type'] as String? ?? '').toLowerCase();
    return type == 'direct' || nodeName.toUpperCase() == 'DIRECT';
  }

  // 仅对 Selector 和 URLTest 都支持手动触发后自动切换，在测速完成后自动切换到延迟最低的节点。
  // Fallback / LoadBalance / Relay 仍由内核自己管理
  Future<void> _autoSelectBestNode(String groupName, Map<String, int> delays, Map<String, dynamic> proxiesRaw) async {
    final groupInfo = proxiesRaw[groupName] as Map<String, dynamic>?;
    final groupType = groupInfo?['type'] as String? ?? '';

    const autoSelectTypes = {'Selector', 'URLTest'};
    if (!autoSelectTypes.contains(groupType)) return;

    final validEntries = delays.entries.where((e) => !e.key.toUpperCase().contains('DIRECT') && e.value > 0).toList();

    if (validEntries.isEmpty) return;

    validEntries.sort((a, b) => a.value.compareTo(b.value));
    final bestNode = validEntries.first.key;
    final bestMs = validEntries.first.value;

    final c = globalState.appController;
    c.updateCurrentSelectedMap(groupName, bestNode);
    await c.changeProxy(groupName: groupName, proxyName: bestNode);
    commonPrint.log('autoSelect[$groupName/${groupType}] → $bestNode (${bestMs}ms)');
  }

  Future<void> testGroupDelay(String groupName) async {
    // 防重入：该组正在测速时直接返回
    if (state[groupName]?.testState == DelayTestState.testing) return;

    // 保留旧延迟数据，只更新 testState → testing
    // state 变化会触发 tray_manager 监听器立即刷新菜单（"测速中..."）
    state = Map.of(state)
      ..[groupName] = GroupDelayState(testState: DelayTestState.testing, delays: state[groupName]?.delays ?? {});

    Map<String, int> newDelays = {};
    // 提升到方法级，供 finally 块复用，避免二次网络请求
    Map<String, dynamic> proxiesRaw = {};

    try {
      final raw = await clashService?.getProxies() ?? {};
      proxiesRaw = Map<String, dynamic>.from(raw);
      final group = proxiesRaw[groupName] as Map<String, dynamic>?;
      if (group == null) return;

      final members = (group['all'] as List?)?.cast<String>() ?? [];

      final proxyTestUrl = (group['testUrl'] as String?)?.isNotEmpty == true
          ? group['testUrl'] as String
          : 'https://www.gstatic.com/generate_204';

      const directTestUrl = 'http://connectivitycheck.platform.hicloud.com/generate_204';

      final entries = await Future.wait(
        members.map((node) async {
          final nodeInfo = proxiesRaw[node] as Map<String, dynamic>?;
          final nodeType = nodeInfo?['type'] as String? ?? '';

          final isGroup = const {'Selector', 'Fallback', 'URLTest', 'LoadBalance', 'Relay'}.contains(nodeType);

          // 子节点是组类型（如 Fallback / URLTest）：测其当前激活节点
          if (isGroup) {
            final now = nodeInfo?['now'] as String?;
            if (now != null) {
              final nowInfo = proxiesRaw[now] as Map<String, dynamic>?;
              final url = _isDirectNode(nowInfo, now) ? directTestUrl : proxyTestUrl;
              final raw = await clashService?.asyncTestDelay(url, now) ?? '';
              final decoded = jsonDecode(raw) as Map<String, dynamic>;
              final ms = (decoded['value'] as num?)?.toInt() ?? -1;
              return MapEntry(node, ms);
            }
            return MapEntry(node, -1);
          }

          // 普通叶子节点
          final url = _isDirectNode(nodeInfo, node) ? directTestUrl : proxyTestUrl;
          final raw = await clashService?.asyncTestDelay(url, node) ?? '';
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final ms = (decoded['value'] as num?)?.toInt() ?? -1;
          return MapEntry(node, ms);
        }),
      );

      newDelays = Map.fromEntries(entries);
    } catch (e) {
      commonPrint.log('testGroupDelay[$groupName] error: $e');
      // 异常时保留旧延迟数据，避免数据清空
      newDelays = state[groupName]?.delays ?? {};
    } finally {
      // 先切换最优节点，确保 selectedMap 先更新
      if (newDelays.isNotEmpty && proxiesRaw.isNotEmpty) {
        await _autoSelectBestNode(groupName, newDelays, proxiesRaw);
      }
      // 再更新延迟 state → done，触发 tray 刷新
      // 此时 selectedMap 已经是新节点，父菜单能正确显示 "组名 / 最优节点"
      state = Map.of(state)..[groupName] = GroupDelayState(testState: DelayTestState.done, delays: newDelays);
    }
  }
}
