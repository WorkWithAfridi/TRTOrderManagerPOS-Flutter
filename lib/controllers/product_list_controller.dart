import 'package:get/get.dart';
import 'package:pdf_printer/models/product_m.dart';
import 'package:pdf_printer/prod_env/prod_end.dart';
import 'package:pdf_printer/service/debug/logger.dart';

import '../service/network/network-c.dart';

class ProductListController extends GetxController {
  final NetworkController _networkController = Get.find<NetworkController>();

  List<ProductModel> products = [];

  Future<List<ProductModel>?> fetchAllProducts() async {
    String endpoint = "$baseUrl/wp-json/wc/v3/products"; // WooCommerce Products endpoint
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
        List<ProductModel> fetchedProducts = (response.data as List).map((product) => ProductModel.fromJson(product)).toList();
        products = fetchedProducts;
        return products;
      } else {
        throw Exception("Failed to fetch products. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error fetching products: $e");
    }
    update();
    return null;
  }

  Future<bool> updateProductDetails({
    required int productId,
    required Map<String, dynamic> updatedData,
  }) async {
    final String endpoint = "$baseUrl/wp-json/wc/v3/products/$productId"; // Endpoint for updating product
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.PUT,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
          ...updatedData, // Merge additional fields for the update
        },
      );

      if (response != null && response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to update product. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error updating product: $e");
    }
    return false;
  }
}
