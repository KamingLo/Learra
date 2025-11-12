import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
    const MyApp({super.key});
    
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Lecarra - Detail Pembayaran',
            theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
            home: const DetailPembayaranScreen(),
            debugShowCheckedModeBanner: false,
        );
    }
}

class DetailPembayaranScreen extends StatelessWidget {
    const DetailPembayaranScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                leading: const BackButton(color: Colors.black),
                title: const Text(
                    'Detail Pembayaran',
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                        'assets/PayKlaim/AsuransiMobil.png',
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image, size: 50),
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                    child: DottedBorder(
                                        color: const Color(0xFFDEDEDE),
                                        strokeWidth: 1.5,
                                        dashPattern: const [5, 3],
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(8),
                                        child: Container(
                                            width: double.infinity,
                                            constraints: const BoxConstraints(maxWidth: 400),
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
                                                    _infoRow('Tanggal Klaim:', '15 Oktober 2025'),
                                                    const SizedBox(height: 12),
                                                    _infoRow('Jumlah Klaim:', 'Rp 15.000.000'),
                                                    const SizedBox(height: 12),
                                                    _infoRow(
                                                        'Status Pengajuan:',
                                                        'Diproses',
                                                        color: Colors.orange,
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                    'Catatan oleh sistem: (jika ditolak)',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                    ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                        'Klaim Anda ditolak karena dokumen tidak lengkap.',
                                        style: TextStyle(fontSize: 14, color: Colors.black87),
                                    ),
                                ),
                                const SizedBox(height: 80),
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
                            color: color,
                        ),
                    ),
                ),
            ],
        );
    }
}