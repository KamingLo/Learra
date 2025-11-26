import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../../services/api_service.dart';
import '../../../services/session_service.dart'; // 1. Import SessionService Anda
import '../../../models/product_model.dart';
import '../../../utils/product_helper.dart'; 
import '../../../widgets/user/home/product_card_item.dart';
import '../../auth/auth_screen.dart'; // Pastikan path ini sesuai

class UserProductDetailScreen extends StatefulWidget {
  final String productId;
  // Parameter role DIHAPUS, karena kita cek via SessionService
  
  const UserProductDetailScreen({
    super.key, 
    required this.productId,
  });

  @override
  State<UserProductDetailScreen> createState() => _UserProductDetailScreenState();
}

class _UserProductDetailScreenState extends State<UserProductDetailScreen> {
  final ApiService _apiService = ApiService();
  
  // State Utama
  ProductModel? _product;
  bool _isLoading = true;
  String? _errorMessage;

  // State Rekomendasi
  List<ProductModel> _relatedProducts = [];
  bool _isLoadingRelated = true;

  // 2. State untuk Session Role
  String _currentRole = 'guest'; // Default guest

  @override
  void initState() {
    super.initState();
    _checkSession(); // Cek session saat pertama kali load
    _fetchProductDetail();
    _fetchRelatedProducts();
  }

  // --- 3. FUNGSI CEK SESSION PAKAI SERVICE ---
  Future<void> _checkSession() async {
    // Menggunakan method dari SessionService yang Anda buat
    final role = await SessionService.getCurrentRole();
    if (mounted) {
      setState(() {
        _currentRole = role;
      });
    }
  }

  // --- AMBIL DETAIL PRODUK UTAMA ---
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

  // --- AMBIL PRODUK LAINNYA ---
  Future<void> _fetchRelatedProducts() async {
    try {
      final response = await _apiService.get('/produk');
      if (!mounted) return;

      List<dynamic> data = (response is Map && response.containsKey('data')) 
          ? response['data'] 
          : (response is List ? response : []);

      List<ProductModel> allProducts = data.map((json) => ProductModel.fromJson(json)).toList();

      final filtered = allProducts
          .where((p) => p.id != widget.productId)
          .take(3)
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

  // --- NAVIGASI ---
  void _navigateToLogin() {
    // Arahkan ke Login, lalu refresh session saat kembali
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const AuthScreen())
    ).then((_) {
      // PENTING: Cek ulang session setelah user kembali dari halaman login
      // Siapa tahu dia berhasil login
      _checkSession();
    });
  }

  void _buyNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lanjut ke form pembayaran..."))
    );
  }

  void _goToDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProductDetailScreen(
          productId: product.id,
          // Tidak perlu kirim role
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, 
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ProductHelper.primaryGreen))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(),
      
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
          ]
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_product == null) return const SizedBox();
    final imageUrl = ProductHelper.getImageUrl(_product!.tipe);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Header
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_,__,___) => Container(color: Colors.grey.shade200),
            ),
          ),
          
          // Konten Body
          Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (Bagian UI Header, Nama, Harga sama seperti sebelumnya)
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ProductHelper.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _product!.tipe.toUpperCase(),
                      style: const TextStyle(
                        color: ProductHelper.darkGreen, 
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _product!.namaProduk,
                    style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87, height: 1.2
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp ${_product!.premiDasar}",
                    style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: ProductHelper.primaryGreen
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Deskripsi
                  const Text("Deskripsi Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.6),
                  ),
                  
                  const SizedBox(height: 40),

                  // Produk Lainnya
                  if (!_isLoadingRelated && _relatedProducts.isNotEmpty) ...[
                    const Text("Produk Lainnya", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _relatedProducts.length,
                      itemBuilder: (context, index) {
                        final related = _relatedProducts[index];
                        return ProductCardItem(
                          product: related,
                          onTap: () => _goToDetail(related),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. BOTTOM BAR LOGIC (Menggunakan _currentRole) ---
  Widget _buildBottomBar() {
    // Cek apakah role adalah 'user' (sesuaikan string 'user' dengan logic backend Anda)
    // Jika backend mengembalikan 'guest' saat belum login, logika ini valid.
    final bool isUser = _currentRole == 'user'; 
    
    final String buttonText = isUser ? "Beli Sekarang" : "Login Untuk Membeli";
    final Color buttonColor = isUser ? ProductHelper.primaryGreen : Colors.grey.shade800;
    final VoidCallback onPressed = isUser ? _buyNow : _navigateToLogin;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5)
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isUser ? 4 : 2,
          shadowColor: isUser ? ProductHelper.primaryGreen.withOpacity(0.4) : Colors.black12,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}