import { commonEventManager } from '@kit.BasicServicesKit';
import { common, Want, WantAgent, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { vpnExtension } from '@kit.NetworkKit';
import { closeServer, initServer, receiveFd } from 'libvpnfd.so';
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult
} from '@ohos/flutter_ohos';

const TAG = 'BettboxVpnPlugin';
const CHANNEL_NAME = 'service';
const BUNDLE_NAME = 'com.appshub.bett_box';
const VPN_ABILITY_NAME = 'BettboxVpnExtensionAbility';
const VPN_STARTED_EVENT = `${BUNDLE_NAME}.VPN_STARTED`;

interface VpnOptions {
  ipv4Address: string;
  ipv6Address: string;
  routeAddress: Array<string>;
  dnsServerAddress: string;
}

export default class BettboxVpnPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private pendingStartResult: MethodResult | null = null;
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private vpnRunning: boolean = false;
  private backgroundTaskActive: boolean = false;
  private readonly abilityContext: common.UIAbilityContext;

  constructor(abilityContext: common.UIAbilityContext) {
    this.abilityContext = abilityContext;
  }

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    if (!initServer()) {
      throw new Error('Failed to initialize the VPN file descriptor server');
    }
    this.subscribeVpnEvents();
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    if (this.subscriber != null) {
      commonEventManager.unsubscribe(this.subscriber);
      this.subscriber = null;
    }
    closeServer();
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'startVpn':
        this.startVpn(call.argument('data') as string, result);
        break;
      case 'stopVpn':
      case 'destroy':
        this.stopVpn(result);
        break;
      case 'init':
      case 'reconnectIpc':
        result.success(true);
        break;
      case 'status':
      case 'isServiceEngineRunning':
        result.success(this.vpnRunning);
        break;
      case 'smartStop':
        this.stopVpn(result);
        break;
      case 'smartResume':
        this.startVpn(call.argument('data') as string, result);
        break;
      case 'setSmartStopped':
      case 'setQuickResponse':
      case 'updateNotificationSpeed':
      case 'restoreNotification':
        result.success(true);
        break;
      case 'isSmartStopped':
        result.success(false);
        break;
      case 'getLocalIpAddresses':
        result.success([]);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private async subscribeVpnEvents(): Promise<void> {
    this.subscriber = await commonEventManager.createSubscriber({
      events: [VPN_STARTED_EVENT]
    });
    commonEventManager.subscribe(this.subscriber, (_error, eventData) => {
      const result = this.pendingStartResult;
      this.pendingStartResult = null;
      if (result == null) return;
      if (eventData.code !== 1) {
        this.stopBackgroundTask();
        result.error('VPN_START_FAILED', eventData.data ?? 'VPN creation failed', null);
        return;
      }
      const fd = receiveFd();
      if (fd < 0) {
        this.stopVpnExtension();
        result.error('VPN_FD_TRANSFER_FAILED', 'Failed to transfer the VPN file descriptor', null);
        return;
      }
      this.vpnRunning = true;
      result.success(fd);
    });
  }

  private startVpn(optionsJson: string, result: MethodResult): void {
    if (this.pendingStartResult != null) {
      result.error('VPN_START_PENDING', 'A VPN start request is already pending', null);
      return;
    }
    let options: VpnOptions;
    try {
      options = JSON.parse(optionsJson) as VpnOptions;
    } catch (error) {
      const message = error instanceof Error ? error.message : `${error}`;
      result.error('VPN_OPTIONS_INVALID', message, null);
      return;
    }
    this.pendingStartResult = result;
    const want: Want = {
      bundleName: BUNDLE_NAME,
      abilityName: VPN_ABILITY_NAME,
      parameters: {
        ipv4Address: options.ipv4Address,
        ipv6Address: options.ipv6Address,
        routeAddress: options.routeAddress,
        dnsServerAddress: options.dnsServerAddress
      }
    };
    this.startBackgroundTask().then(() => {
      return vpnExtension.startVpnExtensionAbility(want);
    }).catch((error: Error) => {
      const pendingResult = this.pendingStartResult;
      this.pendingStartResult = null;
      this.stopBackgroundTask();
      pendingResult?.error('VPN_EXTENSION_START_FAILED', error.message, null);
    });
  }

  private stopVpn(result: MethodResult): void {
    this.stopVpnExtension(result);
  }

  private stopVpnExtension(result?: MethodResult): void {
    const want: Want = {
      bundleName: BUNDLE_NAME,
      abilityName: VPN_ABILITY_NAME
    };
    vpnExtension.stopVpnExtensionAbility(want).then(() => {
      this.vpnRunning = false;
      this.stopBackgroundTask().then(() => {
        result?.success(true);
      }).catch((error: Error) => {
        console.warn(`${TAG}: failed to stop background task: ${error.message}`);
        result?.success(true);
      });
    }).catch((error: Error) => {
      result?.error('VPN_EXTENSION_STOP_FAILED', error.message, null);
    });
  }

  private async startBackgroundTask(): Promise<void> {
    if (this.backgroundTaskActive) return;
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName: BUNDLE_NAME,
        abilityName: 'EntryAbility'
      }],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    const agent: WantAgent = await wantAgent.getWantAgent(wantAgentInfo);
    await backgroundTaskManager.startBackgroundRunning(
      this.abilityContext,
      ['dataTransfer'],
      agent
    );
    this.backgroundTaskActive = true;
  }

  private async stopBackgroundTask(): Promise<void> {
    if (!this.backgroundTaskActive) return;
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.abilityContext);
    } finally {
      this.backgroundTaskActive = false;
    }
  }
}
