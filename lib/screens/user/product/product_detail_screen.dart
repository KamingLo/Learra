import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/product_model.dart';
import '../../../utils/product_helper.dart'; // Gunakan Helper

class UserProductDetailScreen extends StatefulWidget {
  final String productId; 

  const UserProductDetailScreen({super.key, required this.productId});

  @override
  State<UserProductDetailScreen> createState() => _UserProductDetailScreenState();
}

class _UserProductDetailScreenState extends State<UserProductDetailScreen> {
  final ApiService _apiService = ApiService();
  ProductModel? _product;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProductDetail();
  }

  Future<void> _fetchProductDetail() async {
    try {
      final response = await _apiService.get('/produk/${widget.productId}');
      if (!mounted) return;
      final data = (response is Map && response.containsKey('data')) ? response['data'] : response;

      setState(() {
        _product = ProductModel.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal memuat: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
            ]
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ProductHelper.primaryGreen))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(),
      
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent() {
    if (_product == null) return const SizedBox();

    // Ambil URL dari helper agar konsisten
    final imageUrl = ProductHelper.getImageUrl(_product!.tipe);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER IMAGE
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_,__,___) => Container(color: Colors.grey.shade200),
            ),
          ),
          
          // INFO BODY
          Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle UI
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)
                      ),
                    ),
                  ),

                  // Badge Tipe (Konsisten Hijau)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ProductHelper.lightGreen, // Background Hijau Muda
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _product!.tipe.toUpperCase(),
                      style: const TextStyle(
                        color: ProductHelper.darkGreen, // Teks Hijau Tua
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Judul
                  Text(
                    _product!.namaProduk,
                    style: const TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.w800, 
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Harga
                  Text(
                    "Rp ${_product!.premiDasar}",
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      color: ProductHelper.primaryGreen, // Harga Hijau
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Deskripsi
                  const Text(
                    "Deskripsi Produk",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.6),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5)
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lanjut ke pembayaran..."))
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ProductHelper.primaryGreen, // Tombol Hijau Solid
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0, // Flat design, modern
        ),
        child: const Text(
          "Beli Sekarang",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}