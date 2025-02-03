import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:order_manager/service/debug/logger.dart';
import 'package:order_manager/service/evn_constant.dart';
import 'package:order_manager/service/network/network-c.dart';
import 'package:order_manager/service/printer_service.dart';
import 'package:printing/printing.dart';

class StoreController extends GetxController {
  StoreModel? storeModel;
  List<Printer> availablePrinter = [];

  double receiptRightPadding = 0.0;
  double receiptLeftPadding = 0.0;
  static const rightPaddingKey = "paddingRightKey";
  static const leftPaddingKey = "paddingLeftKey";
  Printer? selectedPrinter;
  bool isStoreActive = false;
  final GetStorage _storage = GetStorage(); // Initialize GetStorage

  onPaddingUpdated(String x, String leftOrRight) {
    try {
      if (leftOrRight == "right") {
        receiptRightPadding = double.parse(x);
      } else {
        receiptLeftPadding = double.parse(x);
      }
    } catch (e) {
      receiptRightPadding = 0.0;
      receiptLeftPadding = 0.0;
    }
    savePaddingSettings(leftOrRight);
    update();
  }

  setupPrinter() async {
    try {
      logger.d("Init setupPrinter");

      double? rightPadding = _storage.read(rightPaddingKey);
      double? leftPadding = _storage.read(leftPaddingKey);
      if (rightPadding != null) {
        receiptRightPadding = rightPadding;
      }
      if (leftPadding != null) {
        receiptLeftPadding = leftPadding;
      }

      availablePrinter = await PrinterService().getPrinters();
      selectedPrinter = availablePrinter.first;

      String? selectedPrinterName = _storage.read('defalutPrinterName');
      String? selectedPrinterModel = _storage.read('defalutPrinterModel');

      if (selectedPrinterName != null && selectedPrinterModel != null) {
        for (var element in availablePrinter) {
          if (element.name == selectedPrinterName &&
              element.model == selectedPrinterModel) {
            selectedPrinter = element;
          }
        }
      }
      logger.d("Setting up store printer");
    } catch (e) {
      logger.e("Error fetching printer list: $e");
    }

    update();
  }

  savePrinterSettings() {
    _storage.write('defalutPrinterModel', selectedPrinter?.model);
    _storage.write('defalutPrinterName', selectedPrinter?.name);
  }

  savePaddingSettings(String leftOrRight) {
    if (leftOrRight == "right") {
      _storage.write(
        rightPaddingKey,
        receiptRightPadding,
      );
    } else {
      _storage.write(
        leftPaddingKey,
        receiptLeftPadding,
      );
    }
  }

  final NetworkController _networkController = Get.find<NetworkController>();

  Future getStoreDetails() async {
    String? baseUrl = EvnConstant.baseUrl;
    final String endpoint =
        "$baseUrl/wp-json/wc/v3/trt/store/status"; // Corrected endpoint
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.GET,
        params: {
          'consumer_key': EvnConstant.consumerKey, // Replace with actual key
          'consumer_secret':
              EvnConstant.consumerSecret, // Replace with actual secret
        },
      );

      if (response != null && response.statusCode == 200) {
        storeModel = StoreModel.fromJson(response.data);
        isStoreActive = storeModel?.storeEnabled ?? false;
        logger.d("Response data: ${response.data}");
      } else {
        throw Exception(
            "Failed to fetch store details. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error fetching store details: $e");
    }
  }

  Future toogleStoreStatus() async {
    isStoreActive = !isStoreActive;
    update();
    String? baseUrl = EvnConstant.baseUrl;
    final String endpoint =
        "$baseUrl/wp-json/wc/v3/trt/store/toggle"; // Corrected endpoint
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.POST,
        params: {
          'consumer_key': EvnConstant.consumerKey, // Replace with actual key
          'consumer_secret':
              EvnConstant.consumerSecret, // Replace with actual secret
        },
        body: {
          'enabled': isStoreActive,
        },
      );

      if (response != null && response.statusCode == 200) {
        logger.d("Response data: ${response.data}");
      } else {
        throw Exception(
            "Failed to toogle store status. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error toogling store status: $e");
    }
    update();
  }
}

StoreModel storeModelFromJson(String str) =>
    StoreModel.fromJson(json.decode(str));

String storeModelToJson(StoreModel data) => json.encode(data.toJson());

class StoreModel {
  String? name;
  String? timezone;
  String? contact;
  String? address;
  String? tagline;
  bool? storeEnabled;
  bool? storeOpenHours;

  StoreModel({
    this.name,
    this.contact,
    this.address,
    this.tagline,
    this.storeEnabled,
    this.timezone,
    this.storeOpenHours,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
        name: json["name"],
        contact: json["contact"],
        address: json["address"],
        tagline: json["tagline"],
        timezone: json["timezone"],
        storeEnabled: json["store_enabled"],
        storeOpenHours: json["store_open_hours"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "contact": contact,
        "address": address,
        "tagline": tagline,
        "timezone": timezone,
        "store_enabled": storeEnabled,
        "store_open_hours": storeOpenHours,
      };
}
