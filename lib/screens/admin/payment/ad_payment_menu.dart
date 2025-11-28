// lib/screens/admin/payment_menu.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ad_payment_detail.dart';
import '../../../services/api_service.dart';

class AdminPembayaranScreen extends StatefulWidget {
  const AdminPembayaranScreen({super.key});

  @override
  State<AdminPembayaranScreen> createState() => _AdminPembayaranScreenState();
}

class _AdminPembayaranScreenState extends State<AdminPembayaranScreen> {
  late Future<List<dynamic>> futurePayments;
  final api = ApiService();
  final searchCtrl = TextEditingController();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  late DateFormat dateFmt;
  bool _isInitialized = false;

  // Filter status
  String?
  _selectedStatus; // null = semua, 'menunggu_konfirmasi', 'berhasil', 'gagal'

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');
      _isInitialized = true;
      loadData();
    });
  }

  void loadData() {
    if (!_isInitialized) return;
    setState(() {
      String query = '/payment?limit=100';
      final search = searchCtrl.text.trim();
      if (search.isNotEmpty) query += '&search=$search';
      if (_selectedStatus != null) query += '&status=$_selectedStatus';

      futurePayments = api.get(query).then((res) => res as List<dynamic>);
    });
  }

  String val(dynamic value, [String fallback = '-']) {
    if (value == null) return fallback;
    if (value is String && value.isEmpty) return fallback;
    return value.toString();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Status Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filterOption('Semua', null),
            _filterOption('Menunggu', 'menunggu_konfirmasi'),
            _filterOption('Berhasil', 'berhasil'),
            _filterOption('Ditolak', 'gagal'),
          ],
        ),
      ),
    );
  }

  Widget _filterOption(String label, String? value) {
    final isSelected = _selectedStatus == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        setState(() => _selectedStatus = value);
        Navigator.pop(context);
        loadData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        // Icon tanda tanya dihapus
      ),
      body: Column(
        children: [
          // Search + Filter Bar
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
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Cari nama pengguna...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => loadData(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _selectedStatus != null
                        ? Colors.indigo[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _selectedStatus != null
                          ? Colors.indigo
                          : Colors.grey[700],
                    ),
                    onPressed: _showFilterDialog,
                  ),
                ),
              ],
            ),
          ),

          // Daftar Pembayaran
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => loadData(),
              child: FutureBuilder<List<dynamic>>(
                future: futurePayments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data ?? [];
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada pembayaran',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final p = data[i];

                      final id = val(p['_id']);
                      final amount = (p['amount'] is int
                          ? p['amount'].toDouble()
                          : p['amount'] ?? 0.0);
                      final status = val(p['status'], 'menunggu_konfirmasi');
                      final createdAt =
                          DateTime.tryParse(val(p['createdAt'])) ??
                          DateTime.now();

                      final userName = val(
                        p['policyId']?['userId']?['name'],
                        'User Tidak Diketahui',
                      );
                      final userEmail = val(
                        p['policyId']?['userId']?['email'],
                        '-',
                      );
                      final policyNumber = val(
                        p['policyId']?['policyNumber'],
                        'Belum ada polis',
                      );

                      final isPending = status == 'menunggu_konfirmasi';
                      final statusLabel = isPending
                          ? 'MENUNGGU'
                          : status == 'berhasil'
                          ? 'BERHASIL'
                          : 'DITOLAK'; // GAGAL → DITOLAK

                      return PaymentCardAdmin(
                        name: userName,
                        email: userEmail,
                        polisId: policyNumber,
                        amount: currency.format(amount),
                        date: dateFmt.format(createdAt),
                        status: statusLabel,
                        isPending: isPending,
                        onConfirm: () => _confirmPayment(id, true),
                        onReject: () => _confirmPayment(id, false),
                        paymentData:
                            p, // Tambahkan ini untuk pass p ke PaymentCardAdmin
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment(String id, bool approve) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(approve ? 'Konfirmasi Pembayaran' : 'Tolak Pembayaran'),
        content: Text(
          approve
              ? 'Polis akan diaktifkan.'
              : 'Pembayaran akan ditandai ditolak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.green : Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Konfirmasi' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await api.put(
          '/payment/$id/confirm',
          body: {'action': approve ? 'confirm' : 'tolak'},
        );
        loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? 'Pembayaran dikonfirmasi' : 'Pembayaran ditolak',
            ),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}

// Card dengan email + teks "Konfirmasi" putih + status "DITOLAK"
class PaymentCardAdmin extends StatelessWidget {
  final String name;
  final String email;
  final String polisId;
  final String amount;
  final String date;
  final String status;
  final bool isPending;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final Map<String, dynamic> paymentData; // Tambahkan prop ini

  const PaymentCardAdmin({
    super.key,
    required this.name,
    required this.email,
    required this.polisId,
    required this.amount,
    required this.date,
    required this.status,
    required this.isPending,
    required this.onConfirm,
    required this.onReject,
    required this.paymentData, // Required baru
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
            color: Colors.black.withValues(alpha:0.05),
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
                        email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 2),
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
                if (isPending)
                  Row(
                    children: [
                      TextButton(
                        onPressed: onReject,
                        child: const Text(
                          'Tolak',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPembayaranScreen(
                            paymentData: paymentData,
                          ), // Gunakan paymentData
                        ),
                      );
                    },
                    child: const Row(
                      children: [
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
      case 'DITOLAK':
        return Colors.red[100]!;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getStatusTextColor() {
    switch (status) {
      case 'BERHASIL':
        return Colors.green[800]!;
      case 'MENUNGGU':
        return Colors.orange[800]!;
      case 'DITOLAK':
        return Colors.red[800]!;
      default:
        return Colors.grey[800]!;
    }
  }
}
