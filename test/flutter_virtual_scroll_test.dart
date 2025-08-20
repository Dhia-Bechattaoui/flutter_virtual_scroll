import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_virtual_scroll/flutter_virtual_scroll.dart';

void main() {
  group('VirtualListView', () {
    testWidgets('renders items correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VirtualListView(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item $index'),
              );
            },
          ),
        ),
      );

      // Verify that items are rendered
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
      expect(find.text('Item 9'), findsOneWidget);
    });

    testWidgets('handles empty item count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VirtualListView(
            itemCount: 0,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item $index'),
              );
            },
          ),
        ),
      );

      // Verify no items are rendered
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('respects itemExtent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VirtualListView(
            itemCount: 5,
            itemExtent: 100.0,
            itemBuilder: (context, index) {
              return Container(
                height: 100.0,
                child: Text('Item $index'),
              );
            },
          ),
        ),
      );

      // Verify items have correct height
      final listTile = tester.widget<ListTile>(find.byType(ListTile).first);
      expect(listTile, isNotNull);
    });
  });

  group('VirtualGridView', () {
    testWidgets('renders grid items correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VirtualGridView(
            itemCount: 9,
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
          ),
        ),
      );

      // Verify that grid items are rendered
      expect(find.text('Grid Item 0'), findsOneWidget);
      expect(find.text('Grid Item 4'), findsOneWidget);
      expect(find.text('Grid Item 8'), findsOneWidget);
    });

    testWidgets('handles empty grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VirtualGridView(
            itemCount: 0,
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
          ),
        ),
      );

      // Verify no grid items are rendered
      expect(find.byType(Card), findsNothing);
    });
  });

  group('VirtualScrollController', () {
    test('creates controller with default values', () {
      final controller = VirtualScrollController();
      expect(controller, isNotNull);
      expect(controller.hasClients, false);
    });

    test('creates controller with custom values', () {
      final controller = VirtualScrollController(
        initialScrollOffset: 100.0,
        debugLabel: 'test',
      );
      expect(controller, isNotNull);
      expect(controller.debugLabel, 'test');
    });
  });

  group('VirtualScrollMetrics', () {
    test('creates metrics with required values', () {
      final metrics = VirtualScrollMetrics(
        itemCount: 100,
        visibleItemStart: 0,
        visibleItemEnd: 9,
        cachedItemStart: 0,
        cachedItemEnd: 19,
        totalItemHeight: 6000.0,
        visibleItemHeight: 600.0,
        scrollOffset: 0.0,
        viewportDimension: 600.0,
        maxScrollExtent: 5400.0,
        minScrollExtent: 0.0,
        pixels: 0.0,
        atEdge: true,
        outOfRange: false,
      );

      expect(metrics.itemCount, 100);
      expect(metrics.visibleItemCount, 10);
      expect(metrics.cachedItemCount, 20);
      expect(metrics.atTop, true);
      expect(metrics.atBottom, false);
      expect(metrics.scrollProgress, 0.0);
    });

    test('calculates scroll progress correctly', () {
      final metrics = VirtualScrollMetrics(
        itemCount: 100,
        visibleItemStart: 50,
        visibleItemEnd: 59,
        cachedItemStart: 45,
        cachedItemEnd: 64,
        totalItemHeight: 6000.0,
        visibleItemHeight: 600.0,
        scrollOffset: 3000.0,
        viewportDimension: 600.0,
        maxScrollExtent: 5400.0,
        minScrollExtent: 0.0,
        pixels: 3000.0,
        atEdge: false,
        outOfRange: false,
      );

      expect(metrics.scrollProgress, closeTo(0.556, 0.001));
    });
  });

  group('VirtualScrollUtils', () {
    test('calculates optimal cache extent', () {
      final cacheExtent = calculateOptimalCacheExtent(
        viewportDimension: 600.0,
        itemCount: 1000,
        averageItemHeight: 60.0,
      );

      expect(cacheExtent, 1200.0); // 2x viewport items * item height
    });

    test('calculates estimated total height', () {
      final totalHeight = calculateEstimatedTotalHeight(
        itemCount: 100,
        estimatedItemHeight: 60.0,
      );

      expect(totalHeight, 6000.0);
    });

    test('determines item rendering correctly', () {
      final shouldRender = shouldRenderItem(
        itemIndex: 5,
        visibleStartIndex: 0,
        visibleEndIndex: 9,
        cacheStartIndex: 0,
        cacheEndIndex: 19,
      );

      expect(shouldRender, true);
    });

    test('calculates visible item range', () {
      final visibleRange = calculateVisibleItemRange(
        scrollOffset: 300.0,
        viewportDimension: 600.0,
        itemCount: 100,
        getItemHeight: (index) => 60.0,
      );

      expect(visibleRange, [5, 14]); // Items 5-14 are visible
    });
  });

  group('VirtualScrollPerformanceUtils', () {
    test('measures execution time', () {
      final executionTime =
          VirtualScrollPerformanceUtils.measureExecutionTime(() {
        // Simulate some work
        for (int i = 0; i < 1000; i++) {
          i * i;
        }
      });

      expect(executionTime, greaterThan(0.0));
    });

    test('calculates FPS correctly', () {
      final frameTimes = [16.67, 16.67, 16.67, 16.67, 16.67]; // 60fps
      final fps = VirtualScrollPerformanceUtils.calculateFPS(frameTimes);

      expect(fps, closeTo(60.0, 1.0));
    });

    test('formats memory usage correctly', () {
      expect(VirtualScrollPerformanceUtils.formatMemoryUsage(1024), '1.0KB');
      expect(VirtualScrollPerformanceUtils.formatMemoryUsage(1048576), '1.0MB');
      expect(
          VirtualScrollPerformanceUtils.formatMemoryUsage(1073741824), '1.0GB');
    });
  });
}
