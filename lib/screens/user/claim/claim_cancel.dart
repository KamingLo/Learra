// lib/screens/user/claim/claim_cancel.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';

class ClaimCancelScreen extends StatefulWidget {
  final Map<String, dynamic> klaimData;
  const ClaimCancelScreen({super.key, required this.klaimData});

  @override
  State<ClaimCancelScreen> createState() => _ClaimCancelScreenState();
}

class _ClaimCancelScreenState extends State<ClaimCancelScreen> {
  final ApiService api = ApiService();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  bool _isLoading = false;

  Future<void> _batalkanKlaim() async {
    setState(() => _isLoading = true);
    try {
      await api.delete('/klaim/${widget.klaimData['_id']}');
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan klaim berhasil dibatalkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Kembali & refresh list
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final polis = widget.klaimData['polisId'];
    final productName = polis?['productId']?['name'] ?? 'Produk Asuransi';
    final policyNumber = polis?['policyNumber'] ?? 'N/A';
    final jumlah = (widget.klaimData['jumlahKlaim'] as num?)?.toDouble() ?? 0.0;
    final deskripsi = widget.klaimData['deskripsi'] ?? '-';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Batalkan Pengajuan Klaim'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nomor Polis',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(policyNumber, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text(
                  'Jumlah Klaim',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  currency.format(jumlah),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Deskripsi Kejadian',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(deskripsi, style: const TextStyle(fontSize: 15)),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Apakah Anda yakin ingin membatalkan pengajuan klaim ini?',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _batalkanKlaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(0, 56),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Batalkan Klaim',
                              style: TextStyle(fontSize: 16),
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
