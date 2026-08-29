// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on SharedPreferencesPlugin.java originally written by
// Copyright 2013 The Flutter Authors.

import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import { SharedPreferencesApi, wrapError } from './Messages';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import data_preferences from '@ohos.data.preferences'
import BasicMessageChannel, { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { SharedPreferencesListEncoder } from './SharedPreferencesListEncoder';
import buffer  from '@ohos.buffer';

const TAG = "SharedPreferencesOhosPlugin"
const PREFERENCES_NAME = "FlutterSharedPreferences";
const LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";

export default class SharedPreferencesOhosPlugin implements FlutterPlugin, SharedPreferencesApi {

  private preferences: data_preferences.Preferences | null = null;
  private listEncoder: ListEncoder;

  getUniqueClassName(): string {
    return "SharedPreferencesOhosPlugin"
  }

  constructor() {
    this.listEncoder = new ListEncoder();
  }

  setup(binaryMessenger: BinaryMessenger, api: SharedPreferencesApi | null): void {
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.SharedPreferencesApi.remove", this.getCodec());
      Log.d(TAG, 'setup')
      if (api != null) {
        Log.d(TAG, 'setMessageHandler')
        channel.setMessageHandler({
          onMessage(msg: Object, reply: Reply<Object>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let keyArg = args[0] as string;
            try {
              let output = api.remove(keyArg);
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
        binaryMessenger, "dev.flutter.pigeon.SharedPreferencesApi.getAll", this.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(msg: Object, reply: Reply<Object>): void {
            Log.d(TAG, 'onMessage reply:' + reply)
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let prefixArg = args[0] as string;
            let allowListArg = args[1] as Array<string>;
            api.getAll(prefixArg, allowListArg).then((res) => {
              wrapped.push(res);
              Log.w(TAG, "getAll res=" + JSON.stringify(res));
              reply.reply(wrapped)
            }).catch((err: ESObject) => {
              Log.w(TAG, "Failed to getAll. code =" + err.code +", message =" + err.message);
              let errs = wrapError(err);
              wrapped = errs;
              reply.reply(wrapped)
            })
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.SharedPreferencesApi.clear", this.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(msg: Object, reply: Reply<Object>): void {
            Log.d(TAG, 'onMessage reply:' + reply)
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let prefixArg = args[0] as string;
            let allowListArg = args[1] as Array<string>;
            api.clear(prefixArg, allowListArg).then(() => {
              wrapped.push(true);
              reply.reply(wrapped)
            }).catch((err: ESObject) => {
              Log.w(TAG, "Failed to clear. code =" + err.code +", message =" + err.message);
              let errs = wrapError(err);
              wrapped = errs;
              reply.reply(wrapped)
            })
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.SharedPreferencesApi.setInt", this.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(msg: Object, reply: Reply<Object>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let keyArg = args[0] as string;
            let valueArg = args[1] as number;
            api.setInt(keyArg, valueArg).then(() => {
              wrapped.push(true);
              reply.reply(wrapped)
            }).catch((err: ESObject) => {
              Log.w(TAG, "Failed to setInt. code =" + err.code +", message =" + err.message);
              let errs = wrapError(err);
              wrapped = errs;
              reply.reply(wrapped)
            })
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.SharedPreferencesApi.setString", this.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(msg: Object, reply: Reply<Object>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let keyArg = args[0] as string;
            let valueArg = args[1] as string;
            api.setString(keyArg, valueArg).then(() => {
              wrapped.push(true);
              reply.reply(wrapped)
            }).catch((err: ESObject) => {
              Log.w(TAG, "Failed to setString. code =" + err.code +", message =" + err.message);
              let errs = wrapError(err);
              wrapped = errs;
              reply.reply(wrapped)
            })
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.SharedPreferencesApi.setDouble", this.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(msg: Object, reply: Reply<Object>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let keyArg = args[0] as string;
            let valueArg = args[1] as number;
            api.setDouble(keyArg, valueArg).then(() => {
              wrapped.push(true);
              reply.reply(wrapped)
            }).catch((err: ESObject) => {
              Log.w(TAG, "Failed to setDouble. code =" + err.code +", message =" + err.message);
              let errs = wrapError(err);
              wrapped = errs;
              reply.reply(wrapped)
            })
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.SharedPreferencesApi.setBool", this.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(msg: Object, reply: Reply<Object>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let keyArg = args[0] as string;
            let valueArg = args[1] as boolean;
            api.setBool(keyArg, valueArg).then(() => {
              wrapped.push(true);
              reply.reply(wrapped)
            }).catch((err: ESObject) => {
              Log.w(TAG, "Failed to setBool. code =" + err.code +", message =" + err.message);
              let errs = wrapError(err);
              wrapped = errs;
              reply.reply(wrapped)
            })
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
    {
      let channel = new BasicMessageChannel<Object>(
        binaryMessenger, "dev.flutter.pigeon.SharedPreferencesApi.setStringList", this.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(msg: Object, reply: Reply<Object>): void {
            let wrapped = new Array<Object>();
            let args = msg as Array<Object>;
            let keyArg = args[0] as string;
            let valueArg = args[1] as Array<string>;
            api.setStringList(keyArg, valueArg).then(() => {
              wrapped.push(true);
              reply.reply(wrapped)
            }).catch((err: ESObject) => {
              Log.w(TAG, "Failed to setStringList. code =" + err.code +", message =" + err.message);
              let errs = wrapError(err);
              wrapped = errs;
              reply.reply(wrapped)
            })
          }
        });
      } else {
        channel.setMessageHandler(null)
      }
    }
  }

  remove(key: string): boolean {
    try {
      let result = true
      this.preferences?.delete(key,async (err: ESObject) => {
        if (err) {
          Log.w(TAG, "Failed to delete.  message =" + err.message);
          result =  false;
        }
        Log.i(TAG, "Succeeded in deleting.");
        await this.preferences?.flush();
      })
      return result;
    } catch (err) {
      Log.e(TAG, "Failed to delete. " + JSON.stringify(err));
      return false;
    }
  }

  setString(key: string, value: string): Promise<void> {
    if (value.startsWith(LIST_IDENTIFIER)) {
      throw new Error(
        "StorageError: This string cannot be stored as it clashes with special identifier prefixes");
    }
    return this.put(key, value);
  }

  setInt(key: string, value: number): Promise<void> {
    if(typeof value == "bigint") {
      return this.put(key, Number(value));
    }
    return this.put(key, value);
  }

  put(key: string, value: ESObject): Promise<void> {
    try {
      if (this.preferences == null) {
        return new Promise((reject) => {
          reject();
        });
      } else {
        this.preferences.put(key, value);
        return this.preferences.flush();
      }
    } catch(err) {
      Log.w(TAG, "Failed to put value of 'startup'. " + JSON.stringify(err));
      return new Promise((reject) => {
        reject();
      });
    }
  }

  setDouble(key: string, value: number): Promise<void> {
    return this.put(key, value);
  }

  setStringList(key: string, value: string[]): Promise<void> {
    Log.w(TAG, "setStringList :" + value);
    Log.w(TAG, "setStringList encoded:" + (LIST_IDENTIFIER + this.listEncoder.encode(value)));
    return this.put(key, LIST_IDENTIFIER + this.listEncoder.encode(value));
  }

  clear(prefix: string, allowList: string[]): Promise<void> {
    try {
      this.preferences?.getAll().then((value: object) => {
        let allKeys = Object.keys(value);
        for (let key of allKeys) {
          if (key.startsWith(prefix) && (allowList == null || allowList.indexOf(key) != -1)) {
            this.preferences?.delete(key);
          }
        }
        return this.preferences?.flush();
      }).catch((err: ESObject) => {
        Log.w(TAG, "Failed to clear." + JSON.stringify(err));
      });
    } catch (err) {
      Log.w(TAG, "Failed to clear." + JSON.stringify(err));
    }
    return new Promise((reject) => {
      reject();
    })
  }

  filterData(value: [string, Object], prefix: string, allowList: string[]): Map<string, Object> {
    let allVal = Object.entries(value);
    let filteredPrefs = new Map<string, Object>();
    for (let val of allVal) {
      let key = val[0];
      let v = val[1];
      if (key.startsWith(prefix) && (allowList == null || allowList.indexOf(key) != -1)) {
        filteredPrefs.set(key, this.transformPref(v));
        Log.w(TAG, "filterData00：key:" + key + " val:" + (this.transformPref(v)));
      }
    }
    Log.w(TAG, "filterData1：" + JSON.stringify(filteredPrefs));
    return filteredPrefs;
  }

  async getAll(prefix: string, allowList: Array<string>): Promise<Object> {
    try {
      let res = new Map<string, Object>();
      if (this.preferences == null) {
        return new Promise((reject) => {
          reject("Failed to getAll");
        })
      }
      await this.preferences.getAll().then((obj: Object) => {
        res = this.filterData(obj as [string, ESObject], prefix, allowList);
      })
      return new Promise((resolve) => {
        resolve(res);
      })
    } catch (err) {
      Log.w(TAG, "Failed to excute getAll." + JSON.stringify(err));
      return new Promise((reject) => {
        reject("Failed to getAll");
      })
    }
  }

  getCodec(): MessageCodec<Object> {
    return new StandardMessageCodec();
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    try {
      let promise = data_preferences.getPreferences(binding.getApplicationContext(), PREFERENCES_NAME);
      promise.then((object) => {
        this.preferences = object;
        Log.i(TAG, "Succeeded in getting preferences.");
      }).catch((err: ESObject) => {
        Log.w(TAG, "Failed to get preferences. code =" + err.code + ", message =" + err.message);
      })
    } catch(err) {
      Log.w(TAG, "Failed to get preferences."+ JSON.stringify(err));
    }
    this.setup(binding.getBinaryMessenger(), this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    try {
      let promise = this.preferences?.flush();
      promise?.then(() => {
        Log.i(TAG, "Succeeded in flushing.");
      }).catch((err: ESObject) => {
        Log.w(TAG, "Failed to flush." + JSON.stringify(err));
      })
    } catch (err) {
      Log.w(TAG, "Failed to flush." + JSON.stringify(err));
    }
    this.setup(binding.getBinaryMessenger(), null);
  }

  setBool(key: string, value: boolean): Promise<void> {
    return this.put(key, value)
  }

  transformPref(value: Object): Object {
    if (typeof value == "string") {
      let stringValue = (value as string);
      if (stringValue.startsWith(LIST_IDENTIFIER)) {
        let strList: ESObject = this.listEncoder.decode(stringValue.substring(LIST_IDENTIFIER.length));
        let t: ESObject = JSON.parse(strList);
        return t;
      }
    }
    return value;
  }
}

class ListEncoder implements SharedPreferencesListEncoder {
  encode(list: string[]): string {
    try {
      let jsonList = JSON.stringify(list)
      return buffer.from(jsonList).toString('base64');;
    } catch (err) {
      Log.e(TAG, "Failed encode."  + JSON.stringify(err));
    }
    return ''
  }

  decode(listString: string): ESObject {
    try {
      let buf = buffer.from(listString, 'base64');
      return buf.toString();
    } catch (err) {
      Log.e(TAG, "Failed decode." + JSON.stringify(err));
    }
    return undefined
  }
}
