import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class BatalkanPembayaranScreen extends StatefulWidget {
  final Map<String, String> paymentData;
  final String paymentId;
  final VoidCallback? onCancelSuccess;

  const BatalkanPembayaranScreen({
    super.key,
    required this.paymentData,
    required this.paymentId,
    this.onCancelSuccess,
  });

  @override
  State<BatalkanPembayaranScreen> createState() =>
      _BatalkanPembayaranScreenState();
}

class _BatalkanPembayaranScreenState extends State<BatalkanPembayaranScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleCancelPayment() async {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      _showSnackBar('Mohon isi alasan pembatalan', Colors.orange);
      return;
    }

    if (reason.length < 10) {
      _showSnackBar('Alasan minimal 10 karakter', Colors.orange);
      return;
    }

    // Show confirmation dialog
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
              'Apakah Anda yakin ingin membatalkan pembayaran ini?',
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
      await _apiService.delete('/payment/${widget.paymentId}');

      if (!mounted) return;

      widget.onCancelSuccess?.call();
      _showSnackBar('Pembayaran berhasil dibatalkan', Colors.green);

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      String errorMessage = 'Gagal membatalkan pembayaran';
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

  String _getBannerAsset() {
    final produk = widget.paymentData['Produk'] ?? '';

    if (produk.toLowerCase().contains('kesehatan')) {
      return 'assets/PayKlaim/AsuransiKesehatan.png';
    } else if (produk.toLowerCase().contains('jiwa')) {
      return 'assets/PayKlaim/AsuransiJiwa.png';
    } else if (produk.toLowerCase().contains('kendaraan') ||
        produk.toLowerCase().contains('mobil')) {
      return 'assets/PayKlaim/AsuransiMobil.png';
    }

    return 'assets/PayKlaim/AsuransiMobil.png';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
          title: const Text(
            'Batalkan Pembayaran',
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
                  // Banner Image - FIXED
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

                  // Payment Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Nomor Pembayaran',
                          widget.paymentData['Nomor Pembayaran'] ?? '-',
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade300, height: 1),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Nomor Polis',
                          widget.paymentData['Nomor Polis'] ?? '-',
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade300, height: 1),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Produk',
                          widget.paymentData['Produk'] ?? '-',
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade300, height: 1),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Metode Pembayaran',
                          widget.paymentData['Metode Pembayaran'] ?? '-',
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade300, height: 1),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Total Pembayaran',
                          widget.paymentData['Total Pembayaran'] ?? '-',
                          isAmount: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reason Input
                  const Text(
                    'Alasan Membatalkan Pembayaran',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reasonController,
                    enabled: !_isLoading,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Salah pilih metode pembayaran...',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      counterStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Warning Card
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
                            'Dengan melanjutkan pembatalan, tindakan ini bersifat final dan tidak dapat diubah kembali. Seluruh data transaksi yang terkait akan dinonaktifkan dari sistem pembayaran.',
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

            // Bottom Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCancelPayment,
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
                                'Batalkan Pembayaran',
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
