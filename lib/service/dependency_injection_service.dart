import 'package:get/get.dart';
import 'package:order_manager/controllers/dashboard_controller.dart';
import 'package:order_manager/controllers/order_list_controller.dart';
import 'package:order_manager/controllers/product_list_controller.dart';
import 'package:order_manager/controllers/sales_report_controller.dart';
import 'package:order_manager/controllers/store_controller.dart';
import 'package:order_manager/service/network/network-c.dart';
import 'package:order_manager/service/network/network-service-c.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
    Get.put<NetworkService>(NetworkService(), permanent: true);
    Get.put<DashboardController>(DashboardController(), permanent: true);
    Get.put<OrderListController>(OrderListController(), permanent: true);
    Get.put<ProductListController>(ProductListController(), permanent: true);
    Get.put<SalesReportController>(SalesReportController(), permanent: true);
    Get.put<StoreController>(StoreController(), permanent: true);
  }
}
