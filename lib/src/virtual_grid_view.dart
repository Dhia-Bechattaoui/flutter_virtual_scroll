import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A high-performance virtual scrolling grid view.
///
/// This widget provides efficient memory usage by only rendering grid items
/// that are currently visible in the viewport.
class VirtualGridView extends StatelessWidget {
  /// Creates a virtual grid view.
  const VirtualGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.physics,
    this.padding,
    this.cacheExtent = 250.0,
  });

  /// The total number of items in the grid.
  final int itemCount;

  /// Builder function for creating grid items.
  final IndexedWidgetBuilder itemBuilder;

  /// Controls the layout of the children within the grid.
  final SliverGridDelegate gridDelegate;

  /// Controller for managing scroll behavior.
  final ScrollController? controller;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// The amount of space to cache beyond the visible viewport.
  final double cacheExtent;

  @override
  Widget build(BuildContext context) {
    // Web/WASM optimization: Use larger cache extent for smoother scrolling
    final optimizedCacheExtent = kIsWeb ? cacheExtent * 1.5 : cacheExtent;

    return Semantics(
      label: 'Virtual grid with $itemCount items',
      hint: 'Scroll to navigate through the grid',
      child: GridView.builder(
        controller: controller,
        physics: physics ?? const ClampingScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        cacheExtent: optimizedCacheExtent,
        itemBuilder: (context, index) {
          return Semantics(
            label: 'Grid item ${index + 1} of $itemCount',
            child: itemBuilder(context, index),
          );
        },
        gridDelegate: gridDelegate,
      ),
    );
  }
}
