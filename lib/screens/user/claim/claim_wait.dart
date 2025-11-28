// lib/screens/user/claim/claim_wait.dart
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';

class ClaimWaitScreen extends StatefulWidget {
  final Map<String, dynamic> klaimData;

  const ClaimWaitScreen({super.key, required this.klaimData});

  @override
  State<ClaimWaitScreen> createState() => _ClaimWaitScreenState();
}

class _ClaimWaitScreenState extends State<ClaimWaitScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);
    _rotationController.repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _getPolisNumber() {
    final polis = widget.klaimData['polis'];
    if (polis == null) return 'Tidak tersedia';
    return polis['policyNumber']?.toString() ??
        polis['nomorPolis']?.toString() ??
        'Tidak tersedia';
  }

  String _getProductName() {
    final polis = widget.klaimData['polis'];
    if (polis == null) return 'Tidak tersedia';

    final productId = polis['productId'];
    if (productId == null) return 'Tidak tersedia';

    return productId['name']?.toString() ??
        productId['namaProduk']?.toString() ??
        'Tidak tersedia';
  }

  double _getJumlahKlaim() {
    final jumlah = widget.klaimData['jumlahKlaim'];
    if (jumlah is int) return jumlah.toDouble();
    if (jumlah is double) return jumlah;
    if (jumlah is String) return double.tryParse(jumlah) ?? 0.0;
    return 0.0;
  }

  String _getDeskripsi() {
    return widget.klaimData['deskripsi']?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Pengajuan Klaim',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                // Animasi jam
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _scaleController,
                        builder: (_, child) => Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.1),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (_, child) => Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.1416,
                          child: child,
                        ),
                        child: const Icon(
                          Icons.hourglass_bottom,
                          size: 60,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pengajuan klaim Anda berhasil dikirim!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Admin akan memverifikasi klaim dalam 1-3 hari kerja.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Kotak info klaim
                Center(
                  child: DottedBorder(
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
                          _infoRow('Nama Produk:', _getProductName()),
                          const SizedBox(height: 12),
                          _infoRow('Nomor Polis:', _getPolisNumber()),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Jumlah Klaim:',
                            currency.format(_getJumlahKlaim()),
                          ),
                          const SizedBox(height: 12),
                          _infoRow('Deskripsi:', _getDeskripsi(), maxLines: 3),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Status:',
                            'Menunggu Verifikasi',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info tambahan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Anda dapat melihat status klaim di menu "Klaim Saya"',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol Kembali di bawah
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
                onPressed: () {
                  // Kembali ke home atau menu klaim
                  Navigator.popUntil(context, (route) => route.isFirst);
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
                  'Kembali ke Beranda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color? color,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
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
}
