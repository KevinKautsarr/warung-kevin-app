import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

// Halaman untuk memperbarui username dan password di shared_preferences
class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  // State untuk toggle visibilitas password (sembunyikan / tampilkan teks)
  bool _obscure = true;

  // Variabel pesan error inline untuk validasi kolom kosong
  String? _errorUser;
  String? _errorPass;

  @override
  void initState() {
    super.initState();
    _muatDataPengguna();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Membaca username dan password yang tersimpan di shared_preferences
  Future<void> _muatDataPengguna() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userController.text = prefs.getString('username') ?? '';
      _passController.text = prefs.getString('password') ?? '';
    });
  }

  // Validasi inline dan menyimpan perubahan ke shared_preferences
  Future<void> _update() async {
    final usernameBaru = _userController.text.trim();
    final passwordBaru = _passController.text;

    // ── Logika validasi inline: periksa kolom kosong ──
    bool adaError = false;
    String? errUser;
    String? errPass;

    if (usernameBaru.isEmpty) {
      errUser = 'User tidak boleh kosong';
      adaError = true;
    }
    if (passwordBaru.isEmpty) {
      errPass = 'Password tidak boleh kosong';
      adaError = true;
    }

    if (adaError) {
      setState(() {
        _errorUser = errUser;
        _errorPass = errPass;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', usernameBaru);
    await prefs.setString('password', passwordBaru);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data pengguna berhasil diperbarui')),
    );

    // Navigator kembali ke DashboardPage
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('Update User & Password'),
        centerTitle: true,
      ),
      // Tata letak rata tengah vertikal & horizontal, lebar maks 480 px
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ubah Kredensial Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sekunder,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Perubahan akan dipakai untuk login berikutnya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.teksUtama.withAlpha(160),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Kolom User dengan ikon garis tipis person_outline
                    TextField(
                      controller: _userController,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_errorUser != null) {
                          setState(() => _errorUser = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'User',
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.sekunder),
                        border: const OutlineInputBorder(),
                        errorText: _errorUser,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kolom Password dengan ikon lock_outline dan toggle intip password
                    TextField(
                      controller: _passController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _update(), // Tekan Enter menjalankan Update
                      onChanged: (_) {
                        if (_errorPass != null) {
                          setState(() => _errorPass = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.sekunder),
                        // Toggle visibilitas password (ikon mata)
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.sekunder,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscure = !_obscure;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                        errorText: _errorPass,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Update - tinggi 48, lebar penuh
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _update,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.utama,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Cancel - tinggi 48, lebar penuh
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigator membatalkan perubahan dan kembali
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.sekunder,
                          side: const BorderSide(color: AppColors.sekunder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
