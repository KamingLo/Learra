import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController priceController;
  final String selectedType;
  final Function(String?) onTypeChanged;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isEdit;

  static const Color kPrimaryGreen = Color(0xFF0FA958);
  static const Color kBorderColor = Color(0xFFE0E0E0);
  static const Color kTextLabel = Color(0xFF6B7280); 

  const ProductFormFields({
    super.key,
    required this.nameController,
    required this.descController,
    required this.priceController,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onSubmit,
    required this.isLoading,
    required this.isEdit,
  });

  InputDecoration _whiteDecoration({
    required String label,
    IconData? icon,
    String? prefixText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixText: prefixText,
      
      labelStyle: const TextStyle(color: kTextLabel, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold),
      prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      
      prefixIcon: icon != null 
          ? Icon(icon, color: kTextLabel, size: 22) 
          : null,
      prefixIconColor: WidgetStateColor.resolveWith((states) => 
          states.contains(WidgetState.focused) ? kPrimaryGreen : kTextLabel
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const Text(
          "Detail Produk",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: nameController,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          cursorColor: kPrimaryGreen,
          decoration: _whiteDecoration(
            label: "Nama Produk",
            hintText: "Contoh: Asuransi Jiwa Keluarga",
            icon: Icons.edit_note_rounded,
          ),
          validator: (val) => val!.isEmpty ? "Nama produk wajib diisi" : null,
        ),
        
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: selectedType,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextLabel),
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          decoration: _whiteDecoration(
            label: "Kategori Asuransi",
            icon: Icons.category_outlined,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: ['kesehatan', 'jiwa', 'kendaraan'].map((String type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: _getColorByType(type),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onTypeChanged,
        ),

        const SizedBox(height: 24),

        const Text(
          "Informasi Penjualan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold, fontSize: 16),
          cursorColor: kPrimaryGreen,
          decoration: _whiteDecoration(
            label: "Premi Dasar",
            prefixText: "Rp ",
            icon: Icons.wallet_rounded,
          ),
          validator: (val) => val!.isEmpty ? "Harga wajib diisi" : null,
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: descController,
          maxLines: 4,
          style: const TextStyle(color: Colors.black87, height: 1.5),
          cursorColor: kPrimaryGreen,
          decoration: _whiteDecoration(
            label: "Deskripsi Lengkap",
            hintText: "Jelaskan manfaat produk ini...",
            icon: Icons.description_outlined,
          ).copyWith(alignLabelWithHint: true),
          validator: (val) => val!.isEmpty ? "Deskripsi wajib diisi" : null,
        ),

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    isEdit ? "Simpan Perubahan" : "Buat Produk Sekarang",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        )
      ],
    );
  }

  Color _getColorByType(String type) {
    switch (type) {
      case 'kesehatan': return Colors.blueAccent;
      case 'jiwa': return Colors.purpleAccent;
      case 'kendaraan': return Colors.orangeAccent;
      default: return Colors.grey;
    }
  }
}