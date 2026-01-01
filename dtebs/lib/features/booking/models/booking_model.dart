class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({required this.name, required this.price, required this.quantity});

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  double get totalPrice => price * quantity;
}

class Booking {
  final String? id;
  final String restaurantId;
  final String restaurantName;
  final String customerId;
  final String customerName;
  final DateTime bookingDate;
  final String timeSlot;
  final int pax;
  final List<OrderItem> menuItems;
  final DateTime createdAt;
  final String status;

  Booking({
    this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.customerId,
    required this.customerName,
    required this.bookingDate,
    required this.timeSlot,
    required this.pax,
    required this.menuItems,
    required this.createdAt,
    this.status = 'confirmed',
  });

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'customerId': customerId,
      'customerName': customerName,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'pax': pax,
      'menuItems': menuItems.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map, String documentId) {
    return Booking(
      id: documentId,
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      bookingDate: DateTime.parse(map['bookingDate']),
      timeSlot: map['timeSlot'] ?? '',
      pax: map['pax'] ?? 0,
      menuItems:
          (map['menuItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'confirmed',
    );
  }

  double get totalAmount {
    return menuItems.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
