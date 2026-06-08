import 'package:web/web.dart' as web;
import 'silky_scroll_web_helper_interface.dart';

class SilkyScrollWebManager implements SilkyScrollWebManagerInterface {
  SilkyScrollWebManager() {
    _rootHtmlElement = web.window.document.documentElement as web.HTMLElement?;
    _rootBodyElement = web.window.document.body;
  }

  late final web.HTMLElement? _rootHtmlElement;
  late final web.HTMLElement? _rootBodyElement;

  @override
  bool get isWebPlatform => true;

  @override
  void setOverscrollBehaviorX(OverscrollBehaviorX value) {
    _rootHtmlElement?.style.overscrollBehaviorX = value.cssValue;
    _rootBodyElement?.style.overscrollBehaviorX = value.cssValue;
  }
}
