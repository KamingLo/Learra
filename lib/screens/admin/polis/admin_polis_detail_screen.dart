import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/polis_model.dart';
import '../../../models/product_model.dart';
import '../../../services/api_service.dart';

import '../../../widgets/user/polis/user_polis_form_fields.dart';

class AdminPolicyDetailScreen extends StatefulWidget {
  final PolicyModel policy;

  const AdminPolicyDetailScreen({super.key, required this.policy});

  @override
  State<AdminPolicyDetailScreen> createState() =>
      _AdminPolicyDetailScreenState();
}

class _AdminPolicyDetailScreenState extends State<AdminPolicyDetailScreen> {
  final ApiService _apiService = ApiService();

  late TextEditingController _premiController;
  late TextEditingController _statusReasonController;

  String _selectedStatus = 'inaktif';
  DateTime _selectedDate = DateTime.now();

  final _merkController = TextEditingController();
  final _jenisController = TextEditingController();
  final _platController = TextEditingController();
  final _rangkaController = TextEditingController();
  final _mesinController = TextEditingController();
  final _pemilikController = TextEditingController();
  final _tahunController = TextEditingController();
  final _hargaKendaraanController = TextEditingController();

  final _tanggunganController = TextEditingController();
  String _maritalStatus = 'belum menikah';

  bool _diabetes = false;
  bool _merokok = false;
  bool _hipertensi = false;

