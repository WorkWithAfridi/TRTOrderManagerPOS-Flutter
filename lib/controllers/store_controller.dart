import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf_printer/prod_env/prod_end.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:pdf_printer/service/network/network-c.dart';

class StoreController extends GetxController {
  StoreModel? storeModel;
  bool isStoreActive = false;
  final GetStorage _storage = GetStorage(); // Initialize GetStorage

  final NetworkController _networkController = Get.find<NetworkController>();

  Future getStoreDetails() async {
    final String endpoint = "$baseUrl/wp-json/wc/v3/trt/store/status"; // Corrected endpoint
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.GET,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
        },
      );

      if (response != null && response.statusCode == 200) {
        storeModel = StoreModel.fromJson(response.data);
        isStoreActive = storeModel?.storeEnabled ?? false;
        logger.d("Response data: ${response.data}");
      } else {
        throw Exception("Failed to fetch store details. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error fetching store details: $e");
    }
  }

  Future toogleStoreStatus() async {
    isStoreActive = !isStoreActive;
    update();
    final String endpoint = "$baseUrl/wp-json/wc/v3/trt/store/toggle"; // Corrected endpoint
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.POST,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
        },
        body: {
          'enabled': isStoreActive,
        },
      );

      if (response != null && response.statusCode == 200) {
        logger.d("Response data: ${response.data}");
      } else {
        throw Exception("Failed to toogle store status. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error toogling store status: $e");
    }
    update();
  }
}

StoreModel storeModelFromJson(String str) => StoreModel.fromJson(json.decode(str));

String storeModelToJson(StoreModel data) => json.encode(data.toJson());

class StoreModel {
  String? name;
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
    this.storeOpenHours,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
        name: json["name"],
        contact: json["contact"],
        address: json["address"],
        tagline: json["tagline"],
        storeEnabled: json["store_enabled"],
        storeOpenHours: json["store_open_hours"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "contact": contact,
        "address": address,
        "tagline": tagline,
        "store_enabled": storeEnabled,
        "store_open_hours": storeOpenHours,
      };
}
