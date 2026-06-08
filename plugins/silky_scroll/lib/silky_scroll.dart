/// Silky Scroll — smooth scrolling for Flutter.
///
/// Provides a [SilkyScroll] widget that wraps scrollable content
/// and delivers smooth, animated scrolling on all platforms.
library;

export 'src/silky_scroll_animator.dart' show kDefaultDecayLogFactor;
export 'src/silky_scroll_widget.dart'
    show SilkyScroll, SilkyScrollWidgetBuilder;
export 'src/silky_scroll_controller.dart'
    show SilkyScrollController, SilkyScrollPosition;
export 'src/blocked_scroll_physics.dart'
    show
        BlockedScrollPhysics,
        DynamicBlockingScrollPhysics,
        ScrollBlockingState;
export 'src/silky_scroll_config.dart'
    show SilkyScrollConfig, EdgeForwardingMode, MouseWheelVerticalDeltaBehavior;
export 'src/silky_scroll_state.dart' show ScrollPhysicsPhase;
export 'src/scroll_delta_sample.dart' show ScrollDeltaSample;
export 'src/scroll_delta_sample_analyzer.dart' show ScrollDeltaSampleAnalyzer;
export 'src/silky_scroll_global_manager.dart' show SilkyScrollGlobalManager;

// Preset widgets
export 'src/presets/silky_list_view.dart' show SilkyListView;
export 'src/presets/silky_grid_view.dart' show SilkyGridView;
export 'src/presets/silky_custom_scroll_view.dart' show SilkyCustomScrollView;
export 'src/presets/silky_single_child_scroll_view.dart'
    show SilkySingleChildScrollView;
