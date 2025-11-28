import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../utils/product_helper.dart';

class ProductCoverCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCoverCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  // Helper Format Rupiah
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

  @override
  Widget build(BuildContext context) {
    // Ambil gambar dari ProductHelper yang kamu kirim
    final imageUrl = ProductHelper.getImageUrl(product.tipe);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ClipRRect untuk membulatkan sudut gambar dan konten
        clipBehavior: Clip.antiAlias, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow agak gelap
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // --- LAYER 1: GAMBAR COVER ---
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Gambar memenuhi area
                errorBuilder: (ctx, err, stack) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),

            // --- LAYER 2: GRADIENT HITAM (Agar teks terbaca) ---
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7), // Gelap di bawah
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.4, 0.8, 1.0],
                  ),
                ),
              ),
            ),

            // --- LAYER 3: KONTEN TEKS ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Tipe Produk
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: ProductHelper.primaryGreen, // Warna ijo sesuai request
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.tipe.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Nama Produk
                    Text(
                      product.namaProduk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Harga
                    Text(
                      "Rp ${_formatRupiah(product.premiDasar)}",
                      style: const TextStyle(
                        color: Color(0xFF81C784), // Hijau muda cerah agar kontras di hitam
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- LAYER 4: RIPPLE EFFECT (Feedback Klik) ---
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}