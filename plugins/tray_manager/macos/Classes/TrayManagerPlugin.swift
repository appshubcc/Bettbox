import Cocoa
import FlutterMacOS

let kEventOnTrayIconMouseDown = "onTrayIconMouseDown"
let kEventOnTrayIconMouseUp = "onTrayIconMouseUp"
let kEventOnTrayIconRightMouseDown = "onTrayIconRightMouseDown"
let kEventOnTrayIconRightMouseUp = "onTrayIconRightMouseUp"
let kEventOnTrayMenuItemClick = "onTrayMenuItemClick"

extension NSRect {
    var topLeft: CGPoint {
        set {
            let screenFrameRect = NSScreen.main!.frame
            origin.x = newValue.x
            origin.y = screenFrameRect.height - newValue.y - size.height
        }
        get {
            let screenFrameRect = NSScreen.main!.frame
            return CGPoint(x: origin.x, y: screenFrameRect.height - origin.y - size.height)
        }
    }
}

public class TrayManagerPlugin: NSObject, FlutterPlugin, NSMenuDelegate {
    static let instance = TrayManagerPlugin()
    
    var channel: FlutterMethodChannel!
    
    var trayIcon: TrayIcon?
    var trayMenu: TrayMenu?
    //    var statusItem: NSStatusItem = NSStatusItem();
    
    var _inited: Bool = false;
    var _isMenuOpen: Bool = false
    var _shouldReopenMenu: Bool = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tray_manager", binaryMessenger: registrar.messenger)
        let instance = TrayManagerPlugin.instance
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "destroy":
            destroy(call, result: result)
            break
        case "getBounds":
            getBounds(call, result: result)
            break
        case "setIcon":
            setIcon(call, result: result)
            break
        case "setIconPosition":
            setIconPosition(call, result: result)
            break
        case "setToolTip":
            setToolTip(call, result: result)
            break
        case "setTitle":
            setTitle(call, result: result)
            break
        case "setSpeedTitle":
            setSpeedTitle(call, result: result)
            break
        case "setActive":
            setActive(call, result: result)
            break
        case "clearSpeedTitle":
            clearSpeedTitle(call, result: result)
            break
        case "setContextMenu":
            setContextMenu(call, result: result)
            break
        case "popUpContextMenu":
            popUpContextMenu(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    //    private func _init() {
    //        statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    //        if let button = statusItem.button {
    //            button.action = #selector(self.statusItemButtonClicked(sender:))
    //            button.target = self
    //            button.sendAction(on: [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp])
    //            _inited = true
    //        }
    //    }
    
    @objc func statusItemButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        var methodName: String?
        
        switch event.type {
        case NSEvent.EventType.leftMouseDown:
            methodName = kEventOnTrayIconMouseDown
            break
        case NSEvent.EventType.leftMouseUp:
            methodName = kEventOnTrayIconMouseUp
            break
        case NSEvent.EventType.rightMouseDown:
            methodName = kEventOnTrayIconRightMouseDown
            break
        case NSEvent.EventType.rightMouseUp:
            methodName = kEventOnTrayIconRightMouseUp
            break
        default:
            break
        }
        if (methodName != nil) {
            channel.invokeMethod(methodName!, arguments: nil, result: nil)
        }
    }
    
