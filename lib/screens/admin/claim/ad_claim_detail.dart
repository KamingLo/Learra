// lib/screens/admin/klaim_detail.dart
// Tampilan Detail Klaim Admin - 100% mirip dengan payment_detail.dart

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';

class DetailKlaimScreen extends StatelessWidget {
  final Map<String, dynamic> klaimData;

  const DetailKlaimScreen({ super.key, required this.klaimData});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

    // Ambil data dengan aman (hindari null)
    final userName = _val(
      klaimData['polisId']?['userId']?['name'],
      'Tidak diketahui',
    );
    final userEmail = _val(klaimData['polisId']?['userId']?['email'], '-');
    final policyNumber = _val(
      klaimData['polisId']?['policyNumber'],
      'Tidak tersedia',
    );
    final productName = _val(
      klaimData['polisId']?['productId']?['name'],
      'Produk Tidak Diketahui',
    );
    final jumlahKlaim = (klaimData['jumlahKlaim'] is int
        ? klaimData['jumlahKlaim'].toDouble()
        : klaimData['jumlahKlaim'] ?? 0.0);
    final deskripsi = _val(klaimData['deskripsi'], 'Tidak ada deskripsi');
    final status = klaimData['status'] ?? 'menunggu';
    final tanggalKlaim =
        DateTime.tryParse(
          klaimData['tanggalKlaim']?.toString() ??
              klaimData['createdAt']?.toString() ??
              '',
        ) ??
        DateTime.now();

    // Status tampilan
    String statusText = 'Menunggu Konfirmasi';
    Color statusColor = Colors.orange;

    if (status == 'diterima') {
      statusText = 'Diterima';
      statusColor = Colors.green;
    } else if (status == 'ditolak') {
      statusText = 'Ditolak';
      statusColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Detail Klaim',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar placeholder (bisa diganti dengan URL foto bukti klaim nanti)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/klaim_placeholder.jpg', // Optional: buat asset ini
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: Colors.grey[300],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Foto Bukti Klaim',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Kotak Informasi Utama
                Center(
                  child: DottedBorder(
                    color: const Color(0xFFDEDEDE),
                    strokeWidth: 1.5,
                    dashPattern: const [5, 3],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(8),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
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
                          _infoRow('Nama Produk:', productName),
                          const SizedBox(height: 12),
                          _infoRow('Nomor Polis:', policyNumber),
                          const SizedBox(height: 12),
                          _infoRow('Pemegang Polis:', userName),
                          const SizedBox(height: 12),
                          _infoRow('Email:', userEmail),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Jumlah Klaim:',
                            currency.format(jumlahKlaim),
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Tanggal Pengajuan:',
                            dateFmt.format(tanggalKlaim),
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Status Klaim:',
                            statusText,
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Deskripsi Klaim
                const Text(
                  'Deskripsi Klaim:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    deskripsi,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Catatan jika ditolak
                if (status == 'ditolak') ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Catatan Penolakan:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Klaim ditolak oleh admin. Jika ada pertanyaan, silakan hubungi customer service.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),

          // Tombol Kembali (sama persis seperti payment_detail)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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

  Widget _infoRow(String label, String value, {Color? color}) {
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
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _val(dynamic value, [String fallback = '-']) {
    if (value == null) return fallback;
    if (value is String && value.isEmpty) return fallback;
    return value.toString();
  }
}
