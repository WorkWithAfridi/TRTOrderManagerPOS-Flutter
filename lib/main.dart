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

void initializeTimeZones() {
  // Initialize time zones data
  tz.initializeTimeZones();
}

void main() async {
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0FCA77),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
// flutter run -d chrome --dart-define=BASE_URL=https://cp.trttechnologies.net --dart-define=CONSUMER_KEY=ck_bc2663992cdf540bf18572a3b8ed25527b472001 --dart-define=CONSUMER_SECRET=cs_f8dcc9937cb605113bfc0431bbe2c219d1b18ed8 --dart-define=VERSION=wc/v3
