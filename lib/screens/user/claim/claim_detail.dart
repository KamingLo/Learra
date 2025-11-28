import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import '../../../services/api_service.dart';
import 'claim_wait.dart';
import 'dart:math';

class ClaimDetail extends StatefulWidget {
  final dynamic initialData;

  const ClaimDetail({super.key, this.initialData});

  @override
  State<ClaimDetail> createState() => _ClaimDetailState();
}

class _ClaimDetailState extends State<ClaimDetail> {
  bool _isChecked = false;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final api = ApiService();

  late TextEditingController _jumlahKlaimController;
  late TextEditingController _deskripsiController;
  late TextEditingController _namaRekeningController;
  late TextEditingController _noRekeningController;

  List<dynamic> _polisList = [];
  String? _selectedPolisId;
  bool _loadingPolis = true;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _initializeFormState();
    _fetchUserPolis();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
  }

  void _initializeFormState() {
    _jumlahKlaimController = TextEditingController();
    _deskripsiController = TextEditingController();
    _namaRekeningController = TextEditingController();
    _noRekeningController = TextEditingController();

    if (widget.initialData != null) {
      _selectedPolisId = widget.initialData is Map
          ? widget.initialData['_id'] ??
                widget.initialData['id'] ??
                widget.initialData['polisId']
          : null;
    }
  }

  Future<void> _fetchUserPolis() async {
    try {
      final res = await api.get('/user/polis');

      List<dynamic> rawList = [];
      if (res is Map) {
        if (res.containsKey('data') && res['data'] is List) {
          rawList = res['data'];
        } else if (res.containsKey('polis') && res['polis'] is List) {
          rawList = res['polis'];
        }
      } else if (res is List) {
        rawList = res;
      }

      final active = rawList.where((p) {
        if (p is! Map) return false;
        final s = p['status']?.toString().toLowerCase().trim() ?? '';
        return s == 'aktif';
      }).toList();

      setState(() {
        _polisList = active;
        _loadingPolis = false;

        if (_selectedPolisId != null) {
          final found = _polisList.firstWhere(
            (polis) => polis['_id'] == _selectedPolisId,
            orElse: () => null,
          );
          _selectedPolisId = found?['_id'];
        } else if (_polisList.isNotEmpty) {
          _selectedPolisId = _polisList[0]['_id'];
        }
      });
    } catch (e) {
      setState(() => _loadingPolis = false);
      if (mounted) {
        _showSnackBar('Gagal memuat polis: $e', Colors.red);
      }
    }
  }

  String _getBannerAsset() {
    const List<String> availableAssets = [
      'assets/PayKlaim/AsuransiKesehatan.png',
      'assets/PayKlaim/AsuransiJiwa.png',
      'assets/PayKlaim/AsuransiMobil.png',
    ];

    final random = Random();
    final int randomIndex = random.nextInt(availableAssets.length);

    return availableAssets[randomIndex];
  }

  String _getPolisNumber(dynamic polis) {
    return polis['policyNumber']?.toString() ??
        polis['nomorPolis']?.toString() ??
        polis['_id']?.toString() ??
        'Tidak tersedia';
  }

  String _getProductName(dynamic polis) {
    try {
      if (polis['productId'] != null) {
        if (polis['productId'] is Map) {
          return polis['productId']['name']?.toString() ??
              polis['productId']['namaProduk']?.toString() ??
              'Produk';
        }
      }
      return 'Produk';
    } catch (e) {
      return 'Produk';
    }
  }

  Future<void> _prosesPengajuan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_isChecked) {
      _showSnackBar('Harap centang persetujuan terlebih dahulu', Colors.orange);
      return;
    }

    if (_selectedPolisId == null) {
      _showSnackBar('Pilih polis terlebih dahulu', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    final jumlahKlaim =
        int.tryParse(
          _jumlahKlaimController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    if (jumlahKlaim <= 0) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Jumlah klaim harus lebih dari 0', Colors.orange);
      return;
    }

    final klaimData = {
      'polisId': _selectedPolisId,
      'jumlahKlaim': jumlahKlaim,
      'deskripsi': _deskripsiController.text,
      'namaRekening': _namaRekeningController.text,
      'noRekening': _noRekeningController.text,
    };

    try {
      await api.post('/klaim', body: klaimData);

      setState(() => _isSubmitting = false);

      final selectedPolis = _polisList.firstWhere(
        (p) => p['_id'] == _selectedPolisId,
        orElse: () => null,
      );

      final dataForWaitScreen = {
        'jumlahKlaim': jumlahKlaim,
        'deskripsi': _deskripsiController.text,
        'polis': selectedPolis,
      };

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClaimWaitScreen(klaimData: dataForWaitScreen),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Gagal mengajukan klaim: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    _jumlahKlaimController.dispose();
    _deskripsiController.dispose();
    _namaRekeningController.dispose();
    _noRekeningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final randomBannerPath = _getBannerAsset();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ajukan Klaim',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 180.0),
            child: _loadingPolis
                ? const Center(child: CircularProgressIndicator())
                : _polisList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada polis aktif',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Polis Anda tidak tersedia untuk mengajukan klaim',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            randomBannerPath,
                            fit: BoxFit.cover,
                            height: 90.0,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 90.0,
                                color: const Color(0xFFE8F5E9),
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      _buildForm(),
                    ],
                  ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Pilih Polis"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              value: _selectedPolisId,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
              onChanged: (value) {
                setState(() => _selectedPolisId = value);
              },
              items: _polisList.map<DropdownMenuItem<String>>((polis) {
                return DropdownMenuItem<String>(
                  value: polis['_id'],
                  child: Text(
                    '${_getProductName(polis)} - ${_getPolisNumber(polis)}',
                    style: const TextStyle(fontSize: 13.0),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24.0),

          if (_selectedPolisId != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Informasi Polis"),
                _buildInfoCard([
                  {
                    'label': 'Produk',
                    'value': _getProductName(
                      _polisList.firstWhere(
                        (p) => p['_id'] == _selectedPolisId,
                        orElse: () => {},
                      ),
                    ),
                  },
                  {
                    'label': 'Nomor Polis',
                    'value': _getPolisNumber(
                      _polisList.firstWhere(
                        (p) => p['_id'] == _selectedPolisId,
                        orElse: () => {},
                      ),
                    ),
                  },
                ]),
                const SizedBox(height: 24.0),
              ],
            ),

          _buildSectionTitle("Jumlah Klaim"),
          TextFormField(
            controller: _jumlahKlaimController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah klaim',
              prefixIcon: Icon(
                Icons.attach_money,
                color: Colors.green.shade700,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah klaim harus diisi';
              }
              if (int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ==
                  null) {
                return 'Jumlah klaim harus berupa angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),

          _buildSectionTitle("Nama Pemilik Rekening"),
          TextFormField(
            controller: _namaRekeningController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Masukkan nama pemilik rekening',
              prefixIcon: Icon(
                Icons.person_outline,
                color: Colors.green.shade700,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama pemilik rekening harus diisi';
              }
              if (value.length < 3) {
                return 'Nama minimal 3 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),

          _buildSectionTitle("Nomor Rekening"),
          TextFormField(
            controller: _noRekeningController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan nomor rekening',
              prefixIcon: Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.green.shade700,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor rekening harus diisi';
              }
              if (value.length < 8) {
                return 'Nomor rekening minimal 8 digit';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Nomor rekening harus berupa angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),

          _buildSectionTitle("Deskripsi Kejadian"),
          TextFormField(
            controller: _deskripsiController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Jelaskan kejadian secara detail...',
              prefixIcon: Icon(
                Icons.description_outlined,
                color: Colors.green.shade700,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Deskripsi harus diisi';
              }
              if (value.length < 10) {
                return 'Deskripsi minimal 10 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Berikan deskripsi yang lengkap untuk memudahkan verifikasi',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      item['value']!,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20.0,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, -2),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() => _isChecked = value ?? false);
                      },
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                const Expanded(
                  child: Text(
                    'Dengan mengajukan klaim ini, saya menyatakan telah memahami dan menyetujui syarat & ketentuan layanan, termasuk kebijakan perlindungan data pribadi.',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: _isSubmitting || _polisList.isEmpty
                    ? null
                    : _prosesPengajuan,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isChecked && _polisList.isNotEmpty && !_isSubmitting
                      ? Colors.green
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation:
                      _isChecked && _polisList.isNotEmpty && !_isSubmitting
                      ? 4
                      : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _polisList.isEmpty
                            ? 'Tidak Ada Polis Aktif'
                            : 'Kirim Pengajuan',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
