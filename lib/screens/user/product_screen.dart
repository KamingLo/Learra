import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart'; // Pastikan sudah 'flutter pub add shimmer'
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../widgets/admin/product/product_search_bar.dart'; 
import 'product_detail_screen.dart'; 

class UserProductScreen extends StatefulWidget {
  const UserProductScreen({super.key});

  @override
  State<UserProductScreen> createState() => _UserProductScreenState();
}

class _UserProductScreenState extends State<UserProductScreen> {
  final ApiService _apiService = ApiService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = "";
  Timer? _debounce;

  // Warna Modern
  final Color _backgroundColor = const Color(0xFFF4F7F6);
  final Color _accentGreen = const Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String query = ""}) async {
    // Set loading true hanya jika mounted
    if (mounted) setState(() => _isLoading = true);
    
    try {
      final endpoint = query.isEmpty ? '/produk' : '/produk?search=$query';
      final response = await _apiService.get(endpoint);

      if (!mounted) return;

      List<dynamic> data = (response is Map && response.containsKey('data')) 
          ? response['data'] 
          : response;

      setState(() {
        _products = data.map((json) => ProductModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _searchQuery = query);
      _fetchProducts(query: query);
    });
  }

  void _goToDetail(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProductDetailScreen(productId: productId),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Belanja Produk", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 22)
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ProductSearchBar(onChanged: _onSearchChanged),
          ),

          // GRID PRODUCTS
          Expanded(
            child: _isLoading
                ? _buildSkeletonLoader()
                : _products.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _fetchProducts(query: _searchQuery),
                        color: _accentGreen,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return _buildProductGridItem(_products[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // --- SKELETON LOADER ---
  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  // --- ITEM GRID (DENGAN GAMBAR) ---
  Widget _buildProductGridItem(ProductModel product) {
    // Logic Gambar berdasarkan Tipe
    String imageUrl;
    if (product.tipe.toLowerCase().contains('jiwa')) {
      imageUrl = "https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=400&q=80";
    } else if (product.tipe.toLowerCase().contains('kendaraan')) {
      imageUrl = "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=400&q=80";
    } else if (product.tipe.toLowerCase().contains('kesehatan')) {
      imageUrl = "https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=400&q=80";
    } else {
      imageUrl = "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=400&q=80";
    }

    return GestureDetector(
      onTap: () => _goToDetail(product.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stack) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),
            
            // INFO AREA
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Tipe Kecil
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: _accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(
                      product.tipe.toUpperCase(),
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _accentGreen),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: 14,
                      color: _accentGreen
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Produk tidak ditemukan", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}