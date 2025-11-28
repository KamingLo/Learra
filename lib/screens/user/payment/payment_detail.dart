import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/product_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'payment_wait.dart';

class PaymentDetail extends StatefulWidget {
  final ProductModel product;

  const PaymentDetail({super.key, required this.product});

  @override
  State<PaymentDetail> createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
  // --- Common State ---
  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>();
  double _totalBiayaTambahan = 0.0;

  // --- Kesehatan State ---
  late TextEditingController _namaPemegangController;
  String? _limitTahunanValue;
  String? _limitPerKejadianValue;
  String? _kamarPerawatanValue;
  Map<String, Map<String, dynamic>> _coverageKesehatan = {
    'Rawat Inap': {'status': false, 'harga': 700000},
    'Rawat Jalan': {'status': false, 'harga': 50000},
    'Emergency': {'status': false, 'harga': 250000},
    'Operasi / Bedah': {'status': false, 'harga': 10000000},
    'ICU': {'status': false, 'harga': 150000},
    'Medical Check Up': {'status': false, 'harga': 75000},
  };
  Map<String, Map<String, dynamic>> _benefitTambahanKesehatan = {
    'Ambulance': {'status': false, 'harga': 25000},
    'Reimbursement': {'status': false, 'harga': 100000},
    'Telemedicine': {'status': false, 'harga': 35000},
    'Cashless di RS Rekanan': {'status': true, 'harga': 0},
  };

  // --- Jiwa State ---
  late TextEditingController _namaTertanggungController;
  late TextEditingController _umurController;
  String? _jenisPolisValue;
  String? _masaKontrakValue;
  String? _totalUpValue;
  String? _penerimaManfaatValue;
  Map<String, Map<String, dynamic>> _benefitJiwa = {
    'Manfaat Cacat Total Permanen': {'status': false, 'harga': 100000},
    'Manfaat Penyakit Kritis': {'status': true, 'harga': 200000},
    'Waiver Premi': {'status': false, 'harga': 50000},
  };

  // --- Mobil State ---
  late TextEditingController _platNomorController;
  late TextEditingController _nomorRangkaController;
  late TextEditingController _nomorMesinController;
  String? _merkValue;
  String? _modelValue;
  String? _tahunValue;
  String? _jenisPerlindunganValue;
  String? _nilaiPertanggunganValue;
  String? _mobilPenggantiValue;
  List<String> _bengkelRekananValues = [];
  Map<String, Map<String, dynamic>> _coverageMobil = {
    'Tabrakan / Benturan': {'status': false, 'harga': 1000000},
    'Pencurian': {'status': false, 'harga': 500000},
    'Kebakaran': {'status': false, 'harga': 563140},
    'Banjir': {'status': false, 'harga': 75000},
    'Kerusakan Kecil (Baret, penyok)': {'status': false, 'harga': 45000},
    'Kerusakan Besar (tabrakan parah)': {'status': false, 'harga': 2000000},
  };
  Map<String, Map<String, dynamic>> _benefitMobil = {
    'Derek Gratis': {'status': true, 'harga': 0},
    'Perluasan Jaminan Banjir & Gempa': {'status': false, 'harga': 120000},
    'Layanan Darurat 24 Jam': {'status': true, 'harga': 0},
    'Towing & Roadside Assistance': {'status': false, 'harga': 85000},
  };

