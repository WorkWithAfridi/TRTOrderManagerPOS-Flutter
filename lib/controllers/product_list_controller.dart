import 'package:get/get.dart';
import 'package:pdf_printer/models/product_m.dart';
import 'package:pdf_printer/prod_env/prod_end.dart';
import 'package:pdf_printer/service/debug/logger.dart';

import '../service/network/network-c.dart';

class ProductListController extends GetxController {
  final NetworkController _networkController = Get.find<NetworkController>();

  List<ProductModel> products = [];
  int currentPage = 1;
  List<int> productIds = [];

  Future<List<ProductModel>?> fetchAllProducts() async {
    String endpoint = "$baseUrl/wp-json/wc/v3/products"; // WooCommerce Products endpoint
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.GET,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
          'per_page': 100,
          'page': currentPage,
        },
      );

      // logger.d("Response data: ${response?.data}");

      if (response != null && response.statusCode == 200) {
        List<ProductModel> fetchedProducts = (response.data as List).map((product) => ProductModel.fromJson(product)).toList();
        for (var product in fetchedProducts) {
          if (product.id != null) {
            if (!productIds.contains(product.id!)) {
              {
                products.add(product);
                productIds.add(product.id ?? 0);
              }
            }
          }
        }
        logger.d("Total products: ${products.length}");
        update();
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

  Future<bool> toggleProductStatus({
    required int productId,
    required bool isActive, // true for publish, false for deactivate
  }) async {
    final String endpoint = "$baseUrl/wp-json/wc/v3/products/$productId"; // Endpoint for updating product
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.PUT,
        params: {
          'consumer_key': consumerKey, // Replace with actual key
          'consumer_secret': consumerSecret, // Replace with actual secret
          'status': isActive ? 'publish' : 'draft', // Set status based on the toggle
        },
      );

      if (response != null && response.statusCode == 200) {
        // fetchAllProducts();
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
