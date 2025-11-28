import 'package:flutter/material.dart';

class HomeCategorySelector extends StatelessWidget {
  final Function(String) onCategorySelected;

  const HomeCategorySelector({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    // List kategori
    final List<Map<String, dynamic>> categories = [
      {'label': 'Kesehatan', 'icon': Icons.medical_services_rounded, 'value': 'Kesehatan'},
      {'label': 'Jiwa', 'icon': Icons.favorite_rounded, 'value': 'Jiwa'},
      {'label': 'Kendaraan', 'icon': Icons.directions_car_filled_rounded, 'value': 'Kendaraan'},
      {'label': 'Semua', 'icon': Icons.grid_view_rounded, 'value': ''}, 
    ];

    return Container(
      // 1. Ini adalah "Card" pembungkus utama
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Judul di dalam Card
          const Text(
            "Kategori Pilihan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16), // Jarak antara judul dan ikon
          
          // 3. Baris Ikon Kategori
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) {
              return _CategoryItem(
                label: cat['label'],
                icon: cat['icon'],
                onTap: () => onCategorySelected(cat['value']),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label, 
    required this.icon, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Kotak Ikon (Disederhanakan karena sudah ada di dalam Card putih)
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              // Menggunakan warna background hijau sangat muda agar kontras dengan card putih
              color: Colors.green.shade800.withValues(alpha:0.08), 
              borderRadius: BorderRadius.circular(16),
              // Kita hilangkan border/shadow individu agar tidak terlalu "ramai"
            ),
            child: Icon(icon, color: Colors.green.shade800, size: 26),
          ),
          const SizedBox(height: 8),
          
          // Label text
          Text(
            label,
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.w600, 
              color: Colors.grey.shade700
            ),
          ),
        ],
      ),
    );
  }
}