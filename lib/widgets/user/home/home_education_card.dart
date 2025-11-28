import 'package:flutter/material.dart';

class HomeEducationCard extends StatelessWidget {
  const HomeEducationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Pastikan container memenuhi lebar
      padding: const EdgeInsets.all(20), // Padding sedikit diperbesar agar lega
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Shadow lebih halus
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // 1. Bagian Title
          Text(
            "Apa itu Learra?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: 4),
          Text(
            "Learra adalah asuransi yang membantu Anda memperoleh proteksi dengan cepat dan interaktif. "
            "Dengan Learra, kamu dapat memiliki masa depan yang cerah dan terjamin.",
            style: TextStyle(
              fontSize: 13,
              height: 1.3, // Line height agar lebih mudah dibaca
              color: Colors.black54, // Warna sedikit lebih abu agar kontras dengan judul
            ),// Opsi: Rata kanan-kiri (bisa dihapus jika tidak suka)
          ),
        ],
      ),
    );
  }
}