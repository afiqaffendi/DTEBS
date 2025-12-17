class MenuItem {
  final String name;
  final double price;

  MenuItem({required this.name, required this.price});

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price};
  }
}

class Restaurant {
  final String? id;
  final String ownerId;
  final String name;
  final String address;
  final int capacity;
  final String operatingHours;
  final List<MenuItem> menu;

  Restaurant({
    this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.capacity,
    required this.operatingHours,
    this.menu = const [],
  });

  // Factory constructor for creating a new Restaurant instance from a map (e.g., from Firestore)
  factory Restaurant.fromMap(Map<String, dynamic> map, String id) {
    return Restaurant(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      capacity: map['capacity']?.toInt() ?? 0,
      operatingHours: map['operatingHours'] ?? '',
      menu:
          (map['menu'] as List<dynamic>?)
              ?.map((item) => MenuItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Method to convert Restaurant instance to a map (e.g., for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'capacity': capacity,
      'operatingHours': operatingHours,
      'menu': menu.map((item) => item.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, ownerId: $ownerId, name: $name, address: $address, capacity: $capacity, operatingHours: $operatingHours, menu: $menu)';
  }
}
