import 'dart:io';

import 'package:flutter/material.dart';

class BookingItem {
  final String id;
  final String houseId;
  final String houseTitle;
  final String owner;
  final String location;
  final double price;
  final List<String> images;
  final String userName;
  final String userContact;
  final String userEmail;
  final String fromDate; // keep as string for display
  final String toDate;
  String status;
  final String createdAt;

  BookingItem({
    required this.id,
    required this.houseId,
    required this.houseTitle,
    this.owner = '',
    this.location = '',
    this.price = 0.0,
    this.images = const [],
    this.userName = '',
    this.userContact = '',
    this.userEmail = '',
    this.fromDate = '',
    this.toDate = '',
    this.status = 'Pending',
    this.createdAt = '',
  });

  factory BookingItem.fromMap(Map m) {
    return BookingItem(
      id: m['id']?.toString() ?? UniqueKey().toString(),
      houseId: m['houseId']?.toString() ?? m['houseID']?.toString() ?? '',
      houseTitle:
          m['houseTitle']?.toString() ?? m['title']?.toString() ?? 'House',
      owner: m['owner']?.toString() ?? '',
      location: m['location']?.toString() ?? '',
      price: (m['price'] is num)
          ? (m['price'] as num).toDouble()
          : double.tryParse(m['price']?.toString() ?? '') ?? 0.0,
      images: (m['images'] is List)
          ? List<String>.from(m['images'])
          : (m['image'] != null ? [m['image'].toString()] : []),
      userName: m['userName']?.toString() ?? m['name']?.toString() ?? '',
      userContact:
          m['userContact']?.toString() ?? m['userContact']?.toString() ?? '',
      userEmail: m['userEmail']?.toString() ?? m['email']?.toString() ?? '',
      fromDate: m['fromDate']?.toString() ?? '',
      toDate: m['toDate']?.toString() ?? '',
      status: m['status']?.toString() ?? 'Pending',
      createdAt: m['createdAt']?.toString() ?? '',
    );
  }
}

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final List<BookingItem> _bookings = [];
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) return;

    if (args is Map) {
      // single booking passed
      try {
        final b = BookingItem.fromMap(Map<String, dynamic>.from(args));
        _bookings.insert(0, b);
      } catch (_) {}
    } else if (args is List) {
      for (final item in args) {
        if (item is Map) {
          try {
            _bookings.add(BookingItem.fromMap(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
    }
  }

  void _updateStatus(String id, String status) {
    setState(() {
      final idx = _bookings.indexWhere((b) => b.id == id);
      if (idx != -1) _bookings[idx].status = status;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Booking marked $status')));
  }

  void _removeBooking(String id) {
    setState(() => _bookings.removeWhere((b) => b.id == id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking removed')));
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(raw);
      if (dt != null) return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {}
    return raw;
  }

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final f = File(path);
    if (f.existsSync()) return Image.file(f, fit: BoxFit.cover);
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.home, size: 36, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _bookings.isEmpty
          ? const Center(child: Text('No bookings yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final b = _bookings[i];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Show details dialog
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(b.houseTitle),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (b.images.isNotEmpty)
                                SizedBox(
                                  height: 120,
                                  child: _buildImage(b.images.first),
                                ),
                              const SizedBox(height: 8),
                              Text('Owner: ${b.owner}'),
                              Text('Location: ${b.location}'),
                              Text('Price: \$${b.price.toStringAsFixed(0)}'),
                              if (b.fromDate.isNotEmpty || b.toDate.isNotEmpty)
                                Text(
                                  'Dates: ${_formatDate(b.fromDate)} - ${_formatDate(b.toDate)}',
                                ),
                              const SizedBox(height: 8),
                              Text('Status: ${b.status}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                // navigate to house detail if desired
                                Navigator.pushNamed(
                                  context,
                                  '/houseDetail',
                                  arguments: {
                                    'id': b.houseId,
                                    'title': b.houseTitle,
                                    'images': b.images,
                                    'price': b.price,
                                    'location': b.location,
                                    'owner': b.owner,
                                  },
                                );
                              },
                              child: const Text('View House'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 110,
                              height: 80,
                              child: b.images.isNotEmpty
                                  ? _buildImage(b.images.first)
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.home, size: 36),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        b.houseTitle,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${b.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Owner: ${b.owner.isNotEmpty ? b.owner : '—'}',
                                ),
                                const SizedBox(height: 4),
                                if (b.fromDate.isNotEmpty ||
                                    b.toDate.isNotEmpty)
                                  Text(
                                    'Dates: ${_formatDate(b.fromDate)} - ${_formatDate(b.toDate)}',
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(b.status),
                                      backgroundColor: b.status == 'Confirmed'
                                          ? Colors.green[100]
                                          : b.status == 'Cancelled'
                                          ? Colors.red[100]
                                          : Colors.orange[100],
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      onSelected: (v) {
                                        if (v == 'confirm') {
                                          _updateStatus(b.id, 'Confirmed');
                                        }
                                        if (v == 'cancel') {
                                          _updateStatus(b.id, 'Cancelled');
                                        }
                                        if (v == 'remove') _removeBooking(b.id);
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'confirm',
                                          child: Text('Confirm'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'cancel',
                                          child: Text('Cancel'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'remove',
                                          child: Text('Remove'),
                                        ),
                                      ],
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
