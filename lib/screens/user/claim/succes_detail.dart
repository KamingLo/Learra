import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class DetailKlaimScreen extends StatelessWidget {
  const DetailKlaimScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Detail Klaim',
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
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/PayKlaim/AsuransiMobil.png',
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
                const Text(
                  'Catatan oleh sistem: (jika ditolak)',
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
                    'Klaim Anda ditolak karena dokumen tidak lengkap.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
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
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kembali ke halaman sebelumnya'),
                    ),
                  );
                },
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
                  'Kembali',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
}
