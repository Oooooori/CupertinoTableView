import 'package:flutter/cupertino.dart';

import 'refresh_config.dart';
import 'refresh_controller.dart';

/// 默认的刷新组件
/// 默认可以显示一张图片和一段文字
/// 文字和图片左右布局
class DefaultRefreshIndicator extends StatelessWidget {
  const DefaultRefreshIndicator({
    Key? key,
    this.text,
    this.textStyle = const TextStyle(color: Color(0xff555555)),
    this.icon,
    this.height = 60.0,
  }) : super(key: key);

  final String? text;

  final Widget? icon;

  final double height;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    Widget textWidget = _buildText();
    Widget iconWidget = _buildIcon();
    return Container(
      alignment: Alignment.center,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textWidget,
          const SizedBox(width: 15),
          iconWidget,
        ],
      ),
    );
  }

  Widget _buildText() {
    if (text?.isEmpty ?? true) {
      return const SizedBox();
    }
    return Text(text!, style: textStyle);
  }

  Widget _buildIcon() {
    if (icon == null) {
      return const SizedBox();
    }
    return icon!;
  }
}

/// 内部刷新组件类
abstract class _RefreshIndicator extends StatefulWidget {
  final RefreshIndicatorBuilder indicatorBuilder;

  final RefreshController refreshController;

  final RefreshIndicatorConfig config;

  RefreshStatus get status;

  /// 刷新状态
  set status(RefreshStatus status);

  /// 是否处在刷新中
  bool get isRefreshing => status == RefreshStatus.refreshing;

  /// 是否刷新完成
  bool get isCompleted => status == RefreshStatus.completed;

  const _RefreshIndicator({
    Key? key,
    required this.refreshController,
    required this.indicatorBuilder,
    required this.config,
  }) : super(key: key);
}

/// 内部刷新组件状态，处理下拉/上拉事件，改变自身状态
/// 根据不同状态改变自身高度，达到显示和隐藏刷新组件的效果
abstract class _RefreshIndicatorState<T extends _RefreshIndicator>
    extends State<T> with TickerProviderStateMixin implements DragProcessor {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      duration: const Duration(milliseconds: 250),
    );
    widget.refreshController.addHeaderListener(_handleStatusChange);
    widget.refreshController.addFooterListener(_handleStatusChange);
  }

  @override
  void dispose() {
    widget.refreshController.removeHeaderListener(_handleStatusChange);
    widget.refreshController.removeFooterListener(_handleStatusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _handleStatusChange() {
    setState(() {
      switch (widget.status) {
        case RefreshStatus.refreshing:
          _animationController.value = 1.0;
          break;
        case RefreshStatus.completed:
          Future.delayed(
              Duration(milliseconds: widget.config.completeDuration), _dismiss);
          break;
        case RefreshStatus.idle:
          break;
        case RefreshStatus.prepared:
          break;
      }
    });
  }

  void _dismiss() {
    if (!mounted) {
      return;
    }
    _animationController.animateTo(0).then((dynamic value) {
      widget.status = RefreshStatus.idle;
    });
  }

  @override
  void onDragStart(ScrollStartNotification notification) {}

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    if (!_isScrollOutSide(notification)) {
      return;
    }
    if (widget.isCompleted || widget.isRefreshing) {
      return;
    }

    double offset = _measureOffset(notification);
    if (offset >= 1.0) {
      widget.status = RefreshStatus.prepared;
    } else {
      widget.status = RefreshStatus.idle;
    }
  }

  @override
  void onDragEnd(ScrollNotification notification) {
    if (!_isScrollOutSide(notification)) {
      return;
    }
    if (widget.isCompleted || widget.isRefreshing) {
      return;
    }
    bool max = _measureOffset(notification) >= 1.0;
    if (!max) {
      _animationController.animateTo(0);
    } else {
      widget.status = RefreshStatus.refreshing;
    }
  }

  bool _isScrollOutSide(ScrollNotification notification);

  double _measureOffset(ScrollNotification notification);
}

/// 刷新header，布局顺序与footer不同
class RefreshHeader extends _RefreshIndicator {
  const RefreshHeader({
    Key? key,
    required RefreshController refreshController,
    required RefreshIndicatorBuilder indicatorBuilder,
    required RefreshIndicatorConfig config,
  }) : super(
          key: key,
          config: config,
          refreshController: refreshController,
          indicatorBuilder: indicatorBuilder,
        );

  @override
  State<StatefulWidget> createState() {
    return _RefreshHeaderState();
  }

  @override
  RefreshStatus get status => refreshController.refreshHeaderStatus;

  @override
  set status(RefreshStatus newValue) =>
      refreshController.refreshHeaderStatus = newValue;
}

class _RefreshHeaderState extends _RefreshIndicatorState<RefreshHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizeTransition(
          sizeFactor: _animationController,
          child: Container(height: widget.config.visibleRange),
        ),
        widget.indicatorBuilder(context, widget.status),
      ],
    );
  }

  @override
  bool _isScrollOutSide(ScrollNotification notification) {
    return notification.metrics.minScrollExtent > notification.metrics.pixels;
  }

  @override
  double _measureOffset(ScrollNotification notification) {
    return (notification.metrics.minScrollExtent -
            notification.metrics.pixels) /
        widget.config.triggerDistance;
  }
}

/// 刷新footer，布局顺序与header不同
class RefreshFooter extends _RefreshIndicator {
  const RefreshFooter({
    Key? key,
    required RefreshController refreshController,
    required RefreshIndicatorBuilder indicatorBuilder,
    required RefreshIndicatorConfig config,
  }) : super(
          key: key,
          config: config,
          refreshController: refreshController,
          indicatorBuilder: indicatorBuilder,
        );

  @override
  State<StatefulWidget> createState() {
    return _RefreshFooterState();
  }

  @override
  RefreshStatus get status => refreshController.refreshFooterStatus;

  @override
  set status(RefreshStatus newValue) =>
      refreshController.refreshFooterStatus = newValue;
}

class _RefreshFooterState extends _RefreshIndicatorState<RefreshFooter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        widget.indicatorBuilder(context, widget.status),
        SizeTransition(
          sizeFactor: _animationController,
          child: Container(height: widget.config.visibleRange),
        )
      ],
    );
  }

  @override
  bool _isScrollOutSide(ScrollNotification notification) {
    return notification.metrics.pixels > notification.metrics.maxScrollExtent;
  }

  @override
  double _measureOffset(ScrollNotification notification) {
    return (notification.metrics.pixels -
            notification.metrics.maxScrollExtent) /
        widget.config.triggerDistance;
  }
}

/// drag处理接口
abstract class DragProcessor {
  /// 开始
  void onDragStart(ScrollStartNotification notification);

  /// 移动
  void onDragMove(ScrollUpdateNotification notification);

  /// 停止
  void onDragEnd(ScrollNotification notification);
}
