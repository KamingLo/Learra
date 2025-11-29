import 'package:flutter/material.dart';
import '../../../models/polis_model.dart';
import '../../../models/product_model.dart';
import '../../../widgets/user/polis/user_polis_card.dart';
import '../../../services/api_service.dart';
import '../../../services/session_service.dart';
import 'user_polis_detail_screen.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<PolicyModel> _policies = [];
  List<PolicyModel> _filteredPolicies = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _filterStatus = 'Semua';
  String _filterCategory = 'Semua';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchPolicies();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _fetchPolicies() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessionId = await SessionService.getCurrentId();
      if (sessionId == null) {
        throw Exception("Sesi berakhir. Silakan login kembali.");
      }
      List<PolicyModel> myPolicies = [];
      dynamic response;

      try {
        response = await _apiService.get('/user/polis');
      } catch (_) {}

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

      for (var item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            final p = PolicyModel.fromJson(item);
            if (p.ownerId == sessionId || p.ownerId.isEmpty) {
              myPolicies.add(p);
            }
          } catch (_) {}
        }
      }

      final enrichedPolicies = await _hydrateProductNames(myPolicies);

      if (!mounted) return;
      setState(() {
        _policies = enrichedPolicies;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _buildErrorMessage(e);
      });
    }
  }

  void _applyFilters() {
    final searchQuery = _searchController.text.toLowerCase();
    final selectedStatus = _filterStatus.toLowerCase();
    final selectedCategory = _filterCategory.toLowerCase();

    setState(() {
      _filteredPolicies = _policies.where((policy) {
        final matchesSearch =
            searchQuery.isEmpty ||
            policy.productName.toLowerCase().contains(searchQuery) ||
            policy.policyNumber.toLowerCase().contains(searchQuery);

        final matchesStatus =
            selectedStatus == 'semua' ||
            _normalizeStatus(policy.status) == selectedStatus;

        final matchesCategory =
            selectedCategory == 'semua' ||
            policy.category.toLowerCase() == selectedCategory;

        return matchesSearch && matchesStatus && matchesCategory;
      }).toList();

      _sortPolicyList(_filteredPolicies);
    });
  }

  void _sortPolicyList(List<PolicyModel> list) {
    list.sort((a, b) {
      final aDate = a.createdAt ?? a.expiredDate;
      final bDate = b.createdAt ?? b.expiredDate;
      final comparison = aDate.compareTo(bDate);
      return _sortOrder == 'asc' ? comparison : -comparison;
    });
  }

  void _changeSortOrder(String order) {
    if (_sortOrder == order) return;
    setState(() {
      _sortOrder = order;
      _sortPolicyList(_filteredPolicies);
    });
  }

  String _normalizeStatus(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('inaktif') ||
        lower.contains('tidak aktif') ||
        lower.contains('nonaktif')) {
      return 'inaktif';
    }
    return 'aktif';
  }

  Future<List<PolicyModel>> _hydrateProductNames(
    List<PolicyModel> policies,
  ) async {
    final missingIds = policies
        .where(
          (p) =>
              (p.productName.isEmpty || p.productName == 'Produk Asuransi') &&
              (p.productId?.isNotEmpty ?? false),
        )
        .map((p) => p.productId!)
        .toSet();

    if (missingIds.isEmpty) return policies;

    final productMap = <String, ProductModel>{};
    for (final id in missingIds) {
      try {
        final response = await _apiService.get('/produk/$id');
        final data = (response is Map && response['data'] is Map)
            ? response['data']
            : (response is Map ? response : null);
        if (data != null) {
          productMap[id] = ProductModel.fromJson(data);
        }
      } catch (_) {}
    }

    if (productMap.isEmpty) return policies;

    return policies.map((policy) {
      if (policy.productId != null &&
          productMap.containsKey(policy.productId) &&
          (policy.productName.isEmpty ||
              policy.productName == 'Produk Asuransi')) {
        final product = productMap[policy.productId]!;
        return policy.copyWith(
          productName: product.namaProduk,
          productType: product.tipe,
        );
      }
      return policy;
    }).toList();
  }

  String _buildErrorMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('SocketException')) return "Tidak ada koneksi internet";
    return msg.replaceAll('Exception:', '').trim();
  }

  String get _sortLabel => _sortOrder == 'desc' ? 'Terbaru' : 'Terlama';

  bool _shouldShowBack(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) return false;
    return route.canPop;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _fetchPolicies,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.grey[50],
                elevation: 0,
                pinned: true,
                floating: false,
                automaticallyImplyLeading: false,
                titleSpacing: 0,

                title: Row(
                  children: [
                    if (_shouldShowBack(context))
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                        color: Colors.black87,
                      ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Daftar Polis Saya",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _buildSearchBar(),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              "Total Polis",

                              "${_filteredPolicies.length}",
                              Icons.description_outlined,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              "Polis Aktif",

                              "${_filteredPolicies.where((p) => p.status.toLowerCase() == 'aktif').length}",
                              Icons.verified_outlined,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Semua', _filterStatus, (val) {
                              setState(() => _filterStatus = val);
                              _applyFilters();
                            }),
                            const SizedBox(width: 8),
                            _buildFilterChip('Aktif', _filterStatus, (val) {
                              setState(() => _filterStatus = val);
                              _applyFilters();
                            }),
                            const SizedBox(width: 8),
                            _buildFilterChip('Inaktif', _filterStatus, (val) {
                              setState(() => _filterStatus = val);
                              _applyFilters();
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Kategori",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Semua', _filterCategory, (val) {
                              setState(() => _filterCategory = val);
                              _applyFilters();
                            }),
                            const SizedBox(width: 8),
                            _buildFilterChip('Kesehatan', _filterCategory, (
                              val,
                            ) {
                              setState(() => _filterCategory = val);
                              _applyFilters();
                            }),
                            const SizedBox(width: 8),
                            _buildFilterChip('Jiwa', _filterCategory, (val) {
                              setState(() => _filterCategory = val);
                              _applyFilters();
                            }),
                            const SizedBox(width: 8),
                            _buildFilterChip('Kendaraan', _filterCategory, (
                              val,
                            ) {
                              setState(() => _filterCategory = val);
                              _applyFilters();
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            _changeSortOrder(
                              _sortOrder == 'desc' ? 'asc' : 'desc',
                            );
                          },
                          icon: Icon(
                            _sortOrder == 'desc'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          label: Text(
                            "Urutkan $_sortLabel",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(child: Center(child: Text(_errorMessage!)))
              else if (_filteredPolicies.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 72,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ada polis ditemukan",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final policy = _filteredPolicies[index];
                      return PolicyCard(
                        policy: policy,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PolicyDetailScreen(policy: policy),
                            ),
                          );
                        },
                      );
                    }, childCount: _filteredPolicies.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Cari nama produk, no. polis...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.green.shade600,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String groupValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = groupValue.toLowerCase() == label.toLowerCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(label),
      backgroundColor: Colors.white,
      selectedColor: Colors.green.shade50,
      checkmarkColor: Colors.green.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? Colors.green.shade300 : Colors.grey.shade300,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
