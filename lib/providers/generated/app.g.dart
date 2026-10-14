// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../app.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RealTunEnable)
final realTunEnableProvider = RealTunEnableProvider._();

final class RealTunEnableProvider
    extends $NotifierProvider<RealTunEnable, bool> {
  RealTunEnableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realTunEnableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realTunEnableHash();

  @$internal
  @override
  RealTunEnable create() => RealTunEnable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$realTunEnableHash() => r'a4e995c86deca4c8307966470e69d93d64a40df6';

abstract class _$RealTunEnable extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Logs)
final logsProvider = LogsProvider._();

final class LogsProvider extends $NotifierProvider<Logs, FixedList<Log>> {
  LogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logsHash();

  @$internal
  @override
  Logs create() => Logs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FixedList<Log> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FixedList<Log>>(value),
    );
  }
}

String _$logsHash() => r'fbedf36290e515bd258ddf264bb107ecc3241343';

abstract class _$Logs extends $Notifier<FixedList<Log>> {
  FixedList<Log> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FixedList<Log>, FixedList<Log>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FixedList<Log>, FixedList<Log>>,
              FixedList<Log>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LogsFilter)
final logsFilterProvider = LogsFilterProvider._();

final class LogsFilterProvider
    extends $NotifierProvider<LogsFilter, LogsFilterState> {
  LogsFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logsFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logsFilterHash();

  @$internal
  @override
  LogsFilter create() => LogsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogsFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogsFilterState>(value),
    );
  }
}

String _$logsFilterHash() => r'f3ecd349cd39c722215e217dc4cd084a3bbb12fb';

abstract class _$LogsFilter extends $Notifier<LogsFilterState> {
  LogsFilterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LogsFilterState, LogsFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LogsFilterState, LogsFilterState>,
              LogsFilterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredLogs)
final filteredLogsProvider = FilteredLogsProvider._();

final class FilteredLogsProvider
    extends $FunctionalProvider<FilteredLogs, FilteredLogs, FilteredLogs>
    with $Provider<FilteredLogs> {
  FilteredLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredLogsHash();

  @$internal
  @override
  $ProviderElement<FilteredLogs> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FilteredLogs create(Ref ref) {
    return filteredLogs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilteredLogs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilteredLogs>(value),
    );
  }
}

String _$filteredLogsHash() => r'fc6cbf6406f854f7e83ed6b87d6e6cb6b93ab886';

@ProviderFor(Requests)
final requestsProvider = RequestsProvider._();

final class RequestsProvider
    extends $NotifierProvider<Requests, FixedList<TrackerInfo>> {
  RequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestsHash();

  @$internal
  @override
  Requests create() => Requests();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FixedList<TrackerInfo> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FixedList<TrackerInfo>>(value),
    );
  }
}

String _$requestsHash() => r'cd1e176f202240ccf3ed6e59faaa650e57ec257e';

abstract class _$Requests extends $Notifier<FixedList<TrackerInfo>> {
  FixedList<TrackerInfo> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<FixedList<TrackerInfo>, FixedList<TrackerInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FixedList<TrackerInfo>, FixedList<TrackerInfo>>,
              FixedList<TrackerInfo>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Providers)
final providersProvider = ProvidersProvider._();

final class ProvidersProvider
    extends $NotifierProvider<Providers, List<ExternalProvider>> {
  ProvidersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providersHash();

  @$internal
  @override
  Providers create() => Providers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExternalProvider> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExternalProvider>>(value),
    );
  }
}

String _$providersHash() => r'4292240629a99470b2e72426dde3b9049b9b57e0';

abstract class _$Providers extends $Notifier<List<ExternalProvider>> {
  List<ExternalProvider> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<ExternalProvider>, List<ExternalProvider>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ExternalProvider>, List<ExternalProvider>>,
              List<ExternalProvider>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Packages)
final packagesProvider = PackagesProvider._();

final class PackagesProvider
    extends $NotifierProvider<Packages, List<Package>> {
  PackagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packagesHash();

  @$internal
  @override
  Packages create() => Packages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Package> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Package>>(value),
    );
  }
}

