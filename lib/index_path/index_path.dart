import 'package:flutter/foundation.dart';

@immutable
class IndexPath {
  final int section;
  final int row;

  const IndexPath({required this.section, required this.row});

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != IndexPath) {
      return false;
    }
    IndexPath otherIndexPath = other as IndexPath;
    return section == otherIndexPath.section && row == otherIndexPath.row;
  }

  @override
  int get hashCode => section.hashCode & row.hashCode;

  @override
  String toString() {
    return 'section:$section row:$row';
  }
}
