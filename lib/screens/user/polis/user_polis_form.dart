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

  double basePremium = 0;
  bool isPremiumLoaded = false;

  bool _isLoading = false;
  String? _errorMessage;

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
