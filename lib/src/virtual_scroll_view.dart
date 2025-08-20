import 'package:flutter/material.dart';

/// Base class for virtual scrolling views.
///
/// This abstract class provides common functionality for virtual scrolling
/// implementations.
abstract class VirtualScrollView extends StatelessWidget {
  /// Creates a virtual scroll view.
  const VirtualScrollView({
    super.key,
    this.controller,
    this.physics,
    this.padding,
    this.cacheExtent = 250.0,
  });

  /// Controller for managing scroll behavior.
  final ScrollController? controller;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// The amount of space to cache beyond the visible viewport.
  final double cacheExtent;

  /// Builds the scrollable content.
  @override
  Widget build(BuildContext context);
}
