import 'package:flutter/material.dart';

/// A high-performance virtual scrolling list view that only renders visible items.
///
/// This widget provides efficient memory usage by only rendering items that are
/// currently visible in the viewport, making it ideal for large datasets.
class VirtualListView extends StatelessWidget {
  /// Creates a virtual list view.
  const VirtualListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.physics,
    this.padding,
    this.itemExtent,
    this.cacheExtent = 250.0,
  });

  /// The total number of items in the list.
  final int itemCount;

  /// Builder function for creating list items.
  final IndexedWidgetBuilder itemBuilder;

  /// Controller for managing scroll behavior.
  final ScrollController? controller;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// The extent of each item in the scroll direction.
  final double? itemExtent;

  /// The amount of space to cache beyond the visible viewport.
  final double cacheExtent;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      physics: physics ?? const ClampingScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemExtent: itemExtent,
      cacheExtent: cacheExtent,
      itemBuilder: itemBuilder,
    );
  }
}