  PolicyModel? _policy;
  bool _isEditing = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _policy = widget.policy;
    _initializeControllers();
    _fetchPolicyDetail();
  }

  void _initializeControllers() {
    if (_policy == null) return;

    final normalizedStatus = _policy!.status.toLowerCase();
    if (normalizedStatus.contains('batal')) {
      _selectedStatus = 'dibatalkan';
    } else if (normalizedStatus.contains('inaktif') ||
        normalizedStatus.contains('tidak aktif') ||
        normalizedStatus.contains('nonaktif')) {
      _selectedStatus = 'inaktif';
    } else {
      _selectedStatus = 'aktif';
    }

    _selectedDate = _policy!.expiredDate;

    _premiController = TextEditingController(
      text: _policy!.premiumAmount.toStringAsFixed(0),
    );
    _statusReasonController = TextEditingController(
      text: _policy!.statusReason ?? '',
    );

    if (_policy!.category == 'kendaraan') {
      _merkController.text = _policy!.vehicleBrand ?? '';
      _jenisController.text = _policy!.vehicleType ?? '';
      _platController.text = _policy!.plateNumber ?? '';
      _rangkaController.text = _policy!.frameNumber ?? '';
      _mesinController.text = _policy!.engineNumber ?? '';
      _pemilikController.text = _policy!.ownerName ?? '';
      _tahunController.text = _policy!.yearBought ?? '';
      if (_policy!.vehiclePrice != null) {
        _hargaKendaraanController.text = _formatCurrencyRaw(
          _policy!.vehiclePrice!,
        );
      }
    } else if (_policy!.category == 'jiwa') {
      _tanggunganController.text = (_policy!.dependentsCount ?? 0).toString();
      _maritalStatus = _policy!.maritalStatus ?? 'belum menikah';
    } else if (_policy!.category == 'kesehatan') {
      _diabetes = _policy!.hasDiabetes ?? false;
      _merokok = _policy!.isSmoker ?? false;
      _hipertensi = _policy!.hasHypertension ?? false;
    }
  }

  String _formatCurrencyRaw(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  bool _needsHydration(PolicyModel p) {
    return (p.productName.isEmpty || p.productName == 'Produk Asuransi') &&
        (p.productId != null && p.productId!.isNotEmpty);
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
            debugPrint("Gagal mengambil detail produk: $e");
          }
        }
        setState(() {
          _policy = tempPolicy;

          _initializeControllers();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal memuat detail polis. $e";
      });
    }
  }

  Future<void> _updatePolicy() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> kendaraan = {};
      Map<String, dynamic> jiwa = {};
      Map<String, dynamic> kesehatan = {};

      if (_policy!.category == 'kendaraan') {
        kendaraan = {
          'merek': _merkController.text,
          'jenisKendaraan': _jenisController.text,
          'nomorKendaraan': _platController.text,
          'nomorRangka': _rangkaController.text,
          'nomorMesin': _mesinController.text,
          'namaPemilik': _pemilikController.text,
          'umurKendaraan': _tahunController.text,
          'hargaKendaraan':
              int.tryParse(
                _hargaKendaraanController.text.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                ),
              ) ??
              0,
        };
      } else if (_policy!.category == 'jiwa') {
        jiwa = {
          'jumlahTanggungan': int.tryParse(_tanggunganController.text) ?? 0,
          'statusPernikahan': _maritalStatus,
        };
      } else if (_policy!.category == 'kesehatan') {
        kesehatan = {
          'diabetes': _diabetes,
          'merokok': _merokok,
          'hipertensi': _hipertensi,
        };
      }

      final body = {
        'endingDate': _selectedDate.toIso8601String(),

        'premiumAmount':
            double.tryParse(
              _premiController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        'detail': {
          'kendaraan': kendaraan,
          'jiwa': jiwa,
          'kesehatan': kesehatan,
        },
      };

      await _apiService.put('/polis/${_policy!.id}', body: body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Polis berhasil diperbarui'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isEditing = false);
      _fetchPolicyDetail();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deletePolicy() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Polis Permanen"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus polis ini dari database? Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.delete('/polis/${_policy!.id}');
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Polis berhasil dihapus')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  String _formatCurrency(dynamic value) {
    final number = value is num
        ? value
        : double.tryParse(value.toString()) ?? 0.0;
    return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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
        appBar: AppBar(title: const Text("Detail Polis")),
        body: Center(child: Text(_errorMessage ?? "Error")),
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
        title: Text(
          _isEditing ? "Edit Polis" : "Detail Polis",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isEditing ? Icons.save : Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: _isEditing
                ? _updatePolicy
                : () => setState(() => _isEditing = true),
          ),
          const SizedBox(width: 8),
        ],
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
                        _buildStatusWidget(policy),
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
                              Icon(
                                Icons.shield,
                                color: Colors.white.withValues(alpha: 0.3),
                                size: 30,
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
                                    _getFormattedDate(_selectedDate),
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
                                    _formatCurrency(_premiController.text),
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
                    _buildSectionTitle("Informasi Pengguna"),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      _buildDetailRow(
                        Icons.person_outline,
                        "Nama",
                        policy.ownerName ?? '-',
                        isFirst: true,
                      ),
                      _buildDetailRow(
                        Icons.email_outlined,
                        "Email",
                        policy.ownerEmail ?? '-',
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      policy.category == 'kendaraan'
                          ? "Detail Kendaraan"
                          : policy.category == 'kesehatan'
                          ? "Detail Kesehatan"
                          : "Detail Tertanggung",
                    ),

                    const SizedBox(height: 12),

                    _isEditing
                        ? Column(children: _buildSpecificDetails(policy))
                        : Container(
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
                            child: Column(
                              children: _buildSpecificDetails(policy),
                            ),
                          ),

                    if (_isEditing) ...[
                      const SizedBox(height: 40),
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
                              onTap: _deletePolicy,
                              borderRadius: BorderRadius.circular(16),
                              splashColor: Colors.red.withValues(alpha: 0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_forever,
                                      color: Colors.red.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Hapus Polis Permanen",
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

  Widget _buildStatusWidget(PolicyModel policy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  List<Widget> _buildSpecificDetails(PolicyModel p) {
    if (p.category == 'kendaraan') {
      if (_isEditing) {
        return [
          const SizedBox(height: 16),
          CustomTextField(
            controller: _pemilikController,
            label: "Nama Pemilik",
            hint: "Nama sesuai surat",
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _merkController,
            label: "Merk Kendaraan",
            hint: "Contoh: Toyota",
            icon: Icons.branding_watermark,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _jenisController,
            label: "Jenis Kendaraan",
            hint: "Contoh: Avanza G",
            icon: Icons.directions_car,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _hargaKendaraanController,
            label: "Harga Kendaraan",
            hint: "0",
            icon: Icons.payments,
            prefixText: "Rp ",
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _platController,
            label: "Nomor Plat",
            hint: "Contoh: B 1234 ABC",
            icon: Icons.pin_outlined,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _rangkaController,
            label: "Nomor Rangka",
            hint: "Lihat STNK",
            icon: Icons.qr_code,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _mesinController,
            label: "Nomor Mesin",
            hint: "Lihat STNK",
            icon: Icons.settings_suggest,
            textCapitalization: TextCapitalization.characters,
          ),

          const SizedBox(height: 16),
          CustomTextField(
            controller: _tahunController,
            label: "Tahun Pembelian Mobil",
            hint: "YYYY-MM-DD",
            icon: Icons.calendar_today,
          ),
        ];
      }

      return [
        _buildDetailRow(
          Icons.person_outline,
          "Nama Pemilik",
          p.ownerName ?? '-',
        ),
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
          Icons.monetization_on_outlined,
          "Harga Kendaraan",
          _formatCurrency(p.vehiclePrice),
        ),
        _buildDetailRow(Icons.pin_outlined, "Nomor Plat", p.plateNumber ?? '-'),
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
          p.yearBought ?? '-',
          isLast: true,
        ),
      ];
    } else if (p.category == 'kesehatan') {
      if (_isEditing) {
        return [
          HealthConditionTile(
            title: "Diabetes",
            subtitle: "Riwayat diabetes",
            icon: Icons.medical_services,
            value: _diabetes,
            onChanged: (v) => setState(() => _diabetes = v),
          ),
          const SizedBox(height: 12),
          HealthConditionTile(
            title: "Merokok",
            subtitle: "Perokok aktif",
            icon: Icons.smoking_rooms,
            value: _merokok,
            onChanged: (v) => setState(() => _merokok = v),
          ),
          const SizedBox(height: 12),
          HealthConditionTile(
            title: "Hipertensi",
            subtitle: "Tekanan darah tinggi",
            icon: Icons.favorite,
            value: _hipertensi,
            onChanged: (v) => setState(() => _hipertensi = v),
          ),
        ];
      }

      return [
        _buildDetailRow(
          Icons.medical_services_outlined,
          "Diabetes",
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
          "Hipertensi",
          p.hasHypertension == true ? 'Ya' : 'Tidak',
          isLast: true,
        ),
      ];
    } else if (p.category == 'jiwa') {
      if (_isEditing) {
        return [
          MaritalStatusSelector(
            value: _maritalStatus,
            onChanged: (v) {
              if (v != null) setState(() => _maritalStatus = v);
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _tanggunganController,
            label: "Jumlah Tanggungan",
            hint: "Contoh: 3",
            icon: Icons.people,
            suffixText: "orang",
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ];
      }

      return [
        _buildDetailRow(
          Icons.family_restroom_outlined,
          "Status",
          p.maritalStatus ?? '-',
          isFirst: true,
        ),
        _buildDetailRow(
          Icons.people_outline,
          "Tanggungan",
          "${p.dependentsCount ?? 0} Orang",
          isLast: true,
        ),
      ];
    }
    return [
      const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Tidak ada detail tambahan"),
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
