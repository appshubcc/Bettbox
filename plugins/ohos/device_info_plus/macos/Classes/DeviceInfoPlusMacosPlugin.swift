import Cocoa
import FlutterMacOS

public class DeviceInfoPlusMacosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.fluttercommunity.plus/device_info", binaryMessenger: registrar.messenger)
        let instance = DeviceInfoPlusMacosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDeviceInfo":
            handleDeviceInfo(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleDeviceInfo(result: @escaping FlutterResult)-> Void{
        let computerName = Host.current().localizedName ?? Sysctl.hostName
        let hostName = Sysctl.osType
        let arch = Sysctl.machine
        let model = Sysctl.model
        let kernelVersion = Sysctl.version
        let osRelease = ProcessInfo.processInfo.operatingSystemVersionString
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion;
        let majorVersion = osVersion.majorVersion
        let minorVersion = osVersion.minorVersion
        let patchVersion = osVersion.patchVersion
        let activeCPUs = Sysctl.activeCPUs
        let memorySize = Sysctl.memSize
        let cpuFrequency = Sysctl.cpuFreq
        let guid = SystemUUID.getSystemUUID()

        result([
            "computerName": computerName,
            "hostName": hostName,
            "arch": arch,
            "model": model,
            "kernelVersion": kernelVersion,
            "osRelease": osRelease,
            "majorVersion": majorVersion,
            "minorVersion": minorVersion,
            "patchVersion": patchVersion,
            "activeCPUs": activeCPUs,
            "memorySize": memorySize,
            "cpuFrequency": cpuFrequency,
            "systemGUID": guid
        ] as [String: Any?])
    }
}
