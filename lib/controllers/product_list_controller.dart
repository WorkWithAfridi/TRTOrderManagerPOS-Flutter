import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:order_manager/models/product_m.dart';
import 'package:order_manager/service/debug/logger.dart';
import 'package:order_manager/service/evn_constant.dart';

import '../service/network/network-c.dart';

class ProductListController extends GetxController {
  final NetworkController _networkController = Get.find<NetworkController>();

  bool isAllProductActive = false;
  var isLoading = false.obs;

  List<ProductModel> products = [];
  int currentPage = 1;
  List<int> productIds = [];
  final GetStorage _storage = GetStorage();

  Future<List<ProductModel>?> fetchAllProducts() async {
    checkIfAllProductActive();
    String? baseUrl = EvnConstant.baseUrl;
    String endpoint = "$baseUrl/wp-json/wc/v3/products"; // WooCommerce Products endpoint
    // try {
    final response = await _networkController.request(
      url: endpoint,
      method: Method.GET,
      params: {
        'consumer_key': EvnConstant.consumerKey, // Replace with actual key
        'consumer_secret': EvnConstant.consumerSecret, // Replace with actual secret
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
      // sort product by name
      products.sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
      logger.d("Total products: ${products.length}");
      update();
      return products;
    } else {
      throw Exception("Failed to fetch products. Status code: ${response?.statusCode}");
    }
    // } catch (e) {
    //   logger.e("Error fetching products: $e");
    // }
    update();
    return null;
  }

  Future<bool> toggleProductStatus({
    required int productId,
    required bool isActive, // true for publish, false for deactivate
  }) async {
    String? baseUrl = EvnConstant.baseUrl;
    final String endpoint = "$baseUrl/wp-json/wc/v3/products/$productId"; // Endpoint for updating product
    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.PUT,
        params: {
          'consumer_key': EvnConstant.consumerKey, // Replace with actual key
          'consumer_secret': EvnConstant.consumerSecret, // Replace with actual secret
          'stock_status': isActive ? 'instock' : 'outofstock', // Set status based on the toggle
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

  bool checkIfAllProductActive() {
    bool? isAllActive = _storage.read<bool>('isAllProductActive');
    if (isAllActive == null) {
      isAllActive = true;
      _storage.write('isAllProductActive', isAllActive);
    }
    isAllProductActive = isAllActive;
    update();
    return isAllActive;
  }

  Future toggleAllProductStatus() async {
    isAllProductActive = !isAllProductActive;
    for (var product in products) {
      product.stockStatus = isAllProductActive ? 'instock' : 'outofstock';
    }
    update();
    String? baseUrl = EvnConstant.baseUrl;
    final String endpoint = "$baseUrl/wp-json/wc/v3/products/batch"; // Endpoint for updating product

    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.PUT,
        params: {
          'consumer_key': EvnConstant.consumerKey, // Replace with actual key
          'consumer_secret': EvnConstant.consumerSecret, // Replace with actual secret

          "update": [
            ...products.map((product) => {
                  "id": product.id,
                  "stock_status": isAllProductActive ? 'instock' : 'outofstock',
                })
          ],
        },
      );

      if (response != null && response.statusCode == 200) {
        _storage.write('isAllProductActive', isAllProductActive);
        fetchAllProducts();
        return true;
      } else {
        throw Exception("Failed to update batch products. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error updating product: $e");
    }

    update();
    return false;
  }
}
