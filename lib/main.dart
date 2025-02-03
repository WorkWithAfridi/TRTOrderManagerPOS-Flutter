import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:order_manager/service/debug/logger.dart';
import 'package:order_manager/service/dependency_injection_service.dart';
import 'package:order_manager/service/evn_constant.dart';
import 'package:order_manager/service/first_boot_checker.dart';
import 'package:order_manager/views/splash/splash_view.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

/// Initialize timezone data.
void initializeTimeZones() {
  tz.initializeTimeZones();
}

Future<void> main() async {
  await initApp();
  runApp(const MyApp());
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  initializeTimeZones();

  try {
    if (EvnConstant.consumerKey == "" ||
        EvnConstant.consumerSecret == "" ||
        EvnConstant.baseUrl == "") {
      throw Exception("Environment variables are not set");
    }
  } catch (e) {
    logger.e("Error initializing app: $e");
    exit(1);
  }

  DependencyInjection.init();
  FirstBootChecker().checkFirstBoot();

  // If running on Windows or Linux, initialize the window to start hidden.
  if (Platform.isWindows || Platform.isLinux) {
    // Ensure window_manager is initialized.
    await windowManager.ensureInitialized();
    // Set up window options: size, centering, title, and hide on startup.
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      title: "Order Manager",
      skipTaskbar: true,
      alwaysOnTop: true,
      
    );
    // When ready, hide the window (minimized to the tray).
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.hide();
    });
  }
}

/// The main application widget is wrapped in a [TrayManagerHandler]
/// so that tray initialization and events are available throughout the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TrayManagerHandler(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Order Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0FCA77),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

/// A widget that sets up and manages tray functionality.
/// It initializes the tray icon, context menu, and handles tray events.
class TrayManagerHandler extends StatefulWidget {
  final Widget child;

  const TrayManagerHandler({super.key, required this.child});

  @override
  _TrayManagerHandlerState createState() => _TrayManagerHandlerState();
}

class _TrayManagerHandlerState extends State<TrayManagerHandler>
    with TrayListener {
  @override
  void initState() {
    super.initState();
    // Only initialize tray functionality on Windows and Linux.
    if (Platform.isWindows || Platform.isLinux) {
      initTray();
    }
  }

  /// Initializes the tray:
  /// - Sets the tray icon (ensure the asset exists and is declared in pubspec.yaml).
  /// - Defines a context menu with options to show, hide, or quit the app.
  /// - Adds this widget as a listener to tray events.
  Future<void> initTray() async {
    await trayManager.setIcon('assets/icon/icon.png');

    final List<MenuItem> menuItems = [
      MenuItem(
        key: 'show',
        label: 'Show',
      ),
      MenuItem(
        key: 'hide',
        label: 'Hide',
      ),
      MenuItem(
        key: 'quit',
        label: 'Quit',
      ),
    ];

    await trayManager.setContextMenu(Menu(items: menuItems));

    trayManager.addListener(this);
  }

  /// Handles clicks on the tray icon itself.
  /// If the window is visible, hide it; if hidden, show and focus it.
  @override
  void onTrayIconMouseDown() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }

  /// Handles clicks on tray menu items.
  /// - 'show': Shows and focuses the window.
  /// - 'hide': Hides the window.
  /// - 'quit': Closes the window (and thus quits the app).
  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        windowManager.show();
        windowManager.focus();
        break;
      case 'hide':
        windowManager.hide();
        break;
      case 'quit':
        windowManager.close();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux) {
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simply return the wrapped child widget.
    return widget.child;
  }
}
