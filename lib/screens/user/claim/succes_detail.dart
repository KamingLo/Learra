import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class DetailKlaimScreen extends StatelessWidget {
  final Map<String, dynamic> klaimData;

  const DetailKlaimScreen({super.key, required this.klaimData});

  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(amount);
  }

  String _getBannerAsset() {
    const List<String> availableAssets = [
      'assets/PayKlaim/AsuransiKesehatan.png',
      'assets/PayKlaim/AsuransiJiwa.png',
      'assets/PayKlaim/AsuransiMobil.png',
    ];

    final random = Random();
    final int randomIndex = random.nextInt(availableAssets.length);

    return availableAssets[randomIndex];
  }

  String _getStatusText(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'diterima':
        return 'Berhasil';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  Color _getStatusColor(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'diterima':
        return Colors.green.shade700;
      case 'ditolak':
        return Colors.red.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  Color _getStatusBgColor(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'diterima':
        return Colors.green.shade50;
      case 'ditolak':
        return Colors.red.shade50;
      default:
        return Colors.orange.shade50;
    }
  }

  Color _getStatusBorderColor(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'diterima':
        return Colors.green.shade200;
      case 'ditolak':
        return Colors.red.shade200;
      default:
        return Colors.orange.shade200;
    }
  }

  IconData _getStatusIcon(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'diterima':
        return Icons.check_circle_outline;
      case 'ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.schedule;
    }
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
    final klaimId = klaimData['_id']?.toString() ?? '-';

    final tanggalStr =
        klaimData['tanggalKlaim'] ?? klaimData['createdAt'] ?? '';
    final tanggal = DateTime.tryParse(tanggalStr.toString()) ?? DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    final statusText = _getStatusText(rawStatus);
    final statusColor = _getStatusColor(rawStatus);
    final statusBg = _getStatusBgColor(rawStatus);
    final statusBorder = _getStatusBorderColor(rawStatus);
    final statusIcon = _getStatusIcon(rawStatus);

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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _getBannerAsset(),
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

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Klaim',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('ID Klaim', klaimId),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 12),
                      _buildDetailRow('Nomor Polis', policyNumber),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 12),
                      _buildDetailRow('Produk', productName),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Tanggal Pengajuan',
                        dateFormat.format(tanggal),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Jumlah Klaim',
                        formatRupiah(jumlah),
                        isAmount: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Deskripsi Kejadian',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    deskripsi,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (rawStatus == 'diterima')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Klaim Anda telah disetujui. Dana akan segera diproses dan ditransfer ke rekening yang telah terdaftar.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (rawStatus == 'ditolak')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Klaim Anda ditolak. Silakan hubungi customer service untuk informasi lebih lanjut atau ajukan klaim baru dengan dokumen yang lengkap.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.orange.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Klaim Anda sedang dalam proses verifikasi. Kami akan mengirimkan notifikasi setelah proses selesai.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 12),
                      Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isAmount ? Colors.green.shade700 : Colors.black87,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
