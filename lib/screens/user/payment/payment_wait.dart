import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'payment_done.dart';

// 1. Ubah class utama menjadi StatefulWidget
class PaymentWait extends StatefulWidget {
  final Map<String, String> data;

  const PaymentWait({super.key, required this.data});

  @override
  State<PaymentWait> createState() => _PaymentWaitState();
}

// 2. Gunakan TickerProviderStateMixin dan inisialisasi semua animasi
class _PaymentWaitState extends State<PaymentWait>
    with TickerProviderStateMixin {
  // Wajib ganti ke TickerProviderStateMixin

  // Variabel untuk Rotasi Jam
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  // Variabel untuk Skala (Pulse) Lingkaran Luar
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // --- 1. Animation Controller for Clock Rotation ---
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Durasi putaran
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);
    _rotationController.repeat(); // Putaran terus menerus

    // --- 2. Animation Controller for Outer Circle Scale (Pulse) ---
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Durasi denyutan 1 detik
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut, // Denyutan mulus
      ),
    );
    _scaleController.repeat(
      reverse: true,
    ); // Denyutan berulang: membesar lalu mengecil
  }

  @override
  void dispose() {
    // Wajib dispose SEMUA controller
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // --- Widget _infoRow dipindahkan ke sini karena ini adalah State class ---
  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.help_outline, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 300),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lingkaran Terluar: Diberi ScaleTransition
                      ScaleTransition(
                        scale: _scaleAnimation, // Menggunakan Scale Animation
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD966).withOpacity(0.15),
                          ),
                        ),
                      ),
                      // Lingkaran Tengah: Tetap statis
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD966).withOpacity(0.3),
                        ),
                      ),
                      // Ikon Jam: Tetap dengan RotationTransition
                      RotationTransition(
                        turns:
                            _rotationAnimation, // Menggunakan Rotation Animation
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
                const SizedBox(height: 40),
                const Text(
                  'Menunggu Pembayaran',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mohon selesaikan pembelian anda,\nkami akan segera memprosesnya',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                DottedBorder(
                  color: const Color(0xFFDEDEDE),
                  strokeWidth: 1.5,
                  dashPattern: const [5, 3],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x0CD9D9D9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      // Mengakses data dari widget
                      children: widget.data.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _infoRow(entry.key, entry.value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // Mengakses data dari widget
                            builder: (context) =>
                                PaymentDone(data: widget.data),
                          ),
                        );
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
                        'Sudah Bayar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
