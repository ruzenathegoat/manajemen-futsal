import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class FAQItem {
  final String question;
  final String answer;
  
  FAQItem({required this.question, required this.answer});
}

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  static final List<FAQItem> faqItems = [
    FAQItem(
      question: 'Bagaimana cara melakukan booking lapangan?',
      answer: 'Pilih lapangan yang ingin Anda booking, pilih tanggal dan jam yang tersedia, kemudian konfirmasi booking. Anda akan menerima QR code yang bisa ditunjukkan ke admin saat check-in.',
    ),
    FAQItem(
      question: 'Berapa lama durasi booking yang diperbolehkan?',
      answer: 'Anda dapat booking mulai dari 1 jam hingga 3 jam per sesi. Durasi dapat dipilih saat melakukan booking.',
    ),
    FAQItem(
      question: 'Apakah bisa membatalkan booking?',
      answer: 'Ya, Anda dapat membatalkan booking melalui menu "Pesanan Saya". Booking yang dibatalkan tidak dapat dikembalikan.',
    ),
    FAQItem(
      question: 'Bagaimana sistem harga lapangan?',
      answer: 'Harga dasar lapangan berbeda-beda. Harga weekend (Sabtu & Minggu) dikenakan tambahan 10% dari harga normal.',
    ),
    FAQItem(
      question: 'Jam berapa saja lapangan tersedia?',
      answer: 'Lapangan tersedia dari jam 10:00 hingga 21:00 setiap hari.',
    ),
    FAQItem(
      question: 'Bagaimana cara melihat jadwal ketersediaan lapangan?',
      answer: 'Klik tombol "Lihat Jadwal" pada kartu lapangan untuk melihat ketersediaan lapangan dalam 30 hari ke depan.',
    ),
    FAQItem(
      question: 'Apakah bisa booking lebih dari satu lapangan sekaligus?',
      answer: 'Ya, Anda dapat melakukan multiple booking untuk lapangan yang berbeda pada waktu yang berbeda.',
    ),
    FAQItem(
      question: 'Bagaimana cara mengubah profil saya?',
      answer: 'Masuk ke menu Profile melalui drawer, kemudian Anda dapat mengubah foto profil, nama, dan password.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Consumer<ThemeProvider>(
                    builder: (context, theme, _) {
                      return Switch(
                        value: theme.isDarkMode,
                        onChanged: (value) => theme.toggleTheme(),
                      );
                    },
                  ),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notifications'),
                  trailing: Icon(Icons.chevron_right),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  subtitle: Text('Indonesian'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'FAQ (Frequently Asked Questions)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ...faqItems.map((faq) => ExpansionTile(
                  title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.w500)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        faq.answer,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