    public func destroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (trayIcon?.statusItem != nil) {
            NSStatusBar.system.removeStatusItem((trayIcon?.statusItem)!)
        }
        if (trayIcon != nil) {
            trayIcon?.removeImage()
            trayIcon = nil
        }
        result(true)
    }
    
    public func getBounds(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let frame = trayIcon?.statusItem?.button?.window?.frame;
        
        if (frame != nil) {
            let resultData: NSDictionary = [
                "x": frame!.topLeft.x,
                "y": frame!.topLeft.y,
                "width": frame!.size.width,
                "height": frame!.size.height,
            ]
            result(resultData)
        } else {
            result(nil)
        }
    }
    
    public func setIcon(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let base64Icon: String =  args["base64Icon"] as! String;
        let isTemplate: Bool =  args["isTemplate"] as! Bool;
        let iconPosition: String =  args["iconPosition"] as! String;
        let iconSize: Int = args["iconSize"] as! Int;
        
        let imageData = Data(base64Encoded: base64Icon, options: .ignoreUnknownCharacters)
        let image = NSImage(data: imageData!)
        image!.size = NSSize(width: iconSize, height: iconSize)
        image!.isTemplate = isTemplate
        
        if (trayIcon == nil) {
            trayIcon = TrayIcon()
            trayIcon?.onTrayIconMouseDown = { () in
                self.channel.invokeMethod(kEventOnTrayIconMouseDown, arguments: nil, result: nil)
            }
            trayIcon?.onTrayIconMouseUp = { () in
                self.channel.invokeMethod(kEventOnTrayIconMouseUp, arguments: nil, result: nil)
            }
            trayIcon?.onTrayIconRightMouseDown = { () in
                self.channel.invokeMethod(kEventOnTrayIconRightMouseDown, arguments: nil, result: nil)
            }
            trayIcon?.onTrayIconRightMouseUp = { () in
                self.channel.invokeMethod(kEventOnTrayIconRightMouseUp, arguments: nil, result: nil)
            }
        }
        
        trayIcon?.setImage(image!, iconPosition)
        
        result(true)
    }
    
    public func setIconPosition(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let iconPosition: String =  args["iconPosition"] as! String;
        
        trayIcon?.setImagePosition(iconPosition)
        
        result(true)
    }
    
    public func setToolTip(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let toolTip: String =  args["toolTip"] as! String;
        
        trayIcon?.setToolTip(toolTip)
        
        result(true)
    }
    
    public func setTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let title: String =  args["title"] as! String;
        
        trayIcon?.setTitle(title)
        
        result(true)
    }

    public func setSpeedTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let upload = (args?["upload"] as? NSNumber)?.uint64Value ?? 0
        let download = (args?["download"] as? NSNumber)?.uint64Value ?? 0
        let active = args?["active"] as? Bool ?? true

        trayIcon?.setSpeedTitle(
            upload: upload,
            download: download,
            active: active
        )

        result(true)
    }

    public func setActive(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let active = args?["active"] as? Bool ?? true
        trayIcon?.setActive(active)
        result(true)
    }

    public func clearSpeedTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        trayIcon?.clearSpeedTitle()
        result(true)
    }
    
    public func setContextMenu(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        
        let keepMenuOpen = args["keepMenuOpen"] as? Bool ?? false
        let shouldKeepOpen = keepMenuOpen && _isMenuOpen
        
        if (shouldKeepOpen && trayMenu != nil) {
            trayMenu?.update(args["menu"] as! [String: Any])
        } else {
            trayMenu = TrayMenu(args["menu"] as! [String: Any])
            trayMenu?.onMenuItemClick = { [weak self] (menuItem: NSMenuItem) in
                guard let strongSelf = self else { return }
                let args: NSDictionary = [
                    "id": menuItem.tag,
                ]
                strongSelf.channel.invokeMethod(kEventOnTrayMenuItemClick, arguments: args, result: nil)
            }
            trayMenu?.delegate = self
        }
        
        result(true)
    }
    
    public func popUpContextMenu(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (trayMenu != nil) {
            trayIcon?.statusItem?.menu = trayMenu
            trayIcon?.statusItem?.button?.performClick(trayIcon)
        }
        result(true)
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        _isMenuOpen = true
        channel.invokeMethod("onMenuOpen", arguments: nil, result: nil)
    }
    
    public func menuDidClose(_ menu: NSMenu) {
        _isMenuOpen = false
        channel.invokeMethod("onMenuClose", arguments: nil, result: nil)
        trayIcon?.statusItem?.menu = nil
    }
}
