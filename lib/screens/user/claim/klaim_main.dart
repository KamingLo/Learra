import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengajuan Klaim',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const PengajuanKlaimScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PengajuanKlaimScreen extends StatefulWidget {
  const PengajuanKlaimScreen({super.key});

  @override
  State<PengajuanKlaimScreen> createState() => _PengajuanKlaimScreenState();
}

class _PengajuanKlaimScreenState extends State<PengajuanKlaimScreen> {
  bool _isChecked = false;
  final List<File?> _uploadedImages = List.filled(5, null);
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _namaPolisController = TextEditingController(
    text: 'Asuransi Kendaraan A',
  );
  final TextEditingController _nomorPolisController = TextEditingController(
    text: '#PL-2025-001',
  );
  final TextEditingController _namaPemegangController = TextEditingController(
    text: 'Andi Wijaya',
  );
  final TextEditingController _jumlahKlaimController = TextEditingController(
    text: '15.000.000',
  );
  final TextEditingController _alasanController = TextEditingController(
    text:
        'Pintu bagasi saya copot dibawa oleh angin serta beberapa body saya penyok',
  );

  Future<void> _pickImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _uploadedImages[index] = File(pickedFile.path);
      });
    }
  }

  void _submitClaim() {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap centang persetujuan terlebih dahulu'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan klaim berhasil diproses')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Pengajuan Klaim',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.help_outline, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 180.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/AsuransiMobil2.png',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.grey[300],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Asuransi Mobil Lengkap\ndi Lecarra',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                _buildTextField('Nama Polis:', _namaPolisController),
                const SizedBox(height: 16.0),
                _buildTextField('Nomor Polis:', _nomorPolisController),
                const SizedBox(height: 16.0),
                _buildTextField(
                  'Nama Pemegang Polis:',
                  _namaPemegangController,
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  'Jumlah Klaim:',
                  _jumlahKlaimController,
                  prefix: 'Rp ',
                ),
                const SizedBox(height: 16.0),
                _buildTextArea('Alasan Pengajuan Klaim:', _alasanController),
                const SizedBox(height: 16.0),
                const Text(
                  'Unggah Foto: (max 5)',
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => _pickImage(index),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 64) / 3,
                        height: (MediaQuery.of(context).size.width - 64) / 3,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: _uploadedImages[index] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _uploadedImages[index]!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.add,
                                size: 32,
                                color: Colors.grey,
                              ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isChecked,
                          onChanged: (value) {
                            setState(() => _isChecked = value ?? false);
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Expanded(
                        child: Text(
                          'Dengan melanjutkan pengajuan ini, saya menyatakan telah membaca dan menyetujui syarat & ketentuan layanan yang berlaku.',
                          style: TextStyle(fontSize: 13.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _submitClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isChecked
                          ? Colors.green
                          : Colors.grey[300],
                      foregroundColor: _isChecked
                          ? Colors.white
                          : Colors.grey[600],
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Kirim Pengajuan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14.0, color: Colors.black54),
        ),
        const SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              if (prefix != null)
                Text(
                  prefix,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14.0, color: Colors.black54),
        ),
        const SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _namaPolisController.dispose();
    _nomorPolisController.dispose();
    _namaPemegangController.dispose();
    _jumlahKlaimController.dispose();
    _alasanController.dispose();
    super.dispose();
  }
}