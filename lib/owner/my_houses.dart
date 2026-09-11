import 'dart:io';
import 'package:flutter/material.dart';

class House {
  final String id;
  final String title;
  final List<String> images; // asset paths or file paths
  final String description;
  final DateTime createdAt;

  House({
    required this.id,
    required this.title,
    required this.images,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class MyHousesScreen extends StatefulWidget {
  const MyHousesScreen({super.key});

  @override
  State<MyHousesScreen> createState() => _MyHousesScreenState();
}

class _MyHousesScreenState extends State<MyHousesScreen> {
  final List<House> _houses = [];
  bool _loadedArgs = false; // 👈 to prevent reloading every rebuild

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loadedArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is List<House>) {
        _houses.addAll(args);
      } else if (args is List<Map>) {
        for (final m in args) {
          try {
            final h = House(
              id: m['id']?.toString() ?? UniqueKey().toString(),
              title: m['title']?.toString() ?? 'Untitled',
              images: List<String>.from(m['images'] ?? []),
              description: m['description']?.toString() ?? '',
            );
            _houses.add(h);
          } catch (_) {}
        }
      }
      _loadedArgs = true; // 👈 only process once
    }
  }

  Future<void> _openAddHouse() async {
    final result = await Navigator.pushNamed(context, '/addHouse');
    if (result == null) return;

    if (result is House) {
      setState(() => _houses.insert(0, result));
    } else if (result is Map) {
      final newHouse = House(
        id: result['id']?.toString() ?? UniqueKey().toString(),
        title: result['title']?.toString() ?? 'Untitled',
        images: List<String>.from(result['images'] ?? []),
        description: result['description']?.toString() ?? '',
      );
      setState(() => _houses.insert(0, newHouse));
    }
  }

  void _removeHouse(String id) {
    setState(() => _houses.removeWhere((h) => h.id == id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('House removed')));
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.home, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Houses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddHouse,
        label: const Text('Add House'),
        icon: const Icon(Icons.add),
      ),
      body: _houses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No houses uploaded yet'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _openAddHouse,
                    child: const Text('Upload a house'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _houses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final h = _houses[i];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/houseDetail',
                      arguments: h,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 110,
                              height: 80,
                              child: h.images.isNotEmpty
                                  ? _buildImagePreview(h.images.first)
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.home, size: 40),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  h.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '${h.images.length} image(s)',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      tooltip: 'Delete',
                                      onPressed: () => _removeHouse(h.id),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
