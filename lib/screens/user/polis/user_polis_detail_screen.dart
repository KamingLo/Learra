import 'package:flutter/material.dart';
import '../../../models/polis_model.dart';
import '../../../models/product_model.dart';
import '../../../services/api_service.dart';
import '../payment/payment_detail.dart';
import '../payment/payment_wait.dart';

class PolicyDetailScreen extends StatefulWidget {
  final PolicyModel policy;

  const PolicyDetailScreen({super.key, required this.policy});

  @override
  State<PolicyDetailScreen> createState() => _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends State<PolicyDetailScreen> {
  final ApiService _apiService = ApiService();
  PolicyModel? _policy;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _pendingPayment;

  @override
  void initState() {
    super.initState();
    _policy = widget.policy;
    _fetchPolicyDetail();
    _checkPendingPayment();
  }

  Future<void> _checkPendingPayment() async {
    try {
      final response = await _apiService.get('/user/payment');

      if (response != null && response['pembayaran'] is List) {
        final payments = response['pembayaran'] as List;

        // Cari pembayaran yang masih pending untuk polis ini
        final pending = payments.firstWhere(
          (p) =>
              p['policyId']?['_id'] == widget.policy.id &&
              p['status'] == 'menunggu_konfirmasi',
          orElse: () => null,
        );

        if (mounted && pending != null) {
          setState(() {
            _pendingPayment = pending;
          });
        }
      }
    } catch (e) {
      print('Error checking pending payment: $e');
    }
  }

  Future<void> _fetchPolicyDetail() async {
    if (widget.policy.id.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _apiService.get('/polis/${widget.policy.id}');

      if (!mounted) return;

      if (response is Map) {
        setState(() {
          _policy = PolicyModel.fromJson(Map<String, dynamic>.from(response));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Gagal memuat detail polis. ${e.toString().replaceAll('Exception: ', '')}";
      });
    }
  }

  String _getButtonText() {
    if (_pendingPayment != null) {
      return "Cek Status Pembayaran";
    }
    return _policy?.status.toLowerCase() != 'aktif'
        ? "Bayar Sekarang"
        : "Perpanjang Polis";
  }

  IconData _getButtonIcon() {
    if (_pendingPayment != null) {
      return Icons.pending_actions;
    }
    return _policy?.status.toLowerCase() != 'aktif'
        ? Icons.payment
        : Icons.refresh;
  }

  void _handlePaymentAction() {
    if (_pendingPayment != null) {
      // Navigasi ke payment_wait jika ada pembayaran pending
      final Map<String, String> paymentData = {
        'Nomor Pembayaran': _pendingPayment!['_id']?.toString() ?? 'N/A',
        'Nomor Polis': _policy?.policyNumber ?? 'N/A',
        'Produk': _policy?.productName ?? 'N/A',
        'Metode Pembayaran': _getPaymentMethodName(
          _pendingPayment!['method'] ?? 'bca',
        ),
        'Total Pembayaran': _formatCurrency(
          _pendingPayment!['amount']?.toString() ?? '0',
        ),
        'Tanggal': _formatDate(_pendingPayment!['createdAt']),
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWait(
            data: paymentData,
            paymentId: _pendingPayment!['_id']?.toString(),
            onPaymentCancelled: () {
              setState(() {
                _pendingPayment = null;
              });
            },
          ),
        ),
      ).then((_) {
        // Refresh data setelah kembali
        _checkPendingPayment();
        _fetchPolicyDetail();
      });
    } else {
      // Navigasi ke payment_detail untuk pembayaran baru
      final productModel = ProductModel(
        id: _policy!.id,
        namaProduk: _policy!.productName,
        tipe: _policy!.category,
        premiDasar:
            double.tryParse(
              _policy!.formattedPrice.replaceAll(RegExp(r'[^\d]'), ''),
            )?.toInt() ??
            0,
        description: _policy!.summarySubtitle,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetail(
            product: productModel,
            policyId: _policy!.id,
            policyNumber: _policy!.policyNumber,
            userId: _policy!.ownerId,
          ),
        ),
      ).then((_) {
        _checkPendingPayment();
        _fetchPolicyDetail();
      });
    }
  }

  String _getPaymentMethodName(String id) {
    final methods = {
      'bca': 'Bank BCA',
      'mandiri': 'Bank Mandiri',
      'bni': 'Bank BNI',
      'bri': 'Bank BRI',
      'cimb': 'Bank CIMB Niaga',
    };
    return methods[id] ?? 'Bank BCA';
  }

