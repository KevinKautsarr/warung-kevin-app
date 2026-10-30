import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'product.dart';

// Halaman pembayaran dengan ringkasan pesanan, tombol cepat nominal, dan dialog sukses
class PaymentPage extends StatefulWidget {
  final int total;
  final Map<String, int> pesanan;

  const PaymentPage({
    super.key,
    required this.total,
    this.pesanan = const {},
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _bayarController = TextEditingController();

  int get _jumlahBayar => int.tryParse(_bayarController.text) ?? 0;
  int get _kembalian => _jumlahBayar - widget.total;

  @override
  void initState() {
    super.initState();
    // Bersihkan sisa SnackBar dari dashboard agar tidak tampil di halaman pembayaran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

  @override
  void dispose() {
    _bayarController.dispose();
    super.dispose();
  }

  // Dialog sukses pembayaran menampilkan total, uang diterima, dan kembalian
  void _tampilkanDialogSukses() {
    final bayar = _jumlahBayar;
    final kembali = _kembalian;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Pembayaran Berhasil', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terima kasih telah berbelanja di Warung Kevin!',
              style: TextStyle(color: AppColors.teksUtama),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Belanja:'),
                Text(
                  formatRupiah(widget.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Uang Diterima:'),
                Text(
                  formatRupiah(bayar),
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
                  formatRupiah(kembali),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Tutup dialog konfirmasi
              Navigator.pop(dialogContext);
              // Kembali ke dashboard dengan sinyal true agar keranjang/total dikosongkan
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.utama,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textJudul = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.sekunder,
    );

    final bool cukupUang = widget.total > 0 && _kembalian >= 0;

    // Filter daftar item pesanan yang memiliki kuantitas lebih dari 0
    final itemDipesan = widget.pesanan.entries
        .where((entry) => entry.value > 0)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        centerTitle: true,
      ),
      // Konten rata atas dengan jarak 16 px dari AppBar, dibatasi lebar maks 480 px dan rata tengah horizontal
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ringkasan Pesanan (nama, jumlah x harga, subtotal)
                    if (itemDipesan.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.receipt_long, color: AppColors.sekunder, size: 22),
                          SizedBox(width: 8),
                          Text('Ringkasan Pesanan', style: textJudul),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.latar,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          children: itemDipesan.map((item) {
                            final produk = daftarProduk.firstWhere(
                              (p) => p.nama == item.key,
                              orElse: () => Product(
                                nama: item.key,
                                deskripsi: '',
                                harga: 0,
                                gambar: '',
                              ),
                            );
                            final subtotal = produk.harga * item.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.teksUtama,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.value} x ${formatRupiah(produk.harga)}',
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
                                      formatRupiah(subtotal),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.sekunder,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Text('Total Transaksi', style: textJudul, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.aksen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatRupiah(widget.total),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.teksUtama,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Jumlah Pembayaran', style: textJudul, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bayarController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      onChanged: (_) {
                        // Memperbarui tampilan secara otomatis saat nominal diketik
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nominal uang',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money, color: AppColors.sekunder),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol cepat nominal: Uang Pas, 50.000, 100.000
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ActionChip(
                          avatar: (_jumlahBayar == widget.total && widget.total > 0)
                              ? const Icon(Icons.check, size: 16, color: AppColors.sekunder)
                              : null,
                          label: const Text('Uang Pas'),
                          backgroundColor: AppColors.latar,
                          labelStyle: const TextStyle(
                            color: AppColors.sekunder,
                            fontWeight: FontWeight.bold,
                          ),
                          onPressed: () {
                            setState(() {
                              _bayarController.text = widget.total.toString();
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Rp 50.000'),
                          backgroundColor: AppColors.latar,
                          labelStyle: const TextStyle(
                            color: AppColors.sekunder,
                            fontWeight: FontWeight.bold,
                          ),
                          onPressed: () {
                            setState(() {
                              _bayarController.text = '50000';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Rp 100.000'),
                          backgroundColor: AppColors.latar,
                          labelStyle: const TextStyle(
                            color: AppColors.sekunder,
                            fontWeight: FontWeight.bold,
                          ),
                          onPressed: () {
                            setState(() {
                              _bayarController.text = '100000';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Kembalian', style: textJudul, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      _jumlahBayar == 0
                          ? '-'
                          : (_kembalian >= 0
                              ? formatRupiah(_kembalian)
                              : 'Uang kurang ${formatRupiah(-_kembalian)}'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: (_kembalian < 0 && _jumlahBayar > 0)
                            ? Colors.red
                            : AppColors.sekunder,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Teks petunjuk saat tombol Bayar belum aktif (nominal belum mencukupi/diisi)
                    if (!cukupUang) ...[
                      Text(
                        'Masukkan nominal uang untuk membayar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.teksUtama.withAlpha(160),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Tombol Bayar
                    ElevatedButton(
                      onPressed: cukupUang ? _tampilkanDialogSukses : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.utama,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Bayar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Kembali ke Menu
                    OutlinedButton(
                      onPressed: () {
                        // Navigator pop kembali tanpa menyelesaikan transaksi
                        Navigator.pop(context, false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.sekunder,
                        side: const BorderSide(color: AppColors.sekunder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Kembali ke Menu',
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
