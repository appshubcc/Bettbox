// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.

import web_webview from '@ohos.web.webview';
import router from '@ohos.router';
import { ValueType } from '@kit.ArkData';

@Entry
@Component
export struct InAppBrowser {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()

  private url?: string;
  private enableJavaScript: boolean = true;
  private enableDomStorage: boolean = true;

  aboutToAppear(){
    let params = router.getParams() as Map<string, ValueType>
    this.url = params['url'] as string;
    let options = params['options'] as Map<string, ValueType>;
    this.enableJavaScript = options['enableJavaScript'] as boolean;
    this.enableDomStorage = options['enableDomStorage'] as boolean;
  }

  build() {
    Row() {
      Web({ src: this.url, controller: this.webviewController })
        .javaScriptAccess(this.enableJavaScript)
        .domStorageAccess(this.enableDomStorage)
    }.width('100%').height('100%')
  }
}
