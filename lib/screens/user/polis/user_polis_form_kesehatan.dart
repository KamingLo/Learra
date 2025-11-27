import 'package:flutter/material.dart';
import 'user_polis_form.dart';
import '../../../widgets/user/polis/user_polis_form_cards.dart';
import '../../../widgets/user/polis/user_polis_form_fields.dart';

class KesehatanPolisForm extends BasePolisForm {
  const KesehatanPolisForm({
    super.key,
    required super.productId,
    required super.productName,
  }) : super(productType: 'Kesehatan');

  @override
  State<KesehatanPolisForm> createState() => _KesehatanPolisFormState();
}

class _KesehatanPolisFormState extends BasePolisFormState<KesehatanPolisForm> {
  bool _hasDiabetes = false;
  bool _isSmoker = false;
  bool _hasHypertension = false;

  @override
  void disposeControllers() {}

  @override
  String getFormTitle() => "Form Polis Kesehatan";

  @override
  Map<String, dynamic> buildDetailPayload() {
    return {
      'kesehatan': {
        'diabetes': _hasDiabetes,
        'merokok': _isSmoker,
        'hipertensi': _hasHypertension,
      },
    };
  }

  @override
  List<Widget> buildFormFields() {
    return [
      const Divider(height: 32),

      Text(
        "Riwayat Kesehatan",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        "Informasi ini digunakan untuk menghitung premi asuransi Anda",
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 16),

      HealthConditionTile(
        title: "Diabetes",
        subtitle: "Apakah Anda memiliki riwayat diabetes?",
        icon: Icons.medical_services,
        value: _hasDiabetes,
        onChanged: (value) {
          setState(() {
            _hasDiabetes = value;
          });
        },
      ),

      const SizedBox(height: 12),

      HealthConditionTile(
        title: "Merokok",
        subtitle: "Apakah Anda merokok secara rutin?",
        icon: Icons.smoking_rooms,
        value: _isSmoker,
        onChanged: (value) {
          setState(() {
            _isSmoker = value;
          });
        },
      ),

      const SizedBox(height: 12),

      HealthConditionTile(
        title: "Hipertensi",
        subtitle: "Apakah Anda memiliki riwayat tekanan darah tinggi?",
        icon: Icons.favorite,
        value: _hasHypertension,
        onChanged: (value) {
          setState(() {
            _hasHypertension = value;
          });
        },
      ),

      const SizedBox(height: 20),

      const InfoCard.info(
        message:
            "Riwayat kesehatan yang Anda berikan akan mempengaruhi besaran premi asuransi. Harap mengisi dengan jujur.",
      ),
    ];
  }
}
