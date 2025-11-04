import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A widget that provides virtual scrolling capabilities.
///
/// This widget wraps content and provides virtual scrolling behavior.
class VirtualScrollWrapper extends StatelessWidget {
  /// Creates a virtual scroll wrapper.
  const VirtualScrollWrapper({
    super.key,
    required this.child,
    this.controller,
    this.physics,
  });

  /// The child widget to wrap.
  final Widget child;

  /// Controller for managing scroll behavior.
  final ScrollController? controller;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: physics ?? const ClampingScrollPhysics(),
      child: child,
    );
  }
}

/// A widget that provides performance monitoring for virtual scrolling.
///
/// This widget can be used to monitor scroll performance and memory usage.
class VirtualScrollPerformanceMonitor extends StatefulWidget {
  /// Creates a virtual scroll performance monitor.
  const VirtualScrollPerformanceMonitor({
    super.key,
    required this.child,
    this.onPerformanceUpdate,
    this.updateInterval = const Duration(milliseconds: 500),
    this.itemCount,
    this.itemExtent,
    this.controller,
    this.crossAxisCount,
  });

  /// The child widget to monitor.
  final Widget child;

  /// Callback for performance updates.
  final void Function(VirtualScrollPerformanceMetrics metrics)?
  onPerformanceUpdate;

  /// Interval at which performance metrics are updated.
  final Duration updateInterval;

  /// Total number of items (optional, for better accuracy).
  final int? itemCount;

  /// Height of each item (optional, for better accuracy).
  final double? itemExtent;

  /// Scroll controller (optional, for better accuracy).
  final ScrollController? controller;

  /// Number of columns in grid (optional, for grid views).
  final int? crossAxisCount;

  @override
  State<VirtualScrollPerformanceMonitor> createState() =>
      _VirtualScrollPerformanceMonitorState();
}

