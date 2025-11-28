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

  @override
  void disposeControllers() {
    _jumlahTanggunganController.dispose();
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
    return [
      const Divider(height: 32),

      Text(
        "Informasi Keluarga",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        "Data ini diperlukan untuk menentukan besaran perlindungan",
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 16),

      MaritalStatusSelector(
        value: _statusPernikahan,
        onChanged: (value) {
          setState(() {
            _statusPernikahan = value!;
          });
        },
      ),

      const SizedBox(height: 16),

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
          final count = int.tryParse(value);
          if (count == null) {
            return 'Masukkan angka yang valid';
          }
          if (count < 0) {
            return 'Jumlah tidak boleh negatif';
          }
          if (count > 20) {
            return 'Jumlah tanggungan maksimal 20 orang';
          }
          return null;
        },
      ),

      const SizedBox(height: 20),

      const InfoCard.tip(
        title: "Tentang Tanggungan",
        message:
            "Tanggungan adalah anggota keluarga yang bergantung pada penghasilan Anda, seperti pasangan, anak, atau orang tua yang Anda tanggung.",
      ),

      const SizedBox(height: 16),

      MaritalStatusInfoCard(status: _statusPernikahan),
    ];
  }
}
