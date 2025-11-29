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

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
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
                const SizedBox(height: 20),
                _buildProcessingIcon(),
                const SizedBox(height: 32),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: 40),
                _buildClaimDetails(),
                const SizedBox(height: 24),
                _buildInfoCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildProcessingIcon() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _scaleController,
            builder: (_, child) =>
                Transform.scale(scale: _scaleAnimation.value, child: child),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade50,
              ),
            ),
          ),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.shade100,
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (_, child) => Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.1416,
                  child: child,
                ),
                child: const Icon(
                  Icons.hourglass_bottom,
                  size: 50,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Pengajuan Sedang Diproses!',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'Pengajuan klaim Anda telah diterima dan sedang diverifikasi oleh admin kami',
        style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildClaimDetails() {
    return DottedBorder(
      color: const Color(0xFFDEDEDE),
      strokeWidth: 1.5,
      dashPattern: const [5, 3],
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildInfoRow('Nama Produk', _getProductName()),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 12),
            _buildInfoRow('Nomor Polis', _getPolisNumber()),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 12),
            _buildInfoRow('Jumlah Klaim', _formatCurrency(_getJumlahKlaim())),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 12),
            _buildInfoRow('Deskripsi', _getDeskripsi(), maxLines: 3),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Status',
              'Menunggu Verifikasi',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? color,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Admin akan memverifikasi klaim Anda dalam 1-3 hari kerja. Anda akan mendapat notifikasi setelah klaim diproses.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Align(
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
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Kembali ke Beranda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
