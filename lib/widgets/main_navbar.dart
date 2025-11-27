import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- IMPORTS ---
// Sesuaikan path ini dengan struktur foldermu
import '../config/menu_config.dart';
import '../screens/auth/auth_screen.dart';
import '../../screens/user/home/home_screen.dart'; // Import ini PENTING agar bisa deteksi UserHomeScreen

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
    _initializeMenu();
  }

  /// Inisialisasi menu dan menyuntikkan callback ke UserHomeScreen
  void _initializeMenu() {
    // 1. Ambil konfigurasi menu awal dari MenuConfig
    final List<NavItem> originalMenus = MenuConfig.getMenus(widget.role);

    // 2. Kita perlu memodifikasi item menu jika itu adalah UserHomeScreen
    // agar kita bisa memberikan fungsi 'onSwitchTab' kepadanya.
    _menuItems = originalMenus.map((item) {
      
      // Cek apakah screen yang didaftarkan adalah UserHomeScreen
      if (item.screen is UserHomeScreen) {
        return NavItem(
          icon: item.icon,
          label: item.label,
          
          // Ganti screen dengan instance baru yang membawa callback
          screen: UserHomeScreen(
            role: widget.role,
            onSwitchTab: (int targetIndex) {
              // Fungsi ini akan dipanggil dari dalam Home Screen
              _onItemTapped(targetIndex);
            },
          ),
        );
      }
      
      // Jika bukan Home Screen, kembalikan item apa adanya
      return item;
    }).toList();
  }

  void _onItemTapped(int index) {
    // Logika Guest: Jika klik menu terakhir (biasanya Profil/Akun), arahkan ke Login
    if (widget.role == 'guest' && index == _menuItems.length - 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    HapticFeedback.selectionClick(); // Efek getar kecil
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // --- KONFIGURASI UKURAN ---
    const double navBarHeight = 70.0;
    const double bubbleSize = 42.0;
    const double iconSize = 24.0;
    const double sidePadding = 12.0;
    const double navBarBottomMargin = 24.0; 

    const Duration animDuration = Duration(milliseconds: 300);
    const Curve animCurve = Curves.fastOutSlowIn;

    return Scaffold(
      extendBody: true, 
      backgroundColor: const Color(0xFFF5F7FA),

      // Body menggunakan IndexedStack agar state halaman tidak hilang saat pindah tab
      body: Padding(
        padding: const EdgeInsets.only(bottom: navBarHeight + navBarBottomMargin + 10),
        child: IndexedStack(
          index: _currentIndex,
          children: _menuItems.map((item) => item.screen).toList(),
        ),
      ),

      bottomNavigationBar: Container(
        height: navBarHeight,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, navBarBottomMargin), 
        padding: const EdgeInsets.symmetric(horizontal: sidePadding),
        
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth = constraints.maxWidth / _menuItems.length;
            final double centerOffset = (itemWidth - bubbleSize) / 2;
            
            // Hitung posisi bubble berdasarkan index aktif
            final double bubbleLeftPosition = (_currentIndex * itemWidth) + centerOffset;
            const double iconAreaTopPadding = 6.0;

            return Stack(
              children: [
                // LAYER 1: BUBBLE ANIMASI (Lingkaran Hijau)
                AnimatedPositioned(
                  duration: animDuration,
                  curve: animCurve,
                  top: iconAreaTopPadding,
                  left: bubbleLeftPosition,
                  child: Container(
                    width: bubbleSize,
                    height: bubbleSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary, // Mengambil warna primary (Hijau)
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                  ),
                ),

                // LAYER 2: ICON MENU
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
                            // Icon Container
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
                            const SizedBox(height: 2),
                            
                            // Label Text
                            AnimatedOpacity(
                              duration: animDuration,
                              opacity: isSelected ? 1.0 : 0.8,
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 10,
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