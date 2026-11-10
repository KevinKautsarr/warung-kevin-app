import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'call_center_page.dart';
import 'detail_page.dart';
import 'login_page.dart';
import 'maps_page.dart';
import 'payment_page.dart';
import 'product.dart';
import 'riwayat_page.dart';
import 'sms_page.dart';
import 'update_user_page.dart';

// Halaman utama Dashboard toko dengan Grid 2 kolom produk
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Kunci ScaffoldMessenger lokal agar SnackBar penambahan menu hanya muncul di Dashboard
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  // Total nominal belanja yang dihitung secara dinamis
  int total = 0;

  // Menyimpan jumlah pesanan per nama produk (Map<String, int>)
  final Map<String, int> _jumlahPesanan = {};

  // Menghitung ulang total belanja (qty x harga) untuk memastikan nilai selalu tepat dan tidak pernah negatif
  int _hitungTotal() {
    int subtotal = 0;
    for (final entry in _jumlahPesanan.entries) {
      final produk = daftarProduk.firstWhere(
        (p) => p.nama == entry.key,
        orElse: () => Product(nama: entry.key, deskripsi: '', harga: 0, gambar: ''),
      );
      subtotal += entry.value * produk.harga;
    }
    return subtotal < 0 ? 0 : subtotal;
  }

  // Menambah 1 kuantitas produk ke total belanja dan memperbarui tampilan
  void _tambahItem(Product produk) {
    setState(() {
      _jumlahPesanan[produk.nama] = (_jumlahPesanan[produk.nama] ?? 0) + 1;
      total = _hitungTotal();
    });
  }

  // Mengurangi 1 kuantitas produk; jika mencapai 0, produk dihapus dari pesanan dan stepper hilang
  void _kurangItem(Product produk) {
    setState(() {
      final saatIni = _jumlahPesanan[produk.nama] ?? 0;
      if (saatIni > 1) {
        _jumlahPesanan[produk.nama] = saatIni - 1;
      } else {
        _jumlahPesanan.remove(produk.nama);
      }
      total = _hitungTotal();
    });
  }

  // Dialog konfirmasi untuk mengosongkan seluruh pesanan
  void _konfirmasiKosongkan() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan Pesanan?'),
        content: const Text('Semua menu yang dipilih akan dihapus dari pesanan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _jumlahPesanan.clear();
                total = 0;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pesanan berhasil dikosongkan')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }

  // Navigasi ke halaman form pembayaran saat bar Total di bawah diketuk
  Future<void> _bukaHalamanPembayaran() async {
    // Sembunyikan notifikasi SnackBar agar tidak terbawa ke halaman pembayaran
    _messengerKey.currentState?.clearSnackBars();

    final bool? lunas = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          total: total,
          pesanan: Map.from(_jumlahPesanan),
        ),
      ),
    );

    // Jika pembayaran berhasil, reset total belanja dan jumlah pesanan ke 0
    if (lunas == true) {
      setState(() {
        total = 0;
        _jumlahPesanan.clear();
      });
    }
  }

  // Dialog konfirmasi sebelum melakukan logout
  void _konfirmasiLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.utama),
            SizedBox(width: 8),
            Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);

              if (!mounted) return;

              // Navigator berpindah kembali ke halaman Login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.utama,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // Pengendali aksi menu popup di pojok kanan atas
  void _pilihMenu(String pilihan) {
    // Bersihkan SnackBar sebelum berpindah ke halaman menu
    _messengerKey.currentState?.clearSnackBars();
    switch (pilihan) {
      case 'call':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CallCenterPage()),
        );
        break;
      case 'sms':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SmsPage()),
        );
        break;
      case 'maps':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapsPage()),
        );
        break;
      case 'riwayat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RiwayatPage()),
        );
        break;
      case 'update':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UpdateUserPage()),
        );
        break;
      case 'logout':
        _konfirmasiLogout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScaffoldMessenger lokal agar notifikasi SnackBar penambahan produk hanya muncul di Dashboard
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 64,
        // Judul AppBar berupa Row: logo bulat + nama toko, dirata-tengahkan
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo kecil di AppBar dengan border putih tipis dan bayangan halus
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo_icon.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  // Fallback ikon jika logo_icon.png gagal dimuat
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.latar,
                    child: const Icon(
                      Icons.restaurant,
                      size: 22,
                      color: AppColors.sekunder,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Nama toko — Flexible agar tidak terpotong di layar sempit
            const Flexible(
              child: Text(
                'Warung Kevin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _pilihMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'call',
                child: Row(
                  children: [
                    Icon(Icons.phone, color: AppColors.sekunder, size: 20),
                    SizedBox(width: 10),
                    Text('Call Center'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sms',
                child: Row(
                  children: [
                    Icon(Icons.sms, color: AppColors.sekunder, size: 20),
                    SizedBox(width: 10),
                    Text('SMS Center'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'maps',
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.sekunder, size: 20),
                    SizedBox(width: 10),
                    Text('Lokasi / Maps'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'riwayat',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: AppColors.sekunder, size: 20),
                    SizedBox(width: 10),
                    Text('Riwayat Pesanan'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'update',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.sekunder, size: 20),
                    SizedBox(width: 10),
                    Text('Update User & Password'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Konten utama dibatasi lebar maksimum 480 px dan diratakan di tengah
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          // LayoutBuilder untuk mengukur lebar kartu aktual di berbagai ukuran layar (HP & desktop)
          child: LayoutBuilder(
            builder: (context, constraints) {
              // ── Perhitungan Tinggi Kartu yang Responsif ───────────────────
              // Lebar kartu dihitung dari lebar kontainer aktual (maks 480 px)
              // dikurangi padding kiri-kanan (12 x 2 = 24) dan jarak antar kartu (12), lalu dibagi 2
              // Tinggi kartu = (lebar kartu / rasio foto) + tinggi tetap area teks & padding bawah (76 px)
              const double rasioFoto = 1.25;
              const double tinggiAreaTeks = 76.0;
              final double lebarKartu = (constraints.maxWidth - 24 - 12) / 2;
              final double tinggiKartu = (lebarKartu / rasioFoto) + tinggiAreaTeks;

              return CustomScrollView(
                slivers: [
                  // Bagian 1: SliverToBoxAdapter berisi teks petunjuk yang ikut ter-scroll
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.orange.shade50,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.utama),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Ketuk gambar untuk menambah pesanan, ketuk nama untuk melihat detail.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.teksUtama,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bagian 2: SliverPadding & SliverGrid (2 kolom) berisi kartu produk
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      // mainAxisExtent dihitung dinamis dari lebar kartu agar kartu pas tanpa ruang kosong
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: tinggiKartu,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final produk = daftarProduk[index];
                          final int qty = _jumlahPesanan[produk.nama] ?? 0;

                          return Card(
                            color: Colors.white,
                            elevation: 3,
                            clipBehavior: Clip.antiAlias, // agar foto langsung terpotong oleh sudut kartu
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Ketuk GAMBAR -> Total belanja bertambah (setState)
                                // Jika qty > 0, terdapat kontrol stepper overlay berbentuk pil di bagian bawah foto
                                InkWell(
                                  onTap: () => _tambahItem(produk),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // AspectRatio 1.25 agar foto proporsional tanpa ruang kosong
                                      AspectRatio(
                                        aspectRatio: 1.25,
                                        child: Image.asset(
                                          produk.gambar,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                            color: AppColors.latar,
                                            child: const Icon(
                                              Icons.restaurant,
                                              size: 52,
                                              color: AppColors.utama,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Stepper overlay (- qty +) di bagian bawah foto bila qty > 0
                                      if (qty > 0)
                                        Positioned(
                                          bottom: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Tombol "-" untuk mengurangi qty pesanan
                                                InkWell(
                                                  onTap: () => _kurangItem(produk),
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 6, vertical: 2),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                      color: AppColors.utama,
                                                    ),
                                                  ),
                                                ),
                                                // Angka jumlah kuantitas pesanan
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                  child: Text(
                                                    '$qty',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.teksUtama,
                                                    ),
                                                  ),
                                                ),
                                                // Tombol "+" untuk menambah qty pesanan
                                                InkWell(
                                                  onTap: () => _tambahItem(produk),
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 6, vertical: 2),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 16,
                                                      color: AppColors.utama,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Ketuk NAMA produk -> Membuka halaman detail produk (1 baris, tebal, tanpa garis bawah + ikon info)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      _messengerKey.currentState?.clearSnackBars();
                                      final bool? tambah = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailPage(product: produk),
                                        ),
                                      );
                                      // Jika tombol "Tambah ke Total" di halaman detail ditekan
                                      if (tambah == true) {
                                        _tambahItem(produk);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              produk.nama,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.sekunder,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.info_outline,
                                            size: 14,
                                            color: AppColors.sekunder,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Label harga dengan aksen kuning lemon dan padding bawah sekitar 12 px
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.aksen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    formatRupiah(produk.harga),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.teksUtama,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: daftarProduk.length,
                      ),
                    ),
                  ),

                  // Bagian 3: Padding bawah sekitar 24 px di akhir daftar produk
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      // Bar Total di bagian bawah dengan aksi pembayaran dan ikon hapus pesanan
      bottomNavigationBar: Container(
        height: 64,
        color: AppColors.aksen,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    // Ikon tempat sampah untuk mengosongkan pesanan
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.teksUtama),
                      tooltip: 'Kosongkan Pesanan',
                      onPressed: total > 0 ? _konfirmasiKosongkan : null,
                    ),
                    // Ketuk Total -> Navigasi ke halaman form pembayaran (hanya aktif jika total > 0)
                    Expanded(
                      child: InkWell(
                        onTap: total > 0 ? _bukaHalamanPembayaran : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Total : ${formatRupiah(total)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.teksUtama,
                              ),
                            ),
                            if (total > 0)
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Ketuk untuk bayar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.teksUtama,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: AppColors.teksUtama,
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Pilih menu untuk mulai memesan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.teksUtama.withAlpha(179), // Opacity sekitar 0.7 agar lebih jelas terbaca
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Ruang penyeimbang agar area teks Total tetap tepat di tengah
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
