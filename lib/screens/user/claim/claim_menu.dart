// lib/screens/user/claim/claim_menu.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../services/api_service.dart';
import 'claim_detail.dart';
import 'claim_cancel.dart';
import 'succes_detail.dart';

class KlaimSayaScreen extends StatefulWidget {
  const KlaimSayaScreen({Key? key}) : super(key: key);

  @override
  State<KlaimSayaScreen> createState() => _KlaimSayaScreenState();
}

class _KlaimSayaScreenState extends State<KlaimSayaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateFormat dateFmt;
  final ApiService api = ApiService();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  List<dynamic> _allKlaim = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initializeDateFormatting('id_ID', null).then((_) {
      dateFmt = DateFormat('dd MMM yyyy', 'id_ID');
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final res = await api.get('/user/klaim');
      setState(() {
        if (res is Map && res.containsKey('klaim')) {
          _allKlaim = res['klaim'] as List;
        } else if (res is List) {
          _allKlaim = res;
        } else {
          _allKlaim = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _hasError = true);
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return 'Menunggu';
      case 'diterima':
        return 'Berhasil';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange.shade50;
      case 'diterima':
        return Colors.green.shade50;
      case 'ditolak':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange.shade800;
      case 'diterima':
        return Colors.green.shade800;
      case 'ditolak':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _buildKlaimCard(Map<String, dynamic> klaim) {
    final jumlah = (klaim['jumlahKlaim'] as num?)?.toDouble() ?? 0.0;
    final rawStatus = (klaim['status']?.toString() ?? 'menunggu').toLowerCase();
    final tanggal =
        DateTime.tryParse(
          klaim['tanggalKlaim']?.toString() ??
              klaim['createdAt']?.toString() ??
              '',
        ) ??
        DateTime.now();

    final policyNumber = klaim['polisId']?['policyNumber']?.toString() ?? 'N/A';
    final productName =
        klaim['polisId']?['productId']?['name']?.toString() ??
        'Produk Asuransi';
    final deskripsi = klaim['deskripsi']?.toString() ?? '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (rawStatus == 'menunggu') {
            final bool? refreshed = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClaimCancelScreen(klaimData: klaim),
              ),
            );
            if (refreshed == true) _loadData();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailKlaimScreen(klaimData: klaim),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Polis: $policyNumber',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(rawStatus),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _mapStatus(rawStatus),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusText(rawStatus),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah Klaim',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        currency.format(jumlah),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tanggal Pengajuan',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        dateFmt.format(tanggal),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String filter) {
    final filtered = _allKlaim.where((k) {
      final s = (k['status']?.toString() ?? 'menunggu').toLowerCase();
      return s == filter.toLowerCase();
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Belum ada klaim $filter',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildKlaimCard(filtered[i]),
    );
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Berhasil'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClaimDetail()),
        ).then((_) => _loadData()),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Klaim'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError || _allKlaim.isEmpty
          ? RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(
                      _hasError
                          ? 'Gagal memuat data'
                          : 'Belum ada riwayat klaim',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('menunggu'),
                _buildTabContent('diterima'),
                _buildTabContent('ditolak'),
              ],
            ),
    );
  }
}
