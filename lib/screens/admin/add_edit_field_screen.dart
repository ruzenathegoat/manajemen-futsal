import 'package:flutter/material.dart';
import '../../models/field_model.dart';
import '../../services/firestore_service.dart';

class AddEditFieldScreen extends StatefulWidget {
  final FieldModel? field; // Jika null = Mode Tambah, Jika ada = Mode Edit

  const AddEditFieldScreen({super.key, this.field});

  @override
  State<AddEditFieldScreen> createState() => _AddEditFieldScreenState();
}

class _AddEditFieldScreenState extends State<AddEditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController(); // Simpel URL dulu
  final _facilitiesCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika mode edit, isi form dengan data lama
    if (widget.field != null) {
      _nameCtrl.text = widget.field!.name;
      _descCtrl.text = widget.field!.description;
      _priceCtrl.text = widget.field!.basePrice.toString();
      _imageUrlCtrl.text = widget.field!.imageUrl;
      _facilitiesCtrl.text = widget.field!.facilities.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.field != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Lapangan' : 'Tambah Lapangan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lapangan', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Harga per Jam (Rp)', 
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar', 
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
                validator: (val) => val!.isEmpty ? 'Wajib diisi (Gunakan link dummy jika testing)' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facilitiesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fasilitas (pisahkan dengan koma)', 
                  border: OutlineInputBorder(),
                  hintText: 'Wifi, Toilet, Bola',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _isLoading ? null : _saveField,
                  child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : Text(isEditing ? 'UPDATE LAPANGAN' : 'SIMPAN LAPANGAN'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveField() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Parse fasilitas string ke List
      List<String> facilities = _facilitiesCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newField = FieldModel(
        id: widget.field?.id ?? '', // ID kosong jika tambah baru (nanti diabaikan di service add)
        name: _nameCtrl.text,
        description: _descCtrl.text,
        basePrice: int.parse(_priceCtrl.text),
        imageUrl: _imageUrlCtrl.text,
        facilities: facilities,
      );

      try {
        if (widget.field != null) {
          // Update
          await FirestoreService().updateField(newField);
        } else {
          // Create
          await FirestoreService().addField(newField);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}