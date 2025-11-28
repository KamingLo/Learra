import 'package:flutter/material.dart';
import '../polis/user_polis_form_jiwa.dart';
import '../polis/user_polis_form_kendaraan.dart';
import '../polis/user_polis_form_kesehatan.dart';
import '../../../services/api_service.dart';
import '../../../services/session_service.dart';
import '../../../models/product_model.dart';
import '../../../utils/product_helper.dart';
import '../../auth/auth_screen.dart';

import '../../../widgets/user/home/product_carousel.dart';

class UserProductDetailScreen extends StatefulWidget {
  final String productId;
  const UserProductDetailScreen({super.key, required this.productId});

  @override
  State<UserProductDetailScreen> createState() =>
      _UserProductDetailScreenState();
}

class _UserProductDetailScreenState extends State<UserProductDetailScreen> {
  final ApiService _apiService = ApiService();

  ProductModel? _product;
  bool _isLoading = true;
  String? _errorMessage;

  List<ProductModel> _relatedProducts = [];
  bool _isLoadingRelated = true;
  String _currentRole = 'guest';

  @override
  void initState() {
    super.initState();
    _checkSession();
    _fetchProductDetail();
    _fetchRelatedProducts();
  }

  Future<void> _checkSession() async {
    final role = await SessionService.getCurrentRole();
    if (mounted) setState(() => _currentRole = role);
  }

  Future<void> _fetchProductDetail() async {
    try {
      final response = await _apiService.get('/produk/${widget.productId}');
      if (!mounted) return;
      final data = (response is Map && response.containsKey('data'))
          ? response['data']
          : response;
      setState(() {
        _product = ProductModel.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal memuat detail: $e";
      });
    }
  }

  Future<void> _fetchRelatedProducts() async {
    try {
      final response = await _apiService.get('/produk');
      if (!mounted) return;
      List<dynamic> data = (response is Map && response.containsKey('data'))
          ? response['data']
          : (response is List ? response : []);

      List<ProductModel> allProducts = data
          .map((json) => ProductModel.fromJson(json))
          .toList();
      final filtered = allProducts
          .where((p) => p.id != widget.productId)
          .take(5)
          .toList();

      setState(() {
        _relatedProducts = filtered;
        _isLoadingRelated = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRelated = false);
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    ).then((_) => _checkSession());
  }

  void _buyNow() {
    if (_product == null) return;

    final normalizedType = _product!.tipe.trim().toLowerCase();
    final productId = _product!.id;
    final productName = _product!.namaProduk;

    Widget? targetForm;
    switch (normalizedType) {
      case 'kendaraan':
        targetForm = KendaraanPolisForm(
          productId: productId,
          productName: productName,
        );
        break;
      case 'kesehatan':
        targetForm = KesehatanPolisForm(
          productId: productId,
          productName: productName,
        );
        break;
      case 'jiwa':
        targetForm = JiwaPolisForm(
          productId: productId,
          productName: productName,
        );
        break;
    }

    if (targetForm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Form polis untuk tipe ${_product!.tipe} belum tersedia.",
          ),
        ),
      );
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => targetForm!));
  }

  void _goToDetail(ProductModel product) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UserProductDetailScreen(productId: product.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ProductHelper.primaryGreen,
              ),
            )
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _buildContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent() {
    if (_product == null) return const SizedBox();
    final imageUrl = ProductHelper.getImageUrl(_product!.tipe);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey.shade200),
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ProductHelper.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _product!.tipe.toUpperCase(),
                      style: const TextStyle(
                        color: ProductHelper.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _product!.namaProduk,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp ${_product!.premiDasar}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ProductHelper.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  const Text(
                    "Deskripsi Produk",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          if (_relatedProducts.isNotEmpty || _isLoadingRelated) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Produk Lainnya",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            ProductCarousel(
              products: _relatedProducts,
              isLoading: _isLoadingRelated,
              onTap: _goToDetail,
            ),

            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool isUser = _currentRole == 'user';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isUser ? _buyNow : _navigateToLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: isUser
              ? ProductHelper.primaryGreen
              : Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isUser ? 4 : 2,
        ),
        child: Text(
          isUser ? "Beli Sekarang" : "Login Untuk Membeli",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
