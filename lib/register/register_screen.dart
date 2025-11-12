// ============================================
// register.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedIncome;

  final List<String> _incomeRanges = [
    '< 10.000.000',
    '10.000.000 - 25.000.000',
    '50.000.000 - 250.000.000',
    '250.000.000 - 500.000.000',
    '> 500.000.000',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF06A900),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.login,
                size: 50,
                color: Color(0xFF06A900),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Buat Akun',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buat Akun Sekarang',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF3F3F3F),
              ),
            ),
            const SizedBox(height: 30),
            
            // Name Field
            _buildTextField(
              label: 'Nama',
              controller: _nameController,
              hintText: '',
            ),
            const SizedBox(height: 16),
            
            // Email Field
            _buildTextField(
              label: 'Email',
              controller: _emailController,
              hintText: '',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // Password Field
            _buildTextField(
              label: 'Password',
              controller: _passwordController,
              hintText: '',
              isPassword: true,
              obscureText: _obscurePassword,
              onTogglePassword: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Confirm Password Field
            _buildTextField(
              label: 'Ulang password',
              controller: _confirmPasswordController,
              hintText: '',
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onTogglePassword: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Date of Birth Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanggal lahir',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    hintText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF3F3F3F)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF06A900), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Phone Number Field
            _buildTextField(
              label: 'Nomor identitas (NIK)',
              controller: _phoneController,
              hintText: '',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Job Field
            _buildTextField(
              label: 'Pekerjaan',
              controller: _jobController,
              hintText: '',
            ),
            const SizedBox(height: 16),
            
            // Income Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rentang pendapatan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedIncome,
                  hint: const Text('Pilih rentang pendapatanmu (dropdown)'),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF06A900), width: 2),
                    ),
                  ),
                  items: _incomeRanges.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedIncome = newValue;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Handle registration
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06A900),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Daftar Akun Baru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Divider
            Row(
              children: const [
                Expanded(child: Divider(color: Color(0xFF3F3F3F))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'atau punya akun?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3F3F3F),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Color(0xFF3F3F3F))),
              ],
            ),
            const SizedBox(height: 20),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06A900),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Masuk ke akunmu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF06A900), width: 2),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF3F3F3F),
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}