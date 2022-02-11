import 'package:flutter/widgets.dart';

import 'refresh_controller.dart';

enum RefreshStatus {
  idle,
  prepared,
  refreshing,
  completed,
}

typedef RefreshIndicatorBuilder = Widget Function(BuildContext context, RefreshStatus status);
typedef RefreshStatusDidChange = void Function(RefreshController controller, RefreshStatus status);

class RefreshConfig {
  RefreshIndicatorConfig headerConfig;
  RefreshIndicatorConfig footerConfig;
  RefreshIndicatorBuilder? refreshHeaderBuilder;
  RefreshIndicatorBuilder? refreshFooterBuilder;
  RefreshStatusDidChange? onRefreshHeaderStatusChange;
  RefreshStatusDidChange? onRefreshFooterStatusChange;
  bool enablePullUp;
  bool enablePullDown;
  RefreshController controller;

  RefreshConfig({
    this.enablePullUp = true,
    this.enablePullDown = true,
    this.refreshHeaderBuilder,
    this.headerConfig = const RefreshIndicatorConfig(),
    this.onRefreshHeaderStatusChange,
    this.refreshFooterBuilder,
    this.footerConfig = const RefreshIndicatorConfig(),
    this.onRefreshFooterStatusChange,
    RefreshController? controller,
  }) : controller = controller ?? RefreshController();
}

class RefreshIndicatorConfig {
  final double triggerDistance;

  final int completeDuration; // in millisecond

  final double visibleRange;

  const RefreshIndicatorConfig({
    this.visibleRange = 50,
    this.completeDuration = 300,
    this.triggerDistance = 100,
  });
}