class _VirtualScrollPerformanceMonitorState
    extends State<VirtualScrollPerformanceMonitor> {
  Timer? _timer;
  final List<double> _frameTimes = [];
  double? _lastScrollPosition;
  bool _isScrolling = false;
  double _lastKnownGoodFrameTime = 16.67; // Default to 60fps
  static const int _maxFrameTimes = 60; // Keep last 60 frames
  static const double _maxIdleFrameTime = 50.0; // Ignore frames > 50ms (idle)

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  void _startMonitoring() {
    // Track actual frame render times using frame timings
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);

    // Periodically update metrics and check scroll activity
    _timer = Timer.periodic(widget.updateInterval, (_) {
      _checkScrollActivity();
      _updateMetrics();
    });
  }

  void _stopMonitoring() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _timer?.cancel();
    _timer = null;
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      // Get total frame time (build + rasterize)
      final totalFrameTime = timing.totalSpan.inMicroseconds / 1000.0;

      // Only track frames during active scrolling or reasonable frame times
      // Filter out idle frames (when Flutter is not rendering frequently)
      if (_isScrolling || totalFrameTime <= _maxIdleFrameTime) {
        _frameTimes.add(totalFrameTime);
        if (_frameTimes.length > _maxFrameTimes) {
          _frameTimes.removeAt(0);
        }
      }
    }
  }

  void _checkScrollActivity() {
    if (widget.controller != null && widget.controller!.hasClients) {
      final currentPosition = widget.controller!.position.pixels;

      if (_lastScrollPosition != null) {
        // Check if scroll position changed (scrolling)
        final scrollDelta = (currentPosition - _lastScrollPosition!).abs();
        _isScrolling = scrollDelta > 0.1; // Threshold for scroll detection
      }

      _lastScrollPosition = currentPosition;
    } else {
      _isScrolling = false;
    }

    // If not scrolling for a while, preserve last known good frame time
    if (!_isScrolling && _frameTimes.length > 10) {
      // Keep only recent frames when idle, but preserve the last good average
      if (_frameTimes.isNotEmpty) {
        final validFrames = _frameTimes
            .where((t) => t <= _maxIdleFrameTime)
            .toList();
        if (validFrames.isNotEmpty) {
          _lastKnownGoodFrameTime =
              validFrames.reduce((a, b) => a + b) / validFrames.length;
        }
      }
      // Keep only recent frames when idle
      _frameTimes.removeRange(0, _frameTimes.length - 10);
    }
  }

  void _updateMetrics() {
    if (!mounted || widget.onPerformanceUpdate == null) return;

    // Calculate average frame time from recent active frames
    double averageFrameTime = _lastKnownGoodFrameTime;

    if (_frameTimes.isNotEmpty) {
      // Filter out any outliers (idle frames that might have slipped through)
      final validFrames = _frameTimes
          .where((t) => t <= _maxIdleFrameTime)
          .toList();

      if (validFrames.isNotEmpty) {
        averageFrameTime =
            validFrames.reduce((a, b) => a + b) / validFrames.length;
        // Clamp to reasonable values
        averageFrameTime = averageFrameTime.clamp(8.0, 100.0);
        // Update last known good frame time
        _lastKnownGoodFrameTime = averageFrameTime;
      } else if (_isScrolling && _frameTimes.isNotEmpty) {
        // If scrolling but all frames are idle (shouldn't happen), use minimum
        averageFrameTime = _frameTimes.reduce((a, b) => a < b ? a : b);
      }
      // If not scrolling and no valid frames, use last known good frame time
    }

    // Estimate memory usage (this is a rough estimate)
    // In a real implementation, you'd use platform-specific APIs
    final estimatedMemory = _estimateMemoryUsage();

    // Try to extract item count from child if it's a VirtualListView/GridView
    final itemCounts = _extractItemCounts();
    final visibleItemCount = itemCounts['visible'] ?? 0;
    final totalItemCount = itemCounts['total'] ?? 0;

    final metrics = VirtualScrollPerformanceMetrics(
      frameTime: averageFrameTime,
      memoryUsage: estimatedMemory,
      visibleItemCount: visibleItemCount,
      totalItemCount: totalItemCount,
    );

    widget.onPerformanceUpdate?.call(metrics);
  }

  int _estimateMemoryUsage() {
    // Rough estimate based on frame times and complexity
    // In production, use platform-specific memory APIs
    final baseMemory = 10 * 1024 * 1024; // 10MB base
    final frameTimeFactor = _frameTimes.isNotEmpty
        ? (_frameTimes.reduce((a, b) => a + b) / _frameTimes.length) / 16.67
        : 1.0;
    return (baseMemory * frameTimeFactor).round();
  }

  Map<String, int> _extractItemCounts() {
    // First, try to use provided parameters
    if (widget.itemCount != null && widget.itemExtent != null) {
      return _calculateFromParameters();
    }

    // Try to use controller if available
    if (widget.controller != null && widget.controller!.hasClients) {
      return _calculateFromController();
    }

    // Try to find Scrollable in widget tree
    try {
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable != null) {
        return _calculateFromScrollable(scrollable);
      }
    } catch (e) {
      // Ignore errors
    }

    return {'visible': 0, 'total': 0};
  }

  Map<String, int> _calculateFromParameters() {
    final itemCount = widget.itemCount!;
    final itemExtent = widget.itemExtent!;

    if (widget.controller != null && widget.controller!.hasClients) {
      final position = widget.controller!.position;
      if (position.hasContentDimensions) {
        final startIndex = (position.pixels / itemExtent).floor();
        final endIndex =
            ((position.pixels + position.viewportDimension) / itemExtent)
                .ceil();
        final visibleItems = (endIndex - startIndex).clamp(0, itemCount);
        return {'visible': visibleItems, 'total': itemCount};
      }
    }

    // If no scroll position, estimate visible items
    final estimatedVisible = (800 / itemExtent)
        .ceil(); // Assume ~800px viewport
    return {
      'visible': estimatedVisible.clamp(0, itemCount),
      'total': itemCount,
    };
  }

  Map<String, int> _calculateFromController() {
    final position = widget.controller!.position;
    if (!position.hasContentDimensions) {
      return {'visible': 0, 'total': 0};
    }

    // If we have itemCount but no itemExtent, estimate based on viewport
    // This is typically for grids where items are laid out in rows
    if (widget.itemCount != null && widget.itemExtent == null) {
      // For grids: calculate based on viewport and grid layout
      final crossAxisCount = widget.crossAxisCount ?? 4; // Default to 4 columns

      // Estimate row height based on viewport and typical grid item size
      // For childAspectRatio 1.0: item width ≈ viewport width / crossAxisCount
      // Estimate viewport width (typically 300-400px on mobile, more on desktop)
      // We'll use a more dynamic approach: estimate based on scroll position

      // Try to estimate item size from scroll metrics
      // If we can see maxScrollExtent, we can estimate total rows
      double estimatedRowHeight = 100.0; // Default fallback

      if (position.maxScrollExtent > 0) {
        // Estimate: totalRows ≈ maxScrollExtent / averageRowHeight
        // For a grid with 10000 items and 4 columns: ~2500 rows
        // If maxScrollExtent is, say, 250000px, then rowHeight ≈ 100px
        final estimatedTotalRows = (widget.itemCount! / crossAxisCount).ceil();
        if (estimatedTotalRows > 0) {
          estimatedRowHeight = position.maxScrollExtent / estimatedTotalRows;
          // Clamp to reasonable values (50-200px)
          estimatedRowHeight = estimatedRowHeight.clamp(50.0, 200.0);
        }
      }

      // Calculate visible rows
      final startRow = (position.pixels / estimatedRowHeight).floor();
      final endRow =
          ((position.pixels + position.viewportDimension) / estimatedRowHeight)
              .ceil();
      final visibleRows = (endRow - startRow).clamp(1, 10000);

      // Calculate visible items: rows × columns
      final visibleItems = (visibleRows * crossAxisCount).clamp(
        0,
        widget.itemCount!,
      );

      return {'visible': visibleItems, 'total': widget.itemCount!};
    }

    // Try to estimate itemExtent from scroll position
    final estimatedItemExtent = widget.itemExtent ?? 80.0;
    final startIndex = (position.pixels / estimatedItemExtent).floor();
    final endIndex =
        ((position.pixels + position.viewportDimension) / estimatedItemExtent)
            .ceil();
    final visibleItems = (endIndex - startIndex).clamp(
      0,
      widget.itemCount ?? 1000,
    );
    final totalItems =
        widget.itemCount ??
        (position.maxScrollExtent / estimatedItemExtent).ceil();

    return {'visible': visibleItems, 'total': totalItems};
  }

  Map<String, int> _calculateFromScrollable(ScrollableState scrollable) {
    final position = scrollable.position;
    if (!position.hasContentDimensions) {
      return {'visible': 0, 'total': 0};
    }

    final itemExtent = widget.itemExtent ?? 80.0;
    final startIndex = (position.pixels / itemExtent).floor();
    final endIndex =
        ((position.pixels + position.viewportDimension) / itemExtent).ceil();
    final visibleItems = (endIndex - startIndex).clamp(0, 1000);
    final totalItems =
        widget.itemCount ?? (position.maxScrollExtent / itemExtent).ceil();

    return {'visible': visibleItems, 'total': totalItems};
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Performance metrics for virtual scrolling.
class VirtualScrollPerformanceMetrics {
  /// Creates performance metrics.
  const VirtualScrollPerformanceMetrics({
    required this.frameTime,
    required this.memoryUsage,
    required this.visibleItemCount,
    required this.totalItemCount,
  });

  /// Frame time in milliseconds.
  final double frameTime;

  /// Memory usage in bytes.
  final int memoryUsage;

  /// Number of visible items.
  final int visibleItemCount;

  /// Total number of items.
  final int totalItemCount;

  /// Performance score (0.0 to 1.0).
  ///
  /// Returns a score based on frame time:
  /// - 60fps (≤16.67ms) = 100%
  /// - 30fps (≤33.33ms) = 80%
  /// - 20fps (≤50ms) = 60%
  /// - Below 20fps = scales down from 60% to 0%
  double get performanceScore {
    if (frameTime <= 16.67) return 1.0; // 60fps = 100%
    if (frameTime <= 33.33) return 0.8; // 30fps = 80%
    if (frameTime <= 50.0) return 0.6; // 20fps = 60%

    // For frame times > 50ms, scale down from 60% to 0%
    // At 100ms = ~30%, at 200ms = ~15%, at 500ms+ = ~0%
    final excessTime = frameTime - 50.0;
    final penalty = (excessTime / 100.0).clamp(0.0, 0.6); // Max 60% penalty
    return (0.6 - penalty).clamp(0.0, 1.0);
  }
}
