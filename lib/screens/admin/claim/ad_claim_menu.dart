import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../services/api_service.dart';
import 'ad_claim_detail.dart';

class AdminKlaimScreen extends StatefulWidget {
  const AdminKlaimScreen({super.key});

  @override
  State<AdminKlaimScreen> createState() => _AdminKlaimScreenState();
}

class _AdminKlaimScreenState extends State<AdminKlaimScreen> {
  late Future<List<dynamic>> futureKlaim;
  final api = ApiService();
  final searchCtrl = TextEditingController();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  late DateFormat dateFmt;
  bool _isInitialized = false;

  String? _selectedStatus;

  List<dynamic> _allKlaimData = [];
  List<dynamic> _filteredKlaimData = [];

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
      futureKlaim = api.get('/klaim?limit=100').then((res) {
        _allKlaimData = res as List<dynamic>;

        // --- LOGIKA PENGURUTAN BARU DIMULAI DI SINI ---
        _allKlaimData.sort((a, b) {
          final statusA = val(a['status'], 'menunggu').toLowerCase();
          final statusB = val(b['status'], 'menunggu').toLowerCase();

          // Fungsi pembantu untuk mendapatkan nilai prioritas
          int getStatusPriority(String status) {
            switch (status) {
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

          final priorityA = getStatusPriority(statusA);
          final priorityB = getStatusPriority(statusB);

          // 1. Urutkan berdasarkan prioritas status (1, 2, 3)
          final priorityComparison = priorityA.compareTo(priorityB);

          // 2. Jika prioritas sama, urutkan berdasarkan tanggal (terbaru ke terlama)
          if (priorityComparison == 0) {
            final dateA =
                DateTime.tryParse(val(a['tanggalKlaim'] ?? a['createdAt'])) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final dateB =
                DateTime.tryParse(val(b['tanggalKlaim'] ?? b['createdAt'])) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            // Urutan DESC (terbaru dulu): Bandingkan B dengan A
            return dateB.compareTo(dateA);
          }

          return priorityComparison;
        });
        // --- LOGIKA PENGURUTAN BARU SELESAI DI SINI ---

        _applyFilters();
        return _filteredKlaimData;
      });
    });
  }

  void _applyFilters() {
    List<dynamic> filtered = List.from(_allKlaimData);

    if (_selectedStatus != null) {
      filtered = filtered.where((k) {
        final status = val(k['status'], 'menunggu').toLowerCase();
        return status == _selectedStatus!.toLowerCase();
      }).toList();
    }

    final searchQuery = searchCtrl.text.trim().toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((k) {
        final userName = val(
          k['polisId']?['userId']?['name'],
          '',
        ).toLowerCase();

        final userEmail = val(
          k['polisId']?['userId']?['email'],
          '',
        ).toLowerCase();

        final policyNumber = val(
          k['polisId']?['policyNumber'],
          '',
        ).toLowerCase();

        final createdAt = DateTime.tryParse(
          val(k['tanggalKlaim'] ?? k['createdAt']),
        );

        final dateString = createdAt != null
            ? dateFmt.format(createdAt).toLowerCase()
            : '';

        return userName.contains(searchQuery) ||
            userEmail.contains(searchQuery) ||
            policyNumber.contains(searchQuery) ||
            dateString.contains(searchQuery);
      }).toList();
    }

    _filteredKlaimData = filtered;
  }

  String val(dynamic value, [String fallback = '-']) {
    if (value == null) return fallback;
    if (value is String && value.isEmpty) return fallback;
    return value.toString();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filter Status Klaim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filterOption('Semua', null),
            _filterOption('Menunggu', 'menunggu'),
            _filterOption('Diterima', 'diterima'),
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
        Navigator.pop(context);
        setState(() {
          _selectedStatus = value;
          _applyFilters();
        });
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
          'Riwayat Klaim',
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
                        hintText: 'Cari nama, email, polis, atau tanggal...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  searchCtrl.clear();
                                  setState(() {
                                    _applyFilters();
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _applyFilters();
                        });
                      },
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
                    border: _selectedStatus != null
                        ? Border.all(color: Colors.indigo, width: 2)
                        : null,
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

          if (_selectedStatus != null)
            Container(
              width: double.infinity,
              color: Colors.indigo[50],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: Colors.indigo[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Filter: ${_selectedStatus![0].toUpperCase()}${_selectedStatus!.substring(1)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.indigo[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedStatus = null;
                        _applyFilters();
                      });
                    },
                    child: Text(
                      'Hapus Filter',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => loadData(),
              child: FutureBuilder<List<dynamic>>(
                future: futureKlaim,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final data = _filteredKlaimData;
                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchCtrl.text.isNotEmpty ||
                                    _selectedStatus != null
                                ? 'Tidak ada hasil yang ditemukan'
                                : 'Belum ada pengajuan klaim',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (searchCtrl.text.isNotEmpty ||
                              _selectedStatus != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Coba kata kunci atau filter lain',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final k = data[i];
                      final id = val(k['_id']);
                      final jumlah = (k['jumlahKlaim'] is int
                          ? k['jumlahKlaim'].toDouble()
                          : k['jumlahKlaim'] ?? 0.0);
                      final status = val(k['status'], 'menunggu');
                      final createdAt =
                          DateTime.tryParse(
                            val(k['tanggalKlaim'] ?? k['createdAt']),
                          ) ??
                          DateTime.now();

                      final userName = val(
                        k['polisId']?['userId']?['name'],
                        'User Tidak Diketahui',
                      );
                      final userEmail = val(
                        k['polisId']?['userId']?['email'],
                        '-',
                      );
                      final policyNumber = val(
                        k['polisId']?['policyNumber'],
                        'Tidak ada polis',
                      );

                      final isPending = status.toLowerCase() == 'menunggu';
                      final statusLabel = isPending
                          ? 'MENUNGGU'
                          : status.toLowerCase() == 'diterima'
                          ? 'DITERIMA'
                          : 'DITOLAK';

                      return KlaimCardAdmin(
                        name: userName,
                        email: userEmail,
                        polisId: policyNumber,
                        amount: currency.format(jumlah),
                        date: dateFmt.format(createdAt),
                        status: statusLabel,
                        isPending: isPending,
                        onConfirm: () => _updateKlaim(id, 'diterima'),
                        onReject: () => _updateKlaim(id, 'ditolak'),
                        klaimData: k,
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

  Future<void> _updateKlaim(String id, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(newStatus == 'diterima' ? 'Terima Klaim' : 'Tolak Klaim'),
        content: Text(
          newStatus == 'diterima'
              ? 'Klaim akan disetujui dan dana akan dicairkan.'
              : 'Klaim akan ditolak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'diterima'
                  ? Colors.green
                  : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(newStatus == 'diterima' ? 'Terima' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await api.put('/klaim/$id', body: {'status': newStatus});
        if (!mounted) return;
        loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'diterima' ? 'Klaim diterima' : 'Klaim ditolak',
            ),
            backgroundColor: newStatus == 'diterima'
                ? Colors.green
                : Colors.red,
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

class KlaimCardAdmin extends StatelessWidget {
  final String name;
  final String email;
  final String polisId;
  final String amount;
  final String date;
  final String status;
  final bool isPending;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final Map<String, dynamic> klaimData;

  const KlaimCardAdmin({
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
    required this.klaimData,
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
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

            // LOGIKA AKSI DIPERBARUI DI SINI
            if (isPending)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ROW 1: Status (Kiri) dan Tombol Detail (Kanan)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusTextColor(),
                          ),
                        ),
                      ),

                      // Tombol Detail (Pindah ke baris atas, di kanan)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailKlaimScreen(klaimData: klaimData),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Text('Detail'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8), // Spasi pemisah
                  // ROW 2: Tombol Konfirmasi (Tolak dan Terima) - di baris bawah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                          'Terima',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else // DITERIMA atau DITOLAK: Status dan Detail sebaris
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusTextColor(),
                      ),
                    ),
                  ),

                  // Tombol Detail
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailKlaimScreen(klaimData: klaimData),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text('Detail'),
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

  String _getStatusText() {
    switch (status) {
      case 'DITERIMA':
        return 'DITERIMA';
      case 'MENUNGGU':
        return 'MENUNGGU';
      case 'DITOLAK':
        return 'DITOLAK';
      default:
        return status;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'DITERIMA':
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
      case 'DITERIMA':
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
