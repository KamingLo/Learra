import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import 'product_form_screen.dart';
import '../../../widgets/admin/product/product_card_item.dart';
import '../../../widgets/admin/product/product_search_bar.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = "";
  Timer? _debounce;

  final Color _backgroundColor = const Color(0xFFF4F7F6);
  final Color _accentGreen = const Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String query = ""}) async {
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

  void _clearSearch() {
    _searchCtrl.clear();
    _fetchProducts(query: "");
    setState(() => _searchQuery = "");
  }

  Future<void> _deleteProduct(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Produk", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus produk ini permanen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("Batal", style: TextStyle(color: Colors.grey.shade600))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await _apiService.delete('/produk/$id');
        if (!mounted) return;

        _fetchProducts(query: _searchQuery);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Produk berhasil dihapus"),
            backgroundColor: _accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal hapus: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  void _openForm({ProductModel? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    
    if (!mounted) return;

    if (result == true) {
      _fetchProducts(query: _searchQuery);
    }
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
      backgroundColor: _backgroundColor, 
      appBar: AppBar(
        title: const Text(
          "Manajemen Produk", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 22)
        ),
        backgroundColor: Colors.white, 
        elevation: 0,
        centerTitle: false,
      ),
      
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: ProductSearchBar(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  shadowColor: Colors.green.shade800.withValues(alpha:0.3),
                  child: InkWell(
                    onTap: () => _openForm(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Tambah",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _accentGreen))
                : _products.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ProductCardItem(
                            product: product,
                            onEdit: () => _openForm(product: product),
                            onDelete: () => _deleteProduct(product.id),
                          );
                        },
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
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle
            ),
            child: Icon(Icons.inventory_2_outlined, size: 80, color: Colors.green.shade700),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum ada produk",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 8),
          Text(
            "Tambahkan produk baru untuk memulai.",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
