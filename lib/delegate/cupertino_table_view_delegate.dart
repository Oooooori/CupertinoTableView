import 'package:flutter/material.dart';

import '../index_path/index_path.dart';

typedef NumberOfSectionsInTableView = int Function();
typedef NumberOfRowsInSection = int Function(int section);
typedef WidgetAtIndexPath = Widget Function(
  BuildContext context,
  IndexPath indexPath,
);
typedef WidgetInSection = Widget? Function(
  BuildContext context,
  int section,
);
typedef DecorationForSection = Decoration? Function(
  BuildContext context,
  int section,
);
typedef SelectRowAtIndexPath = void Function(IndexPath indexPath);
typedef CanSelectRowAtIndexPath = bool Function(IndexPath indexPath);
typedef DividerInTableView = Widget Function(BuildContext context);

/// CupertinoTableView代理类，提供数据源和定制UI
class CupertinoTableViewDelegate {
  CupertinoTableViewDelegate({
    required this.numberOfSectionsInTableView,
    this.numberOfRowsInSection,
    required this.cellForRowAtIndexPath,
    this.headerInSection,
    this.footerInSection,
    this.decorationForSection,
    this.marginForSection,
    this.canSelectRowAtIndexPath,
    this.didSelectRowAtIndexPath,
    this.hitBehaviorAtIndexPath,
    this.dividerInTableView,
    this.pressedOpacity,
  });

  NumberOfSectionsInTableView numberOfSectionsInTableView;
  NumberOfRowsInSection? numberOfRowsInSection;
  WidgetAtIndexPath cellForRowAtIndexPath;
  WidgetInSection? headerInSection;
  WidgetInSection? footerInSection;
  DecorationForSection? decorationForSection;
  EdgeInsets? marginForSection;
  CanSelectRowAtIndexPath? canSelectRowAtIndexPath;
  SelectRowAtIndexPath? didSelectRowAtIndexPath;
  HitTestBehavior? hitBehaviorAtIndexPath;
  DividerInTableView? dividerInTableView;
  double? pressedOpacity;
}
