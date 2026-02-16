import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/size_config.dart';
import '../screens/add_task_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final VoidCallback? onFabPressed;
  final ValueChanged<int>? onTabChanged;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onFabPressed,
    this.onTabChanged,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.folder_rounded, label: 'Category'),
    _NavItem(icon: Icons.emoji_events_rounded, label: 'Achievements'),
  ];

  late final List<AnimationController> _scaleControllers;
  late final List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();

    // Scale bounce controllers for each tab
    _scaleControllers = List.generate(
      _items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      ),
    );

    _scaleAnimations = _scaleControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _scaleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    if (index == widget.currentIndex) return;

    // Trigger scale bounce on the tapped item
    _scaleControllers[index].forward(from: 0.0);

    if (widget.onTabChanged != null) {
      widget.onTabChanged!(index);
    }
  }

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
                    final isActive = index == widget.currentIndex;
                    return _buildNavItem(
                      context,
                      index: index,
                      icon: _items[index].icon,
                      label: _items[index].label,
                      isActive: isActive,
                      onTap: () => _onTap(index),
                    );
                  }),
                ),
              ),
            ),

            SizedBox(width: context.rw(12)),

            // FAB button
            GestureDetector(
              onTap: widget.onFabPressed ?? () => AddTaskScreen.show(context),
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
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[index].value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? context.rw(18) : context.rw(14),
            vertical: context.rh(8),
          ),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(context.rw(28)),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon color
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: isActive
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFAEAEB2),
                ),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                builder: (context, color, _) =>
                    Icon(icon, size: context.rw(22), color: color),
              ),
              // Animated label with clip + slide + fade
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                clipBehavior: Clip.hardEdge,
                child: isActive
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: context.rw(6)),
                          TweenAnimationBuilder<double>(
                            key: ValueKey('label_$index'),
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(-8 * (1 - value), 0),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              label,
                              style: GoogleFonts.manrope(
                                fontSize: context.rf(13),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
