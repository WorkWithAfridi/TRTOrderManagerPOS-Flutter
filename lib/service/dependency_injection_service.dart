import 'package:get/get.dart';
import 'package:pdf_printer/controllers/order_list_controller.dart';
import 'package:pdf_printer/controllers/product_list_controller.dart';
import 'package:pdf_printer/controllers/sales_report_controller.dart';
import 'package:pdf_printer/service/network/network-c.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
    Get.put<OrderListController>(OrderListController(), permanent: true);
    Get.put<ProductListController>(ProductListController(), permanent: true);
    Get.put<SalesReportController>(SalesReportController(), permanent: true);
  }
}
