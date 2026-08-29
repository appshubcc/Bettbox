// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on Messages.java originally written by
// Copyright 2013 The Flutter Authors.

import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';

class FlutterError extends Error {
  /** The error code. */
  public code: string;

  /** The error details. Must be a datatype supported by the api codec. */
  public details: Object;

  constructor(code: string, message: string, details: Object) {
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
    errorList.push(exception.toString());
    errorList.push(exception.name);
    errorList.push(
      "Cause: " + exception.message + ", Stacktrace: " + exception.stack);
  }
  return errorList;
}

export interface SharedPreferencesApi {
  /** Removes property from shared preferences data set. */
  remove(key: string): boolean;

  /** Adds property to shared preferences data set of type boolean. */
  setBool(key: string, value: boolean): Promise<void>;

  /** Adds property to shared preferences data set of type string. */
  setString(key: string, value: string): Promise<void>;

  /** Adds property to shared preferences data set of type int. */
  setInt(key: string, value: number): Promise<void>;

  /** Adds property to shared preferences data set of type double. */
  setDouble(key: string, value: number): Promise<void>;

  /** Adds property to shared preferences data set of type String. */
  setStringList(key: string, value: Array<string>): Promise<void>;

  /** Removes all properties from shared preferences data set with matching prefix. */
  clear(prefix: string, allowList: Array<string>): Promise<void>;

  /** Gets all properties from shared preferences data set with matching prefix. */
  getAll(prefix: string, allowList: Array<string>): Promise<Object>;

  /** The codec used by SharedPreferencesApi. */
  getCodec(): MessageCodec<Object>;

  /**
   * Sets up an instance of `SharedPreferencesApi` to handle messages through the
   * `binaryMessenger`.
   */
  setup(messenger: BinaryMessenger, api: SharedPreferencesApi): void;
}