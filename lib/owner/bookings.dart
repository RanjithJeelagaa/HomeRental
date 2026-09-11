// ...existing code...
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerBookingsScreen extends StatelessWidget {
  final String ownerId;
  const OwnerBookingsScreen({super.key, required this.ownerId});

  Future<void> _updateStatus(
    BuildContext context,
    String bookingId,
    String status,
  ) async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Update in visitor bookings collection (root bookings)
      await firestore.collection('bookings').doc(bookingId).update({
        'status': status,
      });

      // Update in owner bookings subcollection
      await firestore
          .collection('ownerBookings')
          .doc(ownerId)
          .collection('bookings')
          .doc(bookingId)
          .update({'status': status});

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $status')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownerBookingsRef = FirebaseFirestore.instance
        .collection('ownerBookings')
        .doc(ownerId)
        .collection('bookings')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('My House Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: ownerBookingsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = (doc.data() as Map<String, dynamic>?) ?? {};
              // Use document id as bookingId (don't rely on a field named 'id')
              final bookingId = doc.id;

              final houseTitle =
                  data['houseTitle'] ?? data['houseId'] ?? 'House';
              final houseImage = data['houseImage'] as String?;
              final userName = data['userName'] ?? '';
              final userContact = data['userContact'] ?? '';
              final status = (data['status'] ?? 'Pending').toString();
              final statusColor = status.toLowerCase() == 'confirmed'
                  ? Colors.green
                  : (status.toLowerCase() == 'rejected'
                        ? Colors.red
                        : Colors.orange);

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (houseImage != null && houseImage.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                houseImage,
                                width: 90,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 90,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.home, size: 32),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 90,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.home, size: 32),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  houseTitle,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('Visitor: $userName'),
                                Text('Phone: $userContact'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if ((data['altContact'] ?? '').toString().isNotEmpty)
                        Text("Alt Phone: ${data['altContact']}"),
                      Text("Email: ${data['userEmail'] ?? ''}"),
                      if ((data['jobTitle'] ?? '').toString().isNotEmpty)
                        Text("Job: ${data['jobTitle']}"),
                      if ((data['salary'] ?? '').toString().isNotEmpty)
                        Text("Salary: ${data['salary']}"),
                      if ((data['companyName'] ?? '').toString().isNotEmpty)
                        Text("Company: ${data['companyName']}"),
                      if ((data['companyAddress'] ?? '').toString().isNotEmpty)
                        Text("Company Address: ${data['companyAddress']}"),
                      const SizedBox(height: 8),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: status.toLowerCase() == 'confirmed'
                                ? null
                                : () => _updateStatus(
                                    context,
                                    bookingId,
                                    'Confirmed',
                                  ),
                            icon: const Icon(Icons.check),
                            label: const Text('Confirm'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: status.toLowerCase() == 'rejected'
                                ? null
                                : () => _updateStatus(
                                    context,
                                    bookingId,
                                    'Rejected',
                                  ),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// ...existing code...