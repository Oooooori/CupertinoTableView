import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../delegate/cupertino_table_view_delegate.dart';
import '../../index_path/index_path.dart';
import '../refresh/refresh_config.dart';
import '../refresh/refresh_controller.dart';
import '../refresh/refresh_indicator.dart';
import 'cupertino_table_view_cell.dart';

class CupertinoTableView extends StatefulWidget {
  const CupertinoTableView({
    Key? key,
    required this.delegate,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.pressedOpacity,
    this.physics,
    this.refreshConfig,
    this.scrollController,
  }) : super(key: key);

  final CupertinoTableViewDelegate delegate;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? pressedOpacity;
  final ScrollPhysics? physics;
  final RefreshConfig? refreshConfig;
  final ScrollController? scrollController;

  @override
  State<CupertinoTableView> createState() => _CupertinoTableViewState();
}

class _CupertinoTableViewState extends State<CupertinoTableView> {
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  double _headerHeight = 0.0;
  double _footerHeight = 0.0;

  ScrollController? _fallbackScrollController;

  ScrollController get _effectiveScrollController => widget.scrollController ?? _fallbackScrollController!;

  @override
  void initState() {
    super.initState();
    _initScrollController();
    _addListener();
    _calculateHeight();
  }

  @override
  void dispose() {
    _removeListener();
    _disposeScrollController();
    widget.refreshConfig?.controller.dispose();
    super.dispose();
  }

  bool get enableRefresh {
    return widget.refreshConfig != null && (widget.refreshConfig!.enablePullUp || widget.refreshConfig!.enablePullDown);
  }

