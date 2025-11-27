import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import '../product/product_detail_screen.dart'; 
import '../../auth/auth_screen.dart';

// Import Widget Carousel Baru (Pastikan path-nya benar)
import '../../../widgets/user/home/product_carousel.dart'; 

class UserHomeScreen extends StatefulWidget {
  final String role;
  final Function(int)? onSwitchTab; 

  const UserHomeScreen({super.key, required this.role, this.onSwitchTab});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final ApiService _apiService = ApiService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  
  final Color _primaryColor = const Color(0xFF0FA958);

  bool get _isLoggedIn => widget.role == 'user';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.get('/produk?limit=5');
      if (!mounted) return;

      final data = (response is Map && response.containsKey('data')) 
          ? response['data'] as List 
          : (response is List ? response : []);

      setState(() {
        _products = data.map((json) => ProductModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _goToDetail(ProductModel product) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => UserProductDetailScreen(productId: product.id))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        color: _primaryColor,
        child: ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          children: [
            // 1. HEADER (Dengan Padding Horizontal)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHeader(),
            ),

            const SizedBox(height: 24),

            // 2. CAROUSEL PRODUK (Full Width / Tanpa Padding Horizontal Parent)
            // Ini sekarang ada di posisi KEDUA (di bawah header)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Kecil di atas Carousel (Opsional, agar user tau ini apa)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Rekomendasi Terbaik",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // Tombol Lihat Semua
                      TextButton(
                        onPressed: () => widget.onSwitchTab?.call(1),
                        child: Text("Lihat Semua", style: TextStyle(color: _primaryColor)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Widget Carousel 16:9
                ProductCarousel(
                  products: _products, 
                  isLoading: _isLoading, 
                  onTap: _goToDetail,
                ),
              ],
            ),
            
            const SizedBox(height: 30),

            // 3. POLIS YANG DIMILIKI (Hero Section)
            // Ini sekarang ada di posisi KETIGA (di bawah carousel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Section Polis
                  const Text(
                    "Polis Anda", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  _buildHeroSection(),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER (Header & Hero) TETAP SAMA ---
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54, width: 54,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded, color: _primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoggedIn ? "Halo!" : "Selamat Datang!", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoggedIn ? "Semoga harimu menyenangkan" : "Temukan perlindunganmu", 
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500)
                ),
              ],
            ),
          ),
          // Tombol Notif
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(Icons.notifications_outlined, size: 22, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    if (!_isLoggedIn) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Akses Penuh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text("Masuk untuk melihat polis Anda.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _primaryColor),
              child: const Text("Masuk"),
            )
          ],
        ),
      );
    }
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text("POLIS AKTIF", style: TextStyle(color: _primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                 Icon(Icons.health_and_safety, size: 40, color: Colors.orange),
                 SizedBox(width: 12),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text("Kesehatan Plus", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text("Berlaku s/d Des 2024", style: TextStyle(color: Colors.grey, fontSize: 12)),
                   ],
                 )
              ],
            )
          ],
        ),
      ),
    );
  }
}