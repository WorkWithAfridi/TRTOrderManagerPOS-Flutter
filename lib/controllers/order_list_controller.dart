// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

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
  List<OrderTimerModel> orderTimers = [];
  final GetStorage _storage = GetStorage(); // Initialize GetStorage

  final NetworkController _networkController = Get.find<NetworkController>();

  void initOrderLoop(BuildContext context) {
    super.onInit();
    // Call getOrderList initially
    getOrderList(context);

    // Set up a timer to call getOrderList every 10 seconds
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      getOrderList(context);
      decreaseAllTimerBy1Minutes();
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
    try {
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
                  orderTimers.add(
                    OrderTimerModel(orderId: order.id!, secondsRemaining: 0),
                  );
                  receivedNewOrders = true;
                }
              }
            }
          }
        }
        orderList = fetchedOrders;
        update();

        // logger.d("Total orders: ${orderList.length}");
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
    } catch (e) {
      logger.e("Error fetching order list: $e");
    }

    update();
    return null;
  }

  void decreaseAllTimerBy1Minutes() {
    for (var order in orderTimers) {
      if (order.secondsRemaining > 0) {
        order.secondsRemaining -= 60;
      }
    }
    saveTimerToLocalStorage();
    update();
  }

  void increaseOrderTimerBy5Minutes(
    int orderId,
  ) {
    try {
      final order = orderTimers.firstWhere(
        (order) => order.orderId == orderId,
      );
      order.secondsRemaining += 300;
      saveTimerToLocalStorage();
      update();
    } catch (e) {
      logger.e("Error updating timer for order #$orderId: $e");
      orderTimers.add(
        OrderTimerModel(
          orderId: orderId,
          secondsRemaining: 300,
        ),
      );
      update();
    }
  }

  void decreaseOrderTimerBy5Minutes(
    int orderId,
  ) {
    try {
      final order = orderTimers.firstWhere(
        (order) => order.orderId == orderId,
      );
      order.secondsRemaining -= 300;
      saveTimerToLocalStorage();
      update();
    } catch (e) {
      logger.e("Error updating timer for order #$orderId: $e");
      orderTimers.add(
        OrderTimerModel(
          orderId: orderId,
          secondsRemaining: 300,
        ),
      );
      update();
    }
  }

  void saveOrderListToLocalStorage() {
    try {
      // Serialize orderList to JSON
      final List<Map<String, dynamic>> jsonOrderList = orderList.map((order) => order.toJson()).toList();

      // logger.d("Order list to be saved to local storage: $jsonOrderList");

      // Save serialized data to GetStorage
      _storage.write('orderList', jsonOrderList);
      // logger.d("Order list saved to local storage successfully.");
      saveTimerToLocalStorage();
    } catch (e) {
      logger.e("Error saving order list to local storage: $e");
    }
    update();
  }

  void loadOrderListFromLocalStorage() {
    try {
      final List<dynamic>? jsonOrderList = _storage.read<List<dynamic>>('orderList');
      if (jsonOrderList != null) {
        orderList = jsonOrderList.map((json) => OrderModel.fromJson(json)).toList();
        orderIds = orderList.map((order) => order.id!).toList();
        logger.d("OrderIds: $orderIds");
      }
      loadTimerListFromLocalStorage();
    } catch (e) {
      logger.e("Error loading order list from local storage: $e");
    }
    update();
  }

  void loadTimerListFromLocalStorage() {
    try {
      final List<dynamic>? jsonTimerList = _storage.read<List<dynamic>>('timerList');
      logger.d("Timer list loaded from local storage. - ${jsonTimerList?.length}");
      if (jsonTimerList != null) {
        orderTimers = jsonTimerList.map((json) => OrderTimerModel.fromJson(json)).toList();
        update();
        // logger.d("Loaded timerlist from local storage : $jsonTimerList");
        // logger.d("Timer list loaded from local storage. - ${orderTimers.length}");
      }

      if (orderIds.length != orderTimers.length) {
        for (var orderId in orderIds) {
          if (!orderTimers.any((element) => element.orderId == orderId)) {
            orderTimers.add(OrderTimerModel(orderId: orderId, secondsRemaining: 300));
          }
        }
        saveTimerToLocalStorage();
      }
    } catch (e) {
      logger.e("Error loading timer list from local storage: $e");
    }
  }

  void saveTimerToLocalStorage() {
    try {
      // Serialize orderList to JSON
      final List<dynamic> jsonTimerList = orderTimers.map((timer) => timer.toJson()).toList();

      // logger.d("Timer list to be saved to local storage: $jsonTimerList");

      // Save serialized data to GetStorage
      _storage.write('timerList', jsonTimerList);
      // logger.d("Timer list saved to local storage successfully.");
    } catch (e) {
      logger.e("Error saving timer list to local storage: $e");
    }
  }

  int? getMinutesRemaining(
    int orderId,
  ) {
    try {
      final order = orderTimers.firstWhere(
        (order) => order.orderId == orderId,
      );

      return (order.secondsRemaining ~/ 60); // Return minutes if found, otherwise null
    } catch (e) {
      logger.e("Error getting minutes remaining for order #$orderId: $e");
      return 0;
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

  Future<bool> notifyCustomerOnOrderTimerUpdate(
    int orderId,
  ) async {
    final String endpoint = "$baseUrl/wp-json/wc/v3/trt/order/email"; // Corrected endpoint
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.PUT,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
          'order_id': orderId, 'delivery_time': (getMinutesRemaining(orderId) ?? 0).toString(),
        },
      );

      if (response != null && response.statusCode == 200) {
        logger.d("Notification sent successfully.");
        return true;
      } else {
        throw Exception("Failed to notify customer. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error notifying customer for order #$orderId: $e");
    }
    return false;
  }

  void showNewOrdersDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
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

class OrderTimerModel {
  final int orderId;
  int secondsRemaining;

  OrderTimerModel({
    required this.orderId,
    required this.secondsRemaining,
  });

  OrderTimerModel copyWith({
    int? orderId,
    int? secondsRemaining,
  }) {
    return OrderTimerModel(
      orderId: orderId ?? this.orderId,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'secondsRemaining': secondsRemaining,
    };
  }

  factory OrderTimerModel.fromMap(Map<String, dynamic> map) {
    return OrderTimerModel(
      orderId: map['orderId'] as int,
      secondsRemaining: map['secondsRemaining'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderTimerModel.fromJson(String source) => OrderTimerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OrderTimerModel(orderId: $orderId, secondsRemaining: $secondsRemaining)';

  @override
  bool operator ==(covariant OrderTimerModel other) {
    if (identical(this, other)) return true;

    return other.orderId == orderId && other.secondsRemaining == secondsRemaining;
  }

  @override
  int get hashCode => orderId.hashCode ^ secondsRemaining.hashCode;
}
