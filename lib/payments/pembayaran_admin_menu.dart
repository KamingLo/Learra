import 'package:flutter/material.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Riwayat Pembayaran Admin',
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            home: const RiwayatPembayaranAdminScreen(),
        );
    }
}

class RiwayatPembayaranAdminScreen extends StatelessWidget {
    const RiwayatPembayaranAdminScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        final List<Map<String, dynamic>> paymentHistory = [
            {
                'name': 'Asuransi Kendaraan A',
                'polis_id': '15348500',
                'amount': 'Rp 15.000.000',
                'date': '17 Oktober 2023',
                'status': 'BERHASIL',
            },
            {
                'name': 'Asuransi Jiwa Extrem',
                'polis_id': '15348500',
                'amount': 'Rp 300.000.000',
                'date': '17 Oktober 2024',
                'status': 'MENUNGGU',
            },
            {
                'name': 'Asuransi Kesehatan S',
                'polis_id': '15348500',
                'amount': 'Rp 20.000.000.000',
                'date': '17 Oktober 2024',
                'status': 'GAGAL',
            },
            {
                'name': 'Asuransi GMAIL.com',
                'polis_id': '15348500',
                'amount': 'Rp 300.000.000',
                'date': '17 Oktober 2024',
                'status': 'BATAL',
            },
        ];

        return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                    'Riwayat Pembayaran',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                    ),
                ),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.help_outline, color: Colors.black),
                        onPressed: () {},
                    ),
                ],
            ),
            body: Column(
                children: [
                    Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                            children: [
                                Expanded(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: TextField(
                                            decoration: InputDecoration(
                                                hintText: 'Asuransi K..l',
                                                hintStyle: TextStyle(color: Colors.grey[600]),
                                                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                        icon: const Icon(Icons.tune),
                                        onPressed: () {},
                                    ),
                                ),
                            ],
                        ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: paymentHistory.length,
                            itemBuilder: (context, index) {
                                final item = paymentHistory[index];
                                return PaymentCardAdmin(
                                    name: item['name'],
                                    polisId: item['polis_id'],
                                    amount: item['amount'],
                                    date: item['date'],
                                    status: item['status'],
                                );
                            },
                        ),
                    ),
                ],
            ),
        );
    }
}

class PaymentCardAdmin extends StatelessWidget {
    final String name;
    final String polisId;
    final String amount;
    final String date;
    final String status;

    const PaymentCardAdmin({
        Key? key,
        required this.name,
        required this.polisId,
        required this.amount,
        required this.date,
        required this.status,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                    ),
                ],
            ),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                name,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                'Polis ID:',
                                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                            Text(
                                                polisId,
                                                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                                            ),
                                        ],
                                    ),
                                ),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                        Text(
                                            amount,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                            ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                            date,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                            children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                        color: _getStatusColor(),
                                        borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                        status,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusTextColor(),
                                        ),
                                    ),
                                ),
                                const Spacer(),
                                TextButton(
                                    onPressed: () {
                                        print('Detail pressed for: $name');
                                    },
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                        ),
                                    ),
                                    child: Row(
                                        children: const [
                                            Text(
                                                'Detail',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.arrow_forward, size: 16),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }

    Color _getStatusColor() {
        switch (status) {
            case 'BERHASIL':
                return Colors.green[100]!;
            case 'MENUNGGU':
                return Colors.orange[100]!;
            case 'GAGAL':
                return Colors.red[100]!;
            case 'BATAL':
                return Colors.grey[300]!;
            default:
                return Colors.grey[200]!;
        }
    }

    Color _getStatusTextColor() {
        switch (status) {
            case 'BERHASIL':
                return Colors.green[800]!;
            case 'MENUNGGU':
                return Colors.orange[800]!;
            case 'GAGAL':
                return Colors.red[800]!;
            case 'BATAL':
                return Colors.grey[800]!;
            default:
                return Colors.black;
        }
    }
}