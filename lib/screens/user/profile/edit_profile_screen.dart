import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // State
  bool _isInitialLoading = true;
  bool _isSaving = false;
  String? _userId = ''; // Variabel untuk menyimpan ID User

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _identityController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _jobController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  // --- 1. AMBIL DATA USER (GET) ---
  Future<void> _fetchUserData() async {
    try {
      final response = await _apiService.get('/user/profile');

      // Cek apakah key 'user' ada sesuai struktur JSON response
      if (response['user'] != null) {
        final data = response['user'];

        setState(() {
          // Simpan ID untuk keperluan Update nanti
          _userId = data['_id'];

          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _identityController.text = data['nomorIdentitas'] ?? '';
          _phoneController.text = data['phone'] ?? '';

          // Parsing Tanggal: Ambil 10 karakter pertama (YYYY-MM-DD)
          String rawDate = data['birthDate'] ?? '';
          if (rawDate.length >= 10) {
            _birthDateController.text = rawDate.substring(0, 10);
          } else {
            _birthDateController.text = rawDate;
          }

          _addressController.text = data['address'] ?? '';
          _jobController.text = data['pekerjaan'] ?? '';
          _salaryController.text = data['rentangGaji'] ?? '';

          _isInitialLoading = false;
        });
      } else {
        throw Exception("Data user tidak ditemukan dalam response");
      }
    } catch (e) {
      setState(() => _isInitialLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal memuat profil: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  // --- 2. UPDATE DATA USER (PUT) ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Pastikan ID sudah didapatkan dari proses GET sebelumnya
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error: ID User tidak ditemukan, silakan refresh."),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Body Request
      final body = {
        "name": _nameController.text,
        "birthDate": _birthDateController.text,
        "address": _addressController.text,
        "pekerjaan": _jobController.text,
        "rentangGaji": _salaryController.text,
      };

      // Gunakan ID di URL Endpoint
      await _apiService.put('/users/$_userId', body: body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Profil berhasil diperbarui"),
            backgroundColor: Colors.green),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal update: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- FUNGSI DATE PICKER ---
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        String formattedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _birthDateController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("Informasi Pribadi"),
                    const SizedBox(height: 10),

                    // Nama (Editable)
                    _buildTextField("Nama Lengkap", _nameController, Icons.person),

                    // Email & Phone & ID (Read Only)
                    _buildTextField("Email", _emailController, Icons.email,
                        isReadOnly: true),
                    _buildTextField("No. Telepon", _phoneController, Icons.phone,
                        isReadOnly: true),
                    _buildTextField(
                        "No. Identitas", _identityController, Icons.badge,
                        isReadOnly: true),

                    // Tanggal Lahir (Picker)
                    _buildDatePickerField(),

                    const SizedBox(height: 20),
                    _buildSectionLabel("Data Tambahan"),
                    const SizedBox(height: 10),

                    // Alamat, Pekerjaan, Gaji (Editable)
                    _buildTextField(
                        "Alamat Lengkap", _addressController, Icons.home,
                        maxLines: 3),
                    _buildTextField("Pekerjaan", _jobController, Icons.work),
                    _buildTextField(
                        "Rentang Gaji", _salaryController, Icons.attach_money),

                    const SizedBox(height: 30),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Simpan Perubahan",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isReadOnly = false, int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey.shade200 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isReadOnly
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? "$label tidak boleh kosong" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon, color: isReadOnly ? Colors.grey : Colors.blueAccent),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextFormField(
        controller: _birthDateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        validator: (value) =>
            value == null || value.isEmpty ? "Tanggal lahir wajib diisi" : null,
        decoration: const InputDecoration(
          labelText: "Tanggal Lahir",
          prefixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}