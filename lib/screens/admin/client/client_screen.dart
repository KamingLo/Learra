import 'dart:async';
import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../models/admin_user_model.dart';
import '../../../widgets/admin/client/client_card.dart';
import '../../../widgets/admin/client/client_detail_sheet.dart';
import '../../../widgets/admin/client/client_edit_sheet.dart';
import '../../../widgets/admin/client/client_empty_state.dart';

const Color _kBackground = Color(0xFFF4F7F6);
const Color _kPrimary = Color(0xFF06A900);
const Color _kTextPrimary = Color(0xFF111111);

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<AdminUser> _users = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({String query = ''}) async {
    if (mounted) {
      setState(() {
        _isLoading = !_isRefreshing;
      });
    }

    try {
      final endpoint = query.isEmpty ? '/users' : '/users?search=$query';
      final response = await _apiService.get(endpoint);
      if (!mounted) return;
      final dynamic raw = response;
      List<dynamic> data;
      if (raw is Map && raw['data'] is List) {
        data = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        data = raw;
      } else {
        data = [];
      }

      setState(() {
        _users = data.map((json) => AdminUser.fromJson(json)).toList();
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _handleSaveUser(Map<String, dynamic> data, String userId) async {
    await _apiService.put('/users/$userId', body: data);

    if (!mounted) return;

    await _fetchUsers(query: _searchQuery);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data pengguna diperbarui"),
        backgroundColor: _kPrimary,
      ),
    );
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _fetchUsers(query: query.trim());
    });
  }

  Future<void> _onRefresh() async {
    if (mounted) setState(() => _isRefreshing = true);
    await _fetchUsers(query: _searchQuery);
  }

  void _deleteUser(AdminUser user) async {
    try {
      await _apiService.delete('/users/${user.id}');
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Close bottom sheet
      await _fetchUsers(query: _searchQuery);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengguna berhasil dihapus"),
          backgroundColor: _kPrimary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus pengguna: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showDeleteConfirmation(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Pengguna"),
        content: Text(
          "Apakah Anda yakin ingin menghapus pengguna '${user.name}'? Tindakan ini tidak dapat dibatalkan.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => _deleteUser(user),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _showUserDetail(AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return ClientDetailSheet(
          user: user,
          onEdit: () => _showEditDialog(user),
          onDelete: () => _showDeleteConfirmation(user),
        );
      },
    );
  }

  void _showEditDialog(AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return ClientEditSheet(
          user: user,
          onSave: (data) async => _handleSaveUser(data, user.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        title: const Text(
          "Manajemen Pengguna",
          style: TextStyle(color: _kTextPrimary, fontWeight: FontWeight.w700),
        ),
        backgroundColor: _kBackground,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama, email, atau tanggal...',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: _kPrimary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  _onSearchChanged(value);
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _kPrimary),
                  )
                : RefreshIndicator(
                    color: _kPrimary,
                    onRefresh: _onRefresh,
                    child: _users.isEmpty
                        ? const ClientEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return ClientCard(
                                user: user,
                                onTap: () => _showUserDetail(user),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
