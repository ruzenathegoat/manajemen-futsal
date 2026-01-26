import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/core.dart';
import '../../services/firestore_service.dart';
import '../../widgets/widgets.dart';

/// FutsalPro QR Scanner Screen
/// Admin screen to scan booking QR codes
class ScanQrScreen extends StatefulWidget {
  final bool embedded;
  
  const ScanQrScreen({super.key, this.embedded = false});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false; // Mencegah scan berulang-ulang cepat
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Booking'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: Colors.orange);
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processQrCode(barcode.rawValue!);
                  break; // Ambil satu saja
                }
              }
            },
          ),
          // Overlay UI untuk guide scanner
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Arahkan ke QR Code",
                  style: TextStyle(color: Colors.red, backgroundColor: Colors.black54),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _processQrCode(String qrData) async {
    setState(() => _isProcessing = true);
    
    // Pause kamera saat processing
    cameraController.stop();

    try {
      // 1. Cari Booking berdasarkan QR String
      final booking = await _firestoreService.getBookingByQr(qrData);

      if (!mounted) return;

      if (booking == null) {
        if (mounted) {
          _showResultDialog(
              isSuccess: false, 
              title: "Tidak Ditemukan", 
              message: "QR Code tidak terdaftar dalam sistem."
          );
        }
      } else if (booking.status == 'cancelled') {
        if (mounted) {
          _showResultDialog(
              isSuccess: false, 
              title: "Dibatalkan", 
              message: "Pesanan ini sudah dibatalkan sebelumnya."
          );
        }
      } else if (booking.status == 'completed') {
        if (mounted) {
          _showResultDialog(
              isSuccess: false, 
              title: "Sudah Dipakai", 
              message: "Pesanan ini sudah check-in sebelumnya."
          );
        }
      } else {
        // 2. Jika Valid (status == booked) -> Update jadi completed
        await _firestoreService.updateBookingStatus(booking.id, 'completed');
        if (mounted) {
          _showResultDialog(
              isSuccess: true, 
              title: "Check-in Berhasil!", 
              message: "Atas nama: ${booking.userName}\nLapangan: ${booking.fieldName}\nJam: ${booking.timeSlot}:00"
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showResultDialog(isSuccess: false, title: "Error", message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showResultDialog({required bool isSuccess, required String title, required String message}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Tutup dialog
                // Mulai ulang kamera untuk scan berikutnya
                if (mounted) {
                  setState(() => _isProcessing = false);
                  cameraController.start();
                }
              },
              child: const Text("SCAN LAGI"),
            ),
            if (isSuccess)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (mounted) {
                    Navigator.pop(context); // Kembali ke dashboard admin
                  }
                },
                child: const Text("SELESAI"),
              )
          ],
        );
      },
    );
  }
  
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}