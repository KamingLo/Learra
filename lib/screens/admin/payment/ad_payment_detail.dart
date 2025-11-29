import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class DetailPembayaranScreen extends StatelessWidget {
  final Map<String, dynamic> paymentData;

  const DetailPembayaranScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');
    final timeFmt = DateFormat('HH:mm', 'id_ID');

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
      getNestedValue(paymentData, ['policyId', 'userId', 'name']),
      'Tidak diketahui',
    );
    final userEmail = val(
      getNestedValue(paymentData, ['policyId', 'userId', 'email']),
      '-',
    );
    final policyNumber = val(
      getNestedValue(paymentData, ['policyId', 'policyNumber']),
      'Belum terhubung',
    );
    final productType = val(
      getNestedValue(paymentData, ['policyId', 'productId', 'tipe']),
      'kendaraan',
    );

    double amount = 0.0;
    if (paymentData['amount'] != null) {
      if (paymentData['amount'] is int) {
        amount = paymentData['amount'].toDouble();
      } else if (paymentData['amount'] is double) {
        amount = paymentData['amount'];
      } else if (paymentData['amount'] is String) {
        amount = double.tryParse(paymentData['amount']) ?? 0.0;
      }
    }

    final method = val(paymentData['method'], 'Tidak diketahui');
    final type = paymentData['type'] == 'perpanjangan'
        ? 'Perpanjangan Polis'
        : 'Pembayaran Awal';
    final status = paymentData['status'] ?? 'menunggu_konfirmasi';

    DateTime createdAt;
    try {
      final tanggalString = paymentData['createdAt']?.toString() ?? '';
      createdAt = DateTime.parse(tanggalString);
    } catch (e) {
      createdAt = DateTime.now();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Detail Pembayaran',
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
                          infoRow('Nomor Polis:', policyNumber),
                          const SizedBox(height: 12),
                          infoRow('Pemegang Polis:', userName),
                          const SizedBox(height: 12),
                          infoRow('Email:', userEmail),
                          const SizedBox(height: 12),
                          infoRow(
                            'Jumlah Pembayaran:',
                            currency.format(amount),
                          ),
                          const SizedBox(height: 12),
                          infoRow('Metode:', method.toUpperCase()),
                          const SizedBox(height: 12),
                          infoRow('Tipe:', type),
                          const SizedBox(height: 12),
                          infoRow('Tanggal:', dateFmt.format(createdAt)),
                          const SizedBox(height: 12),
                          infoRow('Waktu:', timeFmt.format(createdAt)),
                          const SizedBox(height: 12),
                          infoRow(
                            'Status:',
                            getStatusText(status),
                            color: getStatusColor(status),
                          ),
                        ],
                      ),
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
      case 'berhasil':
        return 'Berhasil';
      case 'gagal':
        return 'Ditolak';
      case 'menunggu_konfirmasi':
        return 'Menunggu Konfirmasi';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'berhasil':
        return Colors.green;
      case 'gagal':
        return Colors.red;
      case 'menunggu_konfirmasi':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
