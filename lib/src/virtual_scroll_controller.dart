import 'package:flutter/material.dart';

/// A controller for virtual scrolling that extends [ScrollController].
///
/// This controller provides additional functionality for managing virtual scroll
/// behavior and performance optimization.
class VirtualScrollController extends ScrollController {
  /// Creates a virtual scroll controller.
  VirtualScrollController({
    double? initialScrollOffset,
    bool? keepScrollOffset,
    String? debugLabel,
  }) : super(
          initialScrollOffset: initialScrollOffset ?? 0.0,
          keepScrollOffset: keepScrollOffset ?? true,
          debugLabel: debugLabel,
        );

  /// Scrolls to a specific item index.
  Future<void> scrollToItem(
    int index, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!hasClients) return;

    // For now, just scroll to a calculated offset
    // In a real implementation, this would calculate the item position
    final targetOffset = index * 100.0; // Assuming 100px per item
    await animateTo(
      targetOffset,
      duration: duration,
      curve: curve,
    );
  }

  /// Jumps to a specific item index without animation.
  void jumpToItem(int index) {
    if (!hasClients) return;

    // For now, just jump to a calculated offset
    final targetOffset = index * 100.0; // Assuming 100px per item
    jumpTo(targetOffset);
  }

  /// Gets the current visible item range.
  List<int> getVisibleItemRange() {
    if (!hasClients) return [];

    final position = this.position;

    // Calculate visible range based on scroll position and viewport
    final startIndex = (position.pixels / 100.0).floor();
    final endIndex =
        ((position.pixels + position.viewportDimension) / 100.0).ceil();

    return List.generate(
      endIndex - startIndex + 1,
      (i) => startIndex + i,
    ).where((index) => index >= 0).toList();
  }

  /// Checks if an item is currently visible.
  bool isItemVisible(int index) {
    if (!hasClients) return false;

    final position = this.position;

    final itemOffset = index * 100.0; // Assuming 100px per item
    final itemHeight = 100.0;

    return itemOffset < position.pixels + position.viewportDimension &&
        itemOffset + itemHeight > position.pixels;
  }
}
