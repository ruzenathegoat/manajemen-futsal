import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/core.dart';
import '../../models/field_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/widgets.dart';
import 'add_edit_field_screen.dart';

/// FutsalPro Field Management Screen
/// Admin screen to manage futsal fields
class FieldManagementScreen extends StatelessWidget {
  final bool embedded;
  
  const FieldManagementScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: embedded ? null : const ProAppBar(title: 'Kelola Lapangan'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditFieldScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: SafeArea(
        top: embedded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (embedded)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Lapangan',
                          style: AppTypography.headlineSmall(AppColors.textPrimaryDark),
                        ),
                        Text(
                          'Tambah, edit, atau hapus lapangan',
                          style: AppTypography.bodySmall(AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: StreamBuilder<List<FieldModel>>(
                stream: firestoreService.getFields(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  final fields = snapshot.data ?? [];

                  if (fields.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: fields.length,
                    itemBuilder: (context, index) {
                      final field = fields[index];
                      return _FieldCard(
                        field: field,
                        currencyFormat: currencyFormat,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditFieldScreen(field: field),
                            ),
                          );
                        },
                        onDelete: () => _showDeleteDialog(context, field, firestoreService),
                        onToggleStatus: () => _toggleFieldStatus(context, field, firestoreService),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ProShimmerCard(height: 120, showImage: false, lines: 3),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: AppTypography.titleMedium(AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodySmall(AppColors.textSecondaryDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stadium_outlined,
              size: 48,
              color: AppColors.textTertiaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada lapangan',
            style: AppTypography.titleMedium(AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan lapangan pertama anda',
            style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 24),
          ProButton(
            text: 'Tambah Lapangan',
            leadingIcon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditFieldScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FieldModel field,
    FirestoreService firestoreService,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        title: Text(
          'Hapus Lapangan?',
          style: AppTypography.titleLarge(AppColors.textPrimaryDark),
        ),
        content: Text(
          'Apakah anda yakin ingin menghapus "${field.name}"?',
          style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTypography.buttonMedium(AppColors.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await firestoreService.deleteField(field.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${field.name} berhasil dihapus'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFieldStatus(
    BuildContext context,
    FieldModel field,
    FirestoreService firestoreService,
  ) async {
    try {
      final updatedField = field.copyWith(isActive: !field.isActive);
      await firestoreService.updateField(updatedField);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              field.isActive
                  ? '${field.name} dinonaktifkan'
                  : '${field.name} diaktifkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _FieldCard extends StatelessWidget {
  final FieldModel field;
  final NumberFormat currencyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _FieldCard({
    required this.field,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: AppSpacing.borderRadiusLg,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: AppSpacing.borderRadiusMd,
                child: CachedNetworkImage(
                  imageUrl: field.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceLightDark,
                    child: const Icon(Icons.stadium, color: AppColors.textTertiaryDark),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceLightDark,
                    child: const Icon(Icons.broken_image, color: AppColors.textTertiaryDark),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            field.name,
                            style: AppTypography.titleSmall(AppColors.textPrimaryDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ProBadge(
                          text: field.isActive ? 'Aktif' : 'Nonaktif',
                          variant: field.isActive
                              ? ProBadgeVariant.success
                              : ProBadgeVariant.error,
                          size: ProBadgeSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormat.format(field.basePrice)} / jam',
                      style: AppTypography.priceSmall(AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      field.facilities.isNotEmpty
                          ? field.facilities.join(' • ')
                          : 'Tidak ada fasilitas',
                      style: AppTypography.caption(AppColors.textSecondaryDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColors.textSecondaryDark),
                color: AppColors.surfaceDark,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  side: BorderSide(color: AppColors.borderDark),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'toggle':
                      onToggleStatus();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: AppColors.textPrimaryDark),
                        const SizedBox(width: 12),
                        Text('Edit', style: AppTypography.bodyMedium(AppColors.textPrimaryDark)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          field.isActive ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: AppColors.textPrimaryDark,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          field.isActive ? 'Nonaktifkan' : 'Aktifkan',
                          style: AppTypography.bodyMedium(AppColors.textPrimaryDark),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: AppColors.error),
                        const SizedBox(width: 12),
                        Text('Hapus', style: AppTypography.bodyMedium(AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}