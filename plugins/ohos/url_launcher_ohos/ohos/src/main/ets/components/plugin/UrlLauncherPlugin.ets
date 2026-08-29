// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on UrlLauncherPlugin.java originally written by
// Copyright 2013 The Flutter Authors.

import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import {
  AbilityPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { UrlLauncherApi } from './Messages';
import { UrlLauncher } from './UrlLauncher';

const TAG = "UrlLauncherPlugin"

export default class UrlLauncherPlugin implements FlutterPlugin, AbilityAware {

  private pluginBinding: FlutterPluginBinding | null = null;
  private urlLauncherApi: UrlLauncherApi | null = null;

  getUniqueClassName(): string {
    return "UrlLauncherPlugin"
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    console.debug(TAG, 'onAttachedToAbility ')
    this.urlLauncherApi = new UrlLauncher(binding.getAbility().context);
    this.urlLauncherApi.setup(
      this.pluginBinding?.getBinaryMessenger() ?? null, this.urlLauncherApi);
  }
  onDetachedFromAbility(): void {
    this.urlLauncherApi?.setup(null, null);
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    console.debug(TAG, 'onAttachedToEngine')
    this.pluginBinding = binding;
  }


  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.urlLauncherApi?.setup(this.pluginBinding?.getBinaryMessenger() ?? null, null);
    this.pluginBinding = null;
  }
}