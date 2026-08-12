import Cocoa
import FlutterMacOS
import window_manager
import LaunchAtLogin

class MainFlutterWindow: NSWindow {
    private var appMethodChannel: FlutterMethodChannel?
    
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        FlutterMethodChannel(
            name: "launch_at_startup", binaryMessenger: flutterViewController.engine.binaryMessenger
        )
        .setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "launchAtStartupIsEnabled":
                result(LaunchAtLogin.isEnabled)
            case "launchAtStartupSetEnabled":
                if let arguments = call.arguments as? [String: Any] {
                    LaunchAtLogin.isEnabled = arguments["setEnabledValue"] as! Bool
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        // Setup app method channel
        setupAppMethodChannel(flutterViewController: flutterViewController)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        // Load and apply saved icon preference
        if loadIconPreference() {
            setDockIcon(useDarkIcon: true)
        }
        
        super.awakeFromNib()
    }
    
    override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
        super.order(place, relativeTo: otherWin)
        hiddenWindowAtLaunch()
    }
    
    // MARK: - App Method Channel
    
    private func setupAppMethodChannel(flutterViewController: FlutterViewController) {
        appMethodChannel = FlutterMethodChannel(
            name: "app",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )
        
        appMethodChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "Window unavailable", details: nil))
                return
            }
            
            switch call.method {
            case "setLauncherIcon":
                if let arguments = call.arguments as? [String: Any],
                   let useDarkIcon = arguments["useDarkIcon"] as? Bool {
                    let success = self.setDockIcon(useDarkIcon: useDarkIcon)
                    result(success)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing useDarkIcon argument", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - Icon Management
    
    private func setDockIcon(useDarkIcon: Bool) -> Bool {
        let iconName = useDarkIcon ? "icon_black_macOS" : "icon_light_macOS"
        
        // Load icon from app bundle
        guard let iconPath = Bundle.main.path(forResource: iconName, ofType: "png", inDirectory: "data/flutter_assets/assets/images"),
              let image = NSImage(contentsOfFile: iconPath) else {
            // Fallback to default app icon if load fails
            if let appIcon = NSImage(named: "AppIcon") {
                NSApp.applicationIconImage = appIcon
            }
            return false
        }
        
        // Set Dock icon
        NSApp.applicationIconImage = image
        
        // Save preference
        saveIconPreference(useDarkIcon: useDarkIcon)
        
        return true
    }
    
    private func saveIconPreference(useDarkIcon: Bool) {
        UserDefaults.standard.set(useDarkIcon, forKey: "UseDarkIcon")
        UserDefaults.standard.synchronize()
    }
    
    private func loadIconPreference() -> Bool {
        return UserDefaults.standard.bool(forKey: "UseDarkIcon")
    }
}
