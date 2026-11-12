import 'dart:async';

import 'package:bett_box/plugins/tile.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';

class TileManager extends StatefulWidget {
  final Widget child;

  const TileManager({super.key, required this.child});

  @override
  State<TileManager> createState() => _TileContainerState();
}

class _TileContainerState extends State<TileManager> with TileListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void onStart() {
    globalState.appController.updateStatus(true);
    super.onStart();
  }

  @override
  Future<void> onStop() async {
    unawaited(globalState.appController.updateStatus(false));
    super.onStop();
  }

  @override
  void initState() {
    super.initState();
    tile?.addListener(this);
  }

  @override
  void dispose() {
    tile?.removeListener(this);
    super.dispose();
  }
}
