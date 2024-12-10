import 'package:get/get.dart';
import 'package:pdf_printer/controllers/order_list_controller.dart';
import 'package:pdf_printer/controllers/product_list_controller.dart';
import 'package:pdf_printer/service/network/network-service-c.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkService>(NetworkService(), permanent: true);
    Get.put<OrderListController>(OrderListController(), permanent: true);
    Get.put<ProductListController>(ProductListController(), permanent: true);
  }
}
