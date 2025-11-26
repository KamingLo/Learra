import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../main.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _apiService = ApiService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _identitasController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _rentangGajiController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.post('/auth/register', body: {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "confirmPassword": _confirmPassController.text,
        "nomorIdentitas": _identitasController.text.trim(),
        "phone": _phoneController.text.trim(),
        "birthDate": _birthDateController.text.trim(),
        "address": _addressController.text.trim(),
        "pekerjaan": _pekerjaanController.text.trim(),
        "rentangGaji": _rentangGajiController.text.trim(),
        "role": "user",
      });

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Register gagal');
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception: ", "");
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null) ...[
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
        ],

        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
        TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
        TextField(controller: _confirmPassController, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
        TextField(controller: _identitasController, decoration: const InputDecoration(labelText: 'Nomor Identitas')),
        TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              initialDate: DateTime(2000),
            );
            if (picked != null) {
              _birthDateController.text = picked.toIso8601String().split('T').first;
              setState(() {});
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: _birthDateController,
              decoration: const InputDecoration(
                labelText: 'Birth Date',
              ),
            ),
          ),
        ),
        TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Alamat')),
        TextField(controller: _pekerjaanController, decoration: const InputDecoration(labelText: 'Pekerjaan')),
        DropdownButtonFormField<String>(
          value: _rentangGajiController.text.isEmpty ? null : _rentangGajiController.text,
          items: const [
            DropdownMenuItem(value: '1.000.000 - 9.999.999', child: Text('1.000.000 - 9.999.999')),
            DropdownMenuItem(value: '10.000.000 - 49.999.999', child: Text('10.000.000 - 49.999.999')),
            DropdownMenuItem(value: '50.000.000 - 99.999.999', child: Text('50.000.000 - 99.999.999')),
            DropdownMenuItem(value: '100.000.000 +', child: Text('≥ 100.000.000')),
          ],
          onChanged: (value) {
            _rentangGajiController.text = value ?? '';
          },
          decoration: const InputDecoration(labelText: 'Rentang Gaji'),
        ),

        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Register'),
        ),
      ],
    );
  }
}
