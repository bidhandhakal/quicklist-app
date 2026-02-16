import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/routes.dart';
import '../../utils/size_config.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onFabPressed;
  final ValueChanged<int>? onTabChanged;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onFabPressed,
    this.onTabChanged,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.folder_rounded, label: 'Category'),
    _NavItem(icon: Icons.emoji_events_rounded, label: 'Achievements'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(16),
          vertical: context.rh(10),
        ),
        child: Row(
          children: [
            // Pill-shaped nav bar
            Expanded(
              child: Container(
                height: context.rh(64),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(context.rw(40)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_items.length, (index) {
                    final isActive = index == currentIndex;
                    return _buildNavItem(
                      context,
                      icon: _items[index].icon,
                      label: _items[index].label,
                      isActive: isActive,
                      onTap: () => _onTap(context, index),
                    );
                  }),
                ),
              ),
            ),

            SizedBox(width: context.rw(12)),

            // FAB button
            GestureDetector(
              onTap:
                  onFabPressed ??
                  () => Navigator.pushNamed(context, AppRoutes.addTask),
              child: Container(
                width: context.rw(56),
                height: context.rw(56),
                decoration: const BoxDecoration(
                  color: Color(0xFF1C1C1E),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: context.rw(28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(18),
          vertical: context.rh(8),
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(context.rw(28)),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.rw(22),
              color: isActive ? const Color(0xFF1C1C1E) : Colors.grey[500],
            ),
            if (isActive) ...[
              SizedBox(width: context.rw(6)),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: context.rf(13),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (onTabChanged != null) {
      onTabChanged!(index);
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