  @override
  Widget build(BuildContext context) {
    ListView list = _buildList();
    if (!enableRefresh) {
      return Container(
        color: widget.backgroundColor,
        margin: widget.margin,
        padding: widget.padding,
        child: list,
      );
    }

    RefreshConfig refreshConfig = widget.refreshConfig!;
    List<Widget> slivers = List.from(list.buildSlivers(context));
    if (refreshConfig.enablePullUp) {
      slivers.add(SliverToBoxAdapter(child: _buildRefreshFooter(refreshConfig)));
    }
    if (refreshConfig.enablePullDown) {
      slivers.insert(0, SliverToBoxAdapter(child: _buildRefreshHeader(refreshConfig)));
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: <Widget>[
          Positioned(
            top: refreshConfig.enablePullDown ? -_headerHeight : 0,
            bottom: refreshConfig.enablePullUp ? -_footerHeight : 0,
            left: 0,
            right: 0,
            child: NotificationListener(
              child: Container(
                color: widget.backgroundColor,
                margin: widget.margin,
                padding: widget.padding,
                child: CustomScrollView(
                  key: widget.key,
                  physics: widget.physics,
                  controller: _effectiveScrollController,
                  slivers: slivers,
                ),
              ),
              onNotification: _dispatchScrollEvent,
            ),
          ),
        ],
      );
    });
  }

  ListView _buildList() {
    return ListView.builder(
      physics: widget.physics,
      itemCount: widget.delegate.numberOfSectionsInTableView(),
      itemBuilder: _buildSection,
    );
  }

  Widget _buildSection(BuildContext context, int section) {
    int numberOfRowInSection = widget.delegate.numberOfRowsInSection?.call(section) ?? 0;
    if (numberOfRowInSection == 0) {
      return const SizedBox();
    }
    return Column(
      children: [
        _buildHeaderInSection(context, section),
        Container(
          clipBehavior: Clip.hardEdge,
          margin: widget.delegate.marginForSection,
          decoration: widget.delegate.decorationForSection?.call(context, section),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: numberOfRowInSection,
            itemBuilder: (context, index) => _buildCell(context, IndexPath(section: section, row: index)),
            separatorBuilder: (context, index) => _buildDivider(context),
          ),
        ),
        _buildFooterInSection(context, section),
      ],
    );
  }

  Widget _buildCell(BuildContext context, IndexPath indexPath) {
    return CupertinoTableViewCell(
      pressedOpacity: widget.pressedOpacity,
      onTap: onTapHandler(indexPath),
      builder: (context) => widget.delegate.cellForRowAtIndexPath(context, indexPath),
    );
  }

  Widget _buildHeaderInSection(BuildContext context, int section) {
    return widget.delegate.headerInSection?.call(context, section) ?? const SizedBox();
  }

  Widget _buildFooterInSection(BuildContext context, int section) {
    return widget.delegate.footerInSection?.call(context, section) ?? const SizedBox();
  }

  Widget _buildDivider(BuildContext context) {
    return widget.delegate.dividerInTableView?.call(context) ??
        const Divider(
          height: 1,
          thickness: 1,
          indent: 15,
          endIndent: 15,
          color: Color(0x00f7f7f7),
        );
  }

  VoidCallback? onTapHandler(IndexPath indexPath) {
    if (!(widget.delegate.canSelectRowAtIndexPath?.call(indexPath) ?? true)) {
      return null;
    }
    if (widget.delegate.didSelectRowAtIndexPath == null) {
      return null;
    }
    return () => widget.delegate.didSelectRowAtIndexPath?.call(indexPath);
  }

  Widget _buildRefreshHeader(RefreshConfig config) {
    if (config.refreshHeaderBuilder == null) {
      return const SizedBox();
    }
    return RefreshHeader(
      key: _headerKey,
      refreshController: config.controller,
      indicatorBuilder: config.refreshHeaderBuilder!,
      config: config.headerConfig,
    );
  }

  Widget _buildRefreshFooter(RefreshConfig config) {
    if (config.refreshFooterBuilder == null) {
      return const SizedBox();
    }
    return RefreshFooter(
      key: _footerKey,
      refreshController: config.controller,
      indicatorBuilder: config.refreshFooterBuilder!,
      config: config.footerConfig,
    );
  }

  void _initScrollController() {
    if (widget.scrollController == null) {
      _fallbackScrollController = ScrollController();
    }
  }

  void _disposeScrollController() {
    if (widget.scrollController != null) {
      widget.scrollController!.dispose();
    } else {
      _fallbackScrollController?.dispose();
    }
  }

  void _addListener() {
    if (widget.refreshConfig == null) {
      return;
    }
    RefreshController controller = widget.refreshConfig!.controller;
    controller.addHeaderListener(_headerStatusDidChange);
    controller.addFooterListener(_footerStatusDidChange);
  }

  void _removeListener() {
    if (widget.refreshConfig == null) {
      return;
    }
    RefreshController controller = widget.refreshConfig!.controller;
    controller.removeHeaderListener(_headerStatusDidChange);
    controller.removeFooterListener(_footerStatusDidChange);
  }

  void _headerStatusDidChange() {
    if (widget.refreshConfig == null) {
      return;
    }
    RefreshController controller = widget.refreshConfig!.controller;
    _refreshHeaderStatusDidChange(controller, controller.refreshHeaderStatus);
  }

  void _footerStatusDidChange() {
    if (widget.refreshConfig == null) {
      return;
    }
    RefreshController controller = widget.refreshConfig!.controller;
    _refreshFooterStatusDidChange(controller, controller.refreshFooterStatus);
  }

  void _refreshHeaderStatusDidChange(RefreshController controller, RefreshStatus status) {
    widget.refreshConfig!.onRefreshHeaderStatusChange?.call(controller, status);
    switch (status) {
      case RefreshStatus.refreshing:
        RefreshIndicatorConfig config = widget.refreshConfig!.headerConfig;
        jumpTo(currentOffset + config.visibleRange);
        break;
      case RefreshStatus.idle:
        break;
      case RefreshStatus.prepared:
        break;
      case RefreshStatus.completed:
        break;
    }
  }

  void _refreshFooterStatusDidChange(RefreshController controller, RefreshStatus status) {
    widget.refreshConfig!.onRefreshFooterStatusChange?.call(controller, status);
  }

  void _calculateHeight() {
    if (widget.refreshConfig == null) {
      return;
    }
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        if (widget.refreshConfig!.enablePullDown) {
          _headerHeight = _headerKey.currentContext?.size?.height ?? 0;
        }
        if (widget.refreshConfig!.enablePullUp) {
          _footerHeight = _footerKey.currentContext?.size?.height ?? 0;
        }
      });
    });
  }

  bool _handleScrollStart(ScrollStartNotification notification) {
    if (widget.refreshConfig == null) {
      return false;
    }
    if ((notification.metrics.outOfRange)) {
      return false;
    }

    if (widget.refreshConfig!.enablePullDown) {
      dynamic state = _headerKey.currentState;
      if (_headerKey.currentState == null) {
        return false;
      }
      DragProcessor header = state as DragProcessor;
      header.onDragStart(notification);
    }

    if (widget.refreshConfig!.enablePullUp) {
      dynamic state = _footerKey.currentState;
      if (state == null) {
        return false;
      }
      DragProcessor footer = state as DragProcessor;
      footer.onDragStart(notification);
    }

    return false;
  }

  bool _handleScrollMoving(ScrollUpdateNotification notification) {
    if (widget.refreshConfig == null) {
      return false;
    }

    if (widget.refreshConfig!.enablePullDown) {
      dynamic state = _headerKey.currentState;
      if (_headerKey.currentState == null) {
        return false;
      }
      DragProcessor header = state as DragProcessor;
      header.onDragMove(notification);
    }

    if (widget.refreshConfig!.enablePullUp) {
      dynamic state = _footerKey.currentState;
      if (state == null) {
        return false;
      }
      DragProcessor footer = state as DragProcessor;
      footer.onDragMove(notification);
    }

    return false;
  }

  bool _handleScrollEnd(ScrollNotification notification) {
    if (widget.refreshConfig == null) {
      return false;
    }

    if (widget.refreshConfig!.enablePullDown) {
      dynamic state = _headerKey.currentState;
      if (_headerKey.currentState == null) {
        return false;
      }
      DragProcessor header = state as DragProcessor;
      header.onDragEnd(notification);
    }

    if (widget.refreshConfig!.enablePullUp) {
      dynamic state = _footerKey.currentState;
      if (state == null) {
        return false;
      }
      DragProcessor footer = state as DragProcessor;
      footer.onDragEnd(notification);
    }

    return false;
  }

  bool _dispatchScrollEvent(ScrollNotification notification) {
    bool pullUp = notification.metrics.pixels < 0;
    bool pullDown = notification.metrics.pixels > 0;
    if (!pullUp && !pullDown) {
      return false;
    }

    if (notification is ScrollStartNotification) {
      return _handleScrollStart(notification);
    }

    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails == null) {
        // dragDetails为空表示手指离开了滑动区域
        return _handleScrollEnd(notification);
      } else {
        return _handleScrollMoving(notification);
      }
    }

    if (notification is ScrollEndNotification) {
      return _handleScrollEnd(notification);
    }

    return false;
  }

  double get currentOffset => _effectiveScrollController.offset;

  void jumpTo(double offset) {
    _effectiveScrollController.jumpTo(offset);
  }

  Future<void> animateTo(double offset, {required Duration duration, required Curve curve}) {
    return _effectiveScrollController.animateTo(offset, duration: duration, curve: curve);
  }
}
