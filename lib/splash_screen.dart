import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'dashboard_page.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ─── Kontroler & Animasi ──────────────────────────────────────────────────
  late AnimationController _controller;

  // Logo: fade 0→1 dan scale 0.85→1.0 (Interval 0.0→0.55)
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  // Lingkaran berdenyut di belakang logo (opacity rendah, bolak-balik)
  late Animation<double> _pulseScale;

  // Teks "Warung Kevin": fade dan geser naik 16px (Interval 0.4→0.8)
  late Animation<double> _nameFade;
  late Animation<Offset> _nameSlide;

  // Teks "Selamat Datang" (Interval 0.4→0.8)
  late Animation<double> _greetFade;

  // Tagline "Ikan Bakar Segar" (Interval 0.6→1.0)
  late Animation<double> _tagFade;

  // Indikator progres dan versi (Interval 0.7→1.0)
  late Animation<double> _bottomFade;

  // Simpan future prefs agar bisa di-await paralel dengan animasi
  late Future<SharedPreferences> _prefsFuture;

  // Apakah precacheImage sudah dipanggil (untuk menghindari panggilan ganda)
  bool _imagePrecached = false;

  @override
  void initState() {
    super.initState();

    // Mulai muat SharedPreferences BERSAMAAN dengan animasi (paralel)
    _prefsFuture = SharedPreferences.getInstance();

    // ── Kontroler animasi: total 1.8 detik ──────────────────────────────────
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Logo fade
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    // Logo scale dengan easeOutBack untuk efek "melenting"
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // Denyut lingkaran di belakang logo (berjalan terus setelah controller)
    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Teks sambutan
    _greetFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Nama toko: fade dan slide naik 16px
    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.5), // ≈ 16px relatif terhadap tinggi teks
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Tagline muncul paling akhir
    _tagFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Progress bar & versi
    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Mulai animasi, lalu navigasi segera setelah animasi + prefs keduanya selesai
    _mulaiSplash();
  }

  // Mulai animasi dan tunggu PARALEL: animasi selesai & prefs dimuat
  Future<void> _mulaiSplash() async {
    // Jalankan animasi (1.8 detik) dan prefs secara bersamaan (tipe eksplisit agar Dart tidak salah infer)
    await Future.wait<dynamic>([
      _controller.forward(),
      _prefsFuture,
    ]);

    // Tambah jeda singkat agar splash tidak terlalu kilat (total ≤ 2.5 detik)
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    _navigasi();
  }

  // Periksa status login lalu pindah halaman dengan FadeTransition 400 ms
  Future<void> _navigasi() async {
    final prefs = await _prefsFuture;
    final bool sudahLogin = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (ctx, a1, a2) =>
            sudahLogin ? const DashboardPage() : const LoginPage(),
        // Efek fade halus saat berpindah halaman
        transitionsBuilder: (ctx2, anim, a3, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-muat gambar logo agar tidak berkedip saat pertama tampil
    if (!_imagePrecached) {
      _imagePrecached = true;
      precacheImage(const AssetImage('assets/images/logo.png'), context)
          .catchError((e) {
        debugPrint('[SplashScreen] precacheImage gagal: $e');
      });
    }
  }

  @override
  void dispose() {
    // Bersihkan kontroler animasi saat widget dihancurkan
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.latar, // Latar krem pasir
      body: SafeArea(
        child: Stack(
          children: [
            // ── Konten utama di tengah ────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo + lingkaran berdenyut ─────────────────────────
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran lembut berdenyut di belakang logo
                        ScaleTransition(
                          scale: _pulseScale,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.utama.withAlpha(30),
                                  AppColors.utama.withAlpha(0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Logo dengan animasi fade + scale
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 220,
                              // errorBuilder: tetap ada untuk fallback & debug
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                  '[SplashScreen] Logo gagal dimuat: $error',
                                );
                                return const Icon(
                                  Icons.restaurant,
                                  size: 100,
                                  color: AppColors.sekunder,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Teks sambutan kecil ───────────────────────────────
                  FadeTransition(
                    opacity: _greetFade,
                    child: const Text(
                      'Selamat Datang di',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.sekunder,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ── Nama toko: fade + slide naik ──────────────────────
                  FadeTransition(
                    opacity: _nameFade,
                    child: SlideTransition(
                      position: _nameSlide,
                      child: const Text(
                        'Warung Kevin',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sekunder,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Tagline kecil ─────────────────────────────────────
                  FadeTransition(
                    opacity: _tagFade,
                    child: Text(
                      'Ikan Bakar Segar',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.teksUtama.withAlpha(153), // abu-abu tua
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar tipis + versi di bagian bawah ───────────────
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _bottomFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LinearProgressIndicator lebar 120px, tinggi 3px
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 120,
                        height: 3,
                        child: LinearProgressIndicator(
                          backgroundColor:
                              AppColors.utama.withAlpha(40),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.utama,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Label versi sangat kecil
                    Text(
                      'v1.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.teksUtama.withAlpha(100),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
