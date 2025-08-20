/// Metrics for virtual scrolling that provide information about the virtual scroll state.
///
/// This class provides additional information about the virtual scroll state
/// including visible item ranges and performance metrics.
class VirtualScrollMetrics {
  /// Creates virtual scroll metrics.
  const VirtualScrollMetrics({
    required this.itemCount,
    required this.visibleItemStart,
    required this.visibleItemEnd,
    required this.cachedItemStart,
    required this.cachedItemEnd,
    required this.totalItemHeight,
    required this.visibleItemHeight,
    required this.scrollOffset,
    required this.viewportDimension,
    required this.maxScrollExtent,
    required this.minScrollExtent,
    required this.pixels,
    required this.atEdge,
    required this.outOfRange,
  });

  /// Total number of items in the virtual list.
  final int itemCount;

  /// Index of the first visible item.
  final int visibleItemStart;

  /// Index of the last visible item.
  final int visibleItemEnd;

  /// Index of the first cached item.
  final int cachedItemStart;

  /// Index of the last cached item.
  final int cachedItemEnd;

  /// Total height of all items.
  final double totalItemHeight;

  /// Height of currently visible items.
  final double visibleItemHeight;

  /// Current scroll offset.
  final double scrollOffset;

  /// Dimension of the viewport.
  final double viewportDimension;

  /// Maximum scroll extent.
  final double maxScrollExtent;

  /// Minimum scroll extent.
  final double minScrollExtent;

  /// Current scroll position in pixels.
  final double pixels;

  /// Whether the scroll view is at an edge.
  final bool atEdge;

  /// Whether the scroll view is out of range.
  final bool outOfRange;

  /// Number of visible items.
  int get visibleItemCount => visibleItemEnd - visibleItemStart + 1;

  /// Number of cached items.
  int get cachedItemCount => cachedItemEnd - cachedItemStart + 1;

  /// Whether the scroll view is at the top.
  bool get atTop => pixels <= minScrollExtent;

  /// Whether the scroll view is at the bottom.
  bool get atBottom => pixels >= maxScrollExtent;

  /// Scroll progress as a value between 0.0 and 1.0.
  double get scrollProgress {
    if (maxScrollExtent == 0) return 0.0;
    return (pixels - minScrollExtent) / (maxScrollExtent - minScrollExtent);
  }

  /// Creates a copy of these metrics with the given fields replaced.
  VirtualScrollMetrics copyWith({
    int? itemCount,
    int? visibleItemStart,
    int? visibleItemEnd,
    int? cachedItemStart,
    int? cachedItemEnd,
    double? totalItemHeight,
    double? visibleItemHeight,
    double? scrollOffset,
    double? viewportDimension,
    double? maxScrollExtent,
    double? minScrollExtent,
    double? pixels,
    bool? atEdge,
    bool? outOfRange,
  }) {
    return VirtualScrollMetrics(
      itemCount: itemCount ?? this.itemCount,
      visibleItemStart: visibleItemStart ?? this.visibleItemStart,
      visibleItemEnd: visibleItemEnd ?? this.visibleItemEnd,
      cachedItemStart: cachedItemStart ?? this.cachedItemStart,
      cachedItemEnd: cachedItemEnd ?? this.cachedItemEnd,
      totalItemHeight: totalItemHeight ?? this.totalItemHeight,
      visibleItemHeight: visibleItemHeight ?? this.visibleItemHeight,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      pixels: pixels ?? this.pixels,
      atEdge: atEdge ?? this.atEdge,
      outOfRange: outOfRange ?? this.outOfRange,
    );
  }

  @override
  String toString() {
    return 'VirtualScrollMetrics('
        'itemCount: $itemCount, '
        'visibleItems: $visibleItemStart-$visibleItemEnd, '
        'cachedItems: $cachedItemStart-$cachedItemEnd, '
        'pixels: $pixels, '
        'maxScrollExtent: $maxScrollExtent'
        ')';
  }
}
