const _useDevIdentity = bool.fromEnvironment('APP_DEV');

class AppIdentity {
  static const isDev = _useDevIdentity;

  // [Gamebox] 上游产品名是 Bettbox。这里改成 Gamebox 后，数据目录、TUN、
  // 内核进程名、帮助服务名和管道名都会跟着变成 Gamebox。
  // libclash 里已有的上游文件仍叫 BettboxCore.exe，path.dart 启动前复制成 GameboxCore.exe。
  static const productName = 'Gamebox';
  static const devSuffix = 'Dev';
  static const packageId = 'com.appshub.bettbox';

  static const compactName = isDev ? '$productName$devSuffix' : productName;
  // [Gamebox] 窗口、关于页等用户看到的软件名。上游等于 productName。
  static const displayName = isDev ? 'Gamebox Dev' : 'Gamebox';
  // [Gamebox] 与 windows/CMakeLists.txt 的 BINARY_NAME 一致。
  static const mainExecutableName = 'Gamebox';
  static const coreExecutableName = '${compactName}Core';
  static const dataDirName = compactName;
  static const tunDeviceName = compactName;
}

class WindowsHelperIdentity {
  static const serviceName = '${AppIdentity.compactName}HelperService';
  static const pipeName = '\\\\.\\pipe\\${AppIdentity.compactName}.Helper';
}
