// lib/screens/admin/payment_detail.dart
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';

class DetailPembayaranScreen extends StatelessWidget {
  final Map<String, dynamic> paymentData;

  const DetailPembayaranScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

    // Ambil data dengan aman
    final userName = _val(
      paymentData['policyId']?['userId']?['name'],
      'Tidak diketahui',
    );
    final userEmail = _val(paymentData['policyId']?['userId']?['email'], '-');
    final policyNumber = _val(
      paymentData['policyId']?['policyNumber'],
      'Belum terhubung',
    );
    final productName = _val(
      paymentData['policyId']?['productId']?['name'],
      'Produk Tidak Diketahui',
    );
    final amount = (paymentData['amount'] is int
        ? paymentData['amount'].toDouble()
        : paymentData['amount'] ?? 0.0);
    final method = _val(paymentData['method'], 'Tidak diketahui');
    final type = paymentData['type'] == 'perpanjangan'
        ? 'Perpanjangan Polis'
        : 'Pembayaran Awal';
    final status = paymentData['status'] ?? 'menunggu_konfirmasi';
    final createdAt =
        DateTime.tryParse(paymentData['createdAt']?.toString() ?? '') ??
        DateTime.now();

    String statusText = 'Menunggu Konfirmasi';
    Color statusColor = Colors.orange;

    if (status == 'berhasil') {
      statusText = 'Berhasil';
      statusColor = Colors.green;
    } else if (status == 'gagal') {
      statusText = 'Ditolak';
      statusColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
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
                // Gambar produk (bisa diganti nanti dengan URL dari backend)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Kotak info utama
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
                            'Jumlah Pembayaran:',
                            currency.format(amount),
                          ),
                          const SizedBox(height: 12),
                          _infoRow('Metode:', method.toUpperCase()),
                          const SizedBox(height: 12),
                          _infoRow('Tipe:', type),
                          const SizedBox(height: 12),
                          _infoRow('Tanggal:', dateFmt.format(createdAt)),
                          const SizedBox(height: 12),
                          _infoRow('Status:', statusText, color: statusColor),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Catatan jika ditolak
                if (status == 'gagal') ...[
                  const Text(
                    'Catatan oleh admin:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pembayaran ditolak oleh admin. Silakan hubungi customer service untuk informasi lebih lanjut.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),

          // Tombol Kembali di bawah (tetap sama)
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