  String _formatCurrency(String value) {
    final number = double.tryParse(value) ?? 0.0;
    return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _handleDeletePolicy() async {
    if (_policy == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Akhiri polis ini? Tindakan ini akan menghapus polis dan tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Akhiri'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _apiService.delete('/polis/${_policy!.id}');
      Navigator.of(context).pop(); // tutup loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Polis berhasil diakhiri')));
      Navigator.of(context).pop(true); // kembali dan beri sinyal refresh
    } catch (e) {
      Navigator.of(context).pop(); // tutup loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengakhiri polis: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _policy == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(title: const Text("Detail Polis")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? "Polis tidak ditemukan",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchPolicyDetail,
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    final policy = _policy!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 125,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.green.shade700,
                  size: 16,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade700, Colors.green.shade500],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                policy.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    policy.productName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${policy.summaryTitle} - ${policy.summarySubtitle}",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: policy.statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    policy.status,
                                    style: TextStyle(
                                      color: policy.statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nomor Polis",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  policy.policyNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.shield_outlined,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 48,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Berakhir Pada",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  policy.formattedDate,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Biaya Premi",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  policy.formattedPrice,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    policy.category == 'kendaraan'
                        ? "Informasi Kendaraan"
                        : policy.category == 'kesehatan'
                        ? "Informasi Kesehatan"
                        : "Informasi Tertanggung",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(children: _buildSpecificDetails(policy)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _pendingPayment != null
                                    ? Colors.orange.shade600
                                    : Colors.green.shade600,
                                _pendingPayment != null
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_pendingPayment != null
                                            ? Colors.orange
                                            : Colors.green)
                                        .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handlePaymentAction,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getButtonIcon(),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getButtonText(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.shade300,
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handleDeletePolicy,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.red.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Akhiri Polis",
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpecificDetails(PolicyModel p) {
    if (p.category == 'kendaraan') {
      return [
        _buildDetailRow(
          Icons.directions_car_outlined,
          "Merk Kendaraan",
          p.vehicleBrand ?? '-',
          isFirst: true,
        ),
        _buildDetailRow(
          Icons.category_outlined,
          "Jenis Kendaraan",
          p.vehicleType ?? '-',
        ),
        _buildDetailRow(
          Icons.pin_outlined,
          "Nomor Polisi",
          p.plateNumber ?? '-',
        ),
        _buildDetailRow(
          Icons.qr_code_outlined,
          "Nomor Rangka",
          p.frameNumber ?? '-',
        ),
        _buildDetailRow(
          Icons.settings_outlined,
          "Nomor Mesin",
          p.engineNumber ?? '-',
        ),
        _buildDetailRow(
          Icons.person_outline,
          "Nama Pemilik",
          p.ownerName ?? '-',
        ),
        _buildDetailRow(
          Icons.calendar_today_outlined,
          "Tahun Pembelian",
          p.yearBought ?? '-',
          isLast: true,
        ),
      ];
    } else if (p.category == 'kesehatan') {
      return [
        _buildDetailRow(
          Icons.medical_services_outlined,
          "Riwayat Diabetes",
          p.hasDiabetes == true ? 'Ya' : 'Tidak',
          isFirst: true,
        ),
        _buildDetailRow(
          Icons.smoking_rooms_outlined,
          "Perokok",
          p.isSmoker == true ? 'Ya' : 'Tidak',
        ),
        _buildDetailRow(
          Icons.favorite_outline,
          "Riwayat Hipertensi",
          p.hasHypertension == true ? 'Ya' : 'Tidak',
          isLast: true,
        ),
      ];
    } else if (p.category == 'jiwa') {
      return [
        _buildDetailRow(
          Icons.family_restroom_outlined,
          "Status Pernikahan",
          p.maritalStatus ?? '-',
          isFirst: true,
        ),
        _buildDetailRow(
          Icons.people_outline,
          "Jumlah Tanggungan",
          "${p.dependentsCount ?? 0} Orang",
          isLast: true,
        ),
      ];
    }
    return [
      _buildDetailRow(
        Icons.info_outline,
        "Info",
        "Tidak ada detail tambahan",
        isFirst: true,
        isLast: true,
      ),
    ];
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade100),
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green.shade700, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
