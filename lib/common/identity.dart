const _useDevIdentity = bool.fromEnvironment('APP_DEV');
const _useLiteBuild = bool.fromEnvironment('APP_LITE');

class AppIdentity {
  static const isDev = _useDevIdentity;
  static const isLite = _useLiteBuild;

  static const productName = 'Bettbox';
  static const devSuffix = 'Dev';
  static const packageId = 'com.appshub.bettbox';

  static const compactName = isDev ? '$productName$devSuffix' : productName;
  static const displayName = isDev ? '$productName Dev' : productName;
  static const mainExecutableName = productName;
  static const coreExecutableName = '${compactName}Core';
  static const dataDirName = compactName;
  static const tunDeviceName = compactName;
}

class WindowsHelperIdentity {
  static const serviceName = '${AppIdentity.compactName}HelperService';
  static const pipeName = '\\\\.\\pipe\\${AppIdentity.compactName}.Helper';
}
