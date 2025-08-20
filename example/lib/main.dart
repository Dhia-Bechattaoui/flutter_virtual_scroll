import 'package:flutter/material.dart';
import 'package:flutter_virtual_scroll/flutter_virtual_scroll.dart';

void main() {
  runApp(const VirtualScrollExampleApp());
}

class VirtualScrollExampleApp extends StatelessWidget {
  const VirtualScrollExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Virtual Scroll Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const VirtualScrollExampleHome(),
    );
  }
}

class VirtualScrollExampleHome extends StatefulWidget {
  const VirtualScrollExampleHome({super.key});

  @override
  State<VirtualScrollExampleHome> createState() =>
      _VirtualScrollExampleHomeState();
}

class _VirtualScrollExampleHomeState extends State<VirtualScrollExampleHome> {
  int _selectedIndex = 0;
  late VirtualScrollController _listController;
  late VirtualScrollController _gridController;

  @override
  void initState() {
    super.initState();
    _listController = VirtualScrollController();
    _gridController = VirtualScrollController();
  }

  @override
  void dispose() {
    _listController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Virtual Scroll Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.list),
                label: Text('Virtual List'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grid_on),
                label: Text('Virtual Grid'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Performance'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildSelectedView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return _buildVirtualListView();
      case 1:
        return _buildVirtualGridView();
      case 2:
        return _buildPerformanceView();
      default:
        return const Center(child: Text('Select a view'));
    }
  }

  Widget _buildVirtualListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () => _listController.scrollToItem(1000),
                child: const Text('Scroll to Item 1000'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _listController.scrollToItem(5000),
                child: const Text('Scroll to Item 5000'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _listController.scrollToItem(9999),
                child: const Text('Scroll to Item 9999'),
              ),
            ],
          ),
        ),
        Expanded(
          child: VirtualListView(
            controller: _listController,
            itemCount: 10000,
            itemExtent: 80.0,
            itemBuilder: (context, index) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.primaries[index % Colors.primaries.length],
                    child: Text(
                      '${index % 100}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('List Item $index'),
                  subtitle:
                      Text('This is item number $index in the virtual list'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualGridView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () => _gridController.scrollToItem(1000),
                child: const Text('Scroll to Item 1000'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _gridController.scrollToItem(5000),
                child: const Text('Scroll to Item 5000'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _gridController.scrollToItem(9999),
                child: const Text('Scroll to Item 9999'),
              ),
            ],
          ),
        ),
        Expanded(
          child: VirtualGridView(
            controller: _gridController,
            itemCount: 10000,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.primaries[index % Colors.primaries.length],
                        Colors.primaries[index % Colors.primaries.length]
                            .withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 32.0,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Grid Item $index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Features',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'This package includes several performance optimizations:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildPerformanceFeature(
            'Virtual Rendering',
            'Only visible items are rendered, significantly reducing memory usage',
            Icons.memory,
          ),
          _buildPerformanceFeature(
            'Intelligent Caching',
            'Items are cached beyond the viewport for smooth scrolling',
            Icons.cached,
          ),
          _buildPerformanceFeature(
            'Efficient Item Recycling',
            'Widget instances are reused to minimize object creation',
            Icons.recycling,
          ),
          _buildPerformanceFeature(
            'Platform Optimizations',
            'Native performance on all supported platforms including WASM',
            Icons.speed,
          ),
          const SizedBox(height: 32),
          const Text(
            'Performance Monitoring',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          VirtualScrollPerformanceMonitor(
            onPerformanceUpdate: (metrics) {
              // In a real app, you might log this or display it in the UI
              debugPrint('Performance: ${metrics.performanceScore * 100}%');
            },
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Performance monitoring is active'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceFeature(
      String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
