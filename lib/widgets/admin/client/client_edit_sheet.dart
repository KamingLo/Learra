import 'package:flutter/material.dart';
import '../../../models/admin_user_model.dart';

class ClientEditSheet extends StatefulWidget {
  final AdminUser user;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const ClientEditSheet({super.key, required this.user, required this.onSave});

  @override
  State<ClientEditSheet> createState() => _ClientEditSheetState();
}

class _ClientEditSheetState extends State<ClientEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _pekerjaanController;
  late TextEditingController _gajiController;
  late TextEditingController _birthDateController;

  bool _isSaving = false;

  static const Color _kPrimary = Color(0xFF06A900);
  static const Color _kTextPrimary = Color(0xFF111111);
  static const Color _kTextSecondary = Color(0xFF3F3F3F);
  static const Color _kBackground = Color(0xFFF4F7F6);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);
    _pekerjaanController = TextEditingController(text: widget.user.pekerjaan);
    _gajiController = TextEditingController(text: widget.user.rentangGaji);
    _birthDateController = TextEditingController(text: widget.user.birthDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pekerjaanController.dispose();
    _gajiController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
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
                    icon: const Icon(Icons.close, color: _kTextSecondary),
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _editField(
                        "Nama Lengkap",
                        _nameController,
                        icon: Icons.person_outline,
                      ),
                      _editField(
                        "No. Telepon",
                        _phoneController,
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone_outlined,
                      ),
                      _editField(
                        "Alamat",
                        _addressController,
                        maxLines: 3,
                        icon: Icons.location_on_outlined,
                      ),
                      _editField(
                        "Pekerjaan",
                        _pekerjaanController,
                        icon: Icons.work_outline,
                      ),
                      _editField(
                        "Rentang Gaji",
                        _gajiController,
                        icon: Icons.attach_money,
                      ),
                      _buildDatePicker(
                        context,
                        "Tanggal Lahir",
                        _birthDateController,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  FocusScope.of(context).unfocus();

                                  setState(() => _isSaving = true);

                                  try {
                                    await widget.onSave({
                                      "name": _nameController.text,
                                      "phone": _phoneController.text,
                                      "address": _addressController.text,
                                      "pekerjaan": _pekerjaanController.text,
                                      "rentangGaji": _gajiController.text,
                                      "birthDate": _birthDateController.text,
                                    });
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() => _isSaving = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Gagal menyimpan: $e"),
                                        backgroundColor: Colors.red.shade700,
                                      ),
                                    );
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: _kPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
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
        ),
      ),
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
}
