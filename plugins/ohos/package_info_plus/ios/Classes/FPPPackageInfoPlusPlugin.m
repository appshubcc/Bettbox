// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FPPPackageInfoPlusPlugin.h"

@implementation FPPPackageInfoPlusPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"dev.fluttercommunity.plus/package_info"
            binaryMessenger:[registrar messenger]];
  FPPPackageInfoPlusPlugin *instance = [[FPPPackageInfoPlusPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([call.method isEqualToString:@"getAll"]) {
    NSString *appStoreReceipt =
        [[[NSBundle mainBundle] appStoreReceiptURL] path];

    NSString *installerStore =
        [appStoreReceipt containsString:@"CoreSimulator"]
            ? @"com.apple.simulator"
        : [appStoreReceipt containsString:@"sandboxReceipt"]
            ? @"com.apple.testflight"
            : @"com.apple";

    result(@{
      @"appName" : [[NSBundle mainBundle]
          objectForInfoDictionaryKey:@"CFBundleDisplayName"]
          ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
                 ?: [NSNull null],
      @"packageName" : [[NSBundle mainBundle] bundleIdentifier]
          ?: [NSNull null],
      @"version" : [[NSBundle mainBundle]
          objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
          ?: [NSNull null],
      @"buildNumber" : [[NSBundle mainBundle]
          objectForInfoDictionaryKey:@"CFBundleVersion"]
          ?: [NSNull null],
      @"installerStore" : installerStore
    });
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
