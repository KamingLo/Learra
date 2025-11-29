import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../services/api_service.dart';
import 'claim_detail.dart';
import 'claim_cancel.dart';
import 'succes_detail.dart';

class KlaimSayaScreen extends StatefulWidget {
  const KlaimSayaScreen({super.key});

  @override
  State<KlaimSayaScreen> createState() => _KlaimSayaScreenState();
}

class _KlaimSayaScreenState extends State<KlaimSayaScreen> {
  late DateFormat dateFmt;
  final ApiService api = ApiService();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  final searchCtrl = TextEditingController();

  List<dynamic> _allKlaim = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isInitialized = false;

  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    searchCtrl.addListener(() => setState(() {}));
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');
      _isInitialized = true;
    });
    _loadData();
  }

  // Fungsi untuk mendapatkan nilai bersarang dengan aman
  dynamic _getNestedValue(Map<String, dynamic> map, List<String> keys) {
    dynamic value = map;
    for (String key in keys) {
      if (value is Map) {
        value = value[key];
      } else {
        return null;
      }
    }
    return value;
  }

  // --- LOGIKA PENGURUTAN STATUS ---
  int _getStatusPriority(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return 1; // Prioritas tertinggi
      case 'diterima':
        return 2;
      case 'ditolak':
        return 3; // Prioritas terendah
      default:
        return 4; // Status lain di paling bawah
    }
  }

  // Fungsi pemuat data dan pengurutan
  Future<void> _loadData() async {
    if (!_isInitialized || !mounted) return;
    setState(() => _isLoading = true);

    try {
      final res = await api.get('/user/klaim');

      List<dynamic> klaimList = [];
      if (res is Map && res.containsKey('klaim')) {
        klaimList = res['klaim'] as List;
      } else if (res is List) {
        klaimList = res;
      }

      // --- PENGURUTAN DATA KLAIM ---
      klaimList.sort((a, b) {
        final statusA = (a['status']?.toString() ?? 'menunggu').toLowerCase();
        final statusB = (b['status']?.toString() ?? 'menunggu').toLowerCase();

        final priorityA = _getStatusPriority(statusA);
        final priorityB = _getStatusPriority(statusB);

        // 1. Urutkan berdasarkan prioritas status
        final priorityComparison = priorityA.compareTo(priorityB);

        // 2. Jika prioritas sama, urutkan berdasarkan tanggal (terbaru ke terlama)
        if (priorityComparison == 0) {
          final dateA =
              DateTime.tryParse(a['tanggalKlaim'] ?? a['createdAt'] ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final dateB =
              DateTime.tryParse(b['tanggalKlaim'] ?? b['createdAt'] ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          // Urutan DESC (terbaru dulu)
          return dateB.compareTo(dateA);
        }

        return priorityComparison;
      });
      // --- AKHIR PENGURUTAN DATA KLAIM ---

      setState(() {
        _allKlaim = klaimList;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Status Klaim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filterOption('Semua', null),
            _filterOption('Menunggu', 'menunggu'),
            _filterOption('Berhasil', 'diterima'),
            _filterOption('Ditolak', 'ditolak'),
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
      },
    );
  }

  List<dynamic> _getFilteredKlaim() {
    var filtered = _allKlaim;

    if (_selectedStatus != null) {
      filtered = filtered.where((k) {
        final status = (k['status']?.toString() ?? 'menunggu').toLowerCase();
        return status == _selectedStatus!.toLowerCase();
      }).toList();
    }

    final query = searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((k) {
        final policyNumber =
            _getNestedValue(k, [
              'polisId',
              'policyNumber',
            ])?.toString().toLowerCase() ??
            _getNestedValue(k, [
              'polisId',
              'nomorPolis',
            ])?.toString().toLowerCase() ??
            _getNestedValue(k, ['polisId', '_id'])?.toString().toLowerCase() ??
            '';

        final productName =
            _getNestedValue(k, [
              'polisId',
              'productId',
              'name',
            ])?.toString().toLowerCase() ??
            _getNestedValue(k, [
              'polisId',
              'productId',
              'namaProduk',
            ])?.toString().toLowerCase() ??
            'produk asuransi';

        final deskripsi = k['deskripsi']?.toString().toLowerCase() ?? '';

        final rawDate = k['tanggalKlaim'] ?? k['createdAt'] ?? '';
        String dateStr = '';
        String isoDate = '';
        try {
          final date = DateTime.parse(rawDate.toString());
          dateStr = dateFmt.format(date).toLowerCase();
          isoDate = DateFormat('yyyy-MM-dd').format(date).toLowerCase();
        } catch (_) {}

        return policyNumber.contains(query) ||
            productName.contains(query) ||
            deskripsi.contains(query) ||
            dateStr.contains(query) ||
            isoDate.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  String _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return 'MENUNGGU';
      case 'diterima':
        return 'BERHASIL';
      case 'ditolak':
        return 'DITOLAK';
      default:
        return status.toUpperCase();
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange[100]!;
      case 'diterima':
        return Colors.green[100]!;
      case 'ditolak':
        return Colors.red[100]!;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange[800]!;
      case 'diterima':
        return Colors.green[800]!;
      case 'ditolak':
        return Colors.red[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredKlaim = _getFilteredKlaim();

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
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText:
                            'Cari polis, produk, tanggal, atau deskripsi...',
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
                    color: _selectedStatus != null
                        ? Colors.green[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _selectedStatus != null
                          ? Colors.green
                          : Colors.grey[700],
                    ),
                    onPressed: _showFilterDialog,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData, // Fungsi ini dipanggil saat swipe down
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Gagal memuat data'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : filteredKlaim.isEmpty
                  ? Center(
                      child: Text(
                        searchCtrl.text.isEmpty
                            ? 'Belum ada klaim'
                            : 'Tidak ditemukan',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredKlaim.length,
                      itemBuilder: (context, i) =>
                          _buildKlaimCard(filteredKlaim[i]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClaimDetail()),
          );
          if (result == true) _loadData();
        },
        label: const Text(
          'Ajukan Klaim',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildKlaimCard(Map<String, dynamic> klaim) {
    final jumlah = (klaim['jumlahKlaim'] as num?)?.toDouble() ?? 0.0;
    final rawStatus = (klaim['status']?.toString() ?? 'menunggu').toLowerCase();

    String rawDateStr = klaim['tanggalKlaim'] ?? klaim['createdAt'] ?? '';
    DateTime tanggal = DateTime.now();
    try {
      tanggal = DateTime.parse(rawDateStr);
    } catch (_) {}

    final policyNumber =
        _getNestedValue(klaim, ['polisId', 'policyNumber'])?.toString() ??
        _getNestedValue(klaim, ['polisId', 'nomorPolis'])?.toString() ??
        _getNestedValue(klaim, ['polisId', '_id'])?.toString() ??
        'ID Tidak tersedia';

    final productName =
        _getNestedValue(klaim, ['polisId', 'productId', 'name'])?.toString() ??
        _getNestedValue(klaim, [
          'polisId',
          'productId',
          'namaProduk',
        ])?.toString() ??
        'Produk Asuransi';

    final deskripsi = klaim['deskripsi']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
                        productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Polis ID:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        policyNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.format(jumlah),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFmt.format(tanggal),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                    color: _statusBg(rawStatus),
                    borderRadius: BorderRadius.circular(6),
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
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    if (rawStatus == 'menunggu') {
                      final refreshed = await Navigator.push(
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
}
