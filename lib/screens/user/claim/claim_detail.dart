// lib/screens/user/claim/claim_detail.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../services/api_service.dart';
import 'claim_wait.dart';

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
      print("Response polis: $res");

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

      // Filter hanya polis yang aktif
      final active = rawList.where((p) {
        if (p is! Map) return false;
        final s = p['status']?.toString().toLowerCase().trim() ?? '';
        return s == 'aktif';
      }).toList();

      print("Polis aktif: ${active.length}");

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
      print("Error fetching polis: $e");
      setState(() => _loadingPolis = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat polis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      // Submit ke backend
      final response = await api.post(
        '/klaim',
        body: klaimData,
      ); // Changed to '/klaim' as per previous analysis

      setState(() => _isSubmitting = false);

      // Cari data polis yang dipilih
      final selectedPolis = _polisList.firstWhere(
        (p) => p['_id'] == _selectedPolisId,
        orElse: () => null,
      );

      // Siapkan data untuk ditampilkan di halaman wait
      final dataForWaitScreen = {
        'jumlahKlaim': jumlahKlaim,
        'deskripsi': _deskripsiController.text,
        'polis': selectedPolis,
      };

      // Navigate ke ClaimWaitScreen
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Klaim'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 200.0),
            child: _loadingPolis
                ? const Center(child: CircularProgressIndicator())
                : _polisList.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada polis aktif yang tersedia untuk klaim.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  )
                : _buildForm(),
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
          const Text(
            'Pilih Polis',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
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
                    style: const TextStyle(fontSize: 14.0),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24.0),
          const Text(
            'Jumlah Klaim',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
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
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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
          const Text(
            'Nama Pemilik Rekening',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
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
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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
          const Text(
            'Nomor Rekening',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
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
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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
          const Text(
            'Deskripsi Kejadian',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
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
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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
        ],
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
              color: Colors.black.withOpacity(0.1),
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
