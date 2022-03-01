import 'package:flutter/widgets.dart';

import 'refresh_config.dart';

/// 刷新控制类
class RefreshController {
  RefreshController();

  final ValueNotifier<RefreshStatus> _headerStatus =
      ValueNotifier(RefreshStatus.idle);

  /// refreshHeader的状态
  RefreshStatus get refreshHeaderStatus => _headerStatus.value;

  /// 设置refreshHeader的状态，可以通过设置这个值来改变tableView的刷新状态，比如完成刷新等
  set refreshHeaderStatus(RefreshStatus newValue) {
    if (_headerStatus.value != newValue) {
      _headerStatus.value = newValue;
    }
  }

  final ValueNotifier<RefreshStatus> _footerStatus =
      ValueNotifier(RefreshStatus.idle);

  /// refreshFooter的状态
  RefreshStatus get refreshFooterStatus => _footerStatus.value;

  /// 设置refreshFooter的状态，可以通过设置这个值来改变tableView的刷新状态，比如完成刷新等
  set refreshFooterStatus(RefreshStatus newValue) {
    if (_footerStatus.value != newValue) {
      _footerStatus.value = newValue;
    }
  }

  /// header是否出现refreshing状态中
  bool get isHeaderRefreshing =>
      refreshHeaderStatus == RefreshStatus.refreshing;

  /// footer是否出现refreshing状态中
  bool get isFooterRefreshing =>
      refreshFooterStatus == RefreshStatus.refreshing;

  /// 向header中增加一个listener。想要监听下拉动作的可以调用。
  void addHeaderListener(VoidCallback listener) {
    _headerStatus.addListener(listener);
  }

  /// 向footer中增加一个listener。想要监听下拉动作的可以调用。
  void addFooterListener(VoidCallback listener) {
    _footerStatus.addListener(listener);
  }

  /// 移除header listener
  void removeHeaderListener(VoidCallback listener) {
    _headerStatus.removeListener(listener);
  }

  /// 移除footer listener
  void removeFooterListener(VoidCallback listener) {
    _footerStatus.removeListener(listener);
  }

  /// dispose方法会在tableView dispose时被调用
  /// 如果有自己加listener，请在dispose之前remove
  void dispose() {
    _headerStatus.dispose();
    _footerStatus.dispose();
  }
}
