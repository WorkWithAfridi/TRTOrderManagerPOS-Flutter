import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_printer/controllers/order_list_controller.dart';
import 'package:pdf_printer/controllers/product_list_controller.dart';
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
    Get.find<ProductListController>().fetchAllProducts();
    Get.find<OrderListController>().getOrderList();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardView(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[700], // Splash screen background color
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or Icon
            Icon(
              Icons.fastfood_rounded,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 16),

            // App Name or Slogan
            Text(
              'TRT Order Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),

            // Subtitle or tagline
            Text(
              'Manage your orders effortlessly!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 32),

            // Loading Indicator
            SizedBox(
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
