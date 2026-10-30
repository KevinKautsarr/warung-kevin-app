import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_colors.dart';

// Koordinat toko Warung Kevin (Bandungrejo, Mranggen, Demak)
const double kLat = -7.023075;
const double kLng = 110.505710;

// Halaman tampilan lokasi Maps dengan peta interaktif OpenStreetMap
class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  // Membuka koordinat toko di aplikasi/browser Google Maps via url_launcher
  Future<void> _bukaGoogleMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$kLat,$kLng',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Maps')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String namaToko = 'Warung Kevin';
    const String alamatToko = 'Bandungrejo, Mranggen, Demak';

    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('Lokasi / Maps'),
        centerTitle: true,
      ),
      // Konten dibatasi lebar maksimum 480 px dan diratakan di tengah
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Peta tertanam flutter_map dengan OpenStreetMap, tinggi ~300px, sudut membulat
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.aksen, width: 2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(kLat, kLng), // Pusat koordinat toko
                            initialZoom: 16.0,                 // Tingkat perbesaran awal
                          ),
                          children: [
                            // Lapisan tile OpenStreetMap gratis tanpa API key
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'warung_kevin',
                            ),
                            // Lapisan penanda (Marker) lokasi toko dengan ikon lokasi oranye bara
                            const MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(kLat, kLng),
                                  width: 45,
                                  height: 45,
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppColors.utama,
                                    size: 45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Informasi Toko dan Alamat
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.storefront, color: AppColors.sekunder, size: 26),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaToko,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.sekunder,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                alamatToko,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.teksUtama,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tombol Buka di Google Maps
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: const Text(
                        'Buka di Google Maps',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _bukaGoogleMaps(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.utama,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tombol Kembali ke Dashboard
                    OutlinedButton(
                      onPressed: () {
                        // Navigator kembali ke halaman Dashboard
                        Navigator.pop(context);
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
                        'Kembali ke Dashboard',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
