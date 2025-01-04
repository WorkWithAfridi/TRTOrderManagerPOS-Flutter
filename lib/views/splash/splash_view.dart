import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pdf_printer/controllers/product_list_controller.dart';
import 'package:pdf_printer/controllers/store_controller.dart';
import 'package:pdf_printer/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to DashboardView after 3 seconds
    appSetup();
  }

  Future<void> appSetup() async {
    Get.find<ProductListController>().fetchAllProducts();
    await Get.find<StoreController>().setupPrinter();
    Get.find<StoreController>().getStoreDetails().then((_) {
      Timer(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardView(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0FCA77), // Splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SvgPicture.asset(
                'assets/icon/app-logo.svg',
                height: 80,
                width: 80,
              ),
            ),
            const SizedBox(height: 16),

            // App Name or Slogan
            const Text(
              'TRT Order Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle or tagline
            const Text(
              'Manage your orders effortlessly!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),

            // Loading Indicator
            const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
