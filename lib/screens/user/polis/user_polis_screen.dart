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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String tempFilterStatus = _filterStatus;
        String tempFilterCategory = _filterCategory;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Filter Polis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("Status Polis"),
                          const SizedBox(height: 12),
                          _buildFilterOption(
                            "Semua Status",
                            "Semua",
                            tempFilterStatus,
                            (val) =>
                                setSheetState(() => tempFilterStatus = val),
                          ),
                          const SizedBox(height: 8),
                          _buildFilterOption(
                            "Aktif",
                            "Aktif",
                            tempFilterStatus,
                            (val) =>
                                setSheetState(() => tempFilterStatus = val),
                          ),
                          const SizedBox(height: 8),
                          _buildFilterOption(
                            "Inaktif",
                            "Inaktif",
                            tempFilterStatus,
                            (val) =>
                                setSheetState(() => tempFilterStatus = val),
                          ),

                          const SizedBox(height: 24),

                          _buildSectionLabel("Kategori Asuransi"),
                          const SizedBox(height: 12),
                          _buildFilterOption(
                            "Semua Kategori",
                            "Semua",
                            tempFilterCategory,
                            (val) =>
                                setSheetState(() => tempFilterCategory = val),
                          ),
                          const SizedBox(height: 8),
                          _buildFilterOption(
                            "Kesehatan",
                            "Kesehatan",
                            tempFilterCategory,
                            (val) =>
                                setSheetState(() => tempFilterCategory = val),
                          ),
                          const SizedBox(height: 8),
                          _buildFilterOption(
                            "Jiwa",
                            "Jiwa",
                            tempFilterCategory,
                            (val) =>
                                setSheetState(() => tempFilterCategory = val),
                          ),
                          const SizedBox(height: 8),
                          _buildFilterOption(
                            "Kendaraan",
                            "Kendaraan",
                            tempFilterCategory,
                            (val) =>
                                setSheetState(() => tempFilterCategory = val),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              tempFilterStatus = 'Semua';
                              tempFilterCategory = 'Semua';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            "Reset",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
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
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Terapkan Filter",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildFilterOption(
    String label,
    String value,
    String currentValue,
    Function(String) onSelect,
  ) {
    final isSelected = currentValue.toLowerCase() == value.toLowerCase();

    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green[300]! : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          visualDensity: VisualDensity.compact,
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.green[700] : Colors.black87,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: Colors.green[600], size: 22)
              : Icon(Icons.circle_outlined, color: Colors.grey[300], size: 22),
        ),
      ),
    );
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
                hintText: 'Cari nama produk, no. polis...',
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
            onPressed: _showFilterSheet,
          ),
        ),
      ],
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
