import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// --- IMPORTS ---
import '../../../services/api_service.dart'; // Service untuk request API
import '../../../models/product_model.dart'; // Model Produk
import '../../../utils/product_helper.dart'; // Helper Warna & Gambar
import '../../../widgets/user/home/product_card_item.dart'; // Widget Item Card (Lokasi Baru)
// Sesuaikan import ini jika lokasi product detail berbeda
import '../product/product_detail_screen.dart'; 
import '../../auth/auth_screen.dart';
// import 'login_screen.dart'; // Uncomment jika sudah ada login screen

class UserHomeScreen extends StatefulWidget {
  final String role; 

  const UserHomeScreen({
    super.key, 
    required this.role
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // --- STATE VARIABLES ---
  final ApiService _apiService = ApiService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Color _backgroundColor = const Color(0xFFF4F7F6);

  // Helper untuk cek status login berdasarkan role yang dikirim
  bool get _isLoggedIn => widget.role == 'user';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // --- FETCH DATA DARI API ---
  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Panggil endpoint /produk (sesuaikan dengan backend kamu)
      final response = await _apiService.get('/produk');

      if (!mounted) return;

      // Cek format response (apakah langsung List atau ada di dalam key 'data')
      List<dynamic> data;
      if (response is Map && response.containsKey('data')) {
        data = response['data'];
      } else if (response is List) {
        data = response;
      } else {
        data = [];
      }

      setState(() {
        _products = data.map((json) => ProductModel.fromJson(json)).toList();
        _isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal memuat produk. Cek koneksi internet.";
      });
      debugPrint("Error fetching products: $e");
    }
  }

  // --- NAVIGASI ---
  void _navigateToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  void _goToDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProductDetailScreen(productId: product.id),
      ),
    );
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchProducts, // Tarik ke bawah untuk refresh
        color: ProductHelper.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _buildHeader(),

              // POLIS SECTION (Hanya jika Login)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isLoggedIn ? _buildMyPolisSection() : _buildLoginBanner(),
              ),

              const SizedBox(height: 24),

              // JUDUL REKOMENDASI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Rekomendasi Produk",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    // Jika error, tampilkan tombol retry kecil
                    if (_errorMessage != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        onPressed: _fetchProducts,
                      )
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // LIST PRODUK
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildProductContent(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    if (_isLoading) {
      return _buildListSkeleton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text("Belum ada produk tersedia.", style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(), // Scroll ikut parent
      shrinkWrap: true,
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCardItem(
          product: product,
          onTap: () => _goToDetail(product),
        );
      },
    );
  }

  // --- SKELETON LIST (SHIMMER) ---
  Widget _buildListSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(4, (index) => Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        )),
      ),
    );
  }

  // --- HEADER WIDGET ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ProductHelper.lightGreen,
            radius: 24,
            child: Icon(
              _isLoggedIn ? Icons.person : Icons.person_outline, 
              color: ProductHelper.primaryGreen
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLoggedIn ? "Halo, Kaming!" : "Selamat Datang!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _isLoggedIn ? "Proteksi Anda aktif." : "Temukan proteksi terbaikmu",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
          const Spacer(),
          if (_isLoggedIn)
            IconButton(
              onPressed: () {}, 
              icon: const Icon(Icons.notifications_outlined, color: Colors.grey)
            ),
        ],
      ),
    );
  }

  // --- LOGIN BANNER (USER BELUM LOGIN) ---
  Widget _buildLoginBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ProductHelper.darkGreen, ProductHelper.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ProductHelper.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Anda belum login",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "Masuk untuk melihat polis dan promo khusus member.",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: ProductHelper.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            ),
            child: const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- POLIS SECTION (USER SUDAH LOGIN) ---
  Widget _buildMyPolisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Polis Saya",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            TextButton(
              onPressed: () {}, 
              child: const Text("Lihat Semua", style: TextStyle(color: ProductHelper.primaryGreen))
            )
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4)
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ProductHelper.lightGreen,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Text(
                      "AKTIF", 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ProductHelper.primaryGreen)
                    )
                  ),
                  const Text("No. 88291002", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Asuransi Kesehatan Keluarga",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              const Text("Jatuh tempo: 25 Des 2024", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}