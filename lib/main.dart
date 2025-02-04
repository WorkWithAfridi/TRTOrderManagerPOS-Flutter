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
    if (EvnConstant.consumerKey.isEmpty ||
        EvnConstant.consumerSecret.isEmpty ||
        EvnConstant.baseUrl.isEmpty) {
      throw Exception("Environment variables are not set");
    }
  } catch (e) {
    logger.e("Error initializing app: $e");
    exit(1);
  }

  DependencyInjection.init();
  FirstBootChecker().checkFirstBoot();

  // Initialize window manager for Windows and Linux.
  if (Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      title: "Order Manager",
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.hide(); // Start hidden in the tray.
    });
  }
}

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

class TrayManagerHandler extends StatefulWidget {
  final Widget child;

  const TrayManagerHandler({super.key, required this.child});

  @override
  _TrayManagerHandlerState createState() => _TrayManagerHandlerState();
}

class _TrayManagerHandlerState extends State<TrayManagerHandler>
    with TrayListener, WindowListener {
  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux) {
      initTray();
      windowManager.addListener(this);
    }
  }

  Future<void> initTray() async {
    try {
      if (Platform.isWindows) {
        await trayManager
            .setIcon('assets/icon/icon.ico'); // Use .ico for Windows
      } else if (Platform.isLinux) {
        await trayManager.setIcon('assets/icon/icon.png'); // Use .png for Linux
      }

      final menuItems = [
        MenuItem(key: 'show', label: 'Show'),
        MenuItem(key: 'quit', label: 'Quit'),
      ];

      await trayManager.setContextMenu(Menu(items: menuItems));
      logger.i("Tray menu set successfully");

      await windowManager.setPreventClose(true);
      trayManager.addListener(this);
    } catch (e) {
      logger.e("Error initializing tray: $e");
    }
  }

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

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show':
        await windowManager.restore();
        await windowManager.show();
        await windowManager.focus();
        break;
      case 'quit':
        await windowManager.destroy();
        exit(0); // Ensure the app fully exits.
      default:
        break;
    }
  }

  @override
  Future<bool> onWindowClose() async {
    await windowManager.hide();
    return true; // Prevent default close behavior
  }

  @override
  void onWindowMinimize() async {
    await windowManager.hide(); // Hide instead of minimizing.
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux) {
      trayManager.removeListener(this);
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
