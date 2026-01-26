import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    
    // Handle null user case
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Booking')),
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
      appBar: AppBar(title: const Text('Riwayat Booking')),
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
          // Filter only completed or cancelled bookings
          final historyBookings = allBookings.where((booking) => 
            booking.status == 'completed' || booking.status == 'cancelled'
          ).toList();

          if (historyBookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada riwayat booking.'),
                  SizedBox(height: 8),
                  Text('Booking yang selesai atau dibatalkan akan muncul di sini'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyBookings.length,
            itemBuilder: (context, index) {
              final booking = historyBookings[index];
              Color statusColor;
              String statusText;

              // Logika Warna Status
              switch (booking.status) {
                case 'completed':
                  statusColor = Colors.green;
                  statusText = 'Selesai';
                  break;
                case 'cancelled':
                  statusColor = Colors.red;
                  statusText = 'Dibatalkan';
                  break;
                default:
                  statusColor = Colors.grey;
                  statusText = booking.status;
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(currencyFormat.format(booking.totalCost)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
