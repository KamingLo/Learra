import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'payment_cancel.dart';

class PaymentWait extends StatefulWidget {
  final Map<String, String> data;
  final String? paymentId;
  final VoidCallback? onPaymentCancelled;

  const PaymentWait({
    super.key,
    required this.data,
    this.paymentId,
    this.onPaymentCancelled,
  });

  @override
  State<PaymentWait> createState() => _PaymentWaitState();
}

class _PaymentWaitState extends State<PaymentWait>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
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

  Future<void> _cancelPayment() async {
    if (widget.paymentId == null) {
      _showSnackBar('ID pembayaran tidak ditemukan', Colors.red);
      return;
    }

    // Navigate to payment cancel screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BatalkanPembayaranScreen(
          paymentData: widget.data,
          paymentId: widget.paymentId!,
          onCancelSuccess: () {
            // Call callback if provided
            widget.onPaymentCancelled?.call();
          },
        ),
      ),
    );

    // If cancellation was successful, go back
    if (result == true && mounted) {
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(children: [_buildScrollableContent(), _buildBottomButtons()]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Status Pembayaran',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildAnimatedIcon(),
          const SizedBox(height: 40),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 40),
          _buildPaymentDetails(),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD966).withValues(alpha:0.15),
                ),
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD966).withValues(alpha:0.3),
              ),
            ),
            RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD966),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Menunggu Konfirmasi',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Pembayaran Anda sedang diproses oleh admin.\nMohon tunggu konfirmasi dalam 1x24 jam.',
        style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPaymentDetails() {
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
        child: Column(children: _buildDetailRows()),
      ),
    );
  }

  List<Widget> _buildDetailRows() {
    final entries = widget.data.entries.toList();
    List<Widget> rows = [];

    for (int i = 0; i < entries.length; i++) {
      rows.add(_buildInfoRow(entries[i].key, entries[i].value));

      if (i < entries.length - 1) {
        rows.add(const SizedBox(height: 12));
        rows.add(Divider(color: Colors.grey.shade300, height: 1));
        rows.add(const SizedBox(height: 12));
      }
    }

    return rows;
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
          const Expanded(
            child: Text(
              'Admin akan memverifikasi pembayaran Anda dalam 1x24 jam. Anda akan mendapat notifikasi setelah pembayaran dikonfirmasi.',
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

  Widget _buildBottomButtons() {
    return Align(
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 2),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Batalkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
