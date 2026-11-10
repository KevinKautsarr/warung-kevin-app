import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'product.dart';
import 'riwayat.dart';

// Halaman riwayat transaksi pesanan yang telah dibayar
class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool _memuat = true;
  List<Transaksi> _daftarTransaksi = [];

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  // Memuat data riwayat dari SharedPreferences
  Future<void> _muatData() async {
    setState(() => _memuat = true);
    final data = await RiwayatStorage.muat();
    if (!mounted) return;
    setState(() {
      _daftarTransaksi = data;
      _memuat = false;
    });
  }

  // Dialog konfirmasi untuk menghapus seluruh riwayat pesanan
  void _konfirmasiHapusSemua() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Hapus Semua Riwayat?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Semua catatan riwayat transaksi yang tersimpan di perangkat akan dihapus.',
          style: TextStyle(color: AppColors.teksUtama),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await RiwayatStorage.hapusSemua();
              if (!mounted) return;
              setState(() {
                _daftarTransaksi = [];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Riwayat berhasil dihapus'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Menampilkan bottom sheet rincian detail pesanan dan transaksi
  void _tampilkanRincian(Transaksi transaksi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis pegangan (drag handle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header judul dan tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rincian Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sekunder,
                    ),
                  ),
                  Text(
                    formatTanggal(transaksi.waktu),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.teksUtama.withAlpha(160),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Daftar item yang dipesan
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: transaksi.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final item = transaksi.items[index];
                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.teksUtama,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${item.jumlah} x ${formatRupiah(item.harga)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            formatRupiah(item.subtotal),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.sekunder,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Rincian total, uang diterima, dan kembalian
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatRupiah(transaksi.total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.utama,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uang Diterima:'),
                  Text(
                    formatRupiah(transaksi.uangDiterima),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian:'),
                  Text(
                    formatRupiah(transaksi.kembalian),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tombol Tutup
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.utama,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kartu ringkasan atas: jumlah transaksi dan total pendapatan
  Widget _buildRingkasan() {
    final totalPendapatan =
        _daftarTransaksi.fold<int>(0, (sum, t) => sum + t.total);

    return Card(
      color: AppColors.aksen,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Kolom Jumlah Transaksi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teksUtama.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.receipt, color: AppColors.sekunder, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${_daftarTransaksi.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sekunder,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: AppColors.teksUtama.withAlpha(50),
            ),
            const SizedBox(width: 16),
            // Kolom Total Pendapatan
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pendapatan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teksUtama.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(totalPendapatan),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.teksUtama,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kartu putih tiap item transaksi
  Widget _buildKartuTransaksi(Transaksi transaksi) {
    final totalItem =
        transaksi.items.fold<int>(0, (sum, item) => sum + item.jumlah);

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _tampilkanRincian(transaksi),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ikon struk
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.latar,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.sekunder,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Tanggal dan ringkasan item
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTanggal(transaksi.waktu),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sekunder,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalItem item (${transaksi.items.length} menu)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.teksUtama.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),

              // Total dalam pil kuning
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.aksen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formatRupiah(transaksi.total),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teksUtama,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        centerTitle: true,
        actions: [
          if (_daftarTransaksi.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Hapus Semua Riwayat',
              onPressed: _konfirmasiHapusSemua,
            ),
        ],
      ),
      // Konten dibatasi lebar maksimum 480 px dan diratakan di tengah
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _memuat
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.utama),
                )
              : _daftarTransaksi.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: AppColors.sekunder.withAlpha(120),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada riwayat pesanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.sekunder,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Transaksi yang sudah dibayar akan muncul di sini',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.teksUtama.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _buildRingkasan(),
                        const SizedBox(height: 16),
                        ..._daftarTransaksi.map(_buildKartuTransaksi),
                      ],
                    ),
        ),
      ),
    );
  }
}

