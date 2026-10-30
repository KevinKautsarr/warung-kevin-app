import 'package:flutter/material.dart';
import 'app_colors.dart';

// Halaman tampilan SMS (hanya form simulasi, tanpa membuka aplikasi SMS eksternal)
class SmsPage extends StatefulWidget {
  const SmsPage({super.key});

  @override
  State<SmsPage> createState() => _SmsPageState();
}

class _SmsPageState extends State<SmsPage> {
  // Nomor tujuan default terisi nomor penjual Warung Kevin
  final _tujuanController = TextEditingController(text: '0812-3456-7890');
  final _pesanController = TextEditingController();

  @override
  void dispose() {
    _tujuanController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  void _kirimSms() {
    final pesan = _pesanController.text.trim();
    if (pesan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi pesan tidak boleh kosong')),
      );
      return;
    }

    _pesanController.clear();
    // Menampilkan SnackBar "Pesan terkirim" sesuai instruksi tugas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesan terkirim')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('SMS Center'),
        centerTitle: true,
      ),
      // Konten dibatasi lebar maksimum 480 px dan diratakan di tengah
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sms_outlined, color: AppColors.sekunder, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Kirim Pesan SMS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sekunder,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Kolom nomor tujuan terisi nomor penjual
                    TextField(
                      controller: _tujuanController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Tujuan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_android, color: AppColors.sekunder),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kolom isi pesan
                    TextField(
                      controller: _pesanController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Isi Pesan',
                        hintText: 'Tulis pesan Anda untuk Warung Kevin di sini...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Kirim Pesan
                    ElevatedButton(
                      onPressed: _kirimSms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.utama,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Kirim',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
