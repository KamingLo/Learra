import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../models/product_model.dart';
import 'claim_detail.dart';
import 'claim_cancel.dart';
import 'succes_detail.dart';

class KlaimSayaScreen extends StatefulWidget {
  const KlaimSayaScreen({super.key});

  @override
  State<KlaimSayaScreen> createState() => _KlaimSayaScreenState();
}

class _KlaimSayaScreenState extends State<KlaimSayaScreen> {
  List<dynamic> klaimList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchKlaimUser();
  }

  Future<void> fetchKlaimUser() async {
    try {
      // TOKEN sudah otomatis diinject API service lu, jadi tidak perlu header Authorization
      final res = await http.get(
        Uri.parse("https://yourdomain.com/user/klaim"),
      );

      if (res.statusCode == 200) {
        setState(() {
          klaimList = jsonDecode(res.body);
          loading = false;
        });
      } else {
        print(res.body);
        setState(() => loading = false);
      }
    } catch (e) {
      print("ERR: $e");
      setState(() => loading = false);
    }
  }

  // Format tanggal
  String formatTanggal(String tgl) {
    try {
      final date = DateTime.parse(tgl);
      return "${date.day}-${date.month}-${date.year}";
    } catch (e) {
      return tgl;
    }
  }

  // Format harga
  String formatRupiah(num value) {
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
  }

  // Mapping status dari backend
  String mapStatus(String status) {
    switch (status) {
      case "menunggu":
        return "Menunggu";
      case "ditolak":
        return "Ditolak";
      case "disetujui":
        return "Diterima";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Klaim Saya',
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    // Search
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
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[600],
                                  ),
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

                    // List Klaim
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                        itemCount: klaimList.length,
                        itemBuilder: (context, index) {
                          final item = klaimList[index];
                          final polis = item["polisId"] ?? {};
                          final produk = polis["produkId"] ?? {};

                          return ClaimCard(
                            name:
                                produk["namaProduk"] ?? "Nama Produk Tidak Ada",
                            polisId: polis["_id"] ?? "-",
                            amount: formatRupiah(item["jumlahKlaim"] ?? 0),
                            date: formatTanggal(item["tanggalKlaim"] ?? ""),
                            status: mapStatus(item["status"] ?? "menunggu"),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Button Klaim Baru
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      final newProduct = ProductModel(
                        id: 'temp_claim',
                        namaProduk: 'Klaim Baru',
                        tipe: 'Kesehatan',
                        premiDasar: 0,
                        description: 'Klaim baru',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ClaimDetail(product: newProduct),
                        ),
                      );
                    },
                    backgroundColor: Colors.green,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Klaim Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ClaimCard extends StatelessWidget {
  final String name;
  final String polisId;
  final String amount;
  final String date;
  final String status;

  const ClaimCard({
    super.key,
    required this.name,
    required this.polisId,
    required this.amount,
    required this.date,
    required this.status,
  });

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
            // Header
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
                        "Polis ID:",
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
                      "Tanggal Klaim",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status + Button
            _buildStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    // terima
    if (status == "Diterima") {
      return Row(
        children: [_badge("Diterima"), const Spacer(), _detailButton(context)],
      );
    }

    // menunggu
    if (status == "Menunggu") {
      return Row(
        children: [
          _badge("Menunggu"),
          const Spacer(),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PengajuanKlaimScreen(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
            ),
            child: Row(
              children: const [
                Text("Batal"),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      );
    }

    // ditolak atau batal
    return Row(
      children: [_badge(status), const Spacer(), _detailButton(context)],
    );
  }

  Widget _badge(String txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        txt,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _detailButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailKlaimScreen()),
        );
      },
      child: Row(
        children: const [
          Text("Detail"),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}
