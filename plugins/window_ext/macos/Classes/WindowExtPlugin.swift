import Cocoa
import FlutterMacOS

public class WindowExtPlugin: NSObject, FlutterPlugin {
    public static var instance:WindowExtPlugin?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window_ext", binaryMessenger: registrar.messenger)
        instance = WindowExtPlugin(registrar, channel)
        registrar.addMethodCallDelegate(instance!, channel: channel)
    }
    
    private var registrar: FlutterPluginRegistrar!
    private var channel: FlutterMethodChannel!
    
    public init(_ registrar: FlutterPluginRegistrar, _ channel: FlutterMethodChannel) {
        super.init()
        self.registrar = registrar
        self.channel = channel
    }
    
    public func handleShouldTerminate(){
        channel.invokeMethod("shouldTerminate", arguments: nil)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setDockIconVisible":
            let visible: Bool? = {
                if let b = call.arguments as? Bool { return b }
                if let n = call.arguments as? NSNumber { return n.boolValue }
                return nil
            }()
            guard let visible = visible else {
                result(FlutterError(code: "invalid_arguments", message: "Expected a bool argument", details: nil))
                return
            }
            // setActivationPolicy 必须在主线程调用，Flutter 引擎已在主线程回调，此处再做一次主线程派发以兜底。
            if Thread.isMainThread {
                setDockIconVisible(visible)
                result(nil)
            } else {
                DispatchQueue.main.async {
                    self.setDockIconVisible(visible)
                    result(nil)
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setDockIconVisible(_ visible: Bool) {
        if visible {
            NSApp.setActivationPolicy(.regular)
            // 从 accessory 切回 regular 时，窗口可能仍处于隐藏状态，主动前置以避免“Dock 出现但窗口不出现”。
            for window in NSApp.windows {
                window.makeKeyAndOrderFront(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
