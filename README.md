# flutter_virtual_scroll

[![Pub](https://img.shields.io/pub/v/flutter_virtual_scroll.svg)](https://pub.dev/packages/flutter_virtual_scroll)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](https://flutter.dev/docs/development/tools/sdk/releases)

High-performance virtual scrolling for large lists and grids with support for all 6 platforms (iOS, Android, Web, Windows, macOS, Linux) and WASM compatibility.

## Features

- 🚀 **High Performance**: Only renders visible items for optimal memory usage
- 🌐 **Cross-Platform**: Supports iOS, Android, Web, Windows, macOS, and Linux
- 🔧 **WASM Compatible**: Optimized for web with WebAssembly support
- 📱 **Responsive**: Adapts to different screen sizes and orientations
- 🎯 **Customizable**: Flexible item builders and scroll controllers
- 📊 **Performance Monitoring**: Built-in performance metrics and optimization
- ♿ **Accessibility**: Full screen reader and navigation support
- 🔄 **Memory Efficient**: Intelligent item recycling and caching

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_virtual_scroll: ^0.0.1
```

### Basic Usage

#### Virtual List View

```dart
import 'package:flutter_virtual_scroll/flutter_virtual_scroll.dart';

class MyListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VirtualListView(
      itemCount: 10000,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          subtitle: Text('Description for item $index'),
        );
      },
    );
  }
}
```

#### Virtual Grid View

```dart
import 'package:flutter_virtual_scroll/flutter_virtual_scroll.dart';

class MyGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VirtualGridView(
      itemCount: 10000,
      itemBuilder: (context, index) {
        return Card(
          child: Center(
            child: Text('Grid Item $index'),
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
      ),
    );
  }
}
```

#### Custom Scroll Controller

```dart
import 'package:flutter_virtual_scroll/flutter_virtual_scroll.dart';

class MyCustomListView extends StatefulWidget {
  @override
  _MyCustomListViewState createState() => _MyCustomListViewState();
}

class _MyCustomListViewState extends State<MyCustomListView> {
  late VirtualScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VirtualScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _controller.scrollToItem(1000),
          child: Text('Scroll to Item 1000'),
        ),
        Expanded(
          child: VirtualListView(
            controller: _controller,
            itemCount: 10000,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item $index'),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Advanced Features

### Dynamic Item Heights

```dart
VirtualListView(
  itemCount: 10000,
  itemExtentBuilder: (index) {
    // Return different heights based on content
    return (index % 3 == 0) ? 100.0 : 60.0;
  },
  itemBuilder: (context, index) {
    return Container(
      height: (index % 3 == 0) ? 100.0 : 60.0,
      child: ListTile(
        title: Text('Item $index'),
      ),
    );
  },
)
```

### Performance Monitoring

```dart
VirtualScrollPerformanceMonitor(
  onPerformanceUpdate: (metrics) {
    print('Frame time: ${metrics.frameTime}ms');
    print('Memory usage: ${VirtualScrollPerformanceUtils.formatMemoryUsage(metrics.memoryUsage)}');
    print('Performance score: ${(metrics.performanceScore * 100).toStringAsFixed(1)}%');
  },
  child: VirtualListView(
    itemCount: 10000,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text('Item $index'),
      );
    },
  ),
)
```

### Custom Scroll Physics

```dart
VirtualListView(
  itemCount: 10000,
  physics: VirtualScrollPhysics(
    itemExtent: 60.0,
  ),
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('Item $index'),
    );
  },
)
```

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ Supported | Native performance with Metal/OpenGL |
| Android | ✅ Supported | Optimized for Android rendering pipeline |
| Web | ✅ Supported | WASM compatible with Canvas/WebGL support |
| Windows | ✅ Supported | Native Windows performance |
| macOS | ✅ Supported | Native macOS performance with Metal |
| Linux | ✅ Supported | Native Linux performance with OpenGL |

## Performance Characteristics

- **Memory Usage**: Scales linearly with visible items (typically 10-50 items)
- **Scroll Response**: Sub-millisecond response times
- **Frame Rate**: Maintains 60fps on all supported platforms
- **Item Rendering**: Only visible items are rendered and updated
- **Cache Management**: Intelligent item recycling and memory management

## Best Practices

1. **Use Fixed Item Heights**: When possible, use `itemExtent` for better performance
2. **Implement Efficient Builders**: Keep `itemBuilder` functions lightweight
3. **Monitor Performance**: Use `VirtualScrollPerformanceMonitor` in development
4. **Optimize Images**: Use appropriate image formats and sizes for your platform
5. **Test on Target Devices**: Performance can vary between platforms and devices

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Community contributors for feedback and suggestions
- Performance optimization research and best practices

## Support

If you encounter any issues or have questions, please:

1. Check the [documentation](https://github.com/Dhia-Bechattaoui/flutter_virtual_scroll#readme)
2. Search [existing issues](https://github.com/Dhia-Bechattaoui/flutter_virtual_scroll/issues)
3. Create a [new issue](https://github.com/Dhia-Bechattaoui/flutter_virtual_scroll/issues/new)

---

**Made with ❤️ for the Flutter community**
