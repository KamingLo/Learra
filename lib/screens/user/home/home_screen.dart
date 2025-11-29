import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import '../../../models/polis_model.dart';
import '../../../services/session_service.dart';
import '../product/product_detail_screen.dart';
import '../../auth/auth_screen.dart';
import '../polis/user_polis_detail_screen.dart';
import '../../user/bantuan/helpfaq.dart'; 
import '../../../widgets/user/home/product_carousel.dart';
import '../../../widgets/user/home/home_category_selector.dart';
import '../../../widgets/user/home/home_header.dart';
import '../../../widgets/user/home/home_quote_card.dart';
import '../../../widgets/user/home/home_policy_carrousel.dart';
import '../../../widgets/user/home/home_faq_card.dart';

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
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  List<ProductModel> _products = [];
  bool _isLoadingProduct = true;

  List<PolicyModel> _policies = [];
  bool _isLoadingPolicy = false;

  final Color _primaryColor = const Color(0xFF0FA958);
  String? _userName;

  bool get _isLoggedIn => widget.role != 'guest' && widget.role != 'public';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(UserHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.role != oldWidget.role) {
      _loadAllData();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
    );
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
            debugPrint("Error parsing policy: $e");
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
    }
  }

  void _goToProductDetail(ProductModel product) {
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
    const int tabIndexProduct = 1;
    const int tabIndexPolis = 2;
    const int tabIndexProfile = 4;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black54),
            tooltip: 'Bantuan & FAQ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FAQPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadAllData();
        },
        color: _primaryColor,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeHeader(
                userName: _userName,
                isLoggedIn: _isLoggedIn,
                primaryColor: _primaryColor,
                onToProfile: () {
                  widget.onSwitchTab?.call(tabIndexProfile);
                },
              ),
            ),

            const SizedBox(height: 24),

            // PRODUCT SECTION
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
                        onPressed: () =>
                            widget.onSwitchTab?.call(tabIndexProduct),
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
                  onTap: _goToProductDetail,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // CATEGORY SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeCategorySelector(
                onCategorySelected: (category) {
                  widget.onCategoryTap?.call(category);
                },
              ),
            ),

            const SizedBox(height: 24),

            // POLICY SECTION
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isLoggedIn && _policies.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            widget.onSwitchTab?.call(tabIndexPolis);
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PolicyDetailScreen(policy: policy),
                        ),
                      ).then((_) {
                        _fetchPolicies();
                      });
                    },
                    primaryColor: _primaryColor,
                  ),
                ),
              ],
            ),

            // EDUCATION / FAQ CARD
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: HomeFaqCard(), 
            ),

            // QUOTE CARD (With Back To Top)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: HomeQuoteCard(
                onBackToTop: _scrollToTop,
              ),
            ),

            // --- BAGIAN BARU: FOOTER COPYRIGHT ---
            const SizedBox(height: 20), // Spacing dari quote card
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.8, // Agar tidak terlalu mencolok
                  child: SizedBox(
                    height: 48, // Ukuran logo proporsional
                    child: Image.asset(
                      'assets/IconApp/LearraFull.png',
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.verified_user, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "© ${2025} Learra. Hak Cipta Dilindungi.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Terdaftar dan diawasi oleh OJK",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 20), // Bottom safe area padding
              ],
            ),
          ],
        ),
      ),
    );
  }
}