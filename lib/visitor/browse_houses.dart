import 'package:flutter/material.dart';

class House {
  final String name;
  final String location;
  final double price;
  final double rating;

  House({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
  });
}

class BrowseHousesPage extends StatefulWidget {
  const BrowseHousesPage({super.key});

  @override
  _BrowseHousesPageState createState() => _BrowseHousesPageState();
}

class _BrowseHousesPageState extends State<BrowseHousesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<House> allHouses = [
    House(name: 'Sunny Villa', location: 'New York', price: 120.0, rating: 4.5),
    House(name: 'Cozy Cottage', location: 'Boston', price: 90.0, rating: 4.0),
    House(
      name: 'Luxury Loft',
      location: 'San Francisco',
      price: 200.0,
      rating: 4.8,
    ),
    // Add more houses...
  ];
  List<House> filteredHouses = [];

  @override
  void initState() {
    super.initState();
    filteredHouses = allHouses;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredHouses = allHouses.where((house) {
        return house.name.toLowerCase().contains(query) ||
            house.location.toLowerCase().contains(query) ||
            house.price.toString().contains(query) ||
            house.rating.toString().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetails(House house) {
    Navigator.pushNamed(context, '/house_details', arguments: house);
    // Adjust navigation as per your routing setup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Browse Houses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, location, price, rating...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredHouses.length,
              itemBuilder: (context, index) {
                final house = filteredHouses[index];
                return ListTile(
                  title: Text(house.name),
                  subtitle: Text(
                    '${house.location} • \$${house.price} • ⭐${house.rating}',
                  ),
                  onTap: () => _navigateToDetails(house),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
