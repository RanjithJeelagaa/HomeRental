import 'package:flutter/material.dart';

class VisitorHome extends StatefulWidget {
  const VisitorHome({super.key});

  @override
  State<VisitorHome> createState() => _VisitorHomeState();
}

class HouseItem {
  final String id;
  final String title;
  final String image;
  final double price;
  final double rating;
  final String availability;
  final String propertyType;
  final String location;
  final String description;
  final double discount; // ✅ Added

  HouseItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    required this.availability,
    required this.propertyType,
    required this.location,
    this.description = '',
    this.discount = 0.0,
  });
}

class _VisitorHomeState extends State<VisitorHome> {
  final TextEditingController _searchController = TextEditingController();
  int _navIndex = 0;

  String _availabilityFilter = 'All';
  String _propertyFilter = 'All';
  final double _minRating = 0.0;
  final RangeValues _priceRange = const RangeValues(0, 50000);

  final List<String> _apPlaces = [
    'Visakhapatnam',
    'Vijayawada',
    'Guntur',
    'Nellore',
    'Kurnool',
    'Tirupati',
  ];

  // ✅ 16 images total
  final List<String> _images = [
    'assets/images/house1.jpg',
    'assets/images/house2.jpg',
    'assets/images/house3.jpg',
    'assets/images/house4.jpg',
    'assets/images/house5.jpg',
    'assets/images/house6.jpg',
    'assets/images/house7.jpg',
    'assets/images/house8.jpg',
    'assets/images/house9.jpg',
    'assets/images/house10.jpg',
    'assets/images/house11.jpg',
    'assets/images/house12.jpg',
    'assets/images/house13.jpg',
    'assets/images/house14.jpg',
    'assets/images/house15.jpg',
    'assets/images/house16.jpg',
    'assets/images/house17.jpg',
    'assets/images/house18.jpg',
    'assets/images/house19.jpg',
    'assets/images/house20.jpg',
  ];

  late final List<HouseItem> _allHouses = List.generate(
    _apPlaces.length * 5, // ✅ 5 houses per city
    (i) {
      final city = _apPlaces[i % _apPlaces.length];
      final types = ['Apartment', 'Cottage', 'Villa', 'Studio', 'Duplex'];
      final type = types[i % types.length];

      return HouseItem(
        id: 'h${i + 1}',
        title: '$type in $city',
        image: _images[i % _images.length],
        price: 8000.0 + (i % 5) * 2000, // ✅ monthly rent
        rating: (3.0 + (i % 3) * 0.8).clamp(0.0, 5.0),
        availability: i % 2 == 0 ? 'Available' : 'Not available',
        propertyType: type,
        location: city,
        description: 'Spacious $type with modern amenities in $city.',
        discount: (i % 3 == 0)
            ? 10.0
            : 0.0, // ✅ 10% discount on every 3rd house
      );
    },
  );

  List<HouseItem> get _filteredHouses {
    final q = _searchController.text.trim().toLowerCase();
    return _allHouses.where((h) {
      if (_availabilityFilter != 'All' &&
          h.availability != _availabilityFilter) {
        return false;
      }
      if (_propertyFilter != 'All' && h.propertyType != _propertyFilter) {
        return false;
      }
      if (h.rating < _minRating) return false;
      if (h.price < _priceRange.start || h.price > _priceRange.end) {
        return false;
      }
      if (q.isNotEmpty &&
          !('${h.title} ${h.location}'.toLowerCase()).contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        _showFilterSheet();
        break;
      case 2:
        Navigator.pushNamed(context, '/myBookings');
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
        break;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Availability:'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _availabilityFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'Not available',
                        child: Text('Not available'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _availabilityFilter = v ?? 'All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Property:'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _propertyFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                        value: 'Apartment',
                        child: Text('Apartment'),
                      ),
                      DropdownMenuItem(
                        value: 'Cottage',
                        child: Text('Cottage'),
                      ),
                      DropdownMenuItem(value: 'Villa', child: Text('Villa')),
                      DropdownMenuItem(value: 'Studio', child: Text('Studio')),
                      DropdownMenuItem(value: 'Duplex', child: Text('Duplex')),
                    ],
                    onChanged: (v) =>
                        setState(() => _propertyFilter = v ?? 'All'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingStars(double r) {
    final full = r.floor();
    final half = (r - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star, size: 14, color: Colors.amber);
        }
        if (i == full && half) {
          return const Icon(Icons.star_half, size: 14, color: Colors.amber);
        }
        return const Icon(Icons.star_border, size: 14, color: Colors.amber);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houses = _filteredHouses;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search houses, location...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: houses.isEmpty
            ? const Center(child: Text('No houses found'))
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: houses.length,
                itemBuilder: (context, i) {
                  final h = houses[i];
                  final discountedPrice = h.discount > 0
                      ? h.price * (1 - h.discount / 100)
                      : h.price;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/houseDetail',
                        arguments: h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  h.image,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (h.discount > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '-${h.discount.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  h.location,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildRatingStars(h.rating),
                                    const SizedBox(width: 4),
                                    Text(
                                      h.rating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (h.discount > 0) ...[
                                  Text(
                                    '₹${h.price.toStringAsFixed(0)} / month',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${discountedPrice.toStringAsFixed(0)} / month',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                ] else
                                  Text(
                                    '₹${h.price.toStringAsFixed(0)} / month',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
