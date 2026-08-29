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

import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import { AbilityPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import HashMap from '@ohos.util.HashMap';


import bundleManager from '@ohos.bundle.bundleManager'
let bundleFlags =  bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO

const TAG:string ="PackageInfoPlugin"

const CHANNEL_NAME = "dev.fluttercommunity.plus/package_info";
export class PackageInfoPlugin implements FlutterPlugin,MethodCallHandler{


  getUniqueClassName(): string {
    return "PackageInfoPlugin";
  }


  private methodChannel: MethodChannel | null = null;

  private applicationContext: Context | null = null;

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG,'onAttachedToEngine packageInfo plugin')
    this.applicationContext =binding.getApplicationContext();
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.methodChannel.setMethodCallHandler(this);

  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG,'onDetachedFromEngine packageInfo plugin')
    this.applicationContext = null;
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    Log.d(TAG,'onMethodCall packageInfo plugin1')
    try {
             if (call.method == "getAll") {

               const bundleManage = bundleManager.getBundleInfoForSelfSync(bundleFlags);
               const appInfo = bundleManage.appInfo;

               const infoMap = new Map<string,string>();
               const buildSignature = bundleManage.signatureInfo.fingerprint;
               const appName = this.applicationContext?.resourceManager.getStringSync(appInfo.labelId) ?? '';
               infoMap.set("appName", appName);
               Log.d(TAG,'onMethodCall packageInfo plugin appName '+ appName);
               infoMap.set("packageName",bundleManage.name);
               Log.d(TAG,'onMethodCall packageInfo plugin packageName '+bundleManage.name)
               infoMap.set("version",bundleManage.versionName);
               Log.d(TAG,'onMethodCall packageInfo plugin version '+bundleManage.versionName)
               infoMap.set("buildNumber",bundleManage.versionCode.toString());
               Log.d(TAG,'onMethodCall packageInfo plugin buildNumber '+bundleManage.versionCode.toString())
               if (buildSignature != null){
                 infoMap.set("buildSignature",buildSignature);
                 Log.d(TAG,'onMethodCall packageInfo plugin buildSignature '+buildSignature)
               }
              infoMap.set("installerStore","");

               result.success(infoMap);
            } else {
               result.notImplemented()
             }
    } catch(err){
      result.error("Name not found", err.message, null)
    }
  }

}
