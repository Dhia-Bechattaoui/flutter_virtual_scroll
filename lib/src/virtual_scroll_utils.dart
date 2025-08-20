/// Calculates the optimal cache extent based on viewport size and item count.
///
/// Returns a cache extent value that balances memory usage with performance.
double calculateOptimalCacheExtent({
  required double viewportDimension,
  required int itemCount,
  required double averageItemHeight,
  double minCacheExtent = 100.0,
  double maxCacheExtent = 1000.0,
}) {
  if (itemCount == 0) return minCacheExtent;

  // Calculate how many items fit in the viewport
  final itemsInViewport = (viewportDimension / averageItemHeight).ceil();

  // Cache 2x the viewport items for smooth scrolling
  final calculatedCacheExtent = itemsInViewport * averageItemHeight * 2;

  // Clamp to reasonable bounds
  return calculatedCacheExtent.clamp(minCacheExtent, maxCacheExtent);
}

/// Calculates the estimated total height of a virtual list.
///
/// This is useful for providing initial scroll metrics before all items
/// are measured.
double calculateEstimatedTotalHeight({
  required int itemCount,
  required double estimatedItemHeight,
  double? knownItemHeight,
  List<double>? knownItemHeights,
}) {
  if (itemCount == 0) return 0.0;

  if (knownItemHeight != null) {
    return itemCount * knownItemHeight;
  }

  if (knownItemHeights != null && knownItemHeights.isNotEmpty) {
    final totalKnownHeight = knownItemHeights.reduce((a, b) => a + b);
    final averageKnownHeight = totalKnownHeight / knownItemHeights.length;
    final remainingItems = itemCount - knownItemHeights.length;
    return totalKnownHeight + (remainingItems * averageKnownHeight);
  }

  return itemCount * estimatedItemHeight;
}

/// Determines if an item should be rendered based on visibility and cache settings.
///
/// Returns true if the item should be rendered, false otherwise.
bool shouldRenderItem({
  required int itemIndex,
  required int visibleStartIndex,
  required int visibleEndIndex,
  required int cacheStartIndex,
  required int cacheEndIndex,
}) {
  return itemIndex >= cacheStartIndex && itemIndex <= cacheEndIndex;
}

/// Calculates the visible item range based on scroll position and viewport.
///
/// Returns a list containing the start and end indices of visible items.
List<int> calculateVisibleItemRange({
  required double scrollOffset,
  required double viewportDimension,
  required int itemCount,
  required double Function(int index) getItemHeight,
}) {
  if (itemCount == 0) return [];

  int startIndex = 0;
  int endIndex = 0;
  double currentOffset = 0.0;

  // Find the first visible item
  for (int i = 0; i < itemCount; i++) {
    final itemHeight = getItemHeight(i);
    if (currentOffset + itemHeight > scrollOffset) {
      startIndex = i;
      break;
    }
    currentOffset += itemHeight;
  }

  // Find the last visible item
  currentOffset = 0.0;
  for (int i = 0; i < itemCount; i++) {
    final itemHeight = getItemHeight(i);
    currentOffset += itemHeight;
    if (currentOffset >= scrollOffset + viewportDimension) {
      endIndex = i;
      break;
    }
  }

  // Ensure we have at least one item visible
  if (endIndex < startIndex) {
    endIndex = startIndex;
  }

  return [startIndex, endIndex];
}

/// Performance monitoring utilities for virtual scrolling.
///
/// This class provides static methods for measuring and monitoring
/// virtual scrolling performance metrics.
class VirtualScrollPerformanceUtils {
  /// Measures the time taken to execute a function.
  ///
  /// Returns the execution time in milliseconds.
  static double measureExecutionTime(Function function) {
    final stopwatch = Stopwatch()..start();
    function();
    stopwatch.stop();
    return stopwatch.elapsedMicroseconds / 1000.0;
  }

  /// Calculates the frame rate based on frame times.
  ///
  /// Returns the calculated FPS.
  static double calculateFPS(List<double> frameTimes) {
    if (frameTimes.isEmpty) return 0.0;

    final averageFrameTime =
        frameTimes.reduce((a, b) => a + b) / frameTimes.length;
    return 1000.0 / averageFrameTime;
  }

  /// Formats memory usage for display.
  ///
  /// Returns a human-readable string representation of memory usage.
  static String formatMemoryUsage(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
