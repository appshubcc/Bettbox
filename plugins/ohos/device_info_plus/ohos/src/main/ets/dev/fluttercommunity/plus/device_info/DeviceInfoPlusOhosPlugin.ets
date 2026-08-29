/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import {
  AbilityPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import deviceInfo from '@ohos.deviceInfo';

const TAG = "DeviceInfoPlusOhosPlugin";
const CHANNEL_NAME = 'dev.fluttercommunity.plus/device_info';

/** DeviceInfoPlusOhosPlugin  */
export default class DeviceInfoPlusOhosPlugin implements FlutterPlugin, AbilityAware, MethodCallHandler {
  private abilityPluginBinding: AbilityPluginBinding | null = null;
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToAbility(binding: AbilityPluginBinding) {
    this.abilityPluginBinding = binding;
    this.channel?.setMethodCallHandler(this);
  }

  onDetachedFromAbility() {
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG, 'onAttachedToEngine local auth')
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    Log.d(TAG, 'onMethodCall step in');
    switch (call.method) {
      case "getDeviceInfo":
        let data: Map<String, ESObject> = new Map();
        data.set('deviceType', deviceInfo.deviceType);
        data.set('manufacture', deviceInfo.manufacture);
        data.set('brand', deviceInfo.brand);
        data.set('marketName', deviceInfo.marketName);
        data.set('productSeries', deviceInfo.productSeries);
        data.set('productModel', deviceInfo.productModel);
        data.set('softwareModel', deviceInfo.softwareModel);
        data.set('hardwareModel', deviceInfo.hardwareModel);
        data.set('hardwareProfile', deviceInfo.hardwareProfile);
        data.set('serial', deviceInfo.serial);
        data.set('bootloaderVersion', deviceInfo.bootloaderVersion);
        data.set('abiList', deviceInfo.abiList);
        data.set('securityPatchTag', deviceInfo.securityPatchTag);
        data.set('displayVersion', deviceInfo.displayVersion);
        data.set('incrementalVersion', deviceInfo.incrementalVersion);
        data.set('osReleaseType', deviceInfo.osReleaseType);
        data.set('osFullName', deviceInfo.osFullName);
        data.set('majorVersion', deviceInfo.majorVersion);
        data.set('seniorVersion', deviceInfo.seniorVersion);
        data.set('featureVersion', deviceInfo.featureVersion);
        data.set('buildVersion', deviceInfo.buildVersion);
        data.set('sdkApiVersion', deviceInfo.sdkApiVersion);
        data.set('firstApiVersion', deviceInfo.firstApiVersion);
        data.set('versionId', deviceInfo.versionId);
        data.set('buildType', deviceInfo.buildType);
        data.set('buildUser', deviceInfo.buildUser);
        data.set('buildHost', deviceInfo.buildHost);
        data.set('buildTime', deviceInfo.buildTime);
        data.set('buildRootHash', deviceInfo.buildRootHash);
        data.set('udid', deviceInfo.udid);
        data.set('distributionOSName', deviceInfo.distributionOSName);
        data.set('distributionOSVersion', deviceInfo.distributionOSVersion);
        data.set('distributionOSApiVersion', deviceInfo.distributionOSApiVersion);
        data.set('distributionOSReleaseType', deviceInfo.distributionOSReleaseType);
        data.set('ODID', deviceInfo.ODID);
        result.success(data);
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
