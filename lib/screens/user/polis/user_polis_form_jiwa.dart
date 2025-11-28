import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_polis_form.dart';
import '../../../widgets/user/polis/user_polis_form_cards.dart';
import '../../../widgets/user/polis/user_polis_form_fields.dart';

class JiwaPolisForm extends BasePolisForm {
  const JiwaPolisForm({
    super.key,
    required super.productId,
    required super.productName,
  }) : super(productType: 'Jiwa');

  @override
  State<JiwaPolisForm> createState() => _JiwaPolisFormState();
}

class _JiwaPolisFormState extends BasePolisFormState<JiwaPolisForm> {
  final _jumlahTanggunganController = TextEditingController();
  String _statusPernikahan = 'belum menikah';
  double _estimatedPremium = 0;

  @override
  void initState() {
    super.initState();
    _jumlahTanggunganController.addListener(_calculateEstimation);
  }

  @override
  void disposeControllers() {
    _jumlahTanggunganController.dispose();
  }

  void _calculateEstimation() {
    if (!isPremiumLoaded) return;

    double base = basePremium;
    int tanggungan = int.tryParse(_jumlahTanggunganController.text) ?? 0;

    double extra = tanggungan * (base * 0.05);

    if (_statusPernikahan == 'menikah') {
      extra += base * 0.02;
    }

    setState(() {
      _estimatedPremium = base + extra;
    });
  }

  @override
  String getFormTitle() => "Form Polis Jiwa";

  @override
  Map<String, dynamic> buildDetailPayload() {
    return {
      'jiwa': {
        'jumlahTanggungan': int.parse(_jumlahTanggunganController.text),
        'statusPernikahan': _statusPernikahan,
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
        "Informasi Keluarga",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade900,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        "Data ini diperlukan untuk menentukan besaran perlindungan",
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 24),

      MaritalStatusSelector(
        value: _statusPernikahan,
        onChanged: (value) {
          setState(() {
            _statusPernikahan = value!;
            _calculateEstimation();
          });
        },
      ),

      const SizedBox(height: 20),

      CustomTextField(
        controller: _jumlahTanggunganController,
        label: "Jumlah Tanggungan",
        hint: "Contoh: 3",
        icon: Icons.people,
        keyboardType: TextInputType.number,
        suffixText: "orang",
        helperText: "Jumlah anggota keluarga yang menjadi tanggungan Anda",
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Masukkan jumlah tanggungan';
          }
          return null;
        },
      ),

      const SizedBox(height: 24),

      const InfoCard.tip(
        title: "Tentang Tanggungan",
        message:
            "Tanggungan adalah anggota keluarga yang bergantung pada penghasilan Anda, seperti pasangan, anak, atau orang tua yang Anda tanggung.",
      ),

      const SizedBox(height: 20),

      MaritalStatusInfoCard(status: _statusPernikahan),

      const SizedBox(height: 24),

      EstimationCard(amount: _estimatedPremium),
    ];
  }
}
