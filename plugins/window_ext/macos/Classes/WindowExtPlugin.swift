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
            guard let visible = (call.arguments as? NSNumber)?.boolValue else {
                result(FlutterError(code: "invalid_arguments", message: "Expected a bool argument", details: nil))
                return
            }
            setDockIconVisible(visible)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setDockIconVisible(_ visible: Bool) {
        if visible {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
