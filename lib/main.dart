import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf_printer/controllers/dashboard_controller.dart';
import 'package:pdf_printer/controllers/order_list_controller.dart';
import 'package:pdf_printer/controllers/product_list_controller.dart';
import 'package:pdf_printer/controllers/sales_report_controller.dart';
import 'package:pdf_printer/controllers/store_controller.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:pdf_printer/service/dependency_injection_service.dart';
import 'package:pdf_printer/service/evn_constant.dart';
import 'package:pdf_printer/service/first_boot_checker.dart';
import 'package:pdf_printer/views/dashboard/all_orders_view.dart';
import 'package:pdf_printer/views/dashboard/order_list_view.dart';
import 'package:pdf_printer/views/dashboard/product_list_view.dart';
import 'package:pdf_printer/views/dashboard/product_search_view.dart';
import 'package:pdf_printer/views/splash/splash_view.dart';
import 'package:pdf_printer/views/store_settings_view.dart';

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
          seedColor: const Color(0xFF0FCA77), // Set primary color to Colors.pink[700]
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  SalesReportController get salesReportController => Get.find<SalesReportController>();

  DashboardController get dashboardController => Get.find<DashboardController>();
  OrderListController get orderListController => Get.find<OrderListController>();
  ProductListController get productListController => Get.find<ProductListController>();

  @override
  void initState() {
    orderListController.initOrderLoop(context);
    super.initState();
  }

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
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          saveText: "Select",
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.blue, // header background color
                                  onPrimary: Colors.white, // header text color
                                  onSurface: Colors.black, // body text color
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          logger.d("Selected date range: ${salesReportController.selectedDateRange?.start}, ${salesReportController.selectedDateRange?.end}");
                          salesReportController.selectedDateRange = picked;
                          salesReportController.getSalesReport(
                              startDate: salesReportController.selectedDateRange!.start.toString(),
                              endDate: salesReportController.selectedDateRange!.end.toString());
                        }
                      },
                      child: const Text(
                        "Select date range",
                      ),
                    ),
                  ],
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

  StoreController get controller => Get.find<StoreController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Obx(() => Text('TRT Order Manager - ${dashboardController.isProductTabSelected.value ? 'Store' : 'Orders'}')),
        actions: [
          Obx(
            () => dashboardController.isProductTabSelected.value
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Accepting Online Orders: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      GetBuilder<StoreController>(
                        init: controller,
                        initState: (_) {},
                        builder: (_) {
                          return Switch(
                            value: controller.isStoreActive,
                            activeTrackColor: Colors.green,
                            activeColor: Colors.white,
                            inactiveTrackColor: Colors.red,
                            inactiveThumbColor: Colors.white,
                            onChanged: (value) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Are you sure you want to ${controller.isStoreActive ? 'stop receiving online orders' : 'start receiving online orders'}?',
                                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                              ),
                                        ),
                                        const Gap(20),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'NO',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            const Gap(16),
                                            ElevatedButton(
                                              onPressed: () {
                                                controller.toogleStoreStatus();

                                                Get.back();
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'YES',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      Text(
                        controller.isStoreActive ? ' (Yes)' : ' (No)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Gap(20),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.find<OrderListController>().getOrderList(context);
                        },
                        child: const Text(
                          "Refresh",
                        ),
                      ),
                      const Gap(12),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(
                            () => const AllOrdersPage(),
                          );
                        },
                        child: const Text(
                          "View all orders",
                        ),
                      ),
                      const Gap(20),
                    ],
                  ),
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              width: Get.width,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() => ListTile(
                  leading: Icon(
                    Icons.receipt,
                    color: !dashboardController.isProductTabSelected.value ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    'Orders',
                    style: TextStyle(
                      color: !dashboardController.isProductTabSelected.value ? Colors.black : Colors.grey,
                    ),
                  ),
                  onTap: () {
                    dashboardController.isProductTabSelected.value = false;
                    Get.back();
                  },
                )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(height: 20, thickness: 1),
            ),
            Obx(() => ListTile(
                  leading: Icon(
                    Icons.fastfood_rounded,
                    color: dashboardController.isProductTabSelected.value ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    'Store',
                    style: TextStyle(
                      color: dashboardController.isProductTabSelected.value ? Colors.black : Colors.grey,
                    ),
                  ),
                  onTap: () {
                    dashboardController.isProductTabSelected.value = true;
                    Get.back();
                  },
                )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(height: 20, thickness: 1),
            ),
            ListTile(
              leading: const Icon(
                Icons.file_copy_sharp,
                color: Colors.grey,
              ),
              title: const Text(
                'Report',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                Get.back();

                _generateReport(context);
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(height: 20, thickness: 1),
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: Colors.grey,
              ),
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                Get.to(
                  () => const StoreSettingsView(),
                );
              },
            ),
            const Spacer(),
            const Text(
              "Copyright © 2024\nwww.trttech.ca\nAll Rights Reserved by TRT Technologies Ltd.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const Gap(12),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Close'),
              onTap: () {
                Get.back();
              },
            )
          ],
        ),
      ),
      body: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: dashboardController.isProductTabSelected.value
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetBuilder<ProductListController>(
                            init: productListController,
                            initState: (_) {},
                            builder: (_) {
                              return Row(
                                children: [
                                  const Text("All products: "),
                                  Switch(
                                    value: productListController.isAllProductActive,
                                    activeTrackColor: Colors.green,
                                    activeColor: Colors.white,
                                    inactiveTrackColor: Colors.red,
                                    inactiveThumbColor: Colors.white,
                                    onChanged: (value) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16.0),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Are you sure you want to set all products ${productListController.isAllProductActive ? 'out-of-stock' : 'in-stock'}?',
                                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 22,
                                                      ),
                                                ),
                                                const Gap(20),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(12.0),
                                                        child: Text(
                                                          'NO',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    const Gap(12),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        productListController.toggleAllProductStatus();
                                                        Get.back();
                                                      },
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(12.0),
                                                        child: Text(
                                                          'YES',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  Text(
                                    productListController.isAllProductActive ? ' (in-stock)' : ' (out-of-stock)',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              );
                            },
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  productListController.isLoading.value = true;
                                  await productListController.fetchAllProducts();
                                  await Get.find<StoreController>().getStoreDetails();
                                  productListController.isLoading.value = false;
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text("Refresh"),
                                ),
                              ),
                              const Gap(12),
                              ElevatedButton(
                                onPressed: () {
                                  Get.to(
                                    const ProductSearchPage(),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text("Search"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: productListController.isLoading.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const ProductsPage(),
                    ),
                  ],
                )
              : const OrdersPage(),
        ),
      ),
    );
  }
}

// run on chrome command
// flutter run -d chrome --dart-define=BASE_URL=https://cp.trttechnologies.net --dart-define=CONSUMER_KEY=ck_bc2663992cdf540bf18572a3b8ed25527b472001 --dart-define=CONSUMER_SECRET=cs_f8dcc9937cb605113bfc0431bbe2c219d1b18ed8 --dart-define=VERSION=wc/v3


// TODO: Add tabs in todays order page for all status, disable loader on 1 min fetch logic