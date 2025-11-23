import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../utils/product_helper.dart'; // Sesuaikan import helper

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ProductHelper.getImageUrl(product.tipe);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100), // Border halus
          boxShadow: [
            BoxShadow(
              color: ProductHelper.primaryGreen.withOpacity(0.08), // Shadow kehijauan
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AREA GAMBAR
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stack) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                      ),
                    ),
                    // Overlay gradasi hijau tipis di bawah gambar agar teks jelas (opsional)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // INFO AREA
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Tipe (Hijau Muda)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: ProductHelper.lightGreen, // Background Hijau Muda
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text(
                      product.tipe.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9, 
                        fontWeight: FontWeight.bold, 
                        color: ProductHelper.primaryGreen // Teks Hijau Tua
                      ),
                    ),
                  ),
                  
                  Text(
                    product.namaProduk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 14,
                      color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${product.premiDasar}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: 14,
                      color: ProductHelper.primaryGreen // Harga Hijau
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