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
  VirtualScrollPerformanceMetrics? _performanceMetrics;

  @override
  void initState() {
    super.initState();
    _listController = VirtualScrollController(itemExtent: 80.0);
    _gridController = VirtualScrollController(
      crossAxisCount: 4,
      itemCount: 10000,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(16.0),
    );
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
      default:
        return const Center(child: Text('Select a view'));
    }
  }

  Widget _buildVirtualListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
        ),
        Expanded(
          child: Stack(
            children: [
              VirtualScrollPerformanceMonitor(
                onPerformanceUpdate: (metrics) {
                  setState(() {
                    _performanceMetrics = metrics;
                  });
                },
                itemCount: 10000,
                itemExtent: 80.0,
                controller: _listController,
                child: VirtualListView(
                  controller: _listController,
                  itemCount: 10000,
                  itemExtent: 80.0,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
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
                        subtitle: Text(
                            'This is item number $index in the virtual list'),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_performanceMetrics != null) _buildPerformanceOverlay(),
            ],
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
        ),
        Expanded(
          child: Stack(
            children: [
              VirtualScrollPerformanceMonitor(
                onPerformanceUpdate: (metrics) {
                  setState(() {
                    _performanceMetrics = metrics;
                  });
                },
                itemCount: 10000,
                controller: _gridController,
                crossAxisCount: 4,
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
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
              if (_performanceMetrics != null) _buildPerformanceOverlay(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceOverlay() {
    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Performance',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildOverlayMetric(
                'Score',
                '${(_performanceMetrics!.performanceScore * 100).toStringAsFixed(0)}%',
                _getPerformanceColor(_performanceMetrics!.performanceScore),
              ),
              const SizedBox(height: 4),
              _buildOverlayMetric(
                'Frame',
                '${_performanceMetrics!.frameTime.toStringAsFixed(1)}ms',
                Colors.blue,
              ),
              const SizedBox(height: 4),
              _buildOverlayMetric(
                'Memory',
                _formatMemory(_performanceMetrics!.memoryUsage),
                Colors.green,
              ),
              const SizedBox(height: 4),
              _buildOverlayMetric(
                'Items',
                '${_performanceMetrics!.visibleItemCount}/${_performanceMetrics!.totalItemCount}',
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayMetric(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatMemory(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
