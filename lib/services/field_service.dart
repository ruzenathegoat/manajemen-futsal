import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/field_model.dart';
import '../core/constants/app_constants.dart';

class FieldService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Get all active fields
  Stream<List<FieldModel>> getActiveFields() {
    return _firestore
        .collection(AppConstants.fieldsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FieldModel.fromFirestore(doc))
            .toList());
  }

  // Get all fields (admin)
  Stream<List<FieldModel>> getAllFields() {
    return _firestore
        .collection(AppConstants.fieldsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FieldModel.fromFirestore(doc))
            .toList());
  }

  // Get field by ID
  Future<FieldModel?> getFieldById(String fieldId) async {
    final doc = await _firestore
        .collection(AppConstants.fieldsCollection)
        .doc(fieldId)
        .get();

    if (doc.exists) {
      return FieldModel.fromFirestore(doc);
    }
    return null;
  }

  // Stream single field
  Stream<FieldModel?> streamField(String fieldId) {
    return _firestore
        .collection(AppConstants.fieldsCollection)
        .doc(fieldId)
        .snapshots()
        .map((doc) => doc.exists ? FieldModel.fromFirestore(doc) : null);
  }

  // Create new field (admin)
  Future<FieldModel> createField({
    required String name,
    required String description,
    required double basePrice,
    String? imageUrl,
    List<String> facilities = const [],
  }) async {
    final fieldId = _uuid.v4();

    final field = FieldModel(
      fieldId: fieldId,
      name: name,
      description: description,
      basePrice: basePrice,
      imageUrl: imageUrl,
      isActive: true,
      facilities: facilities,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.fieldsCollection)
        .doc(fieldId)
        .set(field.toFirestore());

    return field;
  }

  // Update field (admin)
  Future<void> updateField({
    required String fieldId,
    String? name,
    String? description,
    double? basePrice,
    String? imageUrl,
    bool? isActive,
    List<String>? facilities,
  }) async {
    final Map<String, dynamic> updates = {
      'updatedAt': Timestamp.now(),
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (basePrice != null) updates['basePrice'] = basePrice;
    if (imageUrl != null) updates['imageUrl'] = imageUrl;
    if (isActive != null) updates['isActive'] = isActive;
    if (facilities != null) updates['facilities'] = facilities;

    await _firestore
        .collection(AppConstants.fieldsCollection)
        .doc(fieldId)
        .update(updates);
  }

  // Toggle field status (admin)
  Future<void> toggleFieldStatus(String fieldId, bool isActive) async {
    await _firestore
        .collection(AppConstants.fieldsCollection)
        .doc(fieldId)
        .update({
          'isActive': isActive,
          'updatedAt': Timestamp.now(),
        });
  }

  // Delete field (admin) - soft delete by setting isActive to false
  Future<void> deleteField(String fieldId) async {
    await _firestore
        .collection(AppConstants.fieldsCollection)
        .doc(fieldId)
        .delete();
  }

  // Get field count
  Future<int> getFieldCount() async {
    final snapshot = await _firestore
        .collection(AppConstants.fieldsCollection)
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
