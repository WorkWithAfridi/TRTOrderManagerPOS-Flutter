import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf_printer/models/order_m.dart';
import 'package:pdf_printer/prod_env/prod_end.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:pdf_printer/service/first_boot_checker.dart';
import 'package:pdf_printer/service/network/network-c.dart';
import 'package:pdf_printer/service/notification_sound_player.dart';

class OrderListController extends GetxController {
  Timer? _timer;
  List<OrderModel> orderList = [];
  List<int> orderIds = [];
  final GetStorage _storage = GetStorage(); // Initialize GetStorage

  final NetworkController _networkController = Get.find<NetworkController>();

  @override
  void onInit() {
    super.onInit();
    // Call getOrderList initially
    getOrderList();

    // Set up a timer to call getOrderList every 10 seconds
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
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
    loadOrderListFromLocalStorage();
    String endpoint = "$baseUrl/wp-json/wc/v3/orders"; // WooCommerce Products endpoint
    // try {
    final response = await _networkController.request(
      url: endpoint,
      method: Method.GET,
      params: {
        'consumer_key': consumerKey, // Replace with actual key
        'consumer_secret': consumerSecret, // Replace with actual secret
        'per_page': 100,
      },
    );

    // logger.d("Response data: ${response?.data}");

    if (response != null && response.statusCode == 200) {
      // Parse response to list of OrderModel
      final fetchedOrders = (response.data as List).map((order) => OrderModel.fromJson(order)).toList();
      for (var order in fetchedOrders) {
        if (order.id != null) {
          if (!orderIds.contains(order.id!)) {
            {
              orderList.add(order);
              orderIds.add(order.id ?? 0);
              if (!FirstBootChecker().isFirstBoot) {
                NotificationSoundPlayer().playNotification();
              }
            }
          }
        }
      }
      orderList = fetchedOrders;
      update();

      logger.d("Total orders: ${orderList.length}");
      saveOrderListToLocalStorage();
      return orderList;
    } else {
      logger.e("Failed to fetch order list");
    }
    // } catch (e) {
    //   logger.e("Error fetching order list: $e");
    // }

    update();
    return null;
  }

  void saveOrderListToLocalStorage() {
    try {
      // Serialize orderList to JSON
      final List<Map<String, dynamic>> jsonOrderList = orderList.map((order) => order.toJson()).toList();

      logger.d("Order list to be saved to local storage: $jsonOrderList");

      // Save serialized data to GetStorage
      _storage.write('orderList', jsonOrderList);
      logger.d("Order list saved to local storage successfully.");
    } catch (e) {
      logger.e("Error saving order list to local storage: $e");
    }
  }

  void loadOrderListFromLocalStorage() {
    try {
      final List<dynamic>? jsonOrderList = _storage.read<List<dynamic>>('orderList');
      if (jsonOrderList != null) {
        orderList = jsonOrderList.map((json) => OrderModel.fromJson(json)).toList();
        orderIds = orderList.map((order) => order.id!).toList();
        update();
        logger.d("Loaded orderlist from local storage : $jsonOrderList");
        logger.d("Order list loaded from local storage. - ${orderList.length}");
      }
    } catch (e) {
      logger.e("Error loading order list from local storage: $e");
    }
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
