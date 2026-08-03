import Cocoa
import FlutterMacOS
import window_manager
import LaunchAtLogin

class MainFlutterWindow: NSWindow {
    private var appMethodChannel: FlutterMethodChannel?
    private var systemDidWakeObserver: NSObjectProtocol?
    
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
        setupSystemWakeNotification()
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        // Load and apply saved icon preference
        if loadIconPreference() {
            setDockIcon(useLightIcon: true)
        }
        
        super.awakeFromNib()
    }

    deinit {
        if let observer = systemDidWakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
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
                   let useLightIcon = arguments["useLightIcon"] as? Bool {
                    let success = self.setDockIcon(useLightIcon: useLightIcon)
                    result(success)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing useLightIcon argument", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func setupSystemWakeNotification() {
        systemDidWakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appMethodChannel?.invokeMethod("systemDidWake", arguments: nil)
        }
    }
    
    // MARK: - Icon Management
    
    private func setDockIcon(useLightIcon: Bool) -> Bool {
        let iconName = useLightIcon ? "icon_light" : "icon"
        
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
        saveIconPreference(useLightIcon: useLightIcon)
        
        return true
    }
    
    private func saveIconPreference(useLightIcon: Bool) {
        UserDefaults.standard.set(useLightIcon, forKey: "UseLightIcon")
        UserDefaults.standard.synchronize()
    }
    
    private func loadIconPreference() -> Bool {
        return UserDefaults.standard.bool(forKey: "UseLightIcon")
    }
}
