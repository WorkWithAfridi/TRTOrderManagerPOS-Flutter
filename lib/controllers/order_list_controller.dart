import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf_printer/models/order_m.dart';
import 'package:pdf_printer/prod_env/prod_end.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:pdf_printer/service/first_boot_checker.dart';
import 'package:pdf_printer/service/network/network-c.dart';
import 'package:pdf_printer/service/notification_sound_player.dart';
import 'package:pdf_printer/service/printer_service.dart';

class OrderListController extends GetxController {
  Timer? _timer;
  List<OrderModel> orderList = [];
  List<int> orderIds = [];
  final GetStorage _storage = GetStorage(); // Initialize GetStorage

  final NetworkController _networkController = Get.find<NetworkController>();

  void initOrderLoop(BuildContext context) {
    super.onInit();
    // Call getOrderList initially
    getOrderList(context);

    // Set up a timer to call getOrderList every 10 seconds
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      getOrderList(context);
    });
  }

  @override
  void onClose() {
    // Cancel the timer when the controller is disposed
    _timer?.cancel();
    super.onClose();
  }

  Future<List<OrderModel>?> getOrderList(BuildContext context, {bool shouldLoadFromLocalStorage = true}) async {
    bool receivedNewOrders = false;
    if (shouldLoadFromLocalStorage) {
      loadOrderListFromLocalStorage();
    }
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
                PrinterService().printOrderBill(
                  order,
                );
                receivedNewOrders = true;
              }
            }
          }
        }
      }
      orderList = fetchedOrders;
      update();

      logger.d("Total orders: ${orderList.length}");
      saveOrderListToLocalStorage();

      if (receivedNewOrders) {
        showNewOrdersDialog(
          context,
        );
      }
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

  Future<bool> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    final String endpoint = "$baseUrl/wp-json/wc/v3/orders/$orderId"; // Corrected endpoint
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.PUT,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
          'status': status, // Only updating the status field
        },
      );

      if (response != null && response.statusCode == 200) {
        logger.d("Order status updated successfully. Status: $status");
        return true;
      } else {
        throw Exception("Failed to update order status. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error updating status for order #$orderId: $e");
    }
    return false;
  }

  void showNewOrdersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'New Orders!',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'You have new orders waiting to be processed. Please check them at your earliest convenience.',
            style: TextStyle(fontSize: 16.0),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                NotificationSoundPlayer().stopNotification();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
