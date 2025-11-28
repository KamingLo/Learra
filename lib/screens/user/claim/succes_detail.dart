// lib/screens/user/claim/succes_detail.dart → Ganti nama file jadi succes_detail.dart kalau mau
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailKlaimScreen extends StatelessWidget {
  final Map<String, dynamic> klaimData;

  // HAPUS 'const' di sini
  const DetailKlaimScreen({Key? key, required this.klaimData})
    : super(key: key);

  // Pindahkan currency ke dalam build (atau jadi getter)
  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final polis = klaimData['polisId'] ?? {};
    final productName =
        polis['productId']?['name']?.toString() ?? 'Produk Asuransi';
    final policyNumber = polis['policyNumber']?.toString() ?? 'N/A';
    final jumlah = (klaimData['jumlahKlaim'] as num?)?.toDouble() ?? 0.0;
    final rawStatus = (klaimData['status']?.toString() ?? 'menunggu')
        .toLowerCase();
    final deskripsi = klaimData['deskripsi']?.toString() ?? '-';
    final tanggalStr =
        klaimData['tanggalKlaim'] ?? klaimData['createdAt'] ?? '';
    final tanggal = DateTime.tryParse(tanggalStr.toString()) ?? DateTime.now();

    String statusText() {
      switch (rawStatus) {
        case 'diterima':
          return 'Berhasil';
        case 'ditolak':
          return 'Ditolak';
        default:
          return 'Menunggu';
      }
    }

    Color statusColor() {
      switch (rawStatus) {
        case 'diterima':
          return Colors.green;
        case 'ditolak':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Klaim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/PayKlaim/AsuransiMobil.png',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            _infoRow('Produk', productName),
            _infoRow('Nomor Polis', policyNumber),
            _infoRow(
              'Jumlah Klaim',
              formatRupiah(jumlah),
              valueColor: Colors.green[700],
            ),
            _infoRow('Status', statusText(), valueColor: statusColor()),
            _infoRow(
              'Tanggal Pengajuan',
              DateFormat('dd MMM yyyy', 'id_ID').format(tanggal),
            ),

            const SizedBox(height: 24),
            const Text(
              'Deskripsi Kejadian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(deskripsi, style: const TextStyle(fontSize: 15)),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text(
            'Kembali',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
