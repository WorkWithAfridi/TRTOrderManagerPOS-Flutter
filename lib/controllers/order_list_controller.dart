import 'dart:async';

import 'package:get/get.dart';
import 'package:pdf_printer/service/debug/logger.dart';

class OrderListController extends GetxController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Call getOrderList initially
    getOrderList();

    // Set up a timer to call getOrderList every minute
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getOrderList();
    });
  }

  @override
  void onClose() {
    // Cancel the timer when the controller is disposed
    _timer?.cancel();
    super.onClose();
  }

  Future<void> getOrderList() async {
    // Your logic to fetch the order list
    logger.d("Fetching order list");
  }

  Future<void> updateOrderDetails() async {
    // Your logic to update order details
  }
}
