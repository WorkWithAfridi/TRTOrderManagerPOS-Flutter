import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf_printer/controllers/sales_report_controller.dart';
import 'package:pdf_printer/service/dependency_injection_service.dart';
import 'package:pdf_printer/service/first_boot_checker.dart';
import 'package:pdf_printer/views/dashboard/order_list_view.dart';
import 'package:pdf_printer/views/dashboard/product_list_view.dart';
import 'package:pdf_printer/views/splash/splash_view.dart';

void main() async {
  await initApp();
  runApp(const MyApp());
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

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
          seedColor: const Color(0xFF0FCA77), // Set primary color to Colors.pink[700]
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  SalesReportController get salesReportController => Get.find<SalesReportController>();

  void _generateReport(BuildContext context) {
    final List<String> statuses = ['Day', 'Week', 'Two Weeks', 'Month'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Match card corner radius
          ),
          title: const Text('Sales report'),
          content: Obx(() => salesReportController.isLoading.value
              ? const SizedBox(
                  height: 80,
                  width: 80,
                  child: Center(
                    child: Align(child: CircularProgressIndicator()),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: statuses.map((status) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        width: double.infinity, // Ensure button takes max width
                        child: ElevatedButton(
                          onPressed: () async {
                            switch (status) {
                              case 'Day':
                                await salesReportController.getSalesReport(period: "day");
                                break;
                              case 'Week':
                                await salesReportController.getSalesReport(period: "week");
                                break;
                              case 'Two Weeks':
                                await salesReportController.getSalesReport(period: "two_weeks");
                                break;
                              case 'Month':
                                await salesReportController.getSalesReport(period: "month");
                                break;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0FCA77),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Button corner styling
                            ),
                          ),
                          child: Text(status),
                        ),
                      ),
                    );
                  }).toList(),
                )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TRT Order Manager'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Products'),
              Tab(icon: Icon(Icons.receipt), text: 'Orders'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _generateReport(context);
              },
              child: const Text("Report"),
            ),
            const Gap(8),
            // IconButton(
            //   onPressed: () {
            //     NotificationSoundPlayer().playNotification();
            //   },
            //   icon: const Icon(Icons.notification_add),
            // )
          ],
        ),
        body: const TabBarView(
          children: [
            ProductsPage(),
            OrdersPage(),
          ],
        ),
      ),
    );
  }
}
