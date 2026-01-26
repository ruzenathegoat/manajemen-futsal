class FieldModel {
  final String id;
  final String name;
  final String description;
  final String type; // Field type: Vinyl, Rumput Sintetis, dll
  final int basePrice; // Harga per jam
  final String imageUrl; // URL gambar (bisa placeholder dulu)
  final List<String> facilities; // Contoh: Wifi, Toilet, Parkir
  final bool isActive;
  final bool isPopular; // Flag for popular/featured fields

  FieldModel({
    required this.id,
    required this.name,
    required this.description,
    this.type = 'Futsal',
    required this.basePrice,
    required this.imageUrl,
    required this.facilities,
    this.isActive = true,
    this.isPopular = false,
  });

  /// Alias for isActive - used in UI for availability display
  bool get isAvailable => isActive;

  factory FieldModel.fromMap(Map<String, dynamic> data, String documentId) {
    return FieldModel(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'Futsal',
      basePrice: data['basePrice'] ?? 0,
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      facilities: List<String>.from(data['facilities'] ?? []),
      isActive: data['isActive'] ?? true,
      isPopular: data['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'facilities': facilities,
      'isActive': isActive,
      'isPopular': isPopular,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with updated values
  FieldModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    int? basePrice,
    String? imageUrl,
    List<String>? facilities,
    bool? isActive,
    bool? isPopular,
  }) {
    return FieldModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      facilities: facilities ?? this.facilities,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}