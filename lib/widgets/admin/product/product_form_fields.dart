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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Nama Produk",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: descController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Deskripsi",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Premi Dasar (Rp)",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
          ),
          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: selectedType,
          decoration: const InputDecoration(
            labelText: "Tipe Asuransi",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: ['kesehatan', 'jiwa', 'kendaraan'].map((String type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type[0].toUpperCase() + type.substring(1)),
            );
          }).toList(),
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading ? null : onSubmit,
            child: isLoading 
              ? const SizedBox(
                  height: 24, width: 24, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
              : Text(isEdit ? "Simpan Perubahan" : "Buat Produk"),
          ),
        )
      ],
    );
  }
}