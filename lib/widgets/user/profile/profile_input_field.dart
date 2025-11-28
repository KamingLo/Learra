import 'package:flutter/material.dart';

class ProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isReadOnly;
  final int maxLines;
  final VoidCallback? onTap;
  final IconData? suffixIcon;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const Color primaryGreen = Color(0xFF06A900);
    const Color deepGreen = Color(0xFF024000);
    const Color fieldBackground = Color(0xFFF7F7F7);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.2,
                ) ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            maxLines: maxLines,
            onTap: onTap, // aksi tap (penting untuk DatePicker)
            validator: isReadOnly
                ? null
                : (value) => value == null || value.isEmpty
                    ? "$label tidak boleh kosong"
                    : null,
            style: textTheme.bodyMedium?.copyWith(
              color: isReadOnly ? Colors.grey.shade600 : Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isReadOnly ? Colors.grey : primaryGreen,
              ),
              suffixIcon:
                  suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
              filled: true,
              fillColor: isReadOnly ? fieldBackground : Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: deepGreen, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}