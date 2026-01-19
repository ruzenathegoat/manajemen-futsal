import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../services/field_service.dart';

class FieldProvider extends ChangeNotifier {
  final FieldService _fieldService = FieldService();

  List<FieldModel> _fields = [];
  List<FieldModel> _activeFields = [];
  FieldModel? _selectedField;
  bool _isLoading = false;
  String? _error;

  List<FieldModel> get fields => _fields;
  List<FieldModel> get activeFields => _activeFields;
  FieldModel? get selectedField => _selectedField;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Subscribe to all fields (admin)
  void subscribeToAllFields() {
    _fieldService.getAllFields().listen((fields) {
      _fields = fields;
      notifyListeners();
    });
  }

  // Subscribe to active fields (user)
  void subscribeToActiveFields() {
    _fieldService.getActiveFields().listen((fields) {
      _activeFields = fields;
      notifyListeners();
    });
  }

  // Stream single field
  void subscribeToField(String fieldId) {
    _fieldService.streamField(fieldId).listen((field) {
      _selectedField = field;
      notifyListeners();
    });
  }

  // Get field by ID
  Future<FieldModel?> getFieldById(String fieldId) async {
    try {
      return await _fieldService.getFieldById(fieldId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Create field (admin)
  Future<bool> createField({
    required String name,
    required String description,
    required double basePrice,
    String? imageUrl,
    List<String> facilities = const [],
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fieldService.createField(
        name: name,
        description: description,
        basePrice: basePrice,
        imageUrl: imageUrl,
        facilities: facilities,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update field (admin)
  Future<bool> updateField({
    required String fieldId,
    String? name,
    String? description,
    double? basePrice,
    String? imageUrl,
    bool? isActive,
    List<String>? facilities,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fieldService.updateField(
        fieldId: fieldId,
        name: name,
        description: description,
        basePrice: basePrice,
        imageUrl: imageUrl,
        isActive: isActive,
        facilities: facilities,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle field status (admin)
  Future<bool> toggleFieldStatus(String fieldId, bool isActive) async {
    try {
      await _fieldService.toggleFieldStatus(fieldId, isActive);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete field (admin)
  Future<bool> deleteField(String fieldId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fieldService.deleteField(fieldId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
