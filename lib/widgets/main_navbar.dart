import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/menu_config.dart';
import '../screens/auth/auth_screen.dart';
import '../../screens/user/home/home_screen.dart'; 
// PENTING: Import Product Screen untuk akses tipe State-nya
import '../../screens/user/product/product_screen.dart'; 

class MainNavbar extends StatefulWidget {
  final String role;
  const MainNavbar({super.key, required this.role});

  @override
  State<MainNavbar> createState() => _MainNavbarState();
}

class _MainNavbarState extends State<MainNavbar> {
  int _currentIndex = 0;
  late List<NavItem> _menuItems;

  // 1. Buat GLOBAL KEY untuk mengontrol Product Screen
  final GlobalKey<UserProductScreenState> _productScreenKey = GlobalKey<UserProductScreenState>();

  @override
  void initState() {
    super.initState();
    _initializeMenu();
  }

  void _initializeMenu() {
    final List<NavItem> originalMenus = MenuConfig.getMenus(widget.role);

    _menuItems = originalMenus.map((item) {
      
      // A. Jika Screen adalah HOME SCREEN
      if (item.screen is UserHomeScreen) {
        return NavItem(
          icon: item.icon,
          label: item.label,
          screen: UserHomeScreen(
            role: widget.role,
            onSwitchTab: (int targetIndex) {
              _onItemTapped(targetIndex);
            },
            // Callback: Ketika Kategori di Home diklik
            onCategoryTap: (String category) {
              // 1. Pindah tab ke Product (Asumsi index 1 adalah Product)
              // Anda mungkin perlu menyesuaikan index ini jika urutan menu berubah
              // Cari index menu yang screen-nya tipe UserProductScreen
              final productIndex = _menuItems.indexWhere((m) => m.screen is UserProductScreen);
              
              if (productIndex != -1) {
                _onItemTapped(productIndex); // Pindah Tab UI
                
                // 2. Perintahkan Product Screen untuk search
                // Gunakan delay sedikit agar UI render tab-nya dulu
                Future.delayed(const Duration(milliseconds: 100), () {
                  _productScreenKey.currentState?.performSearch(category);
                });
              }
            },
          ),
        );
      }
      
      // B. Jika Screen adalah PRODUCT SCREEN
      // Kita harus menyuntikkan (inject) key yang sudah kita buat
      if (item.screen is UserProductScreen) {
        return NavItem(
          icon: item.icon,
          label: item.label,
          // Gunakan Key disini!
          screen: UserProductScreen(key: _productScreenKey),
        );
      }
      
      // Screen Lainnya
      return item;
    }).toList();
  }

  void _onItemTapped(int index) {
    if (widget.role == 'guest' && index == _menuItems.length - 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }
    HapticFeedback.selectionClick(); 
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            final double bubbleLeftPosition = (_currentIndex * itemWidth) + centerOffset;
            const double iconAreaTopPadding = 6.0;

            return Stack(
              children: [
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
                          color: colorScheme.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                  ),
                ),
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