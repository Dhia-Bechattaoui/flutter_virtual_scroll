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

/// Responsive utilities for virtual scrolling.
///
/// Provides helper methods for adapting virtual scroll layouts
/// to different screen sizes and orientations.
class VirtualScrollResponsiveUtils {
  /// Calculates optimal cross-axis count for grids based on screen width.
  ///
  /// Returns a responsive column count based on breakpoints.
  static int getResponsiveCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) {
      return 2; // Mobile: 2 columns
    } else if (screenWidth < 900) {
      return 3; // Tablet: 3 columns
    } else if (screenWidth < 1200) {
      return 4; // Desktop: 4 columns
    } else {
      return 5; // Large desktop: 5 columns
    }
  }

  /// Calculates optimal item extent based on screen size.
  ///
  /// Returns a responsive item height.
  static double getResponsiveItemExtent(double screenHeight) {
    if (screenHeight < 600) {
      return 60.0; // Small screens
    } else if (screenHeight < 900) {
      return 80.0; // Medium screens
    } else {
      return 100.0; // Large screens
    }
  }

  /// Determines if the device is in landscape orientation.
  static bool isLandscape(double width, double height) {
    return width > height;
  }

  /// Calculates optimal cache extent based on device capabilities.
  static double getResponsiveCacheExtent(
    double screenHeight,
    bool isLowMemoryDevice,
  ) {
    final baseCache = screenHeight * 0.5; // Cache half screen height
    return isLowMemoryDevice ? baseCache * 0.5 : baseCache;
  }
}

/// Intelligent caching utilities for virtual scrolling.
///
/// Provides advanced caching strategies for optimal memory usage
/// and performance.
class VirtualScrollCacheUtils {
  /// Calculates intelligent cache extent based on scroll velocity and item count.
  ///
  /// Returns a cache extent that adapts to scrolling behavior.
  static double calculateIntelligentCacheExtent({
    required double baseCacheExtent,
    required double scrollVelocity,
    required int itemCount,
    double maxVelocity = 1000.0,
  }) {
    // Increase cache for fast scrolling to prevent visible gaps
    final velocityFactor = (scrollVelocity / maxVelocity).clamp(0.0, 1.0);
    final adaptiveCache = baseCacheExtent * (1.0 + velocityFactor);

    // Adjust for large lists (more cache needed)
    final sizeFactor = (itemCount > 10000) ? 1.5 : 1.0;

    return (adaptiveCache * sizeFactor).clamp(
      baseCacheExtent,
      baseCacheExtent * 2.0,
    );
  }

  /// Determines optimal cache size based on memory constraints.
  static double getOptimalCacheForMemory({
    required double viewportSize,
    required int itemCount,
    required double itemSize,
    bool isLowMemory = false,
  }) {
    final itemsInViewport = (viewportSize / itemSize).ceil();

    if (isLowMemory) {
      // Cache only 1x viewport for low memory devices
      return itemsInViewport * itemSize;
    } else {
      // Cache 2-3x viewport for normal devices
      return itemsInViewport * itemSize * 2.5;
    }
  }

  /// Calculates cache priority based on item position.
  ///
  /// Returns true if item should be kept in cache (high priority).
  static bool shouldKeepInCache({
    required int itemIndex,
    required int visibleStartIndex,
    required int visibleEndIndex,
    required int cacheSize,
  }) {
    final distanceFromVisible = [
      (itemIndex - visibleStartIndex).abs(),
      (itemIndex - visibleEndIndex).abs(),
    ].reduce((a, b) => a < b ? a : b);

    // Keep items close to visible area in cache
    return distanceFromVisible <= cacheSize;
  }
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
