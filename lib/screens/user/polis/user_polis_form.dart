import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/api_service.dart';
import '../../../../services/session_service.dart';
import '../../../widgets/user/polis/user_polis_form_cards.dart';
import '../../../widgets/user/polis/user_polis_form_fields.dart';
import '../../../widgets/main_navbar.dart';
import 'terms_and_conditions.dart';

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

  double basePremium = 0;
  bool isPremiumLoaded = false;

  bool _isLoading = false;
  String? _errorMessage;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _fetchBasePremium();
  }

  Future<void> _fetchBasePremium() async {
    try {
      final response = await _apiService.get('/produk/${widget.productId}');
      if (mounted && response is Map) {
        final data = response['data'] ?? response;
        setState(() {
          basePremium =
              double.tryParse(data['premiDasar']?.toString() ?? '0') ?? 0;
          isPremiumLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil premi dasar: $e");
    }
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  void disposeControllers();

  Map<String, dynamic> buildDetailPayload();

  List<Widget> buildFormFields();

  String getFormTitle();

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

  Future<void> _showTermsAndConditions() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TermsAndConditionsDialog(),
    );

    if (result == true) {
      setState(() {
        _agreedToTerms = true;
      });
    }
  }

  Future<void> createPolis() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Anda harus menyetujui Syarat & Ketentuan terlebih dahulu',
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

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
        'detail': buildDetailPayload(),
      };

      final response = await _apiService.post('/polis', body: requestBody);

      if (!mounted) return;

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Gagal membuat polis');
      }

      String role = await SessionService.getCurrentRole();

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

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavbar(role: role, initialIndex: 2),
          ),
          (route) => false,
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
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, now.day);
    final formattedEndDate =
        "${nextMonth.day}/${nextMonth.month}/${nextMonth.year}";

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
                title: "Lengkapi Data Polis",
                children: [
                  InfoCard.info(
                    title: "Masa Berlaku Polis",
                    message:
                        "Polis ini akan berlaku selama 1 bulan terhitung sejak hari ini. Tanggal berakhir otomatis: $formattedEndDate",
                  ),

                  ...buildFormFields(),
                ],
              ),

              const SizedBox(height: 30),

              _buildTermsAndConditionsSection(),

              const SizedBox(height: 20),
              SubmitButton(
                label: "Buat Polis",
                isLoading: _isLoading,
                enabled: _agreedToTerms,
                onPressed: createPolis,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _agreedToTerms ? Colors.green.shade300 : Colors.grey.shade200,
          width: _agreedToTerms ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _agreedToTerms
                ? Colors.green.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _agreedToTerms
                      ? Colors.green.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _agreedToTerms ? Icons.check_circle : Icons.shield_outlined,
                  color: _agreedToTerms
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _agreedToTerms
                          ? 'Persetujuan Diterima'
                          : 'Syarat & Ketentuan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _agreedToTerms
                            ? Colors.green.shade900
                            : Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _agreedToTerms
                          ? 'Anda telah menyetujui S&K'
                          : 'Wajib dibaca dan disetujui',
                      style: TextStyle(
                        fontSize: 12,
                        color: _agreedToTerms
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_agreedToTerms)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.green.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Anda telah membaca dan menyetujui seluruh syarat & ketentuan yang berlaku',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _agreedToTerms ? null : _showTermsAndConditions,
              icon: Icon(
                _agreedToTerms ? Icons.check_circle : Icons.article_outlined,
                size: 20,
              ),
              label: Text(
                _agreedToTerms
                    ? 'Sudah Disetujui'
                    : 'Baca & Setujui Syarat & Ketentuan',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _agreedToTerms
                    ? Colors.green.shade100
                    : Colors.green.shade600,
                foregroundColor: _agreedToTerms
                    ? Colors.green.shade700
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: _agreedToTerms ? 0 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (_agreedToTerms)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _agreedToTerms = false;
                  });
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'Batalkan Persetujuan',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
