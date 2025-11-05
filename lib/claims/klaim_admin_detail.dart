import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin | Detail Klaim',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const AdminDetailKlaimScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminDetailKlaimScreen extends StatefulWidget {
  const AdminDetailKlaimScreen({super.key});

  @override
  State<AdminDetailKlaimScreen> createState() => _AdminDetailKlaimScreenState();
}

class _AdminDetailKlaimScreenState extends State<AdminDetailKlaimScreen> {
  final TextEditingController _catatanController = TextEditingController(
    text: 'Klaim Anda ditolak karena dokumen tidak lengkap. admin ketik disini',
  );

  void _handleTerima() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Klaim diterima')));
  }

  void _handleTolak() {
    if (_catatanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi catatan sebelum menolak')),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Klaim ditolak')));
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data untuk foto yang sudah diupload
    final List<String?> uploadedPhotos = [
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Admin | Detail Klaim',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.help_outline, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Konten utama (scrollable)
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Full JPG
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/AsuransiMobil2.png',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.grey[300],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Asuransi Mobil Lengkap\ndi Lecarra',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Detail Polis dengan Dotted Border
                DottedBorder(
                  color: const Color(0xFFDEDEDE),
                  strokeWidth: 1.5,
                  dashPattern: const [5, 3],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x0CD9D9D9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _infoRow('Nama Polis:', 'Asuransi Kendaraan A'),
                        const SizedBox(height: 12),
                        _infoRow('Nomor Polis:', '#PL-2025-001'),
                        const SizedBox(height: 12),
                        _infoRow('Nama Pemegang Polis:', 'Andi Wijaya'),
                        const SizedBox(height: 12),
                        _infoRow('Tanggal Klaim:', '15 October 2025'),
                        const SizedBox(height: 12),
                        _infoRow(
                          'Jumlah Klaim:',
                          'Rp 15.000.000',
                          valueColor: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _infoRow(
                          'Status Pengajuan:',
                          'Diproses',
                          valueColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Alasan Pengajuan Klaim (readonly)
                const Text(
                  'Alasan Pengajuan Klaim:',
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'Pintu bagasi saya copot dibawa oleh angin serta beberapa body saya penyok',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Foto Bukti (readonly)
                const Text(
                  'Foto Bukti: (max 5)',
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(5, (index) {
                    return Container(
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: (MediaQuery.of(context).size.width - 64) / 3,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: uploadedPhotos[index] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                uploadedPhotos[index]!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : const Icon(Icons.add, size: 32, color: Colors.grey),
                    );
                  }),
                ),
                const SizedBox(height: 24.0),

                // Catatan oleh sistem (editable untuk admin)
                const Text(
                  'Catatan oleh sistem: (jika ditolak atau diterima)',
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: _catatanController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),

          // Sticky Bottom Buttons (Terima & Tolak)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleTerima,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Terima',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleTolak,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF03A3D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tolak',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }
}
