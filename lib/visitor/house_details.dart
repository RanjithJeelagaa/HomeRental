// ...existing code...
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class HouseDetailsScreen extends StatefulWidget {
  const HouseDetailsScreen({super.key});

  @override
  State<HouseDetailsScreen> createState() => _HouseDetailsScreenState();
}

class _HouseDetailsScreenState extends State<HouseDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final _random = Random();
  final _randomOwners = [
    "Ramesh",
    "Suresh",
    "Kavitha",
    "Prakash",
    "Anjali",
    "Venkatesh",
    "Neha",
    "Rajesh",
    "Manoj",
    "Deepthi",
  ];

  final _randomLocations = [
    "Downtown",
    "Near Railway Station",
    "Beside IT Park",
    "Near Beach Road",
    "City Outskirts",
    "Uptown",
    "Near Bus Stand",
    "University Road",
  ];

  final _houseTags = ["For Bachelors", "For Family"];

  Widget _buildRatingStars(double r) {
    final full = r.floor();
    final half = (r - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star, size: 18, color: Colors.amber);
        }
        if (i == full && half) {
          return const Icon(Icons.star_half, size: 18, color: Colors.amber);
        }
        return const Icon(Icons.star_border, size: 18, color: Colors.amber);
      }),
    );
  }

  Widget _imageWidget(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.home, size: 48)),
      );
    }
    try {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.broken_image, size: 40)),
            );
          },
        );
      } else if (path.startsWith('/')) {
        // local file path
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.broken_image, size: 40)),
            );
          },
        );
      } else {
        // asset
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.broken_image, size: 40)),
            );
          },
        );
      }
    } catch (_) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image, size: 40)),
      );
    }
  }

  Map<String, dynamic> _normalizeArgs(Object? args) {
    if (args == null) return {};
    if (args is Map<String, dynamic>) return args;
    if (args is Map) return Map<String, dynamic>.from(args);
    try {
      final dyn = args as dynamic;
      final images = <String>[];
      // try common fields
      if (dyn.images != null) {
        try {
          for (var e in dyn.images) {
            images.add(e.toString());
          }
        } catch (_) {}
      } else if (dyn.image != null) {
        images.add(dyn.image.toString());
      }
      return {
        'title': dyn.title ?? dyn.name ?? 'House',
        'description': dyn.description ?? '',
        'images': images,
        'location': dyn.location ?? '',
        'ownerName': dyn.owner ?? dyn.ownerName,
      };
    } catch (_) {
      return {};
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final argsRaw = ModalRoute.of(context)?.settings.arguments;
    final args = _normalizeArgs(argsRaw);

    // Images list
    final List<String> images =
        (args['images'] is List && (args['images'] as List).isNotEmpty)
        ? List<String>.from(args['images'])
        : [
            // fallback online images
            'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?auto=format&fit=crop&w=1200&q=80',
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
            'https://images.unsplash.com/photo-1460518451285-97b6aa326961?auto=format&fit=crop&w=1200&q=80',
          ];

    // Randomized details (if not provided)
    final ownerName =
        args['ownerName'] ??
        _randomOwners[_random.nextInt(_randomOwners.length)];
    final ownerPhone =
        args['ownerPhone'] ??
        '+91${List.generate(10, (_) => _random.nextInt(10).toString()).join()}';
    final rating = (args['rating'] is num)
        ? (args['rating'] as num).toDouble()
        : (2.5 + _random.nextDouble() * 2.5); // 2.5 - 5.0
    final price = (args['price'] is num)
        ? (args['price'] as num).toDouble()
        : (1000 + _random.nextInt(9000)).toDouble(); // ₹1000 - ₹10000
    final availability =
        args['availability'] ??
        (_random.nextBool() ? 'Available' : 'Not available');
    final title = args['title'] ?? 'Beautiful House';
    final location =
        args['location'] ??
        _randomLocations[_random.nextInt(_randomLocations.length)];
    final description =
        args['description'] ??
        'A comfortable stay located $location. Well-maintained and close to local amenities.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, i) =>
                      SizedBox.expand(child: _imageWidget(images[i])),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${price.toStringAsFixed(0)} / night',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: availability == 'Available'
                          ? Colors.green[700]
                          : Colors.red[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      availability,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildRatingStars(rating),
                        const SizedBox(width: 6),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '$location, Andhra Pradesh, India',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _houseTags
                      .map((t) => Chip(label: Text(t)))
                      .toList(),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ownerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          ownerPhone,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // navigate to booking page or implement call feature
                    Navigator.pushNamed(
                      context,
                      '/book',
                      arguments: {'title': title, 'price': price},
                    );
                  },
                  icon: const Icon(Icons.book_online),
                  label: const Text('Book Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ...existing code...