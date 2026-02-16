import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../utils/size_config.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'add_task_screen.dart';
import 'category_screen.dart';
import 'gamification_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryScreen(),
    GamificationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;

    _fadeController.value = 0.0;
    setState(() => _currentIndex = index);
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_currentIndex != 0) {
            _onTabChanged(0);
          } else {
            // Minimize to background (like pressing the home button)
            const platform = MethodChannel('com.quicklist/navigation');
            try {
              await platform.invokeMethod('moveToBackground');
            } catch (_) {
              // Fallback: move task to back via system navigator
              SystemNavigator.pop();
            }
          }
        },
        child: Scaffold(
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTabChanged: _onTabChanged,
            onFabPressed: () async {
              final controller = context.read<TaskController>();
              await AddTaskScreen.show(context);
              if (mounted) {
                controller.loadTasks();
              }
            },
          ),
        ),
      ),
    );
  }
}
