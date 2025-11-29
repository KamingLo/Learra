import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'dart:math';

class ClaimCancelScreen extends StatefulWidget {
  final Map<String, dynamic> klaimData;
  const ClaimCancelScreen({super.key, required this.klaimData});

  @override
  State<ClaimCancelScreen> createState() => _ClaimCancelScreenState();
}

class _ClaimCancelScreenState extends State<ClaimCancelScreen> {
  final ApiService api = ApiService();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  bool _isLoading = false;

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

  Future<void> _handleCancelClaim() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Konfirmasi Pembatalan',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin membatalkan pengajuan klaim ini?',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              'Tindakan ini bersifat final dan tidak dapat diubah kembali.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      await api.delete('/klaim/${widget.klaimData['_id']}');

      if (!mounted) return;

      _showSnackBar('Pengajuan klaim berhasil dibatalkan', Colors.green);

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      String errorMessage = 'Gagal membatalkan klaim';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      _showSnackBar(errorMessage, Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    final polis = widget.klaimData['polisId'];
    final productName = polis?['productId']?['name'] ?? 'Produk Asuransi';
    final policyNumber = polis?['policyNumber'] ?? 'N/A';
    final jumlah = (widget.klaimData['jumlahKlaim'] as num?)?.toDouble() ?? 0.0;
    final deskripsi = widget.klaimData['deskripsi'] ?? '-';
    final klaimId = widget.klaimData['_id']?.toString() ?? '-';

    final tanggal =
        DateTime.tryParse(
          widget.klaimData['tanggalKlaim']?.toString() ??
              widget.klaimData['createdAt']?.toString() ??
              '',
        ) ??
        DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey[50], // <-- UBAH: Background menjadi abu
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
          title: const Text(
            'Batalkan Pengajuan Klaim',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white, // <-- AppBar tetap putih
          elevation: 0,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image Container
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

                  // Detail Row Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, // <-- UBAH: Card menjadi putih
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
                          currency.format(jumlah),
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
                  // Deskripsi Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, // <-- UBAH: Card menjadi putih
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

                  // Warning Card (Biarkan warnanya tetap merah/abu)
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
                            'Dengan melanjutkan pembatalan, tindakan ini bersifat final dan tidak dapat diubah kembali. Seluruh data pengajuan klaim yang terkait akan dihapus dari sistem.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade900,
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

            // Bottom Bar Container (Jaga tetap putih untuk kontras dengan tombol)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.08 * 255).toInt()),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCancelClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading
                          ? Colors.grey
                          : const Color(0xFFF03A3D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _isLoading ? 0 : 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined, size: 22),
                              SizedBox(width: 12),
                              Text(
                                'Batalkan Klaim',
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
      ),
    );
  }
}