  // --- Dropdown & Options Data ---
  final List<String> _limitTahunanOptions = [
    '50000000',
    '100000000',
    '150000000',
    '200000000',
    '250000000',
    '300000000',
    '500000000',
    '750000000',
    '1000000000',
    '2000000000',
  ];
  final List<String> _limitPerKejadianOptions = [
    '5000000',
    '10000000',
    '25000000',
    '50000000',
    '75000000',
    '100000000',
  ];
  final List<String> _kamarPerawatanOptions = [
    'VIP',
    'Kelas 1',
    'Kelas 2',
    'Kelas 3',
  ];
  final List<String> _jenisPolisOptions = [
    'Jiwa Berjangka',
    'Jiwa Seumur Hidup',
    'Dwiguna',
  ];
  final List<String> _masaKontrakOptions = [
    '5 Tahun',
    '10 Tahun',
    '15 Tahun',
    '20 Tahun',
  ];
  final List<String> _totalUpOptions = [
    '100000000',
    '250000000',
    '500000000',
    '1000000000',
    '2000000000',
  ];
  final List<String> _penerimaManfaatOptions = [
    'Istri',
    'Anak',
    'Orang Tua',
    'Saudara Kandung',
  ];
  final Map<String, List<String>> _modelOptions = {
    'Honda': ['HRV', 'CRV', 'Brio', 'Civic', 'Accord'],
    'Toyota': ['Avanza', 'Innova', 'Fortuner', 'Rush', 'Yaris'],
    'Suzuki': ['Ertiga', 'XL7', 'Jimny', 'Baleno'],
    'Mitsubishi': ['Pajero Sport', 'Xpander', 'Triton'],
  };
  final List<String> _tahunOptions = List.generate(
    15,
    (i) => (DateTime.now().year - i).toString(),
  );
  final List<String> _jenisPerlindunganOptions = [
    'All Risk (Comprehensive)',
    'Total Loss Only (TLO)',
  ];
  final List<String> _nilaiPertanggunganOptions = List.generate(
    10,
    (i) => ((i + 1) * 50000000).toString(),
  );
  final List<String> _bengkelOptions = [
    'Honda Astra',
    'Mitra Garage',
    'Auto2000',
    'Tunas Toyota',
    'Sun Motor',
  ];
  final List<String> _mobilPenggantiOptions = [
    'Tidak Ada',
    '3 Hari',
    '5 Hari',
    '7 Hari',
  ];

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _initializeFormState();
    _hitungTotalBiayaTambahan();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
  }

  void _initializeFormState() {
    String tipe = widget.product.tipe.toLowerCase();
    if (tipe == 'kesehatan') {
      _namaPemegangController = TextEditingController();
      _limitTahunanValue = '250000000';
      _limitPerKejadianValue = '50000000';
      _kamarPerawatanValue = 'VIP';
    } else if (tipe == 'jiwa') {
      _namaTertanggungController = TextEditingController();
      _umurController = TextEditingController();
      _jenisPolisValue = 'Jiwa Berjangka';
      _masaKontrakValue = '10 Tahun';
      _totalUpValue = '500000000';
      _penerimaManfaatValue = 'Istri';
    } else if (tipe == 'kendaraan') {
      _platNomorController = TextEditingController();
      _nomorRangkaController = TextEditingController();
      _nomorMesinController = TextEditingController();
      _merkValue = 'Honda';
      _modelValue = 'HRV';
      _tahunValue = DateTime.now().year.toString();
      _jenisPerlindunganValue = 'All Risk (Comprehensive)';
      _nilaiPertanggunganValue = '250000000';
      _mobilPenggantiValue = '3 Hari';
      _bengkelRekananValues = ['Honda Astra'];
    }
  }

  @override
  void dispose() {
    String tipe = widget.product.tipe.toLowerCase();
    if (tipe == 'kesehatan') {
      _namaPemegangController.dispose();
    } else if (tipe == 'jiwa') {
      _namaTertanggungController.dispose();
      _umurController.dispose();
    } else if (tipe == 'kendaraan') {
      _platNomorController.dispose();
      _nomorRangkaController.dispose();
      _nomorMesinController.dispose();
    }
    super.dispose();
  }

  void _hitungTotalBiayaTambahan() {
    double total = 0.0;

    // Hitung biaya tambahan berdasarkan tipe produk
    switch (widget.product.tipe.toLowerCase()) {
      case 'kesehatan':
        _coverageKesehatan.forEach((key, value) {
          if (value['status'] == true)
            total += (value['harga'] as int).toDouble();
        });
        _benefitTambahanKesehatan.forEach((key, value) {
          if (value['status'] == true)
            total += (value['harga'] as int).toDouble();
        });
        break;
      case 'jiwa':
        _benefitJiwa.forEach((key, value) {
          if (value['status'] == true)
            total += (value['harga'] as int).toDouble();
        });
        break;
      case 'kendaraan':
        _coverageMobil.forEach((key, value) {
          if (value['status'] == true)
            total += (value['harga'] as int).toDouble();
        });
        _benefitMobil.forEach((key, value) {
          if (value['status'] == true)
            total += (value['harga'] as int).toDouble();
        });
        break;
    }

    setState(() {
      _totalBiayaTambahan = total;
    });
  }

  Map<String, String> _getPolicyData() {
    final Map<String, String> data = {};
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
    final now = DateTime.now();
    final oneYearLater = DateTime(now.year + 1, now.month, now.day);
    final masaAktif =
        "${dateFormat.format(now)} - ${dateFormat.format(oneYearLater)}";

    // Common Data
    data['Nomor Polis'] = _generateNomorPolis(widget.product.tipe);
    data['Masa Aktif'] = masaAktif;

    switch (widget.product.tipe.toLowerCase()) {
      case 'kesehatan':
        data['Nama Pemegang'] = _namaPemegangController.text;
        if (_limitTahunanValue != null) {
          data['Limit Tahunan'] = _formatCurrency(_limitTahunanValue!);
        }
        if (_limitPerKejadianValue != null) {
          data['Limit Per Kejadian'] = _formatCurrency(_limitPerKejadianValue!);
        }
        if (_kamarPerawatanValue != null) {
          data['Kamar Perawatan'] = _kamarPerawatanValue!;
        }
        break;

      case 'jiwa':
        data['Nama Tertanggung'] = _namaTertanggungController.text;
        data['Umur'] = _umurController.text;
        if (_jenisPolisValue != null) {
          data['Jenis Polis'] = _jenisPolisValue!;
        }
        if (_masaKontrakValue != null) {
          data['Masa Kontrak'] = _masaKontrakValue!;
        }
        if (_totalUpValue != null) {
          data['Total UP'] = _formatCurrency(_totalUpValue!);
        }
        if (_penerimaManfaatValue != null) {
          data['Penerima Manfaat'] = _penerimaManfaatValue!;
        }
        break;

      case 'kendaraan':
        data['Plat Nomor'] = _platNomorController.text;
        if (_merkValue != null && _modelValue != null) {
          data['Kendaraan'] = "$_merkValue - $_modelValue";
        }
        if (_tahunValue != null) {
          data['Tahun'] = _tahunValue!;
        }
        data['Nomor Rangka'] = _nomorRangkaController.text;
        data['Nomor Mesin'] = _nomorMesinController.text;
        if (_jenisPerlindunganValue != null) {
          data['Jenis Perlindungan'] = _jenisPerlindunganValue!;
        }
        if (_nilaiPertanggunganValue != null) {
          data['Nilai Pertanggungan'] = _formatCurrency(
            _nilaiPertanggunganValue!,
          );
        }
        if (_bengkelRekananValues.isNotEmpty) {
          data['Bengkel Rekanan'] = _bengkelRekananValues.join(', ');
        }
        if (_mobilPenggantiValue != null) {
          data['Mobil Pengganti'] = _mobilPenggantiValue!;
        }
        break;
    }

    // Financial Data
    data['Premi Dasar'] = _formatCurrency(widget.product.premiDasar.toString());
    if (_totalBiayaTambahan > 0) {
      data['Biaya Tambahan'] = _formatCurrencyFromInt(
        _totalBiayaTambahan.toInt(),
      );
    }
    final total = widget.product.premiDasar + _totalBiayaTambahan;
    data['Total Pembayaran'] = _formatCurrency(total.toString());

    return data;
  }

  void _prosesPembayaran() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isChecked) {
        final data = _getPolicyData();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentWait(data: data)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Harap centang persetujuan terlebih dahulu'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _getBannerAsset(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'kesehatan':
        return 'assets/PayKlaim/AsuransiKesehatan.png';
      case 'jiwa':
        return 'assets/PayKlaim/AsuransiJiwa.png';
      case 'kendaraan':
        return 'assets/PayKlaim/AsuransiMobil.png';
      default:
        return 'assets/PayKlaim/AsuransiMobil.png';
    }
  }

  String _generateNomorPolis(String tipe) {
    final random = Random();
    final number = random.nextInt(900000) + 100000;
    String prefix = "POL";
    switch (tipe.toLowerCase()) {
      case 'kesehatan':
        prefix = "POL-KES";
        break;
      case 'jiwa':
        prefix = "POL-JW";
        break;
      case 'kendaraan':
        prefix = "POL-MBL";
        break;
    }
    return "$prefix-$number";
  }

  String _formatCurrency(String value) {
    final number = double.tryParse(value) ?? 0.0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  String _formatCurrencyFromInt(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // ==================== BOTTOM SHEET METHODS ====================
  void _showBottomSheet({
    required String title,
    required List<String> options,
    required String? currentValue,
    required ValueChanged<String> onSelected,
    bool isCurrency = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = currentValue == option;
                    final isLastItem = index == options.length - 1;

                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            isCurrency ? _formatCurrency(option) : option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected ? Colors.green : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 24,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onSelected(option);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                        ),
                        if (!isLastItem)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[300],
                            indent: 0,
                            endIndent: 0,
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPembayaran = widget.product.premiDasar + _totalBiayaTambahan;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pembayaran ${widget.product.namaProduk}',
          style: const TextStyle(
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
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 180.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(_getBannerAsset(widget.product.tipe)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  _buildFormContent(),
                  const SizedBox(height: 24.0),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Premi Dasar:',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              _formatCurrency(
                                widget.product.premiDasar.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (_totalBiayaTambahan > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Biaya Tambahan:',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                _formatCurrencyFromInt(
                                  _totalBiayaTambahan.toInt(),
                                ),
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran:',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatCurrency(totalPembayaran.toString()),
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF06A900),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
            _buildBottomBar(totalPembayaran),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    switch (widget.product.tipe.toLowerCase()) {
      case 'kesehatan':
        return _buildKesehatanForm();
      case 'jiwa':
        return _buildJiwaForm();
      case 'kendaraan':
        return _buildMobilForm();
      default:
        return Text('Unsupported product type: ${widget.product.tipe}');
    }
  }

  // ==================== KESEHATAN FORM ====================
  Widget _buildKesehatanForm() {
    final now = DateTime.now();
    final oneYearLater = DateTime(now.year + 1, now.month, now.day);
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Data Polis"),
        _buildReadOnlyField(
          "Nomor Polis",
          _generateNomorPolis(widget.product.tipe),
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          "Nama Pemegang",
          _namaPemegangController,
          "Masukkan nama lengkap",
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          "Masa Aktif",
          "${dateFormat.format(now)} - ${dateFormat.format(oneYearLater)}",
        ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Limit Tahunan",
          value: _limitTahunanValue != null
              ? _formatCurrency(_limitTahunanValue!)
              : "Pilih Limit Tahunan",
          onTap: () => _showBottomSheet(
            title: "Pilih Limit Tahunan",
            options: _limitTahunanOptions,
            currentValue: _limitTahunanValue,
            onSelected: (value) {
              setState(() => _limitTahunanValue = value);
            },
            isCurrency: true,
          ),
        ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Limit Per Kejadian",
          value: _limitPerKejadianValue != null
              ? _formatCurrency(_limitPerKejadianValue!)
              : "Pilih Limit Per Kejadian",
          onTap: () => _showBottomSheet(
            title: "Pilih Limit Per Kejadian",
            options: _limitPerKejadianOptions,
            currentValue: _limitPerKejadianValue,
            onSelected: (value) {
              setState(() => _limitPerKejadianValue = value);
            },
            isCurrency: true,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Coverage"),
        _buildCheckboxListWithPrice(_coverageKesehatan),
        const SizedBox(height: 24),
        _buildSectionTitle("Benefit Tambahan"),
        _buildBottomSheetField(
          label: "Kamar Perawatan",
          value: _kamarPerawatanValue ?? "Pilih Kamar Perawatan",
          onTap: () => _showBottomSheet(
            title: "Pilih Kamar Perawatan",
            options: _kamarPerawatanOptions,
            currentValue: _kamarPerawatanValue,
            onSelected: (value) {
              setState(() => _kamarPerawatanValue = value);
            },
          ),
        ),
        _buildCheckboxListWithPrice(_benefitTambahanKesehatan),
      ],
    );
  }

  // ==================== JIWA FORM ====================
  Widget _buildJiwaForm() {
    final now = DateTime.now();
    final oneYearLater = DateTime(now.year + 1, now.month, now.day);
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Data Polis"),
        _buildReadOnlyField(
          "Nomor Polis",
          _generateNomorPolis(widget.product.tipe),
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          "Nama Tertanggung",
          _namaTertanggungController,
          "Masukkan nama lengkap",
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          "Umur",
          _umurController,
          "Contoh: 30",
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Jenis Polis",
          value: _jenisPolisValue ?? "Pilih Jenis Polis",
          onTap: () => _showBottomSheet(
            title: "Pilih Jenis Polis",
            options: _jenisPolisOptions,
            currentValue: _jenisPolisValue,
            onSelected: (value) {
              setState(() => _jenisPolisValue = value);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Masa Kontrak",
          value: _masaKontrakValue ?? "Pilih Masa Kontrak",
          onTap: () => _showBottomSheet(
            title: "Pilih Masa Kontrak",
            options: _masaKontrakOptions,
            currentValue: _masaKontrakValue,
            onSelected: (value) {
              setState(() => _masaKontrakValue = value);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          "Masa Aktif",
          "${dateFormat.format(now)} - ${dateFormat.format(oneYearLater)}",
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Uang Pertanggungan"),
        _buildBottomSheetField(
          label: "Total UP",
          value: _totalUpValue != null
              ? _formatCurrency(_totalUpValue!)
              : "Pilih Total UP",
          onTap: () => _showBottomSheet(
            title: "Pilih Total UP",
            options: _totalUpOptions,
            currentValue: _totalUpValue,
            onSelected: (value) {
              setState(() => _totalUpValue = value);
            },
            isCurrency: true,
          ),
        ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Penerima Manfaat",
          value: _penerimaManfaatValue ?? "Pilih Penerima Manfaat",
          onTap: () => _showBottomSheet(
            title: "Pilih Penerima Manfaat",
            options: _penerimaManfaatOptions,
            currentValue: _penerimaManfaatValue,
            onSelected: (value) {
              setState(() => _penerimaManfaatValue = value);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          "Ketentuan",
          "Dibayarkan jika tertanggung meninggal dunia dalam masa polis.",
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Benefit Tambahan"),
        _buildCheckboxListWithPrice(_benefitJiwa),
      ],
    );
  }

  // ==================== MOBIL FORM ====================
  Widget _buildMobilForm() {
    final now = DateTime.now();
    final oneYearLater = DateTime(now.year + 1, now.month, now.day);
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Data Kendaraan"),
        _buildTextFormField(
          "Plat Nomor",
          _platNomorController,
          "Contoh: B 1234 XYZ",
        ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Merk Kendaraan",
          value: _merkValue ?? "Pilih Merk Kendaraan",
          onTap: () => _showBottomSheet(
            title: "Pilih Merk Kendaraan",
            options: _modelOptions.keys.toList(),
            currentValue: _merkValue,
            onSelected: (value) {
              setState(() {
                _merkValue = value;
                _modelValue = null;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_merkValue != null)
          _buildBottomSheetField(
            label: "Model",
            value: _modelValue ?? "Pilih Model",
            onTap: () => _showBottomSheet(
              title: "Pilih Model",
              options: _modelOptions[_merkValue]!,
              currentValue: _modelValue,
              onSelected: (value) {
                setState(() => _modelValue = value);
              },
            ),
          ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Tahun",
          value: _tahunValue ?? "Pilih Tahun",
          onTap: () => _showBottomSheet(
            title: "Pilih Tahun",
            options: _tahunOptions,
            currentValue: _tahunValue,
            onSelected: (value) {
              setState(() => _tahunValue = value);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          "Nomor Rangka",
          _nomorRangkaController,
          "Masukkan nomor rangka",
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          "Nomor Mesin",
          _nomorMesinController,
          "Masukkan nomor mesin",
        ),
        const SizedBox(height: 24),

        _buildSectionTitle("Data Polis"),
        _buildReadOnlyField(
          "Nomor Polis",
          _generateNomorPolis(widget.product.tipe),
        ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Jenis Perlindungan",
          value: _jenisPerlindunganValue ?? "Pilih Jenis Perlindungan",
          onTap: () => _showBottomSheet(
            title: "Pilih Jenis Perlindungan",
            options: _jenisPerlindunganOptions,
            currentValue: _jenisPerlindunganValue,
            onSelected: (value) {
              setState(() => _jenisPerlindunganValue = value);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          "Masa Aktif",
          "${dateFormat.format(now)} - ${dateFormat.format(oneYearLater)}",
        ),
        const SizedBox(height: 16),
        _buildBottomSheetField(
          label: "Nilai Pertanggungan",
          value: _nilaiPertanggunganValue != null
              ? _formatCurrency(_nilaiPertanggunganValue!)
              : "Pilih Nilai Pertanggungan",
          onTap: () => _showBottomSheet(
            title: "Pilih Nilai Pertanggungan",
            options: _nilaiPertanggunganOptions,
            currentValue: _nilaiPertanggunganValue,
            onSelected: (value) {
              setState(() => _nilaiPertanggunganValue = value);
            },
            isCurrency: true,
          ),
        ),
        const SizedBox(height: 16),
        _buildMultiSelectChip(
          "Bengkel Rekanan",
          _bengkelOptions,
          _bengkelRekananValues,
          (selected) {
            setState(() => _bengkelRekananValues = selected);
          },
        ),
        const SizedBox(height: 24),

        _buildSectionTitle("Coverage"),
        _buildCheckboxListWithPrice(_coverageMobil),
        const SizedBox(height: 24),

        _buildSectionTitle("Benefit Tambahan"),
        _buildBottomSheetField(
          label: "Mobil Pengganti",
          value: _mobilPenggantiValue ?? "Pilih Mobil Pengganti",
          onTap: () => _showBottomSheet(
            title: "Pilih Mobil Pengganti",
            options: _mobilPenggantiOptions,
            currentValue: _mobilPenggantiValue,
            onSelected: (value) {
              setState(() => _mobilPenggantiValue = value);
            },
          ),
        ),
        _buildCheckboxListWithPrice(_benefitMobil),
      ],
    );
  }

  // ==================== COMMON WIDGETS ====================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16.0, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.green),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBottomSheetField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxListWithPrice(Map<String, Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        final harga = value['harga'] as int;
        final isSelected = value['status'] as bool;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: CheckboxListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(key, style: const TextStyle(fontSize: 14)),
                  ),
                  if (harga > 0)
                    Text(
                      _formatCurrencyFromInt(harga),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.green : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              value: isSelected,
              onChanged: (selected) {
                setState(() {
                  value['status'] = selected ?? false;
                  _hitungTotalBiayaTambahan();
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectChip(
    String label,
    List<String> allOptions,
    List<String> selectedOptions,
    ValueChanged<List<String>> onSelectionChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: allOptions.map((option) {
            final isSelected = selectedOptions.contains(option);
            return ChoiceChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                  onSelectionChanged(selectedOptions);
                });
              },
              selectedColor: Colors.green,
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar(double totalPembayaran) {
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
            // Agreement Checkbox - Diperbaiki alignment
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
                    'Dengan melanjutkan pembayaran ini, saya menyatakan telah memahami dan menyetujui syarat & ketentuan layanan, termasuk kebijakan perlindungan data pribadi.',
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

            // Tombol Beli - Sekali Klik
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: _prosesPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked ? Colors.green : Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: _isChecked ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Text(
                  'Beli - ${_formatCurrency(totalPembayaran.toString())}',
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
