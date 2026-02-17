import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/local_storage_service.dart';
import 'services/category_service.dart';
import 'services/notification_service.dart';
import 'services/task_reminder_service.dart';
import 'services/home_widget_service.dart';
import 'services/consent_manager.dart';
import 'services/ad_service.dart';
import 'services/app_open_ad_manager.dart';
import 'services/app_lifecycle_reactor.dart';
import 'services/interstitial_ad_manager.dart';
import 'services/rewarded_ad_manager.dart';
import 'services/screen_ad_manager.dart';
import 'services/gamification_service.dart';
import 'controllers/task_controller.dart';
import 'ui/screens/add_task_screen.dart';

/// Global navigator key for deep link navigation (e.g., widget FAB)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await _initializeServices();

  NotificationService.setupListeners();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  // Initialize local storage (includes Hive and all adapters)
  await LocalStorageService.instance.init();

  // Initialize category service (must be after Hive init)
  await CategoryService().init();

  // Initialize gamification service (must be after Hive init)
  await GamificationService.instance.init();

  // Parallelize independent service initializations
  await Future.wait([
    NotificationService.instance.init(),
    HomeWidgetService.instance.initialize(),
    _initializeAdsInBackground(), // Start ad loading in parallel
  ]);

  // Request notification permissions (non-blocking)
  NotificationService.instance.requestPermissions();

  // Initialize reminder service (synchronous, lightweight)
  TaskReminderService.instance.init();
}

// Load ads in background after app starts
Future<void> _initializeAdsInBackground() async {
  // Initialize consent manager and show consent form if required (GDPR/CCPA)
  final canShowAds = await ConsentManager.instance.initialize();

  // Only initialize ads if user has given consent
  if (canShowAds) {
    await AdService.initialize();

    // Immediately start loading all ads in parallel (don't await)
    // This fires all requests simultaneously for maximum speed
    Future.microtask(() {
      // Preload banner ads for all screens
      ScreenAdManager.instance.preloadBannerAd('calendar_screen');
      ScreenAdManager.instance.preloadBannerAd('add_task_screen');
      ScreenAdManager.instance.preloadBannerAd('settings_screen');
      ScreenAdManager.instance.preloadBannerAd('category_screen');
      ScreenAdManager.instance.preloadBannerAd('gamification_screen');
      ScreenAdManager.instance.preloadBannerAd('category_management_screen');
    });

    Future.microtask(() {
      // Preload native ads for all screens and list positions
      ScreenAdManager.instance.preloadNativeAd('settings_screen');
      ScreenAdManager.instance.preloadNativeAd('home_screen');
      ScreenAdManager.instance.preloadNativeAd('gamification_screen_stats');
      ScreenAdManager.instance.preloadNativeAd(
        'gamification_screen_achievements',
      );
      ScreenAdManager.instance.preloadNativeAd('category_screen_category_list');
      
      // Preload native ads for calendar screen task lists
      ScreenAdManager.instance.preloadNativeAd('calendar_screen_tasks_0');
      ScreenAdManager.instance.preloadNativeAd('calendar_screen_tasks_1');
      ScreenAdManager.instance.preloadNativeAd('calendar_screen_tasks_2');
      
      // Preload native ads for category management screen
      ScreenAdManager.instance.preloadNativeAd('category_management_screen_0');
      ScreenAdManager.instance.preloadNativeAd('category_management_screen_1');
      ScreenAdManager.instance.preloadNativeAd('category_management_screen_2');
    });

    // Load full-screen ads in parallel
    Future.microtask(() {
      AppOpenAdManager().loadAd();
      InterstitialAdManager().loadAd();
      RewardedAdManager().loadAd();
    });
  } else {
    if (kDebugMode) {
      print('Ads not initialized: User consent required or denied');
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifecycleReactor _appLifecycleReactor;
  final TaskController _taskController = TaskController();

  @override
  void initState() {
    super.initState();

    // Initialize TaskController asynchronously
    _taskController.init();

    // Listen for widget FAB "add task" navigation
    const channel = MethodChannel('com.quicklist/navigation');
    channel.setMethodCallHandler((call) async {
      if (call.method == 'openAddTask') {
        // Wait a frame so the navigator is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            AddTaskScreen.show(context);
          }
        });
      }
    });

    // Initialize app lifecycle reactor for app open ads
    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: AppOpenAdManager(),
    );
    _appLifecycleReactor.listenToAppStateChanges();
  }

  @override
  void dispose() {
    _appLifecycleReactor.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _taskController)],
      child: MaterialApp(
        title: 'QuickList',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.home,
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
