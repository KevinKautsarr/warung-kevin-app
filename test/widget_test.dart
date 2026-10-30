import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warung_kevin/dashboard_page.dart';
import 'package:warung_kevin/main.dart';

void main() {
  testWidgets('App smoke test - splash screen shows store name and routes to login',
      (WidgetTester tester) async {
    // Inisialisasi mock SharedPreferences dengan status belum login
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});

    // Membangun widget aplikasi MyApp
    await tester.pumpWidget(const MyApp());

    // Verifikasi elemen splash: sambutan, nama toko, dan tagline
    expect(find.text('Selamat Datang di'), findsOneWidget);
    expect(find.text('Warung Kevin'), findsOneWidget);
    expect(find.text('Ikan Bakar Segar'), findsOneWidget);

    // Pompa waktu 3 detik agar splash selesai (animasi 1.8s + jeda 0.5s)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Karena belum login, setelah splash screen harus menuju halaman Login / Registrasi
    expect(find.text('Warung Kevin'), findsWidgets);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('Dashboard renders grid products and total bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardPage(),
      ),
    );
    await tester.pump();

    // Verifikasi produk muncul di layar
    expect(find.text('Nila Bakar Kecap'), findsOneWidget);
    expect(find.text('Gurame Bakar'), findsOneWidget);
    expect(find.text('Total : Rp. 0'), findsOneWidget);
    expect(find.text('Pilih menu untuk mulai memesan'), findsOneWidget);
  });

  testWidgets('Tapping product image in Dashboard displays stepper and increments total',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardPage(),
      ),
    );
    await tester.pump();

    // Ketuk produk pertama
    final inkWells = find.byType(InkWell);
    await tester.tap(inkWells.first);
    await tester.pump();

    // Verifikasi stepper muncul (angka '1' dan ikon add/remove) dan Total bertambah
    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Total : Rp. 25.000'), findsOneWidget);
  });
}
