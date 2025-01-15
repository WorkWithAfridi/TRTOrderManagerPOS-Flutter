import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pdf_printer/controllers/dashboard_controller.dart';
import 'package:pdf_printer/controllers/order_list_controller.dart';
import 'package:pdf_printer/controllers/product_list_controller.dart';
import 'package:pdf_printer/controllers/sales_report_controller.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:pdf_printer/views/store_settings_view.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  SalesReportController get salesReportController => Get.find<SalesReportController>();
  DashboardController get dashboardController => Get.find<DashboardController>();
  OrderListController get orderListController => Get.find<OrderListController>();
  ProductListController get productListController => Get.find<ProductListController>();

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
    );
  }
}
