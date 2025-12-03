import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/local_storage_service.dart';
import 'services/category_service.dart';
import 'services/notification_service.dart';
import 'services/task_reminder_service.dart';
import 'services/home_widget_service.dart';
import 'services/ad_service.dart';
import 'services/app_open_ad_manager.dart';
import 'services/app_lifecycle_reactor.dart';
import 'services/interstitial_ad_manager.dart';
import 'services/rewarded_ad_manager.dart';
import 'controllers/task_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  // Setup notification listeners
  NotificationService.setupListeners();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  // Initialize local storage (includes Hive and all adapters)
  await LocalStorageService.instance.init();

  // Initialize category service (must be after Hive init)
  await CategoryService().init();

  // Initialize notifications
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  // Initialize reminder service
  TaskReminderService.instance.init();

  // Initialize home widget
  await HomeWidgetService.instance.initialize();

  // Initialize Mobile Ads
  await AdService.initialize();

  // Load initial app open ad
  await AppOpenAdManager().loadAd();

  // Load initial interstitial ad
  await InterstitialAdManager().loadAd();

  // Load initial rewarded ad
  await RewardedAdManager().loadAd();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();

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
      providers: [
        ChangeNotifierProvider(create: (_) => TaskController()..init()),
      ],
      child: MaterialApp(
        title: 'QuickList',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.home,
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
