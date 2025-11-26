import 'package:flutter/material.dart';

class ProductFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController priceController;
  final String selectedType;
  final Function(String?) onTypeChanged;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isEdit;

  // Palet Warna
  static const Color kPrimaryGreen = Color(0xFF0FA958);
  static const Color kGreyBorder = Color(0xFFE0E0E0); // Abu-abu lembut untuk border diam

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

  // Helper Decoration: Putih bersih dengan border abu-abu, berubah hijau saat fokus
  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey), // Label abu-abu saat diam
      floatingLabelStyle: const TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600), // Label hijau saat fokus
      
      prefixIcon: Icon(icon, color: kPrimaryGreen), // Ikon tetap hijau sebagai aksen
      
      filled: true,
      fillColor: Colors.white, // TETAP PUTIH
      
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      
      // Border saat diam (Abu-abu halus)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGreyBorder, width: 1.5),
      ),
      
      // Border saat diklik/fokus (Hijau menyala)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryGreen, width: 2),
      ),
      
      // Border saat error (Merah)
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- NAMA PRODUK ---
        TextFormField(
          controller: nameController,
          style: const TextStyle(color: Colors.black87),
          cursorColor: kPrimaryGreen, // Kursor warna hijau
          decoration: _inputDecoration(
            label: "Nama Produk",
            icon: Icons.inventory_2_outlined,
          ),
          validator: (val) => val!.isEmpty ? "Nama produk wajib diisi" : null,
        ),
        const SizedBox(height: 20),

        // --- DESKRIPSI ---
        TextFormField(
          controller: descController,
          maxLines: 3,
          style: const TextStyle(color: Colors.black87),
          cursorColor: kPrimaryGreen,
          decoration: _inputDecoration(
            label: "Deskripsi",
            icon: Icons.description_outlined,
          ).copyWith(alignLabelWithHint: true),
          validator: (val) => val!.isEmpty ? "Deskripsi wajib diisi" : null,
        ),
        const SizedBox(height: 20),

        // --- HARGA ---
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          cursorColor: kPrimaryGreen,
          decoration: _inputDecoration(
            label: "Premi Dasar (Rp)",
            icon: Icons.attach_money,
          ),
          validator: (val) => val!.isEmpty ? "Harga wajib diisi" : null,
        ),
        const SizedBox(height: 20),

        // --- TIPE ASURANSI ---
        DropdownButtonFormField<String>(
          initialValue: selectedType,
          icon: const Icon(Icons.arrow_drop_down, color: kPrimaryGreen), // Panah dropdown hijau
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          decoration: _inputDecoration(
            label: "Tipe Asuransi",
            icon: Icons.category_outlined,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: ['kesehatan', 'jiwa', 'kendaraan'].map((String type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type[0].toUpperCase() + type.substring(1)),
            );
          }).toList(),
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 40),

        // --- TOMBOL SUBMIT ---
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen, // Tombol tetap hijau solid agar kontras
              foregroundColor: Colors.white,
              elevation: 2, // Bayangan lebih tipis agar modern
              shadowColor: kPrimaryGreen.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    isEdit ? "Simpan Perubahan" : "Buat Produk",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        )
      ],
    );
  }
}