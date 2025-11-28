import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/polis_model.dart';
import '../../../services/api_service.dart';

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
    _initializeData();
    _fetchPolicyDetail();
  }

  void _initializeData() {
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
        _hargaKendaraanController.text = _policy!.vehiclePrice!.toStringAsFixed(
          0,
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
          _initializeData();
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

  Future<void> _updatePolicy() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> detailData = {};
      final statusValue = _selectedStatus.toLowerCase();
      final cleanedPremium =
          double.tryParse(
            _premiController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;

      if (statusValue == 'dibatalkan' &&
          _statusReasonController.text.trim().isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alasan wajib diisi untuk status dibatalkan'),
          ),
        );
        return;
      }

      if (_policy!.category == 'kendaraan') {
        detailData['kendaraan'] = {
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
              _policy!.vehiclePrice?.toInt() ??
              0,
        };
      } else if (_policy!.category == 'jiwa') {
        detailData['jiwa'] = {
          'jumlahTanggungan': int.tryParse(_tanggunganController.text) ?? 0,
          'statusPernikahan': _maritalStatus,
        };
      } else if (_policy!.category == 'kesehatan') {
        detailData['kesehatan'] = {
          'diabetes': _diabetes,
          'merokok': _merokok,
          'hipertensi': _hipertensi,
        };
      }

      final body = {
        'status': statusValue,
        'endingDate': _selectedDate.toIso8601String(),
        'premium': cleanedPremium,
        if (detailData.isNotEmpty) 'detail': detailData,
        if (statusValue == 'dibatalkan')
          'statusReason': _statusReasonController.text.trim(),
      };

      await _apiService.put('/polis/${_policy!.id}', body: body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Polis berhasil diperbarui')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePolicy() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Polis"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus polis ini? Data tidak dapat dikembalikan.",
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Polis berhasil dihapus')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal hapus: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _merkController.dispose();
    _jenisController.dispose();
    _platController.dispose();
    _rangkaController.dispose();
    _mesinController.dispose();
    _pemilikController.dispose();
    _tahunController.dispose();
    _hargaKendaraanController.dispose();
    _premiController.dispose();
    _tanggunganController.dispose();
    _statusReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (!_isEditing) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
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
      return Scaffold(body: Center(child: Text(_errorMessage ?? "Error")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Kelola Polis",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: _updatePolicy,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  _buildHeaderRow("Nomor Polis", _policy!.policyNumber),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(color: Colors.grey),
                      ),
                      _isEditing
                          ? DropdownButton<String>(
                              value: _selectedStatus,
                              underline: const SizedBox(),
                              items: ['aktif', 'inaktif', 'dibatalkan']
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s.toUpperCase(),
                                        style: TextStyle(
                                          color: s == 'aktif'
                                              ? Colors.green
                                              : (s == 'dibatalkan'
                                                    ? Colors.red
                                                    : Colors.orange),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedStatus = v!),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _policy!.statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _policy!.status.toUpperCase(),
                                style: TextStyle(
                                  color: _policy!.statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedStatus == 'dibatalkan') ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Alasan Status",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusReasonInput(),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Mulai Pada",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _policy!.formattedStartDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Berakhir Pada",
                        style: TextStyle(color: Colors.grey),
                      ),
                      InkWell(
                        onTap: _pickDate,
                        child: Row(
                          children: [
                            Text(
                              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (_isEditing)
                              const Icon(
                                Icons.edit_calendar,
                                size: 16,
                                color: Colors.blue,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Premi (Rp)",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        width: 150,
                        child: _isEditing
                            ? TextField(
                                controller: _premiController,
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : Text(
                                _policy!.formattedPrice,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildInfoSection("Data Pengguna", [
              _buildInfoRow(
                Icons.person_outline,
                "Nama",
                _policy!.ownerName ?? '-',
              ),
              _buildInfoRow(
                Icons.email_outlined,
                "Email",
                _policy!.ownerEmail ?? '-',
              ),
            ]),
            const SizedBox(height: 16),
            _buildInfoSection("Data Produk", [
              _buildInfoRow(
                Icons.shield_outlined,
                "Produk",
                _policy!.productName,
              ),
              _buildInfoRow(
                Icons.category_outlined,
                "Tipe",
                _policy!.productType?.toUpperCase() ??
                    _policy!.category.toUpperCase(),
              ),
            ]),
            const SizedBox(height: 24),
            Text(
              "Detail ${_policy!.category.toUpperCase()}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(children: _buildDetailFields()),
            ),

            const SizedBox(height: 30),

            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deletePolicy,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Hapus Polis Permanen"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                    elevation: 0,
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<Widget> _buildDetailFields() {
    if (_policy!.category == 'kendaraan') {
      return [
        _buildTextField("Merek", _merkController),
        _buildTextField("Jenis", _jenisController),
        _buildTextField("Plat Nomor", _platController),
        _buildTextField("No. Rangka", _rangkaController),
        _buildTextField("No. Mesin", _mesinController),
        _buildTextField("Pemilik", _pemilikController),
        _buildTextField("Tahun Pembelian", _tahunController),
        _buildTextField(
          "Harga Kendaraan",
          _hargaKendaraanController,
          isNumber: true,
        ),
      ];
    } else if (_policy!.category == 'jiwa') {
      return [
        _buildTextField(
          "Jumlah Tanggungan",
          _tanggunganController,
          isNumber: true,
        ),
        _isEditing
            ? DropdownButtonFormField<String>(
                value: _maritalStatus,
                decoration: const InputDecoration(
                  labelText: "Status Pernikahan",
                ),
                items: ['belum menikah', 'menikah', 'cerai']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _maritalStatus = v!),
              )
            : _buildReadOnlyField("Status Pernikahan", _maritalStatus),
      ];
    } else if (_policy!.category == 'kesehatan') {
      return [
        SwitchListTile(
          title: const Text("Diabetes"),
          value: _diabetes,
          onChanged: _isEditing ? (v) => setState(() => _diabetes = v) : null,
        ),
        SwitchListTile(
          title: const Text("Merokok"),
          value: _merokok,
          onChanged: _isEditing ? (v) => setState(() => _merokok = v) : null,
        ),
        SwitchListTile(
          title: const Text("Hipertensi"),
          value: _hipertensi,
          onChanged: _isEditing ? (v) => setState(() => _hipertensi = v) : null,
        ),
      ];
    }
    return [const Text("Tidak ada detail tambahan")];
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    if (!_isEditing) {
      return _buildReadOnlyField(label, controller.text);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusReasonInput() {
    if (!_isEditing) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _statusReasonController.text.isEmpty
              ? 'Tidak ada alasan'
              : _statusReasonController.text,
          style: TextStyle(
            fontSize: 13,
            color: _statusReasonController.text.isEmpty
                ? Colors.grey.shade500
                : Colors.red.shade600,
            fontStyle: _statusReasonController.text.isEmpty
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
      );
    }

    return TextField(
      controller: _statusReasonController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Alasan Status",
        hintText: "Masukkan alasan pembatalan/inaktivasi",
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
