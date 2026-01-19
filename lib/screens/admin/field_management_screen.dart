import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/field_model.dart';
import '../../providers/field_provider.dart';
import '../../widgets/cards/field_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class FieldManagementScreen extends StatefulWidget {
  const FieldManagementScreen({super.key});

  @override
  State<FieldManagementScreen> createState() => _FieldManagementScreenState();
}

class _FieldManagementScreenState extends State<FieldManagementScreen> {
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldProvider = context.watch<FieldProvider>();

    final fields = fieldProvider.fields.where((field) {
      if (_showActiveOnly && !field.isActive) return false;
      if (_searchQuery.isEmpty) return true;
      return field.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFieldForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchAndFilter(isDark),
            const SizedBox(height: 16),
            Expanded(
              child: fields.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada lapangan',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: fields.length,
                      itemBuilder: (context, index) {
                        final field = fields[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Stack(
                            children: [
                              FieldCard(
                                field: field,
                                showStatus: true,
                                onTap: () => _showFieldForm(context, field: field),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showFieldForm(context, field: field);
                                    } else if (value == 'delete') {
                                      _confirmDelete(field.fieldId);
                                    } else if (value == 'toggle') {
                                      fieldProvider.toggleFieldStatus(
                                        field.fieldId,
                                        !field.isActive,
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'toggle',
                                      child: Text(field.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Cari lapangan...',
                border: InputBorder.none,
                icon: Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilterChip(
          label: const Text('Aktif'),
          selected: _showActiveOnly,
          onSelected: (value) => setState(() => _showActiveOnly = value),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: _showActiveOnly ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showFieldForm(BuildContext context, {FieldModel? field}) {
    final nameController = TextEditingController(text: field?.name ?? '');
    final descriptionController =
        TextEditingController(text: field?.description ?? '');
    final priceController = TextEditingController(
      text: field?.basePrice.toStringAsFixed(0) ?? '',
    );
    final imageController = TextEditingController(text: field?.imageUrl ?? '');
    bool isActive = field?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field == null ? 'Tambah Lapangan' : 'Edit Lapangan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Nama Lapangan',
                    controller: nameController,
                    validator: (value) => Validators.validateRequired(value, 'Nama'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Deskripsi',
                    controller: descriptionController,
                    maxLines: 3,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Deskripsi'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Harga Dasar',
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePrice,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Image URL',
                    controller: imageController,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Switch(
                        value: isActive,
                        onChanged: (value) => setModalState(() => isActive = value),
                        activeThumbColor: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(isActive ? 'Aktif' : 'Nonaktif'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: field == null ? 'Simpan' : 'Update',
                    isFullWidth: true,
                    onPressed: () async {
                      final provider = context.read<FieldProvider>();
                      final price = double.tryParse(
                            priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0;

                      if (field == null) {
                        await provider.createField(
                          name: nameController.text,
                          description: descriptionController.text,
                          basePrice: price,
                          imageUrl: imageController.text,
                        );
                      } else {
                        await provider.updateField(
                          fieldId: field.fieldId,
                          name: nameController.text,
                          description: descriptionController.text,
                          basePrice: price,
                          imageUrl: imageController.text,
                          isActive: isActive,
                        );
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String fieldId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Lapangan'),
          content: const Text('Apakah Anda yakin ingin menghapus lapangan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await context.read<FieldProvider>().deleteField(fieldId);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
