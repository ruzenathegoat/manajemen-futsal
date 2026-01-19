import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String fieldId;
  final String name;
  final String description;
  final double basePrice;
  final String? imageUrl;
  final bool isActive;
  final List<String> facilities;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FieldModel({
    required this.fieldId,
    required this.name,
    required this.description,
    required this.basePrice,
    this.imageUrl,
    this.isActive = true,
    this.facilities = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory FieldModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FieldModel(
      fieldId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      facilities: List<String>.from(data['facilities'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'facilities': facilities,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  FieldModel copyWith({
    String? fieldId,
    String? name,
    String? description,
    double? basePrice,
    String? imageUrl,
    bool? isActive,
    List<String>? facilities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldModel(
      fieldId: fieldId ?? this.fieldId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      facilities: facilities ?? this.facilities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
