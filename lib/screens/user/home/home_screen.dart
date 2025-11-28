import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import '../../../models/polis_model.dart';
import '../../../services/session_service.dart';
import '../product/product_detail_screen.dart';
import '../../auth/auth_screen.dart';

// Import detail polis untuk navigasi langsung saat kartu diklik
import '../polis/user_polis_detail_screen.dart';

// Import widget yang sudah ada
import '../../../widgets/user/home/product_carousel.dart';
import '../../../widgets/user/home/home_category_selector.dart';
import '../../../widgets/user/home/home_header.dart';
import '../../../widgets/user/home/home_education_card.dart';
import '../../../widgets/user/home/home_quote_card.dart';

// Import widget policy carousel
import '../../../widgets/user/home/home_policy_carrousel.dart';

class UserHomeScreen extends StatefulWidget {
  final String role;
  // Callback untuk pindah tab navbar
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

  // State untuk Produk
  List<ProductModel> _products = [];
  bool _isLoadingProduct = true;

  // State untuk Polis
  List<PolicyModel> _policies = [];
  bool _isLoadingPolicy = false;

  final Color _primaryColor = const Color(0xFF0FA958);
  String? _userName;

  bool get _isLoggedIn => widget.role == 'user';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void didUpdateWidget(UserHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.role != oldWidget.role) {
      _loadAllData();
    }
  }

  Future<void> _loadAllData() async {
    await _loadUserData();
    _fetchProducts();

    if (_isLoggedIn) {
      _fetchPolicies();
    } else {
      if (mounted) {
        setState(() {
          _policies = [];
          _isLoadingPolicy = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    final name = await SessionService.getCurrentName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() => _isLoadingProduct = true);

    try {
      final response = await _apiService.get('/produk?limit=5');
      if (!mounted) return;

      final data = (response is Map && response.containsKey('data'))
          ? response['data'] as List
          : (response is List ? response : []);

      setState(() {
        _products = data.map((json) => ProductModel.fromJson(json)).toList();
        _isLoadingProduct = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProduct = false);
    }
  }

  // --- LOGIC FETCHING POLIS ---
  Future<void> _fetchPolicies() async {
    if (!mounted) return;
    setState(() => _isLoadingPolicy = true);

    try {
      final sessionId = await SessionService.getCurrentId();
      if (sessionId == null) {
        if (mounted) {
          setState(() {
            _policies = [];
            _isLoadingPolicy = false;
          });
        }
        return;
      }

      dynamic response;
      try {
        response = await _apiService.get('/user/polis');
      } catch (e) {
        debugPrint("Error fetching API: $e");
      }

      List<dynamic> rawList = [];
      if (response is Map) {
        if (response.containsKey('data') && response['data'] is List) {
          rawList = response['data'];
        } else if (response.containsKey('polis') && response['polis'] is List) {
          rawList = response['polis'];
        }
      } else if (response is List) {
        rawList = response;
      }

      List<PolicyModel> myPolicies = [];
      for (var item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            final p = PolicyModel.fromJson(item);
            if (p.ownerId == sessionId || p.ownerId.isEmpty) {
              myPolicies.add(p);
            }
          } catch (e) {
            debugPrint("Error parsing policy item: $e");
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _policies = myPolicies;
        _isLoadingPolicy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _policies = [];
        _isLoadingPolicy = false;
      });
      debugPrint("Global Error fetching policies: $e");
    }
  }

  void _goToDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => UserProductDetailScreen(productId: product.id)),
    );
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    ).then((_) => _loadAllData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: SizedBox(
          height: 48,
          child: Image.asset(
            'assets/IconApp/LearraFull.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text("Learra",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold));
            },
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadAllData();
        },
        color: _primaryColor,
        child: ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeHeader(
                userName: _userName,
                isLoggedIn: _isLoggedIn,
                primaryColor: _primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            // --- CAROUSEL REKOMENDASI ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Rekomendasi Terbaik",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        // Navigasi ke Tab Product (Biasanya index 1)
                        onPressed: () => widget.onSwitchTab?.call(1),
                        child: Text("Lihat Semua",
                            style: TextStyle(color: _primaryColor)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ProductCarousel(
                  products: _products,
                  isLoading: _isLoadingProduct,
                  onTap: _goToDetail,
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: HomeEducationCard(),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeCategorySelector(
                onCategorySelected: (category) {
                  widget.onCategoryTap?.call(category);
                },
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION POLIS ANDA ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Polis Anda",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      // Logic tombol Lihat Detail
                      if (_isLoggedIn && _policies.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // PERUBAHAN DI SINI:
                            // Memanggil callback onSwitchTab untuk pindah halaman via Navbar.
                            // Angka 2 adalah asumsi index tab 'Polis'. 
                            // Ganti angka 2 jika urutan navbar Anda berbeda (misal 0=Home, 1=Product, 2=Polis).
                            widget.onSwitchTab?.call(2); 
                          },
                          child: Text("Lihat Detail",
                              style: TextStyle(color: _primaryColor)),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HomePolicyCard(
                    isLoggedIn: _isLoggedIn,
                    isLoading: _isLoadingPolicy,
                    policies: _policies,
                    onLoginTap: _goToLogin,
                    onPolicyTap: (policy) {
                      // PERUBAHAN DI SINI:
                      // Navigasi Langsung ke Detail Polis (PolicyDetailScreen)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PolicyDetailScreen(policy: policy),
                        ),
                      ).then((_) {
                         // Refresh data polis setelah kembali (jika ada perubahan/penghapusan)
                         _fetchPolicies();
                      });
                    },
                    primaryColor: _primaryColor,
                  ),
                ),
              ],
            ), 
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: HomeQuoteCard(),
            ),
          ],
        ),
      ),
    );
  }
}