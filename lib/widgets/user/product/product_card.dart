import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../utils/product_helper.dart';

class ProductCardGrid extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCardGrid({
    super.key,
    required this.product,
    required this.onTap,
  });

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
    final imageUrl = ProductHelper.getImageUrl(product.tipe);
    const double radius = 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.broken_image, color: Colors.white54),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha:0.7),
                        Colors.black.withValues(alpha:0.9), 
                      ],
                      stops: const [0.5, 0.75, 1.0], 
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900.withValues(alpha:0.5), 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha:0.2)),
                  ),
                  child: Text(
                    "Rp ${_formatRupiah(product.premiDasar)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.namaProduk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Container(
                          width: 2,
                          height: 12,
                          color: Colors.lightGreenAccent, 
                          margin: const EdgeInsets.only(right: 6),
                        ),
                        Text(
                          product.tipe,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha:0.9),
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}