import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const ProductSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Container untuk membuat efek "Card" melayang
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Latar belakang putih bersih
        borderRadius: BorderRadius.circular(30), // Sudut sangat membulat (bentuk pil)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Bayangan sangat halus
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: "Cari produk...",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.green.shade400), // Ikon hijau
          border: InputBorder.none, // Hilangkan garis border bawaan
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }
}