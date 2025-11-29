import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class DetailKlaimScreen extends StatelessWidget {
  const DetailKlaimScreen({super.key, required this.klaimData});

  final Map<String, dynamic> klaimData;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

    dynamic getNestedValue(Map<String, dynamic> data, List<String> keys) {
      dynamic current = data;
      for (String key in keys) {
        if (current is Map && current.containsKey(key)) {
          current = current[key];
        } else {
          return null;
        }
      }
      return current;
    }

    final userName = val(
      getNestedValue(klaimData, ['polisId', 'userId', 'name']),
      'Tidak diketahui',
    );

    final userEmail = val(
      getNestedValue(klaimData, ['polisId', 'userId', 'email']),
      '-',
    );

    final policyNumber = val(
      getNestedValue(klaimData, ['polisId', 'policyNumber']),
      'Tidak tersedia',
    );

    final productName = val(
      getNestedValue(klaimData, ['polisId', 'productId', 'name']),
      'Produk Tidak Diketahui',
    );

    final productType = val(
      getNestedValue(klaimData, ['polisId', 'productId', 'tipe']),
      'kendaraan',
    );

    double jumlahKlaim = 0.0;
    if (klaimData['jumlahKlaim'] != null) {
      if (klaimData['jumlahKlaim'] is int) {
        jumlahKlaim = klaimData['jumlahKlaim'].toDouble();
      } else if (klaimData['jumlahKlaim'] is double) {
        jumlahKlaim = klaimData['jumlahKlaim'];
      } else if (klaimData['jumlahKlaim'] is String) {
        jumlahKlaim = double.tryParse(klaimData['jumlahKlaim']) ?? 0.0;
      }
    }

    final deskripsi = val(klaimData['deskripsi'], 'Tidak ada deskripsi');
    final status = klaimData['status'] ?? 'menunggu';

    DateTime tanggalKlaim;
    try {
      final tanggalString =
          klaimData['tanggalKlaim']?.toString() ??
          klaimData['createdAt']?.toString() ??
          '';
      tanggalKlaim = DateTime.parse(tanggalString);
    } catch (e) {
      tanggalKlaim = DateTime.now();
    }

    final namaRekening = val(klaimData['namaRekening'], '-');
    final noRekening = val(klaimData['noRekening'], '-');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      getBannerAsset(productType),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: const Color(0xFFE8F5E9),
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
                          infoRow('Nama Produk:', productName),
                          const SizedBox(height: 12),
                          infoRow('Nomor Polis:', policyNumber),
                          const SizedBox(height: 12),
                          infoRow('Pemegang Polis:', userName),
                          const SizedBox(height: 12),
                          infoRow('Email:', userEmail),
                          const SizedBox(height: 12),
                          infoRow(
                            'Jumlah Klaim:',
                            currency.format(jumlahKlaim),
                          ),
                          const SizedBox(height: 12),
                          infoRow(
                            'Tanggal Pengajuan:',
                            dateFmt.format(tanggalKlaim),
                          ),

                          if (status == 'diterima') ...[
                            const SizedBox(height: 12),
                            infoRow(
                              'Nama Rekening:',
                              namaRekening,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 12),
                            infoRow(
                              'Nomor Rekening:',
                              noRekening,
                              color: Colors.green,
                            ),
                          ],

                          const SizedBox(height: 12),
                          infoRow(
                            'Status Klaim:',
                            getStatusText(status),
                            color: getStatusColor(status),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

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

                const SizedBox(height: 80),
              ],
            ),
          ),

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

  Widget infoRow(String label, String value, {Color? color}) {
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

  String val(dynamic value, [String fallback = '-']) {
    if (value == null) return fallback;
    if (value is String && value.isEmpty) return fallback;
    return value.toString();
  }

  String getBannerAsset(String tipe) {
    const List<String> availableAssets = [
      'assets/PayKlaim/AsuransiKesehatan.png',
      'assets/PayKlaim/AsuransiJiwa.png',
      'assets/PayKlaim/AsuransiMobil.png',
    ];

    final random = Random();

    final int randomIndex = random.nextInt(availableAssets.length);

    return availableAssets[randomIndex];
  }

  String getStatusText(String status) {
    switch (status) {
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      case 'menunggu':
        return 'Menunggu Konfirmasi';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'menunggu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
