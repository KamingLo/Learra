import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import '../product/product_detail_screen.dart';
import '../../auth/auth_screen.dart';
import '../../../widgets/user/home/product_carousel.dart'; 
import '../../../widgets/user/home/home_category_selector.dart';
// 1. Import SessionService
import '../../../services/session_service.dart'; 

class UserHomeScreen extends StatefulWidget {
  final String role;
  final Function(int)? onSwitchTab; 
  final Function(String)? onCategoryTap;

  const UserHomeScreen({
    super.key, 
    required this.role, 
    this.onSwitchTab,
    this.onCategoryTap,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final ApiService _apiService = ApiService();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  final Color _primaryColor = const Color(0xFF0FA958);

  // 2. Variabel Nama (Default null atau string kosong)
  String? _userName; 

  bool get _isLoggedIn => widget.role == 'user';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    // 3. Panggil load data saat pertama kali dibuka
    _loadUserData(); 
  }

  // 4. PENTING: Deteksi perubahan Role (Misal dari Guest -> Login jadi User)
  @override
  void didUpdateWidget(UserHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika role berubah (atau parent merebuild widget ini), kita cek nama lagi
    if (widget.role != oldWidget.role || widget.role == 'user') {
      _loadUserData();
    }
  }

  // 5. Fungsi Load Data (Sama persis dengan ProfileScreen Anda)
  Future<void> _loadUserData() async {
    // Ambil nama dari SessionService
    final name = await SessionService.getCurrentName();
    
    // Pastikan widget masih aktif sebelum setState
    if (mounted) {
      setState(() {
        _userName = name; // Isi variabel _userName
      });
    }
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => UserProductDetailScreen(productId: product.id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchProducts();
          await _loadUserData(); // Bisa refresh manual tarik layar
        },
        color: _primaryColor,
        child: ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHeader(),
            ),

            const SizedBox(height: 24),

            // CAROUSEL
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Rekomendasi Terbaik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => widget.onSwitchTab?.call(1),
                        child: Text(
                          "Lihat Semua",
                          style: TextStyle(color: _primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ProductCarousel(
                  products: _products,
                  isLoading: _isLoading,
                  onTap: _goToDetail,
                ),
              ],
            ),

            const SizedBox(height: 30),
            // KATEGORI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeCategorySelector(
                onCategorySelected: (category) {
                  widget.onCategoryTap?.call(category);
                },
              ),
            ),

            const SizedBox(height: 24),

            // POLIS HERO SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Polis Anda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
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

  Widget _buildHeader() {
    // Tentukan teks nama. 
    // Jika _userName ada isinya, pakai itu. Jika null, pakai "User".
    final displayName = _userName ?? "User";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft, // Mulai dari Kiri
          end: Alignment.centerRight,   // Berakhir di Kanan
          colors: [
            Colors.green.shade800,      // Hijau lebih gelap
            Colors.green.shade700,      // Hijau sedikit lebih terang
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            height: 48, width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded, color: _primaryColor, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoggedIn ? "Halo, $displayName!" : "Selamat Datang!", // <--- Pakai displayName
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoggedIn ? "Semoga harimu menyenangkan" : "Temukan perlindunganmu", 
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade300)
                ),
              ],
            ),
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
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Akses Penuh",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Masuk untuk melihat polis Anda.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _primaryColor,
              ),
              child: const Text("Masuk"),
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "POLIS AKTIF",
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
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
                    Text(
                      "Kesehatan Plus",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Berlaku s/d Des 2024",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
