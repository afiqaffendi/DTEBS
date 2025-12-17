import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'restaurants';

  // Get Restaurant by Owner ID
  Future<Restaurant?> getRestaurantByOwnerId(String ownerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Restaurant.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
      }
    } catch (e) {
      print('Error getting restaurant: $e');
    }
    return null;
  }

  // Save Restaurant Details (Create or Update)
  Future<void> saveRestaurantDetails(Restaurant restaurant) async {
    try {
      // Check if restaurant already exists for this owner
      final QuerySnapshot existing = await _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: restaurant.ownerId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update existing document
        await _firestore
            .collection(_collection)
            .doc(existing.docs.first.id)
            .update(restaurant.toMap());
      } else {
        // Create new document
        await _firestore.collection(_collection).add(restaurant.toMap());
      }
    } catch (e) {
      print('Error saving restaurant details: $e');
      rethrow;
    }
  }

  // Get All Restaurants (For Customers)
  Stream<List<Restaurant>> getAllRestaurants() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Restaurant.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
