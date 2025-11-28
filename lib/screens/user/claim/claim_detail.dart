import 'package:flutter/material.dart';
import 'claim_wait.dart';
import '../../../models/product_model.dart'; // ...added import...

class ClaimDetail extends StatefulWidget {
  // Data polis yang dilempar dari halaman sebelumnya (Server Data)
  final dynamic product;

  const ClaimDetail({super.key, required this.product});

  @override
  State<ClaimDetail> createState() => _ClaimDetailState();
}

class _ClaimDetailState extends State<ClaimDetail> {
  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _polisIdController;
  late TextEditingController _jumlahKlaimController;
  late TextEditingController _deskripsiController;

  @override
  void initState() {
    super.initState();
    _initializeFormState();
  }

  void _initializeFormState() {
    _polisIdController = TextEditingController();
    _jumlahKlaimController = TextEditingController();
    _deskripsiController = TextEditingController();

    if (widget.product != null) {
      // Jika ProductModel
      if (widget.product is ProductModel) {
        final ProductModel p = widget.product as ProductModel;
        _polisIdController.text = p.id ?? '';
      } else if (widget.product is Map) {
        final Map prod = widget.product as Map;
        _polisIdController.text =
            prod['_id'] ?? prod['id'] ?? prod['policyId'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _polisIdController.dispose();
    _jumlahKlaimController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _prosesPengajuan() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isChecked) {
        // 1. Siapkan data sesuai skema Backend (klaimController.js)
        // Parse jumlah klaim ke Integer karena model mongoose menggunakan Number
        final int jumlahKlaim =
            int.tryParse(
              _jumlahKlaimController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0;

        final klaimData = {
          'polisId': _polisIdController.text, // String (ObjectId)
          'jumlahKlaim': jumlahKlaim, // Number
          'deskripsi': _deskripsiController.text, // String
        };

        // TODO: Panggil fungsi API/Service Anda di sini dan lempar `klaimData`
        print('Data Siap Dikirim ke Server: $klaimData');

        // Simulasi sukses & Navigasi ke halaman tunggu
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PengajuanKlaimBerhasilScreen(),
          ),
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

  // Helper untuk menentukan gambar banner berdasarkan tipe polis
  String _getBannerAsset(String? tipe) {
    if (tipe == null) return 'assets/PayKlaim/AsuransiMobil.png';
    final lowerTipe = tipe.toLowerCase();

    if (lowerTipe.contains('kesehatan')) {
      return 'assets/PayKlaim/AsuransiKesehatan.png';
    } else if (lowerTipe.contains('jiwa')) {
      return 'assets/PayKlaim/AsuransiJiwa.png';
    } else {
      return 'assets/PayKlaim/AsuransiMobil.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan tipe produk dan nama produk dengan aman untuk kedua tipe input
    String productType = 'kendaraan';
    String productName = 'Produk';

    final p = widget.product;
    if (p != null) {
      if (p is ProductModel) {
        productType = p.tipe ?? productType;
        productName = p.namaProduk ?? productName;
      } else if (p is Map) {
        final Map mp = p as Map;
        if (mp['productId'] is Map) {
          productType =
              mp['productId']['tipe'] ??
              mp['productId']['jenis'] ??
              productType;
          productName = mp['productId']['namaProduk'] ?? productName;
        } else {
          productType = mp['tipe'] ?? mp['jenis'] ?? productType;
          productName = mp['namaProduk'] ?? mp['nama_produk'] ?? productName;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Klaim $productName',
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
                  // Banner Image
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(_getBannerAsset(productType)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Form Content
                  _buildFormContent(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Data Klaim"),

        // Field 1: Polis ID (Read Only agar user tidak mengubah ID unik dari server)
        _buildTextFormField(
          "ID Polis",
          _polisIdController,
          "ID Polis",
          isRequired: true,
          readOnly: true,
        ),
        const SizedBox(height: 16),

        // Field 2: Jumlah Klaim
        _buildTextFormField(
          "Jumlah Klaim (Rp)",
          _jumlahKlaimController,
          "0",
          keyboardType: TextInputType.number,
          isRequired: true,
        ),
        const SizedBox(height: 16),

        // Field 3: Deskripsi
        _buildTextFormField(
          "Deskripsi Kejadian",
          _deskripsiController,
          "Ceritakan detail kejadian...",
          maxLines: 5,
          isRequired: true,
        ),
        const SizedBox(height: 24),

        _buildInfoBox(),
      ],
    );
  }

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

  Widget _buildTextFormField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly ? Colors.grey[700] : Colors.black,
            fontWeight: readOnly ? FontWeight.w500 : FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[200] : null,
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
            if (isRequired && (value == null || value.isEmpty)) {
              return '$label tidak boleh kosong';
            }
            // Validasi khusus angka untuk Jumlah Klaim
            if (label.contains('Jumlah') && value != null) {
              final number = int.tryParse(
                value.replaceAll(RegExp(r'[^0-9]'), ''),
              );
              if (number == null || number <= 0) {
                return 'Masukkan nominal yang valid';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Info Klaim',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan deskripsi kejadian ditulis dengan jelas. Data klaim akan diverifikasi oleh admin dalam 1-3 hari kerja.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[800],
              height: 1.4,
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
            // Agreement Checkbox
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
                    'Saya menyatakan data klaim ini benar dan valid sesuai kondisi sebenarnya.',
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

            // Tombol Kirim Pengajuan
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: _prosesPengajuan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked ? Colors.green : Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: _isChecked ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text(
                  'Kirim Pengajuan',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
