import 'package:flutter/widgets.dart';

import 'refresh_controller.dart';

/// 刷新状态
enum RefreshStatus {
  idle,
  prepared,
  refreshing,
  completed,
}

/// 刷新组件创建
typedef RefreshIndicatorBuilder = Widget Function(
    BuildContext context,
    RefreshStatus status,
    );

/// 刷新状态回调
typedef RefreshStatusDidChange = void Function(
    RefreshController controller,
    RefreshStatus status,
    );

/// tableView刷新控制类
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

  bool disposed = false;

  void dispose() {
    controller.dispose();
    disposed = true;
  }
}

/// 刷新组件配置
class RefreshIndicatorConfig {
  /// 触发刷新距离
  final double triggerDistance;

  /// 完成刷新后，停留在completed状态的停留时长
  final int completeDuration; // in millisecond

  /// 可见范围
  final double visibleRange;

  /// indicator高度，对于不定高度定indicator，可以不传
  /// 如果已经可以在build之前确定indicator高度，那么就不需要tableView内部自己再去计算高度，可以省略一次setState重新构建的步骤
  final double? indicatorHeight;

  const RefreshIndicatorConfig({
    this.visibleRange = 50,
    this.completeDuration = 300,
    this.triggerDistance = 100,
    this.indicatorHeight,
  });
}
