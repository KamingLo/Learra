import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/product_model.dart';
import '../../../utils/product_helper.dart';

class ProductCarousel extends StatefulWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final Function(ProductModel) onTap;

  const ProductCarousel({
    super.key,
    required this.products,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<ProductCarousel> createState() => _FullWidthProductCarouselState();
}

class _FullWidthProductCarouselState extends State<ProductCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    if (!widget.isLoading && widget.products.isNotEmpty) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(ProductCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading && widget.products.isNotEmpty) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.products.isEmpty || !_pageController.hasClients) return;

      if (_currentPage < widget.products.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubicEmphasized,
      );
    });
  }

  void _pauseAutoPlay() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    if (widget.products.isEmpty) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: Text("Tidak ada produk rekomendasi.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9, 
      child: GestureDetector(
        onPanDown: (_) => _pauseAutoPlay(),
        onPanEnd: (_) => _startAutoPlay(),
        onPanCancel: () => _startAutoPlay(),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.products.length,
          onPageChanged: (int index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final product = widget.products[index];
            return _buildFullScreenItem(product);
          },
        ),
      ),
    );
  }

  Widget _buildFullScreenItem(ProductModel product) {
    final imageUrl = ProductHelper.getImageUrl(product.tipe);
    
    return GestureDetector(
      onTap: () => widget.onTap(product),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20), 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
              ),
              
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha:0.1),
                      Colors.black.withValues(alpha:0.8),
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  )
                ),
              ),

              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        product.tipe.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.namaProduk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)]
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${_formatRupiah(product.premiDasar)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

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
}