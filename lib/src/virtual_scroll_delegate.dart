import 'package:flutter/material.dart';

/// A delegate for virtual scrolling that implements [SliverChildDelegate].
///
/// This delegate provides efficient item building and management for virtual lists.
class VirtualScrollDelegate extends SliverChildDelegate {
  /// Creates a virtual scroll delegate.
  const VirtualScrollDelegate({
    required this.itemCount,
    required this.itemBuilder,
    this.itemExtent,
    this.cacheExtent = 250.0,
  });

  /// The total number of items.
  final int itemCount;

  /// Builder function for creating list items.
  final IndexedWidgetBuilder itemBuilder;

  /// The extent of each item.
  final double? itemExtent;

  /// The amount of space to cache beyond the visible viewport.
  final double cacheExtent;

  @override
  Widget? build(BuildContext context, int index) {
    if (index < 0 || index >= itemCount) return null;
    return itemBuilder(context, index);
  }

  /// The total number of children.
  int? get childCount => itemCount;

  @override
  bool shouldRebuild(covariant VirtualScrollDelegate oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.itemBuilder != itemBuilder ||
        oldDelegate.itemExtent != itemExtent ||
        oldDelegate.cacheExtent != cacheExtent;
  }

  /// The extent of each child.
  double? get childExtent => itemExtent;

  /// The estimated extent of each child.
  double get estimatedChildExtent => itemExtent ?? 100.0;

  @override
  String toString() {
    return 'VirtualScrollDelegate(itemCount: $itemCount)';
  }
}
