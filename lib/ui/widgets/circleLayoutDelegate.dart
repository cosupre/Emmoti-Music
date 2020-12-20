import 'package:flutter/material.dart';

class CircleLayoutDelegate extends MultiChildLayoutDelegate {
  CircleLayoutDelegate({this.position, this.getChildrenOffset, this.itemLength = 0});

  final Offset position;
  final int itemLength;

  Function getChildrenOffset = (id, size) => Offset.zero;

  @override
  void performLayout(Size size) {
    for (int i = 1; i <= itemLength; i += 1) {
      if (hasChild(i)) {
        Size itemSize = layoutChild(
          i, // The id once again.
          BoxConstraints.loose(size), // This just says that the child cannot be bigger than the whole layout.
        );

        positionChild(i, getChildrenOffset(i, itemSize));
      }
    }
  }

  @override
  bool shouldRelayout(CircleLayoutDelegate oldDelegate) {
    return oldDelegate.position != position || oldDelegate.itemLength != itemLength;
  }
}