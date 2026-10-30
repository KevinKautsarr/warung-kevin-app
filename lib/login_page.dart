import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _namaController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  bool _modeRegistrasi = true;

  // State untuk toggle visibilitas password (sembunyikan / tampilkan teks)
  bool _obscurePassword = true;

  // Variabel pesan error inline untuk validasi kolom kosong
  String? _errorNama;
  String? _errorUser;
  String? _errorPass;

  @override
  void initState() {
    super.initState();
    _cekAkunTersimpan();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Cek shared_preferences: jika sudah ada akun tersimpan, langsung masuk ke mode login
  Future<void> _cekAkunTersimpan() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('username') != null) {
      setState(() {
        _modeRegistrasi = false;
      });
    }
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  // Validasi input kolom kosong secara inline dan proses submit login / registrasi
  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = _namaController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text;

    // ── Logika validasi inline: muncul teks merah di bawah kolom yang kosong ──
    bool adaError = false;
    String? errNama;
    String? errUser;
    String? errPass;

    if (_modeRegistrasi && nama.isEmpty) {
      errNama = 'Nama lengkap wajib diisi';
      adaError = true;
    }
    if (user.isEmpty) {
      errUser = 'Username wajib diisi';
      adaError = true;
    }
    if (pass.isEmpty) {
      errPass = 'Password wajib diisi';
      adaError = true;
    }

    if (adaError) {
      setState(() {
        _errorNama = errNama;
        _errorUser = errUser;
        _errorPass = errPass;
      });
      return;
    }

    if (_modeRegistrasi) {
      // Simpan data pendaftaran akun baru ke shared_preferences
      await prefs.setString('nama', nama);
      await prefs.setString('username', user);
      await prefs.setString('password', pass);
      await prefs.setBool('isLoggedIn', true);
    } else {
      final savedUser = prefs.getString('username');
      final savedPass = prefs.getString('password');

      // Validasi kecocokan akun; jika salah tetap menampilkan notifikasi SnackBar
      if (user != savedUser || pass != savedPass) {
        _tampilkanPesan('Username atau password salah');
        return;
      }

      // Simpan status sesi aktif ke shared_preferences
      await prefs.setBool('isLoggedIn', true);
    }

    if (!mounted) return;

    // Berpindah ke Dashboard setelah login atau registrasi berhasil
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  // Reset: mengosongkan semua isian kolom dan menghapus seluruh pesan error inline
  void _reset() {
    _namaController.clear();
    _userController.clear();
    _passController.clear();
    setState(() {
      _errorNama = null;
      _errorUser = null;
      _errorPass = null;
    });
  }

  // Alih mode antara registrasi dan login
  void _gantiMode() {
    setState(() {
      _modeRegistrasi = !_modeRegistrasi;
      // Bersihkan pesan error saat beralih mode
      _errorNama = null;
      _errorUser = null;
      _errorPass = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    // Tinggi background header disesuaikan dengan tinggi status bar agar menempel ke atas layar
    final double headerHeight = statusBarHeight + 220;

    return Scaffold(
      backgroundColor: AppColors.latar,
      // Susunan SingleChildScrollView dengan Column rata atas (bukan Center di tengah layar)
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // ── 1. Latar Belakang Header Oranye (Melebar penuh, menempel tepi atas) ──
            Container(
              width: double.infinity,
              height: headerHeight,
              decoration: const BoxDecoration(
                color: AppColors.utama,
                // Hanya sudut bawah yang membulat (32 px); sudut atas lurus
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
            ),

            // ── 2. Konten Rata Atas (Header Info + Kartu Form Menimpa 40 px) ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Padding atas menghormati area status bar perangkat
                SizedBox(height: statusBarHeight + 16),

                // Logo aplikasi (88 x 88 px, sudut 20 px, border putih 2 px)
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.latar,
                        child: const Icon(
                          Icons.restaurant,
                          size: 44,
                          color: AppColors.sekunder,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Nama toko & sub-teks
                const Text(
                  'Warung Kevin',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ikan Bakar & Minuman Segar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // Jarak agar kartu form menimpa batas bawah header sekitar 40 px
                const SizedBox(height: 20),

                // ── 3. Kartu Form (Lebar maks 480 px, rata tengah horizontal) ──
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Judul kartu sesuai mode
                                Text(
                                  _modeRegistrasi
                                      ? 'Buat Akun Baru'
                                      : 'Selamat Datang Kembali',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.sekunder,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _modeRegistrasi
                                      ? 'Silakan isi data untuk mendaftar akun'
                                      : 'Masukkan username dan password Anda',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.teksUtama.withAlpha(160),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Kolom Nama Lengkap (hanya mode registrasi, animasi transisi AnimatedSize)
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  child: _modeRegistrasi
                                      ? Column(
                                          children: [
                                            TextField(
                                              controller: _namaController,
                                              textInputAction: TextInputAction.next,
                                              onChanged: (_) {
                                                if (_errorNama != null) {
                                                  setState(() => _errorNama = null);
                                                }
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Nama Lengkap',
                                                prefixIcon: const Icon(
                                                  Icons.badge_outlined,
                                                  color: AppColors.sekunder,
                                                ),
                                                border: const OutlineInputBorder(),
                                                errorText: _errorNama,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),

                                // Kolom Username
                                TextField(
                                  controller: _userController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (_errorUser != null) {
                                      setState(() => _errorUser = null);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: AppColors.sekunder,
                                    ),
                                    border: const OutlineInputBorder(),
                                    errorText: _errorUser,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Kolom Password dengan toggle intip password
                                TextField(
                                  controller: _passController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submit(), // Enter menjalankan submit
                                  onChanged: (_) {
                                    if (_errorPass != null) {
                                      setState(() => _errorPass = null);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.sekunder,
                                    ),
                                    // Tombol mata untuk melihat / menyembunyikan password
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.sekunder,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: const OutlineInputBorder(),
                                    errorText: _errorPass,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Tombol Submit (Masuk / Daftar) - tinggi 48, lebar penuh
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.utama,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                      _modeRegistrasi ? 'Daftar' : 'Masuk',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Tombol Reset - tinggi 48, lebar penuh
                                SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: _reset,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.sekunder,
                                      side: const BorderSide(color: AppColors.sekunder),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Tautan alih mode registrasi / login (teks wajib UTS)
                                TextButton(
                                  onPressed: _gantiMode,
                                  child: Text(
                                    _modeRegistrasi
                                        ? 'Punya akun? Login!'
                                        : 'Belum punya akun? Registrasi',
                                    style: const TextStyle(
                                      color: AppColors.sekunder,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
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
                ),
                // Jarak bawah sekitar 24 px agar nyaman digulir saat keyboard aktif
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
