import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Model item yang dipesan dalam satu transaksi
class ItemRiwayat {
  final String nama;
  final int harga;
  final int jumlah;

  const ItemRiwayat({
    required this.nama,
    required this.harga,
    required this.jumlah,
  });

  // Getter subtotal per item (harga x jumlah)
  int get subtotal => harga * jumlah;

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'harga': harga,
        'jumlah': jumlah,
      };

  factory ItemRiwayat.fromJson(Map<String, dynamic> json) => ItemRiwayat(
        nama: json['nama'] as String? ?? '',
        harga: (json['harga'] as num?)?.toInt() ?? 0,
        jumlah: (json['jumlah'] as num?)?.toInt() ?? 0,
      );
}

// Model data transaksi pembayaran yang berhasil
class Transaksi {
  final String id;
  final DateTime waktu;
  final List<ItemRiwayat> items;
  final int total;
  final int uangDiterima;
  final int kembalian;

  const Transaksi({
    required this.id,
    required this.waktu,
    required this.items,
    required this.total,
    required this.uangDiterima,
    required this.kembalian,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'waktu': waktu.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
        'uangDiterima': uangDiterima,
        'kembalian': kembalian,
      };

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return Transaksi(
      id: json['id'] as String? ?? '',
      waktu: DateTime.tryParse(json['waktu'] as String? ?? '') ?? DateTime.now(),
      items: rawItems
          .map((item) => ItemRiwayat.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      uangDiterima: (json['uangDiterima'] as num?)?.toInt() ?? 0,
      kembalian: (json['kembalian'] as num?)?.toInt() ?? 0,
    );
  }
}

// Format tanggal lokal Indonesia tanpa package intl (contoh: '10 Nov 2026, 14:35')
String formatTanggal(DateTime waktu) {
  const namaBulan = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final d = waktu.day.toString().padLeft(2, '0');
  final m = (waktu.month >= 1 && waktu.month <= 12) ? namaBulan[waktu.month] : '';
  final y = waktu.year;
  final h = waktu.hour.toString().padLeft(2, '0');
  final min = waktu.minute.toString().padLeft(2, '0');
  return '$d $m $y, $h:$min';
}

// Kelas statis untuk mengelola penyimpanan riwayat transaksi di SharedPreferences
class RiwayatStorage {
  static const String _kunciRiwayat = 'riwayat';

  // Memuat seluruh riwayat transaksi (terbaru di atas)
  static Future<List<Transaksi>> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kunciRiwayat);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final list = decoded
          .map((item) => Transaksi.fromJson(item as Map<String, dynamic>))
          .toList();
      // Pastikan urutan selalu terbaru di atas berdasarkan waktu
      list.sort((a, b) => b.waktu.compareTo(a.waktu));
      return list;
    } catch (_) {
      // Jika data rusak atau parsing gagal, kembalikan daftar kosong tanpa error
      return [];
    }
  }

  // Menyimpan transaksi baru (pencegahan simpan ganda diatur oleh pemanggil di payment_page.dart)
  static Future<void> simpan(Transaksi transaksi) async {
    try {
      final list = await muat();
      // Sisipkan transaksi baru di awal (urutan terbaru di atas)
      list.insert(0, transaksi);

      // Pembatasan maksimal 50 transaksi terbaru untuk efisiensi penyimpanan lokal
      final listBatas = list.length > 50 ? list.sublist(0, 50) : list;

      // Penyimpanan JSON: serialisasi seluruh transaksi menjadi satu String JSON di SharedPreferences
      final jsonString = jsonEncode(listBatas.map((t) => t.toJson()).toList());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kunciRiwayat, jsonString);
    } catch (_) {
      // Tangani kemungkinan error storage secara aman
    }
  }

  // Menghapus seluruh data riwayat dari SharedPreferences
  static Future<void> hapusSemua() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kunciRiwayat);
    } catch (_) {
      // Tangani kemungkinan error storage secara aman
    }
  }
}

