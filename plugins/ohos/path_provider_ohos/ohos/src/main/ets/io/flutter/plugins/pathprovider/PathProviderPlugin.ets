// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on PathProviderPlugin.java originally written by
// Copyright 2013 The Flutter Authors.

import common from '@ohos.app.ability.common';
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import {
  AbilityPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import PathUtils from '@ohos/flutter_ohos/src/main/ets/util/PathUtils';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { PathProviderApi, StorageDirectory } from './Messages';
import fs from '@ohos.file.fs';

const TAG: string = "PathProviderPlugin";

export default class PathProviderPlugin extends PathProviderApi implements FlutterPlugin, AbilityAware {
  private pluginBinding: FlutterPluginBinding | null = null;
  private context: common.Context | null = null;

  constructor(context?: common.Context) {
    super();
    if (context) {
      this.context = context;
    }
  }

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = binding;
    if (this.pluginBinding) {
      this.setup(this.pluginBinding.getBinaryMessenger(), this.pluginBinding.getApplicationContext());
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    Log.i(TAG, "onAttachedToAbility");
  }

  onDetachedFromAbility(): void {
  }

  static registerWith(): void {
  }

  setup(messenger: BinaryMessenger, context: common.Context) {
    try {
      PathProviderApi.setup(messenger, this);
    } catch (err) {
      Log.e(TAG, "Received exception while setting up PathProviderPlugin", err);
    }
    this.context = context;
  }

  getTemporaryPath(): string {
    return this.getPathProviderTemporaryDirectory();
  }

  getApplicationSupportPath(): string {
    return this.getApplicationSupportDirectory();
  }

  getApplicationDocumentsPath(): string {
    return this.getPathProviderApplicationDocumentsDirectory();
  }

  getApplicationCachePath(): string {
    if (this.context) {
      return this.context.cacheDir;
    }
    return "";
  }

  getExternalStoragePath(): string {
    return this.getPathProviderStorageDirectory();
  }

  getExternalCachePaths(): Array<string> {
    return this.getPathProviderExternalCacheDirectories();
  }

  getExternalStoragePaths(directory: StorageDirectory): Array<string> {
    return this.getPathProviderExternalStorageDirectories(directory);
  }

  private getPathProviderTemporaryDirectory(): string {
    if (this.context) {
      return this.context.cacheDir;
    }
    return "";
  }

  private getApplicationSupportDirectory(): string {
    return PathUtils.getFilesDir(this.context);
  }

  private getPathProviderApplicationDocumentsDirectory(): string {
    return PathUtils.getDataDirectory(this.context) ?? "";
  }

  private getPathProviderStorageDirectory(): string {
    if (this.context) {
      return this.context.filesDir;
    }
    return "";
  }

  private getPathProviderExternalCacheDirectories(): Array<string> {
    const paths = new Array<string>();
    if (this.context) {
      paths.push(this.context.cacheDir);
    }
    return paths;
  }

  private getStorageDirectoryString(directory: StorageDirectory): string {
    switch (directory) {
      case StorageDirectory.ROOT:
        return "";
      case StorageDirectory.MUSIC:
        return "music";
      case StorageDirectory.PODCASTS:
        return "podcasts";
      case StorageDirectory.RINGTONES:
        return "ringtones";
      case StorageDirectory.ALARMS:
        return "alarms";
      case StorageDirectory.NOTIFICATIONS:
        return "notifications";
      case StorageDirectory.PICTURES:
        return "pictures";
      case StorageDirectory.MOVIES:
        return "movies";
      case StorageDirectory.DOWNLOADS:
        return "downloads";
      case StorageDirectory.DCIM:
        return "dcim";
      case StorageDirectory.DOCUMENTS:
        return "documents";
      default:
        throw new Error("Unrecognized directory: " + directory);
    }
  }

  private getPathProviderExternalStorageDirectories(directory: StorageDirectory): Array<string> {
    const paths = new Array<string>();
    if (!this.context) {
      return paths;
    }
    const filePath = this.context.filesDir + "/" + this.getStorageDirectoryString(directory);
    if (!fs.accessSync(filePath)) {
      try {
        fs.mkdirSync(filePath);
        paths.push(filePath);
        Log.i(TAG, "no directory " + filePath + " create success");
      } catch (err) {
        Log.e(TAG, "mkdirSync failed err:" + err);
      }
    } else {
      paths.push(filePath);
    }

    return paths;
  }
}