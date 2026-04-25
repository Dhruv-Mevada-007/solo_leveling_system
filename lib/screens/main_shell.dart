import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'quests/quests_screen.dart';
import 'habits/habits_screen.dart';
import 'tasks/tasks_screen.dart';
import 'reminders/reminders_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  static const _screens = [
    QuestsScreen(),
    HabitsScreen(),
    TasksScreen(),
    RemindersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
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
      _NavItem('Quests',    Icons.grid_view_outlined,    Icons.grid_view_rounded,     AppColors.systemBlue),
      _NavItem('Habits',    Icons.repeat_outlined,        Icons.repeat_rounded,         AppColors.agilityColor),
      _NavItem('Tasks',     Icons.list_alt_outlined,      Icons.list_alt_rounded,       AppColors.systemBlue),
      _NavItem('Notes',     Icons.push_pin_outlined,      Icons.push_pin_rounded,       AppColors.manaColor),
      _NavItem('Profile',   Icons.person_outline_rounded, Icons.person_rounded,         AppColors.rankA),
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
              final color = item.color;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? color.withAlpha(25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 21,
                          color: isActive ? color : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 0.5,
                          color: isActive ? color : AppColors.textMuted,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
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
    ).animate().slideY(
        begin: 1,
        duration: 400.ms,
        delay: 300.ms,
        curve: Curves.easeOut);
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color color;
  const _NavItem(this.label, this.icon, this.activeIcon, this.color);
}

