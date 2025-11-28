import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import '../../../widgets/admin/product/product_search_bar.dart';
import '../../../utils/product_helper.dart'; 
import '../../../widgets/user/product/product_card.dart';
import '../../../widgets/user/product/product_skeleton.dart';
import 'product_detail_screen.dart';

class UserProductScreen extends StatefulWidget {
  // Tambahkan key di constructor agar bisa dikontrol Navbar
  const UserProductScreen({super.key});

  @override
  // Perhatikan: Return type adalah UserProductScreenState (Tanpa underscore)
  UserProductScreenState createState() => UserProductScreenState();
}

// HAPUS underscore (_) pada nama class agar PUBLIC
class UserProductScreenState extends State<UserProductScreen> {
  final ApiService _apiService = ApiService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = "";
  Timer? _debounce;

  // Controller text untuk mengisi Search Bar secara otomatis
  // (Pastikan ProductSearchBar-mu support controller, jika tidak, field ini opsional)
  // Tapi untuk logika search, _searchQuery sudah cukup.

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  /// METHOD BARU: Bisa dipanggil dari Navbar
  /// Menerima keyword (bisa nama produk ATAU kategori/tipe)
  void performSearch(String keyword) {
    if (!mounted) return;
    
    setState(() {
      _searchQuery = keyword; // Set keyword
      _isLoading = true;      // Mulai loading
    });

    // Panggil fetch langsung (tanpa debounce karena ini aksi klik)
    _fetchProducts(query: keyword);
  }

  Future<void> _fetchProducts({String query = ""}) async {
    if (!mounted) return;
    // Logika aman: Jika query kosong -> Default list
    // Jika ada query -> Search endpoint
    final endpoint = query.isEmpty 
        ? '/produk?limit=8' 
        : '/produk?search=$query&limit=6';

    try {
      final response = await _apiService.get(endpoint);

      if (!mounted) return;
      List<dynamic> data = (response is Map && response.containsKey('data')) 
          ? response['data'] : response;

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
    Navigator.push(context, MaterialPageRoute(builder: (_) => UserProductDetailScreen(productId: productId)));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text(
          "Belanja Produk", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 22)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tampilkan info jika sedang memfilter berdasarkan kategori
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Hasil pencarian: \"$_searchQuery\"", style: TextStyle(color: ProductHelper.primaryGreen, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => performSearch(""), // Reset search
                          child: const Icon(Icons.close, size: 16, color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ProductSearchBar(onChanged: _onSearchChanged),
              ],
            ),
          ),

          // GRID PRODUCTS
          Expanded(
            child: _isLoading
                ? const ProductSkeleton() 
                : _products.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _fetchProducts(query: _searchQuery),
                        color: ProductHelper.primaryGreen,
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
                            return ProductCard(
                              product: _products[index],
                              onTap: () => _goToDetail(_products[index].id),
                            );
                          },
                        ),
                      ),
          ),
        ],
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
          Text("Produk \"$_searchQuery\" tidak ditemukan", style: TextStyle(color: Colors.grey.shade500)),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () => performSearch(""), 
              child: const Text("Tampilkan Semua Produk")
            )
        ],
      ),
    );
  }
}