import 'package:flutter/material.dart';
import '../../../models/product_model.dart';

class ProductCardItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Hijau Modern
    const Color modernGreen = Color(0xFF00C853);

    // --- LOGIKA ICONS & WARNA BERDASARKAN TIPE ---
    IconData typeIcon;
    Color typeColor = modernGreen; // Default ke hijau modern
    String lowerType = product.tipe.toLowerCase();

    if (lowerType.contains('jiwa')) {
      typeIcon = Icons.favorite_border_rounded; 
    } else if (lowerType.contains('kendaraan')) {
      typeIcon = Icons.directions_car_filled_rounded;
    } else if (lowerType.contains('kesehatan')) {
      typeIcon = Icons.local_hospital_rounded;
    } else {
      typeIcon = Icons.verified_user_rounded;
    }
    // --------------------------------------------

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // --- 1. ICON PRODUK (DINAMIS) ---
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: typeColor.withOpacity(0.1), 
                  border: Border.all(color: typeColor.withOpacity(0.3)),
                ),
                child: Icon(typeIcon, color: typeColor, size: 32),
              ),
              const SizedBox(width: 16),

              // --- 2. INFORMASI PRODUK ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Produk
                    Text(
                      product.namaProduk, 
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Harga (premiDasar)
                    Text(
                      "Rp ${product.premiDasar}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: modernGreen, 
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Badge Tipe
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)
                      ),
                      child: Text(
                        product.tipe.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9, 
                          fontWeight: FontWeight.bold, 
                          color: typeColor
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 3. ICON NAVIGASI (Chevron) ---
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}