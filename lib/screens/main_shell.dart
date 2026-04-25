import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solo_leveling_system/screens/profile/profile_screen.dart';
import 'package:solo_leveling_system/screens/quests/quests_screen.dart';
import 'package:solo_leveling_system/screens/tasks/tasks_screen.dart';
import '../../theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _navAnimController;

  static const _screens = [
    QuestsScreen(),
    TasksScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (i) => setState(() => _currentIndex = i),
      ),
      bottomNavigationBar: _SystemNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _SystemNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SystemNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(label: 'Quests', icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded),
      _NavItem(label: 'Tasks', icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt_rounded),
      _NavItem(label: 'Profile', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.systemBlue.withAlpha(20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 22,
                          color: isActive ? AppColors.systemBlue : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1,
                          color: isActive ? AppColors.systemBlue : AppColors.textMuted,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                        child: Text(item.label.toUpperCase()),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 400.ms, delay: 300.ms, curve: Curves.easeOut);
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem({required this.label, required this.icon, required this.activeIcon});
}
