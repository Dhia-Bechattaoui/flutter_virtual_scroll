/// High-performance virtual scrolling for large lists and grids.
///
/// This package provides efficient virtual scrolling implementations that only
/// render visible items, making it ideal for large datasets with thousands
/// or millions of items.
///
/// Supports all 6 platforms: iOS, Android, Web, Windows, macOS, Linux
/// with WASM compatibility for web.
library flutter_virtual_scroll;

export 'src/virtual_list_view.dart';
export 'src/virtual_grid_view.dart';
export 'src/virtual_scroll_controller.dart';
export 'src/virtual_scroll_delegate.dart';
export 'src/virtual_scroll_metrics.dart';
export 'src/virtual_scroll_physics.dart';
export 'src/virtual_scroll_view.dart';
export 'src/virtual_scroll_widgets.dart';
export 'src/virtual_scroll_utils.dart';
