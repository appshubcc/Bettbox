// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on Messages.java originally written by
// Copyright 2013 The Flutter Authors.

import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { ByteBuffer } from '@ohos/flutter_ohos/src/main/ets/util/ByteBuffer';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG = 'UrlLauncher'

export class FlutterError extends Error {
  /** The error code. */
  public code: string = '';

  /** The error details. Must be a datatype supported by the api codec. */
  public details: ESObject | null;

  constructor(code: string, message: string, details: ESObject) {
    super(message);
    this.code = code;
    this.details = details;
  }
}

export function wrapError(exception: Error): Array<Object> {
  let errorList = new Array<Object>();
  if (exception instanceof FlutterError) {
    let error = exception as FlutterError;
    errorList.push(error.code);
    errorList.push(error.message);
    errorList.push(error.details);
  } else {
    errorList.push(exception.name);
    errorList.push(
      "Cause: " + exception.message + ", Stacktrace: " + exception.stack);
  }
  return errorList;
}

/**
 * Configuration options for an in-app WebView.
 *
 */
export class WebViewOptions {
  private enableJavaScript: boolean = false;

  public getEnableJavaScript(): boolean {
    return this.enableJavaScript;
  }

  public setEnableJavaScript(setterArg: boolean): void {
    if (setterArg == null) {
      throw new ReferenceError("Nonnull field \"enableJavaScript\" is null.");
    }
    this.enableJavaScript = setterArg;
  }

  private enableDomStorage: boolean = false;

  public getEnableDomStorage(): boolean {
    return this.enableDomStorage;
  }

  public setEnableDomStorage(setterArg: boolean) {
    if (setterArg == null) {
      throw new ReferenceError("Nonnull field \"enableDomStorage\" is null.");
    }
    this.enableDomStorage = setterArg;
  }

  private headers: Map<string, string> = new Map<string, string>();

  public getHeaders(): Map<string, string> {
    return this.headers;
  }

  public setHeaders(setterArg: Map<string, string>) {
    if (setterArg == null) {
      throw new ReferenceError("Nonnull field \"headers\" is null.");
    }
    this.headers = setterArg;
  }

  toList(): Array<ESObject> {
    let toListResult = new Array<Object>();
    toListResult.push(this.enableJavaScript);
    toListResult.push(this.enableDomStorage);
    toListResult.push(this.headers);
    return toListResult;
  }

  static fromList(list: Array<Object>): WebViewOptions {
    let result = new WebViewOptions();
    let enableJavaScript = list[0] as boolean;
    result.setEnableJavaScript(enableJavaScript);
    let enableDomStorage = list[1] as boolean;
    result.setEnableDomStorage(enableDomStorage);
    let headers = list[2];
    result.setHeaders(headers as Map<string, string>);
    return result;
  }

  /** Constructor is non-public to enforce null safety; use Builder. */
  private WebViewOptions() {}
}

export class UrlLauncherApiCodec extends StandardMessageCodec {
  public static INSTANCE: UrlLauncherApiCodec = new UrlLauncherApiCodec();

  private constructor() {
    super();
  }

  readValueOfType(type: number, buffer: ByteBuffer): Object {
    switch (type) {
      case 128:
        return WebViewOptions.fromList(super.readValue(buffer) as Array<Object>);
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  writeValue(stream: ByteBuffer, value: ESObject): void {
    if (value instanceof WebViewOptions) {
      stream.writeInt8(128);
      this.writeValue(stream, (value as WebViewOptions).toList());
    } else {
      super.writeValue(stream, value);
    }
  }
}

export interface UrlLauncherApi {
  /** Returns true if the URL can definitely be launched. */
  canLaunchUrl(url: string): boolean;

  /** Opens the URL externally, returning true if successful. */
  launchUrl(url: string, headers: Map<string, string>): boolean;

  /** Opens the URL in an in-app WebView, returning true if it opens successfully. */
  openUrlInWebView(url: string, options: WebViewOptions): boolean;

  /** Closes the view opened by [openUrlInSafariViewController]. */
  closeWebView(): boolean;

  /** The codec used by UrlLauncherApi. */
  getCodec(): MessageCodec<ESObject>;

  /** Sets up an instance of `UrlLauncherApi` to handle messages through the `binaryMessenger`. */
  setup(binaryMessenger: BinaryMessenger | null, api: UrlLauncherApi | null): ESObject;
}