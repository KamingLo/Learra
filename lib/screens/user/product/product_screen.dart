import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import '../../../widgets/admin/product/product_search_bar.dart';
import '../../../utils/product_helper.dart'; // Import helper warna
// Import Widget Baru
import '../../../widgets/user/product/product_card.dart';
import '../../../widgets/user/product/product_skeleton.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String query = ""}) async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final endpoint = query.isEmpty ? '/produk?limit=8' : '/produk?search=$query&limit=6';
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
      backgroundColor: const Color(0xFFF4F7F6), // Background abu-abu sangat muda
      appBar: AppBar(
        title: const Text(
          "Belanja Produk", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 22)
        ),
        backgroundColor: const Color(0xFFF4F7F6),
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
                ? const ProductSkeleton() // Panggil Widget Skeleton
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
                            // Panggil Widget Card
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
          Text("Produk tidak ditemukan", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}