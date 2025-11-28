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

    if (_needsHydration(widget.policy)) {
      _fetchPolicyDetail();
    } else {
      _fetchPolicyDetail();
    }

    _checkPendingPayment();
  }

  bool _needsHydration(PolicyModel p) {
    return (p.productName.isEmpty || p.productName == 'Produk Asuransi') &&
        (p.productId != null && p.productId!.isNotEmpty);
  }

  Future<void> _checkPendingPayment() async {
    try {
      final response = await _apiService.get('/user/payment');

      if (response != null && response['pembayaran'] is List) {
        final payments = response['pembayaran'] as List;

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
        PolicyModel tempPolicy = PolicyModel.fromJson(
          Map<String, dynamic>.from(response),
        );

        if (_needsHydration(tempPolicy)) {
          try {
            final productResponse = await _apiService.get(
              '/produk/${tempPolicy.productId}',
            );

            final productData =
                (productResponse is Map && productResponse['data'] is Map)
                ? productResponse['data']
                : (productResponse is Map ? productResponse : null);

            if (productData != null) {
              final product = ProductModel.fromJson(
                Map<String, dynamic>.from(productData),
              );
              tempPolicy = tempPolicy.copyWith(
                productName: product.namaProduk,
                productType: product.tipe,
              );
            }
          } catch (e) {
            print("Gagal mengambil detail produk: $e");
          }
        }

        setState(() {
          _policy = tempPolicy;
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

  void _handlePaymentAction() {
    if (_pendingPayment != null) {
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
        _checkPendingPayment();
        _fetchPolicyDetail();
      });
    } else {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _apiService.delete('/polis/${_policy!.id}');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Polis berhasil diakhiri')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
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
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
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
      backgroundColor: Colors.green.shade600,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Polis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            policy.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                policy.productName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${policy.summaryTitle} • ${policy.summarySubtitle}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade800,
                            Colors.green.shade700,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    policy.policyNumber,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.shield,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.2),
                            height: 1,
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Berakhir Pada",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    policy.formattedDate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
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
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.category == 'kendaraan'
                          ? "Informasi Kendaraan"
                          : policy.category == 'kesehatan'
                          ? "Informasi Kesehatan"
                          : "Informasi Tertanggung",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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

                    SizedBox(
                      width: double.infinity,
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleDeletePolicy,
                            borderRadius: BorderRadius.circular(16),
                            splashColor: Colors.red.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSpecificDetails(PolicyModel p) {
    if (p.category == 'kendaraan') {
      String formattedYear = p.yearBought ?? '-';
      if (formattedYear.contains('T')) {
        try {
          final date = DateTime.parse(formattedYear);
          formattedYear = "${date.year}";
        } catch (_) {}
      }

      String formattedVehiclePrice = '-';
      if (p.vehiclePrice != null) {
        formattedVehiclePrice = _formatCurrency(p.vehiclePrice.toString());
      }

      return [
        _buildDetailRow(
          Icons.person_outline,
          "Nama Pemilik",
          p.ownerName ?? '-',
          isFirst: true,
        ),
        _buildDetailRow(
          Icons.directions_car_outlined,
          "Merk Kendaraan",
          p.vehicleBrand ?? '-',
        ),
        _buildDetailRow(
          Icons.category_outlined,
          "Jenis Kendaraan",
          p.vehicleType ?? '-',
        ),

        _buildDetailRow(
          Icons.monetization_on_outlined,
          "Harga Kendaraan",
          formattedVehiclePrice,
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
          Icons.calendar_today_outlined,
          "Tahun Pembelian Mobil",
          formattedYear,
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
