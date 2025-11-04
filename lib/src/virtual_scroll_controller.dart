import 'package:flutter/material.dart';

/// A controller for virtual scrolling that extends [ScrollController].
///
/// This controller provides additional functionality for managing virtual scroll
/// behavior and performance optimization.
class VirtualScrollController extends ScrollController {
  /// Creates a virtual scroll controller.
  VirtualScrollController({
    super.initialScrollOffset = 0.0,
    super.keepScrollOffset = true,
    super.debugLabel,
    this.itemExtent,
    this.crossAxisCount,
    this.rowExtent,
    this.itemCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.padding,
  });

  /// The extent (height) of each item in the scroll direction.
  /// If not provided, will be estimated from scroll metrics.
  final double? itemExtent;

  /// Number of columns in grid layout (for grid views).
  /// If provided, scroll calculations will account for grid rows.
  final int? crossAxisCount;

  /// The extent (height) of each row in grid layout.
  /// If not provided, will be estimated from scroll metrics.
  final double? rowExtent;

  /// Total number of items (for better grid row height estimation).
  final int? itemCount;

  /// Spacing between rows in grid layout (main axis spacing).
  final double? mainAxisSpacing;

  /// Spacing between columns in grid layout (cross axis spacing).
  final double? crossAxisSpacing;

  /// Aspect ratio of grid items (width / height).
  final double? childAspectRatio;

  /// Padding around the grid.
  final EdgeInsetsGeometry? padding;

  /// Estimates the item extent from scroll position and metrics.
  double _estimateItemExtent() {
    if (!hasClients) return 80.0; // Default fallback

    final position = this.position;
    if (!position.hasContentDimensions) return 80.0;

    // Try to estimate from maxScrollExtent if available
    // This is a rough estimate - in production, itemExtent should be provided
    if (position.maxScrollExtent > 0) {
      // Estimate based on typical list sizes
      // For lists with many items, estimate average item height
      final estimatedItems = (position.maxScrollExtent / 100.0).ceil();
      if (estimatedItems > 100) {
        // For large lists, estimate from scroll extent
        return position.maxScrollExtent / estimatedItems;
      }
    }

    // Default fallback
    return 80.0;
  }

  /// Estimates the row extent for grid layouts.
  double _estimateRowExtent() {
    if (!hasClients || crossAxisCount == null) return 100.0; // Default fallback

    final position = this.position;
    if (!position.hasContentDimensions) return 100.0;

    // If we have all the grid parameters, calculate exactly from layout
    if (crossAxisCount != null &&
        childAspectRatio != null &&
        mainAxisSpacing != null &&
        padding != null) {
      // Calculate item dimensions from viewport
      // For vertical grids, we need the viewport width to calculate item width
      // viewportDimension is the height for vertical scrolling, but we need width
      // We can estimate width from the scroll context or use a different approach

      // Try to calculate from maxScrollExtent and total content height
      // For a grid: totalContentHeight = paddingTop + (rows * itemHeight) + (rows-1 * spacing) + paddingBottom
      // maxScrollExtent = totalContentHeight - viewportHeight
      // So: totalContentHeight = maxScrollExtent + viewportHeight
      if (position.maxScrollExtent > 0 && itemCount != null && itemCount! > 0) {
        final totalRows = (itemCount! / crossAxisCount!).ceil();
        if (totalRows > 0) {
          final paddingResolved = padding!.resolve(TextDirection.ltr);
          final totalContentHeight =
              position.maxScrollExtent + position.viewportDimension;

          // Calculate: totalContentHeight = paddingTop + paddingBottom + (rows * itemHeight) + ((rows-1) * spacing)
          // So: (rows * itemHeight) + ((rows-1) * spacing) = totalContentHeight - paddingTop - paddingBottom
          final contentHeight =
              totalContentHeight - paddingResolved.top - paddingResolved.bottom;

          // contentHeight = (rows * itemHeight) + ((rows-1) * spacing)
          // contentHeight = (rows * itemHeight) + (rows * spacing) - spacing
          // contentHeight = rows * (itemHeight + spacing) - spacing
          // contentHeight + spacing = rows * (itemHeight + spacing)
          // (itemHeight + spacing) = (contentHeight + spacing) / rows
          // itemHeight = ((contentHeight + spacing) / rows) - spacing
          // rowHeight = itemHeight + spacing = (contentHeight + spacing) / rows
          if (totalRows > 0) {
            final rowHeight = (contentHeight + mainAxisSpacing!) / totalRows;
            return rowHeight;
          }
        }
      }
    }

    // Fallback: use maxScrollExtent calculation with calibration
    if (position.maxScrollExtent > 0 && itemCount != null && itemCount! > 0) {
      final totalRows = (itemCount! / crossAxisCount!).ceil();
      if (totalRows > 0) {
        // Try to calibrate from current position if scrolled
        if (position.pixels > 10 &&
            position.pixels < position.maxScrollExtent - 10) {
          final approximateRowHeight = position.maxScrollExtent / totalRows;
          final estimatedRow = (position.pixels / approximateRowHeight).round();
          if (estimatedRow > 0 && estimatedRow < totalRows) {
            return position.pixels / estimatedRow;
          }
        }
        return (position.maxScrollExtent / totalRows).clamp(50.0, 200.0);
      }
    }

    // Default fallback
    return 100.0;
  }

  /// Gets the item extent to use for calculations.
  double get _effectiveItemExtent => itemExtent ?? _estimateItemExtent();

  /// Gets the row extent to use for grid calculations.
  double get _effectiveRowExtent => rowExtent ?? _estimateRowExtent();

