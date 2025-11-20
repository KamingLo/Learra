import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../widgets/admin/product/product_form_fields.dart'; // Import Widget Form

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product; 

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  String _selectedType = 'kesehatan';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.namaProduk ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.premiDasar.toString() ?? '');
    if (widget.product != null) {
      _selectedType = widget.product!.tipe;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final body = {
      "namaProduk": _nameController.text,
      "description": _descController.text,
      "premiDasar": int.parse(_priceController.text),
      "tipe": _selectedType,
    };

    try {
      if (widget.product == null) {
        await _apiService.post('/produk', body: body);
      } else {
        await _apiService.put('/produk/${widget.product!.id}', body: body);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil menyimpan produk!")),
      );
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Produk" : "Tambah Produk Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ProductFormFields(
            nameController: _nameController,
            descController: _descController,
            priceController: _priceController,
            selectedType: _selectedType,
            isEdit: isEdit,
            isLoading: _isLoading,
            onTypeChanged: (val) => setState(() => _selectedType = val!),
            onSubmit: _saveProduct,
          ),
        ),
      ),
    );
  }
}