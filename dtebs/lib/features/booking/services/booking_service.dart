import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtebs/features/booking/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new booking
  Future<String> createBooking(Booking booking) async {
    try {
      print('═══ BOOKING DEBUG ═══');
      print('Creating booking for: ${booking.restaurantName}');
      print('Restaurant ID: ${booking.restaurantId}');
      print('Customer ID: ${booking.customerId}');
      print('Date: ${booking.bookingDate}');
      print('Time Slot: ${booking.timeSlot}');
      print('PAX: ${booking.pax}');
      print('Menu Items: ${booking.menuItems.length}');

      final docRef = await _firestore
          .collection('bookings')
          .add(booking.toMap());

      print('✓ SUCCESS! Booking ID: ${docRef.id}');
      print('═══════════════════');
      return docRef.id;
    } catch (e) {
      print('✗ ERROR creating booking: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('permission-denied')) {
        print('');
        print('╔════════════════════════════════════════╗');
        print('║  FIRESTORE PERMISSION DENIED ERROR!    ║');
        print('║  Update Firestore Security Rules:      ║');
        print('║  1. Go to Firebase Console             ║');
        print('║  2. Firestore Database > Rules          ║');
        print('║  3. Add bookings collection rules       ║');
        print('╚════════════════════════════════════════╝');
        print('');
      }
      rethrow;
    }
  }

  // Get bookings for a specific restaurant, date, and time slot
  Future<List<Booking>> getBookingsBySlot(
    String restaurantId,
    DateTime date,
    String timeSlot,
  ) async {
    try {
      // Create date range for the specific day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('bookings')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('timeSlot', isEqualTo: timeSlot)
          .where(
            'bookingDate',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where('bookingDate', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .where('status', isEqualTo: 'confirmed')
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting bookings: $e');
      return [];
    }
  }

  // Calculate occupied PAX for a specific slot
  Future<int> getOccupiedPax(
    String restaurantId,
    DateTime date,
    String timeSlot,
  ) async {
    print('─── Checking Occupied PAX ───');
    print('Restaurant: $restaurantId');
    print('Date: ${date.toIso8601String()}');
    print('Time Slot: $timeSlot');

    final bookings = await getBookingsBySlot(restaurantId, date, timeSlot);

    print('Found ${bookings.length} bookings for this slot');

    int total = 0;
    for (var booking in bookings) {
      print('  Booking ${booking.id}: ${booking.pax} pax');
      total += booking.pax;
    }

    print('Total occupied PAX: $total');
    print('─────────────────────────────');

    return total;
  }

  // Check if a slot is available for requested PAX
  Future<bool> isSlotAvailable(
    String restaurantId,
    int restaurantCapacity,
    DateTime date,
    String timeSlot,
    int requestedPax,
  ) async {
    final occupiedPax = await getOccupiedPax(restaurantId, date, timeSlot);
    return (occupiedPax + requestedPax) <= restaurantCapacity;
  }

  // Generate time slots from operating hours
  List<String> generateTimeSlots(String operatingHours) {
    try {
      // Parse "9:00 AM - 10:00 PM" format
      final parts = operatingHours.split(' - ');
      if (parts.length != 2) return [];

      final fromTime = _parseTime(parts[0].trim());
      final untilTime = _parseTime(parts[1].trim());

      if (fromTime == null || untilTime == null) return [];

      List<String> slots = [];
      DateTime currentSlot = fromTime;

      // Generate 2-hour slots
      while (currentSlot.isBefore(untilTime)) {
        final slotEnd = currentSlot.add(const Duration(hours: 2));

        // Only add slot if end time is within operating hours
        if (slotEnd.isAfter(untilTime)) break;

        final slotString =
            '${_formatTime(currentSlot)} - ${_formatTime(slotEnd)}';
        slots.add(slotString);

        currentSlot = slotEnd;
      }

      return slots;
    } catch (e) {
      print('Error generating time slots: $e');
      return [];
    }
  }

  // Parse time string to DateTime (using today's date for comparison)
  DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      int hour = int.parse(parts[0]);
      final minAndPeriod = parts[1].split(' ');
      if (minAndPeriod.length != 2) return null;

      final period = minAndPeriod[1];

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, 0);
    } catch (e) {
      return null;
    }
  }

  // Format DateTime to time string
  String _formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '$hour:00 $period';
  }

  // Get customer's bookings
  Stream<List<Booking>> getCustomerBookings(String customerId) {
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
