import 'dart:async';

import 'package:get/get.dart';
import 'package:pdf_printer/models/order_m.dart';
import 'package:pdf_printer/prod_env/prod_end.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:pdf_printer/service/network/network-c.dart';

class OrderListController extends GetxController {
  Timer? _timer;
  List<OrderModel> orderList = [];

  final NetworkController _networkController = Get.find<NetworkController>();

  @override
  void onInit() {
    super.onInit();
    // Call getOrderList initially
    getOrderList();

    // Set up a timer to call getOrderList every 10 seconds
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

  Future<List<OrderModel>?> getOrderList() async {
    String endpoint = "$baseUrl/wp-json/wc/v3/orders"; // WooCommerce Products endpoint
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.GET,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
        },
      );

      logger.d("Response data: ${response?.data}");

      if (response != null && response.statusCode == 200) {
        // Parse response to list of OrderModel
        final fetchedOrders = (response.data as List).map((order) => OrderModel.fromJson(order)).toList();
        orderList = fetchedOrders;
        return orderList;
      } else {
        logger.e("Failed to fetch order list");
      }
    } catch (e) {
      logger.e("Error fetching order list: $e");
    }

    update();
    return null;
  }

  Future<bool> updateOrderDetails(int orderId, Map<String, dynamic> data) async {
    final String endpoint = "$baseUrl/wp-json/wc/v3//orders/$orderId"; // Endpoint for updating product
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.PUT,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
          ...data, // Merge additional fields for the update
        },
      );

      if (response != null && response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to update order. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error updating order #$orderId: $e");
    }
    return false;
  }
}
