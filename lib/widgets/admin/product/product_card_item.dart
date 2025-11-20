import 'package:flutter/material.dart';
import '../../../models/product_model.dart';

class ProductCardItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Hijau Modern untuk harga
    const Color modernGreen = Color(0xFF00C853);

    // --- LOGIKA ICONS & WARNA BERDASARKAN TIPE ---
    IconData typeIcon;
    Color typeColor;
    String lowerType = product.tipe.toLowerCase();

    if (lowerType.contains('jiwa')) {
      // Asuransi Jiwa
      typeIcon = Icons.favorite_border_rounded; // Ikon Hati
      typeColor = Colors.purple;
    } else if (lowerType.contains('kendaraan')) {
      // Asuransi Kendaraan
      typeIcon = Icons.directions_car_filled_rounded; // Ikon Mobil
      typeColor = Colors.orange;
    } else if (lowerType.contains('kesehatan')) {
       // Asuransi Kesehatan (Default biru jika ada)
      typeIcon = Icons.local_hospital_rounded; // Ikon Rumah Sakit/Kesehatan
      typeColor = Colors.blue;
    } else {
      // Default / Tipe Lainnya
      typeIcon = Icons.verified_user_rounded; // Ikon Perisai umum
      typeColor = Colors.blueGrey;
    }
    // --------------------------------------------


    return Container(
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // Gunakan warna tipe tapi versi sangat muda untuk background
                color: typeColor.withOpacity(0.1), 
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              // Gunakan icon dan warna yang sudah ditentukan di atas
              child: Icon(typeIcon, color: typeColor, size: 36),
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
                  const SizedBox(height: 4),
                  
                  // Harga (premiDasar)
                  Text(
                    "Rp ${product.premiDasar}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: modernGreen, 
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badge Tipe (Warnanya disamakan dengan icon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(
                      product.tipe.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor),
                    ),
                  ),
                ],
              ),
            ),

            // --- 3. TOMBOL AKSI (Vertikal) ---
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.grey.shade600,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade400,
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}