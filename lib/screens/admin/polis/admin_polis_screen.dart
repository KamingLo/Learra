import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/polis_model.dart';
import '../../../models/product_model.dart';
import '../../../widgets/admin/polis/admin_polis_card.dart';
import '../../../services/api_service.dart';

class AdminPolicyScreen extends StatefulWidget {
  const AdminPolicyScreen({super.key});

  @override
  State<AdminPolicyScreen> createState() => _AdminPolicyScreenState();
}

class _AdminPolicyScreenState extends State<AdminPolicyScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

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
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _fetchPolicies(query: query.trim());
    });
    _applyFilters();
  }

  Future<void> _fetchPolicies({String query = ''}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String endpoint = query.isEmpty ? '/polis' : '/polis?search=$query';
      final response = await _apiService.get(endpoint);

      if (!mounted) return;

      List<dynamic> data;
      if (response is Map && response.containsKey('data')) {
        data = response['data'] is List ? response['data'] : [];
      } else if (response is List) {
        data = response;
      } else {
        data = [];
      }

      List<PolicyModel> initialPolicies = data
          .map((json) => PolicyModel.fromJson(json))
          .toList();

      final enrichedPolicies = await _hydrateProductNames(initialPolicies);

      setState(() {
        _policies = enrichedPolicies;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Gagal memuat polis. ${e.toString().replaceAll('Exception: ', '')}";
      });
    }
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

  void _applyFilters() {
    final searchQuery = _searchController.text.toLowerCase();
    final selectedStatus = _filterStatus.toLowerCase();
    final selectedCategory = _filterCategory.toLowerCase();

    setState(() {
      _filteredPolicies = _policies.where((policy) {
        final matchesSearch =
            searchQuery.isEmpty ||
            (policy.ownerName ?? '').toLowerCase().contains(searchQuery) ||
            policy.policyNumber.toLowerCase().contains(searchQuery) ||
            policy.productName.toLowerCase().contains(searchQuery) ||
            (policy.ownerEmail ?? '').toLowerCase().contains(searchQuery);

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

  Future<void> _refreshPolicies() async {
    await _fetchPolicies(query: _searchController.text.trim());
  }

  void _sortPolicyList(List<PolicyModel> list) {
    list.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
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

  String get _sortLabel => _sortOrder == 'desc' ? 'Terbaru' : 'Terlama';

  bool _shouldShowBack(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) return false;
    return route.canPop;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempFilterStatus = _filterStatus;
        String tempFilterCategory = _filterCategory;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Filter Polis',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogSectionTitle('Status Polis'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ['Semua', 'Aktif', 'Inaktif'].map((status) {
                        return _buildDialogFilterChip(
                          label: status,
                          groupValue: tempFilterStatus,
                          onSelected: (val) {
                            setStateDialog(() => tempFilterStatus = val);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    _buildDialogSectionTitle('Kategori Asuransi'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ['Semua', 'Kesehatan', 'Jiwa', 'Kendaraan'].map(
                        (cat) {
                          return _buildDialogFilterChip(
                            label: cat,
                            groupValue: tempFilterCategory,
                            onSelected: (val) {
                              setStateDialog(() => tempFilterCategory = val);
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setStateDialog(() {
                            tempFilterStatus = 'Semua';
                            tempFilterCategory = 'Semua';
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filterStatus = tempFilterStatus;
                            _filterCategory = tempFilterCategory;
                            _applyFilters();
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Terapkan'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildDialogFilterChip({
    required String label,
    required String groupValue,
    required ValueChanged<String> onSelected,
  }) {
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
        width: isSelected ? 1.5 : 1.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshPolicies,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
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
                        "Daftar Polis Pengguna",
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
                  preferredSize: const Size.fromHeight(80),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _buildSearchBar(),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickStatCard(
                              "Total Polis",
                              "${_policies.length}",
                              Icons.description_outlined,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickStatCard(
                              "Polis Aktif",
                              "${_policies.where((p) => p.status.toLowerCase() == 'aktif').length}",
                              Icons.verified_outlined,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
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
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _fetchPolicies(),
                            icon: const Icon(Icons.refresh),
                            label: const Text("Coba Lagi"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AdminPolicyCard(
                        policy: _filteredPolicies[index],
                        onRefresh: _refreshPolicies,
                      ),
                      childCount: _filteredPolicies.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final bool isFilterActive =
        _filterStatus != 'Semua' || _filterCategory != 'Semua';

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama user, polis...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: isFilterActive ? Colors.green.shade50 : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: isFilterActive
                ? Border.all(color: Colors.green.shade600, width: 2)
                : null,
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune,
              color: isFilterActive ? Colors.green.shade700 : Colors.grey[700],
            ),
            onPressed: _showFilterDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
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
