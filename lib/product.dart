// Model data produk restoran ikan bakar "Warung Kevin"
class Product {
  final String nama;
  final String deskripsi;
  final int harga;
  final String gambar;

  const Product({
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.gambar,
  });
}

// Fungsi pembantu untuk memformat angka menjadi format Rupiah
String formatRupiah(num angka) {
  return 'Rp. ${angka.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
}

// Daftar menu restoran ikan bakar Warung Kevin sesuai aset gambar yang tersedia
const List<Product> daftarProduk = [
  Product(
    nama: 'Nila Bakar Kecap',
    deskripsi: 'Ikan nila segar dibakar dengan bumbu kecap manis gurih khas Warung Kevin.',
    harga: 25000,
    gambar: 'assets/images/nila-bakar-kecap.jpg',
  ),
  Product(
    nama: 'Nila Bakar Rica',
    deskripsi: 'Ikan nila bakar lezat berbalut sambal rica pedas gurih menggugah selera.',
    harga: 26000,
    gambar: 'assets/images/ikan-nila-bakar-rica.jpg',
  ),
  Product(
    nama: 'Gurame Bakar',
    deskripsi: 'Ikan gurame bakar bumbu rempah pilihan dengan cita rasa gurih dan aroma sedap.',
    harga: 35000,
    gambar: 'assets/images/ikan-gurame-bakar.jpg',
  ),
  Product(
    nama: 'Gurame Asam Manis',
    deskripsi: 'Ikan gurame krispi disiram kuah saus asam manis segar bertabur rempah.',
    harga: 38000,
    gambar: 'assets/images/ikan-gurame-asam-manis.jpg',
  ),
  Product(
    nama: 'Bawal Bakar Kecap',
    deskripsi: 'Ikan bawal bakar bumbu kecap manis gurih meresap dengan tekstur daging lembut.',
    harga: 28000,
    gambar: 'assets/images/ikan-bawal-bakar-kecap.jpg',
  ),
  Product(
    nama: 'Es Kelapa Muda',
    deskripsi: 'Es kelapa muda asli yang manis, segar, dan murni pelepas dahaga.',
    harga: 8000,
    gambar: 'assets/images/es-kelapa-muda.jpg',
  ),
  Product(
    nama: 'Es Jeruk',
    deskripsi: 'Perasan jeruk peras asli dingin menyegarkan, cocok setelah makan bakar-bakaran.',
    harga: 6000,
    gambar: 'assets/images/es-jeruk.jpg',
  ),
  Product(
    nama: 'Es Teh Manis',
    deskripsi: 'Es teh manis segar khas warung, wangi melati dan pas dinikmati siang hari.',
    harga: 4000,
    gambar: 'assets/images/es-teh.jpg',
  ),
];
