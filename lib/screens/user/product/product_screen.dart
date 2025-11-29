import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import '../../../widgets/admin/product/product_search_bar.dart';
import '../../../widgets/user/product/product_card.dart';
import '../../../widgets/user/product/product_skeleton.dart';
import 'product_detail_screen.dart';

class UserProductScreen extends StatefulWidget {
  const UserProductScreen({super.key});

  @override
  UserProductScreenState createState() => UserProductScreenState();
}

class UserProductScreenState extends State<UserProductScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void performSearch(String keyword) {
    if (!mounted) return;
    
    setState(() {
      _searchQuery = keyword;
      _isLoading = true;
    });

    _fetchProducts(query: keyword);
  }

  Future<void> _fetchProducts({String query = ""}) async {
    if (!mounted) return;
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

  void _clearSearch() {
    _searchCtrl.clear();
    performSearch("");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: ProductSearchBar(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const ProductSkeleton() 
                : _products.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _fetchProducts(query: _searchQuery),
                        color: Colors.green,
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
                            return ProductCardGrid(
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
              onPressed: _clearSearch, 
              child: const Text("Tampilkan Semua Produk")
            )
        ],
      ),
    );
  }
}
