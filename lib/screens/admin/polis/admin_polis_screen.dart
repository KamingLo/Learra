import 'package:flutter/material.dart';
import '../../../models/polis_model.dart';
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

  List<PolicyModel> _policies = [];
  List<PolicyModel> _filteredPolicies = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'Semua';
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

  Future<void> _fetchPolicies({String? searchQuery}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String endpoint = '/polis';
      if (searchQuery != null && searchQuery.isNotEmpty) {
        endpoint += '?search=${Uri.encodeComponent(searchQuery)}';
      }

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

      setState(() {
        _policies = data.map((json) => PolicyModel.fromJson(json)).toList();
        _sortPolicyList(_policies);
        _applyFilters();
        _isLoading = false;
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

  void _applyFilters() {
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredPolicies = _policies.where((policy) {
        final matchesSearch =
            searchQuery.isEmpty ||
            (policy.ownerName ?? '').toLowerCase().contains(searchQuery) ||
            policy.policyNumber.toLowerCase().contains(searchQuery) ||
            policy.productName.toLowerCase().contains(searchQuery) ||
            (policy.ownerEmail ?? '').toLowerCase().contains(searchQuery);

        final selectedFilter = _filterStatus.toLowerCase();
        final matchesStatus =
            selectedFilter == 'semua' ||
            _normalizeStatus(policy.status) == selectedFilter;

        return matchesSearch && matchesStatus;
      }).toList();
      _sortPolicyList(_filteredPolicies);
    });
  }

  Future<void> _refreshPolicies() async {
    final currentQuery = _searchController.text.trim();
    await _fetchPolicies(
      searchQuery: currentQuery.isNotEmpty ? currentQuery : null,
    );
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
      _sortPolicyList(_policies);
      _applyFilters();
    });
  }

  String get _sortLabel => _sortOrder == 'desc' ? 'Terbaru' : 'Terlama';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPolicies,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.grey[50],
                elevation: 0,
                pinned: false,
                floating: true,
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
                        "Polis Pengguna",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (value) =>
                              _fetchPolicies(searchQuery: value),
                          decoration: InputDecoration(
                            hintText: "Cari nama, no. polis, produk...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
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
                                      _fetchPolicies();
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
                      ),
                      const SizedBox(height: 16),

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
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('Semua'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Aktif'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Inaktif'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Dibatalkan'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AdminPolicyCard(
                          policy: _filteredPolicies[index],
                          onRefresh: _refreshPolicies,
                        ),
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
            color: Colors.black.withValues(alpha:0.04),
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
              color: color.withValues(alpha:0.1),
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

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus.toLowerCase() == label.toLowerCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = label;
        });
        _applyFilters();
      },
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

  String _normalizeStatus(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('batal')) return 'dibatalkan';
    if (lower.contains('inaktif') ||
        lower.contains('tidak aktif') ||
        lower.contains('nonaktif')) {
      return 'inaktif';
    }
    return 'aktif';
  }

  bool _shouldShowBack(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) return false;
    return route.canPop;
  }
}
