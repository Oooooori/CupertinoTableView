import 'package:flutter/widgets.dart';

import 'refresh_config.dart';

class RefreshController {
  RefreshController();

  final ValueNotifier<RefreshStatus> _headerStatus = ValueNotifier(RefreshStatus.idle);

  RefreshStatus get refreshHeaderStatus => _headerStatus.value;

  set refreshHeaderStatus(RefreshStatus newValue) {
    if (_headerStatus.value != newValue) {
      _headerStatus.value = newValue;
    }
  }

  final ValueNotifier<RefreshStatus> _footerStatus = ValueNotifier(RefreshStatus.idle);

  RefreshStatus get refreshFooterStatus => _footerStatus.value;

  set refreshFooterStatus(RefreshStatus newValue) {
    if (_footerStatus.value != newValue) {
      _footerStatus.value = newValue;
    }
  }

  bool get isHeaderRefreshing => refreshHeaderStatus == RefreshStatus.refreshing;

  bool get isFooterRefreshing => refreshFooterStatus == RefreshStatus.refreshing;

  void addHeaderListener(VoidCallback listener) {
    _headerStatus.addListener(listener);
  }

  void addFooterListener(VoidCallback listener) {
    _footerStatus.addListener(listener);
  }

  void removeHeaderListener(VoidCallback listener) {
    _headerStatus.removeListener(listener);
  }

  void removeFooterListener(VoidCallback listener) {
    _footerStatus.removeListener(listener);
  }

  void dispose() {
    _headerStatus.dispose();
    _footerStatus.dispose();
  }
}
