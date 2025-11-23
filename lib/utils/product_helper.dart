import 'package:flutter/material.dart';

class ProductHelper {
  // Warna Utama (Hijau)
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color lightGreen = Color(0xFFE8F5E9); // Hijau sangat muda untuk background
  static const Color darkGreen = Color(0xFF1B5E20);

  // Logika Gambar Berdasarkan Tipe
  static String getImageUrl(String type) {
    final t = type.toLowerCase();
    if (t.contains('jiwa')) {
      return "https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=600&q=80";
    } else if (t.contains('kendaraan')) {
      return "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=600&q=80";
    } else if (t.contains('kesehatan')) {
      return "https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=600&q=80";
    } else {
      // Default / Umum
      return "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=600&q=80";
    }
  }
}