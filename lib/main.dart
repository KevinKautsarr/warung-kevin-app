import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

// Widget utama aplikasi Warung Kevin
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Kevin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Konfigurasi skema warna Bara & Laut
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.utama,
          secondary: AppColors.sekunder,
        ),
        scaffoldBackgroundColor: AppColors.latar,
        // Tema AppBar dengan teks putih tebal dan warna oranye bara
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.utama,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        // Tema tombol utama dengan latar oranye bara dan teks putih tebal
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.utama,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