String _$packagesHash() => r'84bff9f5271622ed4199ecafacda8e74fa444fe2';

abstract class _$Packages extends $Notifier<List<Package>> {
  List<Package> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Package>, List<Package>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Package>, List<Package>>,
              List<Package>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SystemBrightness)
final systemBrightnessProvider = SystemBrightnessProvider._();

final class SystemBrightnessProvider
    extends $NotifierProvider<SystemBrightness, Brightness> {
  SystemBrightnessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemBrightnessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemBrightnessHash();

  @$internal
  @override
  SystemBrightness create() => SystemBrightness();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Brightness value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Brightness>(value),
    );
  }
}

String _$systemBrightnessHash() => r'46eb2d23b05405723efc29480e8f258bf2d8138b';

abstract class _$SystemBrightness extends $Notifier<Brightness> {
  Brightness build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Brightness, Brightness>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Brightness, Brightness>,
              Brightness,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Traffics)
final trafficsProvider = TrafficsProvider._();

final class TrafficsProvider
    extends $NotifierProvider<Traffics, FixedList<Traffic>> {
  TrafficsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trafficsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trafficsHash();

  @$internal
  @override
  Traffics create() => Traffics();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FixedList<Traffic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FixedList<Traffic>>(value),
    );
  }
}

String _$trafficsHash() => r'8b86eb718fed5776de174c51fd5b231957011fe6';

abstract class _$Traffics extends $Notifier<FixedList<Traffic>> {
  FixedList<Traffic> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FixedList<Traffic>, FixedList<Traffic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FixedList<Traffic>, FixedList<Traffic>>,
              FixedList<Traffic>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TotalTraffic)
final totalTrafficProvider = TotalTrafficProvider._();

final class TotalTrafficProvider
    extends $NotifierProvider<TotalTraffic, Traffic> {
  TotalTrafficProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalTrafficProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalTrafficHash();

  @$internal
  @override
  TotalTraffic create() => TotalTraffic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Traffic value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Traffic>(value),
    );
  }
}

String _$totalTrafficHash() => r'cc993ec58fa4c8ee0dbbf2e8a146f7039e818d7e';

abstract class _$TotalTraffic extends $Notifier<Traffic> {
  Traffic build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Traffic, Traffic>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Traffic, Traffic>,
              Traffic,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LocalNetwork)
final localNetworkProvider = LocalNetworkProvider._();

final class LocalNetworkProvider
    extends $NotifierProvider<LocalNetwork, NetworkInfo?> {
  LocalNetworkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNetworkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNetworkHash();

  @$internal
  @override
  LocalNetwork create() => LocalNetwork();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkInfo? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkInfo?>(value),
    );
  }
}

String _$localNetworkHash() => r'152235671692c4d184a87d1242bfdd3cfbec5425';

abstract class _$LocalNetwork extends $Notifier<NetworkInfo?> {
  NetworkInfo? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NetworkInfo?, NetworkInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NetworkInfo?, NetworkInfo?>,
              NetworkInfo?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TailscaleAuthUrl)
final tailscaleAuthUrlProvider = TailscaleAuthUrlProvider._();

final class TailscaleAuthUrlProvider
    extends $NotifierProvider<TailscaleAuthUrl, String?> {
  TailscaleAuthUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tailscaleAuthUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tailscaleAuthUrlHash();

  @$internal
  @override
  TailscaleAuthUrl create() => TailscaleAuthUrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$tailscaleAuthUrlHash() => r'7c254faf6b8bcadf365a848219ab64a7ff874a78';

abstract class _$TailscaleAuthUrl extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(RunTime)
final runTimeProvider = RunTimeProvider._();

final class RunTimeProvider extends $NotifierProvider<RunTime, int?> {
  RunTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runTimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runTimeHash();

  @$internal
  @override
  RunTime create() => RunTime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$runTimeHash() => r'9aab44f2234590a70cbf0ff7394e496c2c97c00e';

abstract class _$RunTime extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ViewSize)
final viewSizeProvider = ViewSizeProvider._();

final class ViewSizeProvider extends $NotifierProvider<ViewSize, Size> {
  ViewSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewSizeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewSizeHash();

  @$internal
  @override
  ViewSize create() => ViewSize();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Size value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Size>(value),
    );
  }
}