  /// Scrolls to a specific item index.
  Future<void> scrollToItem(
    int index, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    bool alignToTop = true,
  }) async {
    if (!hasClients) return;

    final position = this.position;

    if (crossAxisCount != null) {
      // For grids: calculate row index and scroll to that row
      final rowIndex = index ~/ crossAxisCount!;

      if (position.hasContentDimensions &&
          position.maxScrollExtent > 0 &&
          itemCount != null &&
          itemCount! > 0) {
        final totalRows = (itemCount! / crossAxisCount!).ceil();

        if (totalRows > 0) {
          // Use the effective row extent which uses the best available calculation
          final rowHeight = _effectiveRowExtent;

          // Calculate target offset for the target row
          // In GridView, scroll position 0 shows padding at the top
          // Row 0 content starts after padding, row N content starts at N * rowHeight from scroll position 0
          // To show row N content at the top of viewport: scroll to N * rowHeight
          // The rowHeight calculation already accounts for padding and spacing
          double targetOffset = rowIndex * rowHeight;

          // Small adjustment to ensure row is fully visible (not cut off at top)
          // This accounts for any small rounding errors in row height calculation
          // Subtract a small amount to ensure the row content is fully visible
          if (rowIndex > 0) {
            // Account for potential rounding errors in row height calculation
            // If padding exists, the adjustment might need to be larger
            final adjustment = padding != null ? 2.0 : 1.0;
            targetOffset -= adjustment;
          }

          // Clamp and scroll
          targetOffset = targetOffset.clamp(0.0, position.maxScrollExtent);

          await animateTo(targetOffset, duration: duration, curve: curve);

          // Fine-tune: after animation, verify we're at the right position
          if (alignToTop) {
            await Future.delayed(duration + const Duration(milliseconds: 150));

            if (hasClients && position.hasContentDimensions) {
              // Recalculate row height using the most accurate method
              final updatedTotalRows = (itemCount! / crossAxisCount!).ceil();
              if (updatedTotalRows > 0) {
                final currentPixels = position.pixels;
                final updatedMaxExtent = position.maxScrollExtent;
                final preciseRowHeight = _effectiveRowExtent;

                // Calculate the exact target offset
                // Don't add padding - it's already accounted for in GridView's layout
                // Apply same small adjustment to ensure row is fully visible
                double exactTargetOffset = rowIndex * preciseRowHeight;
                if (rowIndex > 0) {
                  final adjustment = padding != null ? 2.0 : 1.0;
                  exactTargetOffset -= adjustment;
                }

                // Check if we're showing the wrong row
                // Estimate current row from scroll position
                final currentRowEstimate = (currentPixels / preciseRowHeight)
                    .floor();

                // If we're off by a row or more, make a correction
                if (currentRowEstimate != rowIndex ||
                    (exactTargetOffset - currentPixels).abs() > 5.0) {
                  await animateTo(
                    exactTargetOffset.clamp(0.0, updatedMaxExtent),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                }
              }
            }
          }
          return;
        }
      }

      // Fallback if dimensions not ready
      final fallbackRowHeight = _effectiveRowExtent;
      await animateTo(
        (rowIndex * fallbackRowHeight).clamp(0.0, position.maxScrollExtent),
        duration: duration,
        curve: curve,
      );
      return;
    }

    // For lists: scroll directly to item
    final itemHeight = _effectiveItemExtent;
    final targetOffset = index * itemHeight;
    await animateTo(
      targetOffset.clamp(0.0, position.maxScrollExtent),
      duration: duration,
      curve: curve,
    );
  }

  /// Jumps to a specific item index without animation.
  void jumpToItem(int index) {
    if (!hasClients) return;

    double targetOffset;
    if (crossAxisCount != null) {
      // For grids: calculate row index and jump to that row
      final rowIndex = index ~/ crossAxisCount!;

      // Use a more precise calculation using maxScrollExtent
      final position = this.position;
      if (position.hasContentDimensions &&
          position.maxScrollExtent > 0 &&
          itemCount != null &&
          itemCount! > 0) {
        final totalRows = (itemCount! / crossAxisCount!).ceil();
        if (totalRows > 0) {
          final exactRowHeight = position.maxScrollExtent / totalRows;
          targetOffset = rowIndex * exactRowHeight;
        } else {
          targetOffset = rowIndex * _effectiveRowExtent;
        }
      } else {
        targetOffset = rowIndex * _effectiveRowExtent;
      }
    } else {
      // For lists: jump directly to item
      final itemHeight = _effectiveItemExtent;
      targetOffset = index * itemHeight;
    }

    jumpTo(targetOffset.clamp(0.0, position.maxScrollExtent));
  }

  /// Gets the current visible item range.
  List<int> getVisibleItemRange() {
    if (!hasClients) return [];

    final position = this.position;
    if (!position.hasContentDimensions) return [];

    final itemHeight = _effectiveItemExtent;
    final startIndex = (position.pixels / itemHeight).floor();
    final endIndex =
        ((position.pixels + position.viewportDimension) / itemHeight).ceil();

    return List.generate(
      endIndex - startIndex + 1,
      (i) => startIndex + i,
    ).where((index) => index >= 0).toList();
  }

  /// Checks if an item is currently visible.
  bool isItemVisible(int index) {
    if (!hasClients) return false;

    final position = this.position;
    if (!position.hasContentDimensions) return false;

    final itemHeight = _effectiveItemExtent;
    final itemOffset = index * itemHeight;

    return itemOffset < position.pixels + position.viewportDimension &&
        itemOffset + itemHeight > position.pixels;
  }
}
