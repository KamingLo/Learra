import 'dart:async';
import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

const Color _kBackground = Color(0xFFF4F7F6);
const Color _kPrimary = Color(0xFF06A900);
const Color _kTextPrimary = Color(0xFF111111);
const Color _kTextSecondary = Color(0xFF3F3F3F);

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<AdminUser> _users = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({String query = ''}) async {
    if (mounted) {
      setState(() {
        _isLoading = !_isRefreshing;
      });
    }

    try {
      final endpoint = query.isEmpty ? '/users' : '/users?search=$query';
      final response = await _apiService.get(endpoint);
      if (!mounted) return;
      final dynamic raw = response;
      List<dynamic> data;
      if (raw is Map && raw['data'] is List) {
        data = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        data = raw;
      } else {
        data = [];
      }

      setState(() {
        _users = data.map((json) => AdminUser.fromJson(json)).toList();
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _fetchUsers(query: query.trim());
    });
  }

  Future<void> _onRefresh() async {
    if (mounted) setState(() => _isRefreshing = true);
    await _fetchUsers(query: _searchQuery);
  }

  void _deleteUser(AdminUser user) async {
    try {
      await _apiService.delete('/users/${user.id}');
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Close bottom sheet
      await _fetchUsers(query: _searchQuery);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengguna berhasil dihapus"),
          backgroundColor: _kPrimary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus pengguna: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showDeleteConfirmation(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Pengguna"),
        content: Text(
          "Apakah Anda yakin ingin menghapus pengguna '${user.name}'? Tindakan ini tidak dapat dibatalkan.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => _deleteUser(user),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _showUserDetail(AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            minChildSize: 0.45,
            maxChildSize: 0.85,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: _kPrimary.withOpacity(0.15),
                      child: const Icon(Icons.person, color: _kPrimary),
                    ),
                    title: Text(
                      user.name.isEmpty ? "Nama belum diisi" : user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: TextStyle(color: _kTextSecondary.withOpacity(0.8)),
                    ),
                    trailing: Chip(
                      backgroundColor: _kPrimary.withOpacity(0.1),
                      label: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(
                          color: _kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _detailRow("Nomor Identitas", user.nomorIdentitas),
                  _detailRow("No. Telepon", user.phone),
                  _detailRow("Alamat", user.address),
                  _detailRow("Pekerjaan", user.pekerjaan),
                  _detailRow("Rentang Gaji", user.rentangGaji),
                  _detailRow("Tanggal Lahir", user.birthDate),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(user);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(
                        "Edit Data Pengguna",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(user);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Colors.redAccent.withOpacity(0.2),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(
                        "Hapus Pengguna",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _kTextSecondary.withOpacity(0.7),
              fontSize: 12.5,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _kBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                color: _kTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(AdminUser user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final addressController = TextEditingController(text: user.address);
    final pekerjaanController = TextEditingController(text: user.pekerjaan);
    final gajiController = TextEditingController(text: user.rentangGaji);
    final birthDateController = TextEditingController(text: user.birthDate);

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => StatefulBuilder(
              builder: (context, setStateSheet) {
                return Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 12),
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const Text(
                            "Edit Data Pengguna",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: _kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Form Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _editField(
                                "Nama Lengkap",
                                nameController,
                                icon: Icons.person_outline,
                              ),
                              _editField(
                                "No. Telepon",
                                phoneController,
                                keyboardType: TextInputType.phone,
                                icon: Icons.phone_outlined,
                              ),
                              _editField(
                                "Alamat",
                                addressController,
                                maxLines: 3,
                                icon: Icons.location_on_outlined,
                              ),
                              _editField(
                                "Pekerjaan",
                                pekerjaanController,
                                icon: Icons.work_outline,
                              ),
                              _editField(
                                "Rentang Gaji",
                                gajiController,
                                icon: Icons.attach_money,
                              ),
                              _buildDatePicker(
                                context,
                                "Tanggal Lahir",
                                birthDateController,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          if (!formKey.currentState!
                                              .validate()) {
                                            return;
                                          }
                                          // Tutup keyboard agar tidak lag/freeze
                                          FocusScope.of(context).unfocus();

                                          setStateSheet(() => isSaving = true);

                                          // Beri jeda sedikit agar UI sempat update (spinner muncul)
                                          await Future.delayed(
                                            const Duration(milliseconds: 200),
                                          );

                                          try {
                                            await _apiService.put(
                                              '/users/${user.id}',
                                              body: {
                                                "name": nameController.text,
                                                "phone": phoneController.text,
                                                "address":
                                                    addressController.text,
                                                "pekerjaan":
                                                    pekerjaanController.text,
                                                "rentangGaji":
                                                    gajiController.text,
                                                "birthDate":
                                                    birthDateController.text,
                                              },
                                            );

                                            if (!mounted) return;
                                            Navigator.pop(
                                              context,
                                            ); // Close sheet

                                            // Refresh data
                                            await _fetchUsers(
                                              query: _searchQuery,
                                            );

                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Data pengguna diperbarui",
                                                ),
                                                backgroundColor: _kPrimary,
                                              ),
                                            );
                                          } catch (e) {
                                            if (!mounted) return;
                                            setStateSheet(
                                              () => isSaving = false,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Gagal menyimpan: $e",
                                                ),
                                                backgroundColor:
                                                    Colors.red.shade700,
                                              ),
                                            );
                                          }
                                        },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _kPrimary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Simpan Perubahan",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              DateTime initialDate = DateTime.now();
              if (controller.text.isNotEmpty) {
                try {
                  initialDate = DateTime.parse(controller.text);
                } catch (_) {}
              }

              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: _kPrimary,
                        onPrimary: Colors.white,
                        onSurface: _kTextPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                // Format YYYY-MM-DD
                String formatted =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                controller.text = formatted;
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _kBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: _kTextSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.text.isEmpty
                          ? "Pilih Tanggal Lahir"
                          : controller.text,
                      style: TextStyle(
                        color: controller.text.isEmpty
                            ? _kTextSecondary.withOpacity(0.5)
                            : _kTextPrimary,
                        fontSize: 15,
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

  Widget _editField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: (value) => value == null || value.trim().isEmpty
                ? "$label tidak boleh kosong"
                : null,
            decoration: InputDecoration(
              hintText: "Masukkan $label",
              prefixIcon: icon != null
                  ? Icon(
                      icon,
                      color: _kTextSecondary.withOpacity(0.6),
                      size: 20,
                    )
                  : null,
              filled: true,
              fillColor: _kBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        title: const Text(
          "Manajemen Pengguna",
          style: TextStyle(color: _kTextPrimary, fontWeight: FontWeight.w700),
        ),
        backgroundColor: _kBackground,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Cari nama, email, atau nomor telepon...",
                prefixIcon: const Icon(Icons.search, color: _kTextSecondary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _kPrimary))
                : RefreshIndicator(
                    color: _kPrimary,
                    onRefresh: _onRefresh,
                    child: _users.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return _UserCard(
                                user: user,
                                onTap: () => _showUserDetail(user),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  size: 60,
                  color: _kPrimary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Belum ada data pengguna",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Gunakan form registrasi atau impor data untuk menambahkan pengguna.",
                textAlign: TextAlign.center,
                style: TextStyle(color: _kTextSecondary.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _kPrimary.withOpacity(0.12),
                child: const Icon(Icons.person, color: _kPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? "Nama belum diisi" : user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: _kTextSecondary.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _infoChip(
                          Icons.phone,
                          user.phone.isEmpty ? "-" : user.phone,
                        ),
                        _infoChip(
                          Icons.badge_outlined,
                          user.nomorIdentitas.isEmpty
                              ? "-"
                              : user.nomorIdentitas,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _kTextSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kTextSecondary.withOpacity(0.8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: _kTextSecondary.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String nomorIdentitas;
  final String address;
  final String pekerjaan;
  final String rentangGaji;
  final String birthDate;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.nomorIdentitas,
    required this.address,
    required this.pekerjaan,
    required this.rentangGaji,
    required this.birthDate,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final birthRaw = json['birthDate']?.toString() ?? '';
    final trimmedBirth = birthRaw.length >= 10
        ? birthRaw.substring(0, 10)
        : birthRaw;

    return AdminUser(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '-',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      nomorIdentitas: json['nomorIdentitas']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pekerjaan: json['pekerjaan']?.toString() ?? '',
      rentangGaji: json['rentangGaji']?.toString() ?? '',
      birthDate: trimmedBirth,
    );
  }
}
