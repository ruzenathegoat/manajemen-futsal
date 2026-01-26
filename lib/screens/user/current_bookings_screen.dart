import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';

class CurrentBookingsScreen extends StatelessWidget {
  const CurrentBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    
    // Handle null user case
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Aktif')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('User not found. Please login again.'),
            ],
          ),
        ),
      );
    }
    final firestoreService = FirestoreService();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Aktif')),
      body: StreamBuilder<List<BookingModel>>(
        stream: firestoreService.getUserBookings(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Terjadi kesalahan saat memuat data.'),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          final allBookings = snapshot.data ?? [];
          // Filter only active bookings (booked or approved)
          final activeBookings = allBookings.where((booking) => 
            booking.status == 'booked' || booking.status == 'approved'
          ).toList();

          if (activeBookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_online, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada booking aktif.'),
                  SizedBox(height: 8),
                  Text('Booking aktif akan muncul di sini'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeBookings.length,
            itemBuilder: (context, index) {
              final booking = activeBookings[index];
              Color statusColor;
              String statusText;

              // Logika Warna Status
              switch (booking.status) {
                case 'booked':
                  statusColor = Colors.blue;
                  statusText = 'Menunggu';
                  break;
                case 'approved':
                  statusColor = Colors.orange;
                  statusText = 'Disetujui';
                  break;
                default:
                  statusColor = Colors.grey;
                  statusText = booking.status;
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () => _showBookingDetail(context, booking),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormat.format(booking.date),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                statusText.toUpperCase(),
                                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Icon(Icons.stadium, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(booking.fieldName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Text("Jam: ${booking.timeSlot}:00 - ${booking.timeSlot + booking.duration}:00 (${booking.duration} jam)"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text(currencyFormat.format(booking.totalCost)),
                              ],
                            ),
                            if (booking.status == 'booked' || booking.status == 'approved')
                              const Row(
                                children: [
                                  Text("Lihat QR", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  Icon(Icons.chevron_right, color: Colors.blue),
                                ],
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Menampilkan Detail & QR Code
  void _showBookingDetail(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(booking.fieldName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(DateFormat('EEEE, d MMM yyyy', 'id_ID').format(booking.date)),
              const SizedBox(height: 24),
              
              if (booking.status == 'booked' || booking.status == 'approved') ...[
                const Text("Tunjukkan QR Code ini ke Admin", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: booking.qrCode,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text("Batalkan Pesanan", style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      // Logic Cancel
                      try {
                        await FirestoreService().cancelBooking(booking.id);
                        if (context.mounted) {
                          Navigator.pop(context); // Tutup modal
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Pesanan dibatalkan"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal membatalkan: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                )
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
