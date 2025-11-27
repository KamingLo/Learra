import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../widgets/user/profile/profile_input_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _textPrimary = Color(0xFF111111);
  static const Color _textSecondary = Color(0xFF3F3F3F);
  static const Color _backgroundColor = Color(0xFFF7F7F7);
  static const Color _primaryGreen = Color(0xFF06A900);
  static const Color _deepGreen = Color(0xFF024000);

  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // State
  bool _isInitialLoading = true;
  bool _isSaving = false;
  String? _userId;

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

      if (response['user'] != null) {
        final data = response['user'];

        setState(() {
          _userId = data['_id']?.toString();
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _identityController.text = data['nomorIdentitas'] ?? '';
          _phoneController.text = data['phone'] ?? '';

          // Parsing Tanggal (ambil YYYY-MM-DD saja)
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
        throw Exception("Data user tidak ditemukan");
      }
    } catch (e) {
      setState(() => _isInitialLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat profil: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // --- 2. UPDATE DATA USER (PUT) ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error: ID User tidak ditemukan, silakan refresh."),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = {
        "name": _nameController.text,
        "birthDate": _birthDateController.text,
        "address": _addressController.text,
        "pekerjaan": _jobController.text,
        "rentangGaji": _salaryController.text,
      };

      // Mengirim request PUT ke endpoint spesifik ID user (user/profile)
      await _apiService.put('/users/$_userId', body: body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profil berhasil diperbarui"),
          backgroundColor: _primaryGreen,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal update: $e"),
          backgroundColor: Colors.red.shade700,
        ),
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          "Edit Profil",
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSummaryCard(),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: "Informasi Pribadi",
                        subtitle: "Perbarui data utama akun Anda",
                        children: [
                          ProfileInputField(
                            label: "Nama Lengkap",
                            controller: _nameController,
                            icon: Icons.person,
                          ),
                          ProfileInputField(
                            label: "Email",
                            controller: _emailController,
                            icon: Icons.email,
                            isReadOnly: true,
                          ),
                          ProfileInputField(
                            label: "No. Telepon",
                            controller: _phoneController,
                            icon: Icons.phone,
                            isReadOnly: true,
                          ),
                          ProfileInputField(
                            label: "No. Identitas",
                            controller: _identityController,
                            icon: Icons.badge,
                            isReadOnly: true,
                          ),
                          ProfileInputField(
                            label: "Tanggal Lahir",
                            controller: _birthDateController,
                            icon: Icons.calendar_today,
                            isReadOnly: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: "Data Tambahan",
                        subtitle: "Lengkapi informasi pendukung untuk layanan optimal",
                        children: [
                          ProfileInputField(
                            label: "Alamat Lengkap",
                            controller: _addressController,
                            icon: Icons.home,
                            maxLines: 3,
                          ),
                          ProfileInputField(
                            label: "Pekerjaan",
                            controller: _jobController,
                            icon: Icons.work,
                          ),
                          ProfileInputField(
                            label: "Rentang Gaji",
                            controller: _salaryController,
                            icon: Icons.attach_money,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildSaveButton(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryGreen, _deepGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _deepGreen.withOpacity(0.18),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (_, value, __) => Text(
                    value.text.isEmpty ? "Lengkapi nama Anda" : value.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _emailController,
                  builder: (_, value, __) => Text(
                    value.text.isEmpty ? "Email belum tersedia" : value.text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.eco_outlined, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Data pribadi terlindungi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _backgroundColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: _textSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: FilledButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 3,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Text("Simpan Perubahan"),
      ),
    );
  }
}