String _$viewSizeHash() => r'07f9cce28a69d1496ba4643ef72a739312f6fc28';

abstract class _$ViewSize extends $Notifier<Size> {
  Size build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Size, Size>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Size, Size>,
              Size,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(viewWidth)
final viewWidthProvider = ViewWidthProvider._();

final class ViewWidthProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  ViewWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewWidthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewWidthHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return viewWidth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$viewWidthHash() => r'a469c3414170a6616ff3264962e7f160b2edceca';

@ProviderFor(viewMode)
final viewModeProvider = ViewModeProvider._();

final class ViewModeProvider
    extends $FunctionalProvider<ViewMode, ViewMode, ViewMode>
    with $Provider<ViewMode> {
  ViewModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewModeHash();

  @$internal
  @override
  $ProviderElement<ViewMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ViewMode create(Ref ref) {
    return viewMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewMode>(value),
    );
  }
}

String _$viewModeHash() => r'72c09e2e81bd930b7842fa78b8cf2376fd2b72c0';

@ProviderFor(isMobileView)
final isMobileViewProvider = IsMobileViewProvider._();

final class IsMobileViewProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsMobileViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isMobileViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isMobileViewHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isMobileView(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isMobileViewHash() => r'110d5cbf01a55981c95a434c796600757118ec79';

@ProviderFor(viewHeight)
final viewHeightProvider = ViewHeightProvider._();

final class ViewHeightProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  ViewHeightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewHeightProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewHeightHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return viewHeight(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$viewHeightHash() => r'410aee5b41388226ab16737f0e85a56f7e9fe801';

@ProviderFor(Init)
final initProvider = InitProvider._();

final class InitProvider extends $NotifierProvider<Init, bool> {
  InitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initHash();

  @$internal
  @override
  Init create() => Init();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$initHash() => r'7d3f11c8aff7a1924c5ec8886b2cd2cbdda57c3f';

abstract class _$Init extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentPageLabel)
final currentPageLabelProvider = CurrentPageLabelProvider._();

final class CurrentPageLabelProvider
    extends $NotifierProvider<CurrentPageLabel, PageLabel> {
  CurrentPageLabelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPageLabelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPageLabelHash();

  @$internal
  @override
  CurrentPageLabel create() => CurrentPageLabel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PageLabel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PageLabel>(value),
    );
  }
}

String _$currentPageLabelHash() => r'a4ed13348bcd406ec3be52138cf1083106d31215';

abstract class _$CurrentPageLabel extends $Notifier<PageLabel> {
  PageLabel build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PageLabel, PageLabel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PageLabel, PageLabel>,
              PageLabel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SortNum)
final sortNumProvider = SortNumProvider._();

final class SortNumProvider extends $NotifierProvider<SortNum, int> {
  SortNumProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortNumProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortNumHash();

  @$internal
  @override
  SortNum create() => SortNum();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sortNumHash() => r'b67bee9fdfbb74b484190fbc6e5c3da7d773bed0';

abstract class _$SortNum extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CheckIpNum)
final checkIpNumProvider = CheckIpNumProvider._();

final class CheckIpNumProvider extends $NotifierProvider<CheckIpNum, int> {
  CheckIpNumProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkIpNumProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkIpNumHash();

  @$internal
  @override
  CheckIpNum create() => CheckIpNum();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$checkIpNumHash() => r'4d8b32ed9c0013c056f90c9d5483f11fa5fddec5';

abstract class _$CheckIpNum extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BackBlock)
final backBlockProvider = BackBlockProvider._();

final class BackBlockProvider extends $NotifierProvider<BackBlock, bool> {
  BackBlockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backBlockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backBlockHash();

