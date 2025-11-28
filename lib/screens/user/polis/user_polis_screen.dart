import 'package:flutter/material.dart';
import '../../../models/polis_model.dart';
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
  List<PolicyModel> _policies = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchPolicies();
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
      _currentUserId = sessionId;

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

      if (!mounted) return;
      setState(() {
        _policies = myPolicies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _buildErrorMessage(e);
      });
    }
  }

  bool _shouldShowBack(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) return false;
    return route.canPop;
  }

  String _buildErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('SocketException')) {
      return "Tidak ada koneksi internet";
    }

    if (message.contains('Cast to ObjectId')) {
      return "Terjadi kesalahan server. Mohon coba lagi nanti.";
    }

    if (message.contains('403')) return "Akses ditolak. Coba login ulang.";

    return message.replaceAll('Exception:', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchPolicies,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.grey[50],
                elevation: 0,
                pinned: false,
                floating: true,
                automaticallyImplyLeading: false,
                centerTitle: false,
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
                            onPressed: _fetchPolicies,
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
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Total Polis",
                            "${_policies.length}",
                            Icons.description_outlined,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "Polis Aktif",
                            "${_policies.where((p) => p.status.toLowerCase() == 'aktif').length}",
                            Icons.verified_outlined,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_policies.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Belum ada polis",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Polis yang Anda beli akan muncul di sini",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
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
                        final policy = _policies[index];
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
                      }, childCount: _policies.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ],
          ),
        ),
      ),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
