// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on Messages.java originally written by
// Copyright 2013 The Flutter Authors.

import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import BasicMessageChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';

export enum StorageDirectory {
  ROOT = 0,
  MUSIC = 1,
  PODCASTS = 2,
  RINGTONES = 3,
  ALARMS = 4,
  NOTIFICATIONS = 5,
  PICTURES = 6,
  MOVIES = 7,
  DOWNLOADS = 8,
  DCIM = 9,
  DOCUMENTS = 10
}

const TAG: string = "Message";

export default class Messages {
  static wrapError(exception: Error): Array<ESObject> {
    const errorList: Array<ESObject> = new Array();
    if (exception instanceof FlutterError) {
      const error = exception;
      errorList.push(error.code);
      errorList.push(error.message);
      errorList.push(error.details);
    } else {
      errorList.push(exception.name);
      errorList.push(exception.message);
      errorList.push(exception.stack);
    }
    return errorList;
  }
}

export class FlutterError extends Error {
  code: string;
  details: ESObject;

  constructor(code: string, message: string, details: ESObject) {
    super(message);
    this.code = code;
    this.details = details;
  }
}

export abstract class PathProviderApi {
  abstract getTemporaryPath(): string;

  abstract getApplicationSupportPath(): string;

  abstract getApplicationDocumentsPath(): string;

  abstract getApplicationCachePath(): string;

  abstract getExternalStoragePath(): string;

  abstract getExternalCachePaths(): Array<string>;

  abstract getExternalStoragePaths(directory: StorageDirectory): Array<string>;

  static getCodec(): MessageCodec<ESObject> {
    return new StandardMessageCodec();
  }

  static setup(binaryMessenger: BinaryMessenger, api: PathProviderApi) {
    {
      const channel: BasicMessageChannel<ESObject> =
      new BasicMessageChannel<ESObject>(
        binaryMessenger,
        "dev.flutter.pigeon.PathProviderApi.getTemporaryPath",
        PathProviderApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage: (message: ESObject, reply: ESObject) => {
            Log.i(TAG, "setup on message : " + message);
            let wrapped: Array<ESObject> = new Array<ESObject>();
            try {
              const output = api.getTemporaryPath();
              wrapped.push(output);
            } catch (err) {
              const wrappedError: Array<ESObject> = Messages.wrapError(err);
              wrapped = wrappedError;
            }
            reply.reply(wrapped);
          }
        } as ESObject)
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      const channel: BasicMessageChannel<ESObject> =
      new BasicMessageChannel<ESObject>(
        binaryMessenger,
        "dev.flutter.pigeon.PathProviderApi.getApplicationSupportPath",
        PathProviderApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage: (message: ESObject, reply: ESObject) => {
            Log.i(TAG, "setup on message : " + message);
            let wrapped: Array<ESObject> = new Array<ESObject>();
            try {
              const output = api.getApplicationSupportPath();
              wrapped.push(output);
            } catch (err) {
              const wrappedError: Array<ESObject> = Messages.wrapError(err);
              wrapped = wrappedError;
            }
            reply.reply(wrapped);
          }
        } as ESObject)
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      const channel: BasicMessageChannel<ESObject> =
      new BasicMessageChannel<ESObject>(
        binaryMessenger,
        "dev.flutter.pigeon.PathProviderApi.getApplicationDocumentsPath",
        PathProviderApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage: (message: ESObject, reply: ESObject) => {
            Log.i(TAG, "setup on message : " + message);
            let wrapped: Array<ESObject> = new Array<ESObject>();
            try {
              const output = api.getApplicationDocumentsPath();
              wrapped.push(output);
            } catch (err) {
              const wrappedError: Array<ESObject> = Messages.wrapError(err);
              wrapped = wrappedError;
            }
            reply.reply(wrapped);
          }
        } as ESObject)
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      const channel: BasicMessageChannel<ESObject> =
      new BasicMessageChannel<ESObject>(
        binaryMessenger,
        "dev.flutter.pigeon.PathProviderApi.getApplicationCachePath",
        PathProviderApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage: (message: ESObject, reply: ESObject) => {
            Log.i(TAG, "setup on message : " + message);
            let wrapped: Array<ESObject> = new Array<ESObject>();
            try {
              const output = api.getApplicationCachePath();
              wrapped.push(output);
            } catch (err) {
              const wrappedError: Array<ESObject> = Messages.wrapError(err);
              wrapped = wrappedError;
            }
            reply.reply(wrapped);
          }
        } as ESObject)
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      const channel: BasicMessageChannel<ESObject> =
      new BasicMessageChannel<ESObject>(
        binaryMessenger,
        "dev.flutter.pigeon.PathProviderApi.getExternalStoragePath",
        PathProviderApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage: (message: ESObject, reply: ESObject) => {
            Log.i(TAG, "setup on message : " + message);
            let wrapped: Array<ESObject> = new Array<ESObject>();
            try {
              const output = api.getExternalStoragePath();
              wrapped.push(output);
            } catch (err) {
              const wrappedError: Array<ESObject> = Messages.wrapError(err);
              wrapped = wrappedError;
            }
            reply.reply(wrapped);
          }
        } as ESObject)
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      const channel: BasicMessageChannel<ESObject> =
      new BasicMessageChannel<ESObject>(
        binaryMessenger,
        "dev.flutter.pigeon.PathProviderApi.getExternalCachePaths",
        PathProviderApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage: (message: ESObject, reply: ESObject) => {
            Log.i(TAG, "setup on message : " + message);
            let wrapped: Array<ESObject> = new Array<ESObject>();
            try {
              const output = api.getExternalCachePaths();
              wrapped.push(output);
            } catch (err) {
              const wrappedError: Array<ESObject> = Messages.wrapError(err);
              wrapped = wrappedError;
            }
            reply.reply(wrapped);
          }
        } as ESObject)
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      const channel: BasicMessageChannel<ESObject> =
      new BasicMessageChannel<ESObject>(
        binaryMessenger,
        "dev.flutter.pigeon.PathProviderApi.getExternalStoragePaths",
        PathProviderApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage: (message: ESObject, reply: ESObject) => {
            Log.i(TAG, "setup on message : " + message);
            let wrapped: Array<ESObject> = new Array<ESObject>();
            let args: Array<ESObject> = message;
            const directoryArg: StorageDirectory = args[0] == null ? null : args[0];
            try {
              const output = api.getExternalStoragePaths(directoryArg);
              wrapped.push(output);
            } catch (err) {
              const wrappedError: Array<ESObject> = Messages.wrapError(err);
              wrapped = wrappedError;
            }
            reply.reply(wrapped);
          }
        } as ESObject)
      } else {
        channel.setMessageHandler(null);
      }
    }
  }
}