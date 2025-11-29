import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../models/product_model.dart';
import '../../../services/api_service.dart';
import 'payment_done.dart';
import 'dart:math';

class PaymentDetail extends StatefulWidget {
  final ProductModel product;
  final String? policyId;
  final String? userId;
  final String? policyNumber;
  final bool isPerpanjangan;

  const PaymentDetail({
    super.key,
    required this.product,
    this.policyId,
    this.userId,
    this.policyNumber,
    this.isPerpanjangan = false,
  });

  @override
  State<PaymentDetail> createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
  bool _isChecked = false;
  bool _isLoading = false;
  String _selectedPaymentMethod = 'bca';

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
  }

  final ApiService _apiService = ApiService();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'bca',
      'name': 'Bank BCA',
      'icon': Icons.account_balance,
      'description': 'Transfer via Bank Central Asia',
      'color': const Color(0xFF003D79),
      'accountNumber': '1234567890',
      'accountName': 'PT Learra Insurance',
    },
    {
      'id': 'mandiri',
      'name': 'Bank Mandiri',
      'icon': Icons.account_balance,
      'description': 'Transfer via Bank Mandiri',
      'color': const Color(0xFF003D79),
      'accountNumber': '9876543210',
      'accountName': 'PT Learra Insurance',
    },
  ];

  Future<void> _createPembayaran() async {
    if (!_isChecked) {
      _showSnackBar('Harap centang persetujuan terlebih dahulu', Colors.orange);
      return;
    }

    _showPolicyNumberConfirmation();
  }

  void _showPolicyNumberConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Harap Perhatian!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pastikan anda memasukan nomor polis anda saat melakukan transfer',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processPembayaran();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Paham',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPembayaran() async {
    if (widget.policyId == null || widget.policyId!.isEmpty) {
      _showSnackBar('Data polis tidak lengkap', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String endpoint = widget.isPerpanjangan
          ? '/payment/perpanjangan'
          : '/payment';

      final policyNumber = widget.policyNumber ?? widget.policyId ?? 'Unknown';

      final response = await _apiService.post(
        endpoint,
        body: {
          'policyId': widget.policyId!,
          'amount': widget.product.premiDasar,
          'method': _selectedPaymentMethod,
        },
      );

      setState(() => _isLoading = false);

      if (response != null) {
        final pembayaran = response['pembayaran'];

        final Map<String, String> policyData = {
          'Nomor Pembayaran':
              pembayaran?['_id']?.toString() ??
              'PY${DateTime.now().millisecondsSinceEpoch}',
          'Nomor Polis': policyNumber,
          'Produk': widget.product.namaProduk,
          'Metode Pembayaran': _getPaymentMethodName(_selectedPaymentMethod),
          'Total Pembayaran': _formatCurrency(
            widget.product.premiDasar.toString(),
          ),
          'Tanggal': DateFormat(
            'd MMMM yyyy HH:mm',
            'id_ID',
          ).format(DateTime.now()),
        };

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDone(data: policyData),
            ),
          );
        }
      } else {
        _showSnackBar('Format response tidak valid', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      String errorMessage = 'Terjadi kesalahan';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      _showSnackBar(errorMessage, Colors.red);
    }
  }

  String _getPaymentMethodName(String id) {
    final method = _paymentMethods.firstWhere(
      (m) => m['id'] == id,
      orElse: () => {'name': 'Bank BCA'},
    );
    return method['name'];
  }

  Map<String, dynamic> _getSelectedMethod() {
    return _paymentMethods.firstWhere(
      (m) => m['id'] == _selectedPaymentMethod,
      orElse: () => _paymentMethods[0],
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
      ),
    );
  }

  String _formatCurrency(String value) {
    final number = double.tryParse(value) ?? 0.0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  String _getBannerAsset() {
    const List<String> availableAssets = [
      'assets/PayKlaim/AsuransiKesehatan.png',
      'assets/PayKlaim/AsuransiJiwa.png',
      'assets/PayKlaim/AsuransiMobil.png',
    ];

    final random = Random();
    final int randomIndex = random.nextInt(availableAssets.length);

    return availableAssets[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    final randomBannerPath = _getBannerAsset();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isPerpanjangan ? 'Perpanjangan' : 'Pembayaran',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 180.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      randomBannerPath,
                      fit: BoxFit.cover,
                      height: 90.0,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 90.0,
                          color: const Color(0xFFE8F5E9),
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                _buildSectionTitle("Informasi Polis"),
                _buildInfoCard([
                  {
                    'label': 'Nomor Polis',
                    'value':
                        widget.policyNumber ??
                        widget.policyId ??
                        'Tidak tersedia',
                  },
                  {'label': 'Produk', 'value': widget.product.namaProduk},
                  {'label': 'Tipe', 'value': widget.product.tipe},
                ]),
                const SizedBox(height: 24.0),

                _buildSectionTitle("Pilih Bank Transfer"),
                ..._paymentMethods.map((method) {
                  return _buildPaymentMethodCard(
                    id: method['id'],
                    name: method['name'],
                    icon: method['icon'],
                    description: method['description'],
                    color: method['color'],
                  );
                }),
                const SizedBox(height: 24.0),

                _buildSectionTitle("Detail Transfer"),
                _buildTransferDetail(),
                const SizedBox(height: 24.0),

                _buildSectionTitle("Perhatian Penting"),
                _buildPolicyNumberWarning(),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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

  Widget _buildInfoCard(List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      item['value']!,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String id,
    required String name,
    required IconData icon,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.green[900] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.green[700] : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferDetail() {
    final selectedMethod = _getSelectedMethod();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Transfer ke rekening berikut:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Bank', selectedMethod['name']),
          const SizedBox(height: 12),
          _buildDetailRow('Nomor Rekening', selectedMethod['accountNumber']),
          const SizedBox(height: 12),
          _buildDetailRow('Atas Nama', selectedMethod['accountName']),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Jumlah Transfer',
            _formatCurrency(widget.product.premiDasar.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyNumberWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Harap Perhatian!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pastikan pada saat melakukan transfer untuk pembayaran, mohon untuk diberikan berita berisikan nomor polis anda! tanpa nomor polis maka pembayaran akan ditolak atau pengembalian dana akan tertahan!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange.shade800,
              height: 1.5,
            ),
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
              color: Colors.black.withValues(alpha: 0.1),
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
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked && !_isLoading
                      ? Colors.green
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: _isChecked && !_isLoading ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Bayar - ${_formatCurrency(widget.product.premiDasar.toString())}',
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
