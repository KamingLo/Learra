import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/api_service.dart';
import '../../../../services/session_service.dart';
import '../../../widgets/user/polis/user_polis_form_cards.dart';
import '../../../widgets/user/polis/user_polis_form_fields.dart';
import 'user_polis_screen.dart';

abstract class BasePolisForm extends StatefulWidget {
  final String productId;
  final String productName;
  final String productType;

  const BasePolisForm({
    super.key,
    required this.productId,
    required this.productName,
    required this.productType,
  });
}

abstract class BasePolisFormState<T extends BasePolisForm> extends State<T> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _endingDateController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _endingDateController.dispose();
    disposeControllers();
    super.dispose();
  }

  void disposeControllers();

  Map<String, dynamic> buildDetailPayload();

  List<Widget> buildFormFields();

  String getFormTitle();

  Future<void> selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime cleanNow = DateTime(now.year, now.month, now.day);

    final DateTime tomorrow = cleanNow.add(const Duration(days: 1));
    final DateTime nextYear = cleanNow.add(const Duration(days: 365));
    final DateTime maxDate = cleanNow.add(const Duration(days: 3650));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: nextYear,
      firstDate: tomorrow,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endingDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<String?> _getUserId() async {
    final sessionId = await SessionService.getCurrentId();
    if (sessionId != null && sessionId.isNotEmpty) {
      return sessionId;
    }

    try {
      final response = await _apiService.get('/api/user/me');
      if (response is Map && response.containsKey('id')) {
        return response['id']?.toString();
      }
      if (response is Map && response.containsKey('_id')) {
        return response['_id']?.toString();
      }
    } catch (_) {}
    return null;
  }

  Future<void> createPolis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? userId = await _getUserId();

      if (userId == null) {
        throw Exception("User ID tidak ditemukan. Silakan login ulang.");
      }

      Map<String, dynamic> requestBody = {
        'userId': userId,
        'productId': widget.productId,
        'endingDate': _endingDateController.text,
        'detail': buildDetailPayload(),
      };

      final response = await _apiService.post('/polis', body: requestBody);

      if (!mounted) return;

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Gagal membuat polis');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Polis berhasil dibuat!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PolicyScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          getFormTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),

        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProductInfoCard(
                productName: widget.productName,
                productType: widget.productType,
              ),

              const SizedBox(height: 24),

              if (_errorMessage != null)
                ErrorMessageCard(message: _errorMessage!),

              FormSectionCard(
                title: "Informasi Polis",
                children: [
                  CustomDateField(
                    controller: _endingDateController,
                    label: "Tanggal Berakhir Polis",
                    hint: "Pilih tanggal berakhir",
                    onTap: selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih tanggal berakhir polis';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  ...buildFormFields(),
                ],
              ),

              const SizedBox(height: 30),
              SubmitButton(
                label: "Buat Polis",
                isLoading: _isLoading,
                onPressed: createPolis,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
