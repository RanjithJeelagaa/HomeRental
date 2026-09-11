class HouseModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> facilities;
  final List<String> images;

  HouseModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.facilities,
    required this.images,
  });

  factory HouseModel.fromMap(Map<String, dynamic> map, String id) {
    return HouseModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      facilities:
          (map['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      images:
          (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'facilities': facilities,
      'images': images,
    };
  }
}
