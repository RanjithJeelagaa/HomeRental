import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new house
  Future<DocumentReference> addHouse(Map<String, dynamic> houseData) async {
    return await _db.collection('houses').add(houseData);
  }

  // Get all houses
  Future<List<Map<String, dynamic>>> getHouses() async {
    final snapshot = await _db.collection('houses').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Get houses for a specific user (owner)
  Future<List<Map<String, dynamic>>> getUserHouses(String ownerId) async {
    final snapshot = await _db
        .collection('houses')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Add a new booking
  Future<DocumentReference> addBooking(Map<String, dynamic> bookingData) async {
    return await _db.collection('bookings').add(bookingData);
  }

  // Get bookings for a user (visitor or owner)
  Future<List<Map<String, dynamic>>> getBookings({
    String? userId,
    String? ownerId,
  }) async {
    Query query = _db.collection('bookings');
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (ownerId != null) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}
