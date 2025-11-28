import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_polis_form.dart';
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
  final _merekController = TextEditingController();
  final _umurKendaraanController = TextEditingController();
  final _hargaKendaraanController = TextEditingController();

  @override
  void disposeControllers() {
    _merekController.dispose();
    _umurKendaraanController.dispose();
    _hargaKendaraanController.dispose();
  }

  @override
  String getFormTitle() => "Form Polis Kendaraan";

  @override
  Map<String, dynamic> buildDetailPayload() {
    return {
      'kendaraan': {
        'merek': _merekController.text.trim(),
        'umurKendaraan': int.parse(_umurKendaraanController.text),
        'hargaKendaraan': int.parse(
          _hargaKendaraanController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ),
      },
    };
  }

  @override
  List<Widget> buildFormFields() {
    return [
      const Divider(height: 32),

      Text(
        "Detail Kendaraan",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
      const SizedBox(height: 16),

      CustomTextField(
        controller: _merekController,
        label: "Merek Kendaraan",
        hint: "Contoh: Toyota Avanza, Honda Beat",
        icon: Icons.branding_watermark,
        textCapitalization: TextCapitalization.words,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Masukkan merek kendaraan';
          }
          if (value.trim().length < 2) {
            return 'Merek minimal 2 karakter';
          }
          return null;
        },
      ),

      const SizedBox(height: 16),

      CustomTextField(
        controller: _umurKendaraanController,
        label: "Umur Kendaraan (tahun)",
        hint: "Contoh: 2",
        icon: Icons.calendar_today,
        keyboardType: TextInputType.number,
        suffixText: "tahun",
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Masukkan umur kendaraan';
          }
          final age = int.tryParse(value);
          if (age == null) {
            return 'Masukkan angka yang valid';
          }
          if (age < 0) {
            return 'Umur tidak boleh negatif';
          }
          if (age > 30) {
            return 'Umur kendaraan maksimal 30 tahun';
          }
          return null;
        },
      ),

      const SizedBox(height: 16),

      CustomTextField(
        controller: _hargaKendaraanController,
        label: "Harga Kendaraan",
        hint: "Contoh: 200000000",
        icon: Icons.payments,
        keyboardType: TextInputType.number,
        prefixText: "Rp ",
        helperText: "Harga kendaraan saat ini atau estimasi",
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Masukkan harga kendaraan';
          }
          final price = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
          if (price == null) {
            return 'Masukkan angka yang valid';
          }
          if (price < 5000000) {
            return 'Harga minimal Rp 5.000.000';
          }
          if (price > 10000000000) {
            return 'Harga maksimal Rp 10.000.000.000';
          }
          return null;
        },
      ),
    ];
  }
}
