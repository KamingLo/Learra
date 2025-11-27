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
  // Controller untuk PageView
  late PageController _pageController;
  // Timer untuk auto-play
  Timer? _timer;
  // Halaman saat ini
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    // Hanya mulai timer jika data sudah siap
    if (!widget.isLoading && widget.products.isNotEmpty) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(ProductCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika data baru dimuat, mulai timer
    if (oldWidget.isLoading && !widget.isLoading && widget.products.isNotEmpty) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    // PENTING: Hentikan timer dan controller saat widget dihancurkan untuk mencegah memory leak
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk memulai timer 5 detik
  void _startAutoPlay() {
    _timer?.cancel(); // Pastikan timer sebelumnya mati
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.products.isEmpty || !_pageController.hasClients) return;

      if (_currentPage < widget.products.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Kembali ke awal jika sudah di akhir
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800), // Durasi animasi geser
        curve: Curves.easeInOutCubicEmphasized, // Efek animasi halus
      );
    });
  }

  // Fungsi untuk menghentikan timer sementara (saat user menyentuh layar)
  void _pauseAutoPlay() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // --- 1. Loading State (Shimmer 16:9) ---
    if (widget.isLoading) {
      return AspectRatio(
        aspectRatio: 16 / 9, // Rasio 16:9
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

    // --- 2. Empty State ---
    if (widget.products.isEmpty) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: Text("Tidak ada produk rekomendasi.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    // --- 3. Full Width Carousel Real ---
    // Menggunakan AspectRatio untuk memastikan bentuk 16:9
    return AspectRatio(
      aspectRatio: 16 / 9, 
      child: GestureDetector(
        // Logika: Hentikan timer saat ditekan, lanjutkan saat dilepas
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
            // Membangun item full screen
            return _buildFullScreenItem(product);
          },
        ),
      ),
    );
  }

  // Helper untuk membangun tampilan item 16:9
  Widget _buildFullScreenItem(ProductModel product) {
    final imageUrl = ProductHelper.getImageUrl(product.tipe);
    
    return GestureDetector(
      onTap: () => widget.onTap(product),
      child: Container(
        // Margin horizontal agar tidak terlalu mepet layar (opsional, bisa dihapus jika ingin full 'bleeding')
        margin: const EdgeInsets.symmetric(horizontal: 20), 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24), // Sudut membulat besar
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: Gambar Background
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
              ),
              
              // Layer 2: Gradient Hitam di Bawah agar teks terbaca
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  )
                ),
              ),

              // Layer 3: Informasi Produk
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Tipe
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ProductHelper.primaryGreen,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        product.tipe.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Nama Produk
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
                    // Harga
                    Text(
                      "Rp ${_formatRupiah(product.premiDasar)}",
                      style: TextStyle(
                        color: ProductHelper.lightGreen,
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

  // Helper format rupiah (karena kita tidak pakai card item terpisah lagi di sini)
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