import 'package:flutter/material.dart';

/// Custom scroll physics for virtual scrolling.
///
/// This class provides optimized scroll behavior for virtual lists
/// with large datasets.
class VirtualScrollPhysics extends ScrollPhysics {
  /// Creates virtual scroll physics.
  const VirtualScrollPhysics({
    super.parent,
    this.itemExtent,
  });

  /// The extent of each item.
  final double? itemExtent;

  @override
  VirtualScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return VirtualScrollPhysics(
      parent: buildParent(ancestor),
      itemExtent: itemExtent,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Apply custom boundary conditions for virtual scrolling
    if (itemExtent != null && position.maxScrollExtent > 0) {
      // Ensure smooth scrolling at boundaries
      final maxScroll = position.maxScrollExtent;
      if (value > maxScroll) {
        return value - maxScroll;
      }
      if (value < 0) {
        return value;
      }
    }
    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Custom ballistic simulation for virtual scrolling
    if (itemExtent != null && itemExtent! > 0) {
      // Snap to item boundaries for better UX
      final currentItem = (position.pixels / itemExtent!).round();
      final targetPixels = currentItem * itemExtent!;

      if ((targetPixels - position.pixels).abs() > itemExtent! * 0.1) {
        // Create a spring simulation to snap to the nearest item
        return ScrollSpringSimulation(
          spring,
          position.pixels,
          targetPixels,
          velocity,
        );
      }
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
