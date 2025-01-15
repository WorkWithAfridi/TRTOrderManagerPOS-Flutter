import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:pdf_printer/service/dependency_injection_service.dart';
import 'package:pdf_printer/service/evn_constant.dart';
import 'package:pdf_printer/service/first_boot_checker.dart';
import 'package:pdf_printer/views/splash/splash_view.dart';

void main() async {
  await initApp();
  runApp(const MyApp());
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  try {
    if (EvnConstant.consumerKey == "" || EvnConstant.consumerSecret == "" || EvnConstant.baseUrl == "") {
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
