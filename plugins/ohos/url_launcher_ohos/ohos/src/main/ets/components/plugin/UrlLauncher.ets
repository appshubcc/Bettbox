// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on UrlLauncher.java originally written by
// Copyright 2013 The Flutter Authors.

import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import BasicMessageChannel, { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import Want from '@ohos.app.ability.Want';
import wantConstant from '@ohos.app.ability.wantConstant';
import fileuri from '@ohos.file.fileuri';
import { FlutterError, UrlLauncherApi, UrlLauncherApiCodec, WebViewOptions, wrapError } from './Messages';
import common from '@ohos.app.ability.common';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import call from '@ohos.telephony.call';
import i18n from '@ohos.i18n';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import router from '@ohos.router'
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'UrlLauncher'

class SendMessageParams {
  telephone: string = '';
  telephoneFormat: string = '';
  contactName: string = '';
}

export class UrlLauncher implements UrlLauncherApi {
  static LAUNCH_TYPE_TEL: string = 'tel:';
  static LAUNCH_TYPE_WEB_HTTP: string = 'http:';
  static LAUNCH_TYPE_WEB_HTTPS: string = 'https:';
  static LAUNCH_TYPE_MAILTO: string = 'mailto:';
  static LAUNCH_TYPE_SMS: string = 'sms:';
  static LAUNCH_TYPE_FILE: string = 'file:';
  static LAUNCH_TYPE_APP_GALLERY: string = 'store:';

  static MMS_BUNDLE_NAME = "com.ohos.mms";
  static MMS_ABILITY_NAME = "com.ohos.mms.MainAbility";
  static MMS_ENTITIES = 'entity.system.home';

  private context: common.UIAbilityContext;

  constructor(ctx: common.UIAbilityContext) {
    this.context = ctx;
  }

  getPermission() {
    let array: Array<Permissions> = [
      "ohos.permission.READ_MEDIA",
      "ohos.permission.WRITE_MEDIA",
      "ohos.permission.MEDIA_LOCATION",
      "ohos.permission.GET_BUNDLE_INFO",
      "ohos.permission.DISTRIBUTED_DATASYNC",
    ];

    let atManager = abilityAccessCtrl.createAtManager();
    //requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    atManager.requestPermissionsFromUser(this.context, array).then((data) => {
      Log.d(TAG, "data type:" + typeof (data));
      Log.d(TAG, "data:" + data);
      Log.d(TAG, "data permissions:" + data.permissions);
      Log.d(TAG, "data result:" + data.authResults);
    }, (err: Error) => {
      Log.e(TAG,'Failed to start ability', JSON.stringify(err));
    });
  }

  canLaunchUrl(url: string): boolean {
    let encodedUri = encodeURI(url);
    // Trick：由于 sms、tel、file、mailto 用 bundleManager.canOpenLink 判断会报 17700055 错误，这里暂时保留 if 这段条件判断代码
    if (encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_TEL) ||
        encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_WEB_HTTP) ||
        encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_WEB_HTTPS) ||
        encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_MAILTO) ||
        encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_SMS) ||
        encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_FILE) ||
        encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_APP_GALLERY)) {
      return true;
    }

    try {
      // 除了 sms、tel、file、mailto、http、https 开头的这六种 uri 之外的，用下面的方法判断是否支持打开。
      // 需要在 src/main/module.json5 的 querySchemes 中增加对应的头部信息，例如打开 "amapuri://route/plan/?did=xxx"，module.json5 的样例：{ "module": { "querySchemes": [ "amapuri" ] } }
      if (bundleManager.canOpenLink(encodedUri)) {
        return true;
      }
      return false;
    } catch (error) {
      Log.e(TAG, 'canOpenLink error: ', JSON.stringify(error));
      return false;
    }
  }

  launchUrl(url: string, headers: Map<string, string>): boolean {
    if (!this.canLaunchUrl(url)) {
      return false;
    }

    this.ensureContext();
    let encodedUri = encodeURI(url);
    Log.d(TAG, 'launchUrl. url:' + url + '  eurl:' + encodedUri);
    if (encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_TEL)) {
      return this.launchTel(url);
    } else if (encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_WEB_HTTP) ||
               encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_WEB_HTTPS)) {
      return this.launchWeb(url, headers);
    } else if (encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_MAILTO)) {
      return this.launchMail(url);
    } else if (encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_SMS)) {
      return this.launchSms(url);
    } else if (encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_FILE)) {
      return this.launchFile(url);
    } else if (encodedUri.startsWith(UrlLauncher.LAUNCH_TYPE_APP_GALLERY)) {
      return this.launchAppGallery(url);
    } else {
      return this.launchOther(url);
    }
  }

  format(number: string) {
    let regex: RegExp = new RegExp('/[\s]/g');
    let phoneNumber = number.replace(regex, '');
    let countryId = i18n.getSystemRegion();
    let phoneNumberFormat= new i18n.PhoneNumberFormat(countryId);
    let isNumberValid:boolean = phoneNumberFormat.isValidNumber(phoneNumber);
    let formatNumber = isNumberValid ? phoneNumberFormat.format(phoneNumber) : phoneNumber;
    return formatNumber;
  }

  launchSms(url: string): boolean {
    let phoneNum = this.parseUrl(url, UrlLauncher.LAUNCH_TYPE_SMS);
    let formatNum = this.format(phoneNum);

    let msgParam = new SendMessageParams();
    msgParam.telephone = phoneNum;
    msgParam.telephoneFormat = formatNum;

    let params = new Array<SendMessageParams>();
    params.push(msgParam);

    let actionData: ESObject = {};
    actionData.contactObjects = JSON.stringify(params);
    actionData.pageFlag = 'conversation';
    let str : Want = {
      'bundleName': UrlLauncher.MMS_BUNDLE_NAME,
      'abilityName': UrlLauncher.MMS_ABILITY_NAME,
      'parameters': actionData,
      'entities': [
        UrlLauncher.MMS_ENTITIES,
      ]
    };
    Log.i(TAG, 'jumpToMms want: %s', JSON.stringify(params));
    this.context.startAbility(str).then(() => {
      Log.i(TAG, 'jumpToMms success.');
    }).catch((error: ESObject) => {
      Log.e(TAG, 'jumpToMms failed: %s', JSON.stringify(error));
    })
    return true
  }

  launchTel(url: string): boolean {
    Log.d(TAG, 'launchTel:' + url);
    let phoneNum = this.parseUrl(url, UrlLauncher.LAUNCH_TYPE_TEL + ':');
    call.makeCall(phoneNum).then(() => {
      Log.e(TAG, `launchTel success`);
    }).catch((err: ESObject) => {
      Log.e(TAG, `launchTel failed,  error: ${JSON.stringify(err)}`);
    })
    return true;
  }

  // 只支持沙箱路径
  launchFile(url: string): boolean {
    let fileUrl = this.parseUrl(url, UrlLauncher.LAUNCH_TYPE_FILE + '://');
    let filePath = this.context.filesDir + fileUrl;
    // 将沙箱路径转换为uri
    let uriFromPath = fileuri.getUriFromPath(filePath);
    Log.d(TAG, 'launchFile:' + fileUrl + '  uriFromPath:' + uriFromPath);
    let want: Want = {
      flags: wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION,
      // 配置分享应用的隐式拉起规则
      action: 'ohos.want.action.viewData',
      uri: uriFromPath,
    }
    this.context.startAbility(want)
      .then(() => {
        Log.i(TAG, 'Invoke getCurrentBundleStats succeeded.');
      })
      .catch((err: ESObject) => {
        Log.e(TAG, `Invoke startAbility failed, code is ${err.code}, message is ${err.message}`);
      });
    return true;
  }

  launchWeb(url: string, headers: Map<string, string>): boolean {
    Log.d(TAG, 'launchWeb url:' + url);
    let params: Record<string, Object>  = {};

    for (let val of headers) {
      params[val[0]] = val[1]
    }

    let want: Want = {
      uri: url,
      parameters: params,
      entities: ['entity.system.browsable'],
      action: 'ohos.want.action.viewData',
    }
    try {
      this.context.startAbility(want)
    } catch (e) {
      Log.e(TAG, 'launchWeb failed. err:' + JSON.stringify(e))
      return false
    }
    return true;
  }

  launchMail(url: string): boolean {
    let mailAddress = this.parseUrl(url, UrlLauncher.LAUNCH_TYPE_MAILTO + ':');
    let want: Want = {
      action: 'ohos.want.action.sendToData',
      uri: mailAddress
    }
    try {
      this.context.startAbility(want)
    } catch (e) {
      Log.e(TAG, 'launchMail failed. err:' + JSON.stringify(e))
      return false
    }
    return true;
  }

  /**
   * 跳转到应用商店详情页
   * 文档参考：https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit#section42001122242
   * @param url
   * @returns
   */
  launchAppGallery(url: string): boolean {
    Log.d(TAG, 'launchAppGallery:' + url);
    //url 格式示范 store://appgallery.huawei.com/app/detail?id=C5765880207855137621
    let want: Want = {
      'action': 'ohos.want.action.appdetail',
      'uri': url,
    };
    try {
      this.context.startAbility(want)
    } catch (e) {
      Log.e(TAG, 'launchAppGallery failed. err:' + JSON.stringify(e))
      return false
    }
    return true
  }

  launchOther(url: string): boolean {
    let want: Want = {
      uri: url,
    }
    try {
      this.context.startAbility(want)
    } catch (e) {
      Log.e(TAG, 'launchOther failed. err:' + JSON.stringify(e))
      return false
    }
    return true;
  }

  parseUrl(url: string, prefix: string): string {
    if (url == null || url == undefined) {
      return ''
    }
    return url.replace(prefix, '');
  }

  private ensureContext(): void {
    if (this.context == null) {
      throw new FlutterError(
        "NO_ACTIVITY", "Launching a URL requires a foreground activity.", null);
    }
  }

  openUrlInWebView(url: string, options: WebViewOptions): boolean {
    let headers = options.getHeaders();
    if (!headers.has('harmony_browser_page')) {
      promptAction.showToast({
        message: '请在 launch 函数的 headers 参数中添加 harmony_browser_page 和对应的值，并在鸿蒙工程中增加对应的页面和配置路由',
      });
      return false;
    }

    let harmonyBrowserPage = headers.get('harmony_browser_page');
    router.pushUrl({ url: harmonyBrowserPage, params: {'url': url, 'options': options} }).catch((error: BusinessError) => {
      Log.e(TAG, 'Failed to open url: ', harmonyBrowserPage, ', Error: ', JSON.stringify(error));
      if (error.code == 100002) {
        promptAction.showToast({
          message: harmonyBrowserPage + ' 页面不存在，或者没有在 main_pages.json 中声明',
        });
      }
    });
    return true;
  }

  closeWebView(): boolean {
    throw new Error('Method not implemented.');
  }

  getCodec(): MessageCodec<ESObject> {
    return UrlLauncherApiCodec.INSTANCE;
  }

  setup(binaryMessenger: BinaryMessenger, api: UrlLauncherApi) {
    {
      if (binaryMessenger == null) {
        return;
      }
      let channel: BasicMessageChannel<ESObject> = new BasicMessageChannel<ESObject>(
        binaryMessenger, "dev.flutter.pigeon.UrlLauncherApi.canLaunchUrl", this.getCodec());
      Log.d(TAG, 'setup launchUrl')
      if (api != null && api != undefined) {
        Log.d(TAG, 'setMessageHandler')
        channel.setMessageHandler({
          onMessage(msg: ESObject, reply: Reply<ESObject>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let urlArg = args[0] as string;
            try {
              let output = api.canLaunchUrl(urlArg);
              wrapped.push(output);
            } catch (err) {
              let errs = wrapError(err);
              wrapped = errs;
            }
            reply.reply(wrapped)
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.UrlLauncherApi.launchUrl", this.getCodec());
      Log.d(TAG, 'setup launchUrl')
      if (api != null && api != undefined) {
        Log.d(TAG, 'setMessageHandler')
        channel.setMessageHandler({
          onMessage(msg: ESObject, reply: Reply<ESObject>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let urlArg = args[0] as string;
            let headersArg = args[1] as Map<string, string>;
            try {
              let output = api.launchUrl(urlArg, headersArg);
              wrapped.push(output);
            } catch (err) {
              let errs = wrapError(err);
              wrapped = errs;
            }
            reply.reply(wrapped)
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.UrlLauncherApi.openUrlInWebView", this.getCodec());
      Log.d(TAG, 'setup launchUrl')
      if (api != null && api != undefined) {
        Log.d(TAG, 'setMessageHandler')
        channel.setMessageHandler({
          onMessage(msg: ESObject, reply: Reply<ESObject>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let urlArg = args[0] as string;
            let optionsArg = args[1] as WebViewOptions;
            try {
              let output = api.openUrlInWebView(urlArg, optionsArg);
              wrapped.push(output);
            } catch (err) {
              let errs = wrapError(err);
              wrapped = errs;
            }
            reply.reply(wrapped)
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.UrlLauncherApi.closeWebView", this.getCodec());
      Log.d(TAG, 'setup launchUrl')
      if (api != null && api != undefined) {
        Log.d(TAG, 'setMessageHandler')
        channel.setMessageHandler({
          onMessage(msg: ESObject, reply: Reply<ESObject>): void {
            let wrapped = new Array<Object>();
            try {
              let output = api.closeWebView();
              wrapped.push(output);
            } catch (err) {
              let errs = wrapError(err);
              wrapped = errs;
            }
            reply.reply(wrapped)
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
  }
}