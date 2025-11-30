import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_polis_form.dart';
import '../../../widgets/user/polis/user_polis_form_cards.dart';
import '../../../widgets/user/polis/user_polis_form_fields.dart';

class KendaraanPolisForm extends BasePolisForm {
  const KendaraanPolisForm({
    super.key,
    required super.productId,
    required super.productName,
  }) : super(productType: 'Kendaraan');

  @override
  State<KendaraanPolisForm> createState() => _KendaraanPolisFormState();
}

class _KendaraanPolisFormState extends BasePolisFormState<KendaraanPolisForm> {
  final _merkController = TextEditingController();
  final _jenisController = TextEditingController();
  final _nopolController = TextEditingController();
  final _rangkaController = TextEditingController();
  final _mesinController = TextEditingController();
  final _pemilikController = TextEditingController();
  final _tglBeliController = TextEditingController();
  final _hargaKendaraanController = TextEditingController();

  double _estimatedPremium = 0;

  @override
  void initState() {
    super.initState();
    _tglBeliController.addListener(_calculateEstimation);
    _hargaKendaraanController.addListener(_calculateEstimation);
  }

  @override
  void disposeControllers() {
    _merkController.dispose();
    _jenisController.dispose();
    _nopolController.dispose();
    _rangkaController.dispose();
    _mesinController.dispose();
    _pemilikController.dispose();
    _tglBeliController.dispose();
    _hargaKendaraanController.dispose();
  }

  void _calculateEstimation() {
    if (!isPremiumLoaded) return;

    double base = basePremium;
    double vehiclePrice =
        double.tryParse(
          _hargaKendaraanController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    int age = 0;
    if (_tglBeliController.text.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(_tglBeliController.text);
        age = DateTime.now().year - date.year;
        if (age < 0) age = 0;
      } catch (_) {}
    }

    double ageFactor = (age * base) / 12;
    double priceFactor = (vehiclePrice * 0.002);

    setState(() {
      _estimatedPremium = base + ageFactor + priceFactor;
    });
  }

  Future<void> _selectPurchaseDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green.shade700,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tglBeliController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _calculateEstimation();
    }
  }

  @override
  String getFormTitle() => "Form Polis Kendaraan";

  @override
  Map<String, dynamic> buildDetailPayload() {
    return {
      'kendaraan': {
        'merek': _merkController.text.trim(),
        'jenisKendaraan': _jenisController.text.trim(),
        'nomorKendaraan': _nopolController.text.trim().toUpperCase(),
        'nomorRangka': _rangkaController.text.trim().toUpperCase(),
        'nomorMesin': _mesinController.text.trim().toUpperCase(),
        'namaPemilik': _pemilikController.text.trim(),
        'umurKendaraan': _tglBeliController.text,
        'hargaKendaraan': int.parse(
          _hargaKendaraanController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ),
      },
    };
  }

  @override
  List<Widget> buildFormFields() {
    if (isPremiumLoaded && _estimatedPremium == 0 && basePremium > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _calculateEstimation(),
      );
    }

    return [
      const SizedBox(height: 8),

      Text(
        "Detail Kendaraan",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade900,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        "Lengkapi data kendaraan sesuai STNK/BPKB",
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 24),

      CustomTextField(
        controller: _merkController,
        label: "Merk Kendaraan",
        hint: "Contoh: Toyota, Honda",
        icon: Icons.branding_watermark,
        textCapitalization: TextCapitalization.words,
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
      ),
      const SizedBox(height: 16),

      CustomTextField(
        controller: _jenisController,
        label: "Jenis/Model Kendaraan",
        hint: "Contoh: Avanza G, Jazz RS",
        icon: Icons.directions_car,
        textCapitalization: TextCapitalization.words,
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
      ),
      const SizedBox(height: 16),

      CustomTextField(
        controller: _nopolController,
        label: "Nomor Polisi (Plat)",
        hint: "Contoh: B 1234 ABC",
        icon: Icons.pin_outlined,
        textCapitalization: TextCapitalization.characters,
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
      ),
      const SizedBox(height: 16),

      CustomTextField(
        controller: _rangkaController,
        label: "Nomor Rangka",
        hint: "Lihat di STNK",
        icon: Icons.qr_code,
        textCapitalization: TextCapitalization.characters,
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
      ),
      const SizedBox(height: 16),

      CustomTextField(
        controller: _mesinController,
        label: "Nomor Mesin",
        hint: "Lihat di STNK",
        icon: Icons.settings_suggest,
        textCapitalization: TextCapitalization.characters,
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
      ),
      const SizedBox(height: 16),

      CustomTextField(
        controller: _pemilikController,
        label: "Nama Pemilik (Sesuai STNK)",
        hint: "Nama lengkap pemilik kendaraan",
        icon: Icons.person_outline,
        textCapitalization: TextCapitalization.words,
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
      ),
      const SizedBox(height: 16),

      CustomDateField(
        controller: _tglBeliController,
        label: "Tanggal pembelian mobil",
        hint: "Pilih tanggal",
        onTap: _selectPurchaseDate,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Wajib diisi' : null,
      ),
      const SizedBox(height: 16),

      CustomTextField(
        controller: _hargaKendaraanController,
        label: "Harga Pasar Kendaraan",
        hint: "Contoh: 200000000",
        icon: Icons.payments,
        keyboardType: TextInputType.number,
        prefixText: "Rp ",
        helperText: "Estimasi harga jual saat ini",
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Wajib diisi';
          return null;
        },
      ),

      const SizedBox(height: 24),

      const InfoCard.tip(
        title: "Tentang Harga Pasar",
        message:
            "Harga pasar adalah estimasi nilai kendaraan saat ini. Nilai ini akan digunakan sebagai dasar perhitungan premi asuransi Anda.",
      ),

      const SizedBox(height: 24),

      EstimationCard(amount: _estimatedPremium),
    ];
  }
}
