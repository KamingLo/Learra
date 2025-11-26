import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/menu_config.dart';
import '../screens/auth/login_screen.dart'; // <-- Diperbarui

class MainNavbar extends StatefulWidget {
  final String role;
  const MainNavbar({super.key, required this.role});

  @override
  State<MainNavbar> createState() => _MainNavbarState();
}

class _MainNavbarState extends State<MainNavbar> {
  int _currentIndex = 0;
  late List<NavItem> _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = MenuConfig.getMenus(widget.role);
  }

  void _onItemTapped(int index) {
    if (widget.role == 'guest' && index == _menuItems.length - 1) {
      // Navigasi ke LoginScreen saat mengklik menu 'Masuk'
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // --- 1. KONFIGURASI UKURAN YANG LEBIH PROPORSIONAL ---
    const double navBarHeight = 70.0;  // Tinggi total navbar
    const double bubbleSize = 42.0;    // Diperkecil (sebelumnya 50)
    const double iconSize = 24.0;      // Ukuran icon standar
    const double sidePadding = 12.0;   // Jarak aman kiri-kanan di dalam navbar
    
    const Duration animDuration = Duration(milliseconds: 300);
    const Curve animCurve = Curves.fastOutSlowIn;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F7FA),
      
      body: _menuItems[_currentIndex].screen,

      bottomNavigationBar: Container(
        height: navBarHeight,
        // Margin luar agar navbar melayang
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24), 
        // Padding dalam agar item paling kiri/kanan tidak nabrak sudut bulat
        padding: const EdgeInsets.symmetric(horizontal: sidePadding), 
        
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Lebar tersedia dibagi jumlah menu
            final double itemWidth = constraints.maxWidth / _menuItems.length;
            
            // Posisi Bubble: (Lebar Item / 2) - (Lebar Bubble / 2)
            // Ditambah (Index * Lebar Item)
            final double centerOffset = (itemWidth - bubbleSize) / 2;
            final double bubbleLeftPosition = (_currentIndex * itemWidth) + centerOffset;

            // Posisi vertikal bubble agar pas tengah secara vertikal dengan Icon
            // (Tinggi Icon Area - Tinggi Bubble) / 2 + Top Padding Icon
            const double iconAreaTopPadding = 6.0; // Jarak ikon dari atas

            return Stack(
              children: [
                // --- LAYER 1: SLIDING BUBBLE ---
                AnimatedPositioned(
                  duration: animDuration,
                  curve: animCurve,
                  top: iconAreaTopPadding, 
                  left: bubbleLeftPosition,
                  child: Container(
                    width: bubbleSize,
                    height: bubbleSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                  ),
                ),

                // --- LAYER 2: ICONS & TEXTS ---
                Row(
                  children: _menuItems.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final NavItem item = entry.value;
                    final bool isSelected = index == _currentIndex;

                    return SizedBox(
                      width: itemWidth,
                      height: navBarHeight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onItemTapped(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // 2. PEMBUNGKUS ICON
                            // Tingginya harus cukup untuk menampung bubble + padding
                            Container(
                              padding: const EdgeInsets.only(top: iconAreaTopPadding),
                              height: bubbleSize + iconAreaTopPadding, 
                              alignment: Alignment.center,
                              child: TweenAnimationBuilder<Color?>(
                                duration: animDuration,
                                tween: ColorTween(
                                  begin: Colors.grey, 
                                  end: isSelected ? Colors.white : Colors.grey.shade400
                                ),
                                builder: (context, color, child) {
                                  return Icon(item.icon, color: color, size: iconSize);
                                },
                              ),
                            ),
                            
                            // 3. LABEL TEXT (Jarak sedikit dari icon)
                            const SizedBox(height: 2),
                            AnimatedOpacity(
                              duration: animDuration,
                              opacity: isSelected ? 1.0 : 0.8,
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 10, // Font size pas agar tidak nabrak
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? colorScheme.primary : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}