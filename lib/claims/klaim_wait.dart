import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lecarra - Pengajuan Klaim',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const PengajuanKlaimBerhasilScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PengajuanKlaimBerhasilScreen extends StatelessWidget {
  const PengajuanKlaimBerhasilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text(
          'Pengajuan Klaim',
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
                const SizedBox(height: 60),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD966).withOpacity(0.15),
                        ),
                      ),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD966).withOpacity(0.3),
                        ),
                      ),
                      Container(
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
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Pengajuan Berhasil!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mohon menunggu pengajuan klaim anda,\nkami akan segera memprosesnya',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 124,
            left: 16,
            right: 16,
            child: DottedBorder(
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
                  children: [
                    _infoRow('Nama Polis:', 'Asuransi Kendaraan A'),
                    const SizedBox(height: 12),
                    _infoRow('Nomor Polis:', '#PL-2025-001'),
                    const SizedBox(height: 12),
                    _infoRow('Nama Pemegang Polis:', 'Andi Wijaya'),
                    const SizedBox(height: 12),
                    _infoRow('Tanggal Klaim:', '15 October 2025'),
                    const SizedBox(height: 12),
                    _infoRow(
                      'Status Pengajuan:',
                      'Diajukan',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
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
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kembali ke halaman sebelumnya'),
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
              color: color ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}