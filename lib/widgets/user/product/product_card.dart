import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../utils/product_helper.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  // --- HELPER 1: Format Rupiah ---
  String _formatRupiah(int price) {
    String priceStr = price.toString();
    String result = '';
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      result = priceStr[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = '.$result';
        count = 0;
      }
    }
    return result;
  }

  // --- HELPER 2: Kapitalisasi (Huruf pertama besar) ---
  // Cara kerjanya: Ambil huruf pertama, besarkan. Ambil sisanya, kecilkan.
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ProductHelper.getImageUrl(product.tipe);
    const double radius = 20.0; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          // Shadow halus warna abu-abu (Clean look)
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08), 
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: GAMBAR ---
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(radius)),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => 
                      Container(color: Colors.grey.shade100, child: const Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
            ),

            // --- BAGIAN 2: INFO PRODUK ---
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Nama Produk
                  Text(
                    product.namaProduk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937), // Dark Grey
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 2. Tipe Produk (Hijau & Kapitalisasi)
                  Text(
                    _capitalize(product.tipe), // <-- Panggil helper di sini
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400, // Sedikit tebal agar warna hijaunya jelas
                      color: ProductHelper.primaryGreen, // Warna Hijau sesuai request
                    ),
                  ),

                  const SizedBox(height: 12),
                  
                  // 3. Harga
                  Text(
                    "Rp ${_formatRupiah(product.premiDasar)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ProductHelper.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}