  @$internal
  @override
  BackBlock create() => BackBlock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$backBlockHash() => r'c0223e0776b72d3a8c8842fc32fdb5287353999f';

abstract class _$BackBlock extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Loading)
final loadingProvider = LoadingProvider._();

final class LoadingProvider extends $NotifierProvider<Loading, bool> {
  LoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadingHash();

  @$internal
  @override
  Loading create() => Loading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$loadingHash() => r'a0a09132a78495616785461cdc2a8b412c19b51b';

abstract class _$Loading extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Version)
final versionProvider = VersionProvider._();

final class VersionProvider extends $NotifierProvider<Version, int> {
  VersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versionHash();

  @$internal
  @override
  Version create() => Version();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$versionHash() => r'8c0ee019d20df3f112c38ae4dc4abd61148d3809';

abstract class _$Version extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Groups)
final groupsProvider = GroupsProvider._();

final class GroupsProvider extends $NotifierProvider<Groups, List<Group>> {
  GroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupsHash();

  @$internal
  @override
  Groups create() => Groups();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Group> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Group>>(value),
    );
  }
}

String _$groupsHash() => r'fbff504e0bcdb5a2770a902f2867aabd921fbadc';

abstract class _$Groups extends $Notifier<List<Group>> {
  List<Group> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Group>, List<Group>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Group>, List<Group>>,
              List<Group>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DelayDataSource)
final delayDataSourceProvider = DelayDataSourceProvider._();

final class DelayDataSourceProvider
    extends $NotifierProvider<DelayDataSource, DelayMap> {
  DelayDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'delayDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$delayDataSourceHash();

  @$internal
  @override
  DelayDataSource create() => DelayDataSource();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DelayMap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DelayMap>(value),
    );
  }
}

String _$delayDataSourceHash() => r'77dd4b5227407f64671e11e897b003989a75ea63';

abstract class _$DelayDataSource extends $Notifier<DelayMap> {
  DelayMap build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DelayMap, DelayMap>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DelayMap, DelayMap>,
              DelayMap,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SystemUiOverlayStyleState)
final systemUiOverlayStyleStateProvider = SystemUiOverlayStyleStateProvider._();

final class SystemUiOverlayStyleStateProvider
    extends $NotifierProvider<SystemUiOverlayStyleState, SystemUiOverlayStyle> {
  SystemUiOverlayStyleStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemUiOverlayStyleStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemUiOverlayStyleStateHash();

  @$internal
  @override
  SystemUiOverlayStyleState create() => SystemUiOverlayStyleState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SystemUiOverlayStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SystemUiOverlayStyle>(value),
    );
  }
}

String _$systemUiOverlayStyleStateHash() =>
    r'4420d92227ae617ce685c8943dda64f29f57d5d1';

abstract class _$SystemUiOverlayStyleState
    extends $Notifier<SystemUiOverlayStyle> {
  SystemUiOverlayStyle build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SystemUiOverlayStyle, SystemUiOverlayStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SystemUiOverlayStyle, SystemUiOverlayStyle>,
              SystemUiOverlayStyle,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider to track if VPN was stopped by Smart Auto Stop feature.
/// This is used to show different notification content when smart-stopped.

@ProviderFor(IsSmartStopped)
final isSmartStoppedProvider = IsSmartStoppedProvider._();

/// Provider to track if VPN was stopped by Smart Auto Stop feature.
/// This is used to show different notification content when smart-stopped.
final class IsSmartStoppedProvider
    extends $NotifierProvider<IsSmartStopped, bool> {
  /// Provider to track if VPN was stopped by Smart Auto Stop feature.
  /// This is used to show different notification content when smart-stopped.
  IsSmartStoppedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isSmartStoppedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isSmartStoppedHash();

  @$internal
  @override
  IsSmartStopped create() => IsSmartStopped();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSmartStoppedHash() => r'3f053dad10b19a0ee35a9bbbd5391395f0dcb5f7';

/// Provider to track if VPN was stopped by Smart Auto Stop feature.
/// This is used to show different notification content when smart-stopped.

abstract class _$IsSmartStopped extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
