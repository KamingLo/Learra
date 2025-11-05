import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pembayaran Asuransi',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const PaymentScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecked = false;
  bool _isHolding = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil diproses')),
        );
        _resetHold();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startHold() {
    if (_isChecked && !_isHolding) {
      setState(() => _isHolding = true);
      _animationController.forward(from: 0.0);
    }
  }

  void _resetHold() {
    setState(() => _isHolding = false);
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // <-- BOLD
            fontSize: 18.0,
          ),
        ),
        centerTitle: true, // <-- TENGAH
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.help_outline, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Konten utama (scrollable)
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 180.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Full JPG
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://via.placeholder.com/400x120.png?text=Banner+Asuransi+JPG',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                _buildTextField('Nama Polis:', 'Asuransi Kendaraan A'),
                const SizedBox(height: 16.0),
                _buildTextField('Nomor Polis:', '#PL-2025-001'),
                const SizedBox(height: 16.0),
                _buildTextField('Nama Pemegang Polis:', 'Andi Wijaya'),
                const SizedBox(height: 24.0),

                const Text(
                  'Total Yang Harus Dibayar:',
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Rp 15.000.000',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF06A900), // <-- WARNA #06A900
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),

          // Sticky Bottom: Checkbox + Tombol
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isChecked,
                          onChanged: (value) {
                            setState(() => _isChecked = value ?? false);
                            if (!_isChecked) _resetHold();
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Expanded(
                        child: Text(
                          'Dengan melanjutkan pembayaran ini, saya menyatakan telah memahami dan menyetujui syarat & ketentuan layanan, termasuk kebijakan perlindungan data pribadi.',
                          style: TextStyle(fontSize: 13.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  GestureDetector(
                    onLongPressStart: (_) => _startHold(),
                    onLongPressEnd: (_) => _resetHold(),
                    onTap: () {
                      if (!_isChecked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Harap centang persetujuan terlebih dahulu',
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28.0),
                        color: _isChecked ? Colors.green : Colors.grey[300],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isHolding)
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (_, __) {
                                final buttonWidth =
                                    MediaQuery.of(context).size.width - 32;
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width:
                                        buttonWidth * _progressAnimation.value,
                                    height: 56.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(28.0),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          Text(
                            _isHolding ? 'Tahan untuk membayar...' : 'Bayar',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: _isChecked
                                  ? Colors.white
                                  : Colors.grey[600],
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
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14.0, color: Colors.black54),
        ),
        const SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16.0)),
        ),
      ],
    );
  }
}
