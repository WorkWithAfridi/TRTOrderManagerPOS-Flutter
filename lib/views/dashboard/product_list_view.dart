import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_printer/controllers/product_list_controller.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  ProductListController get controller => Get.find<ProductListController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductListController>(
      init: controller,
      builder: (_) {
        final products = controller.products;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: products.isEmpty
                ? const Center(child: Text('No Products Found'))
                : ListView.builder(
                    itemCount: products.length,
                    shrinkWrap: true, // Prevents scrolling issues within a SingleChildScrollView
                    itemBuilder: (context, index) {
                      final product = products[index];
                      // if (index == products.length / 2) {
                      //   controller.currentPage++;
                      //   controller.fetchAllProducts();
                      // }
                      return Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('#${product.id ?? ''}'),
                              Row(
                                children: [
                                  Text(
                                    product.name ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Switch(
                                    value: product.status == 'publish',
                                    onChanged: (value) {
                                      controller.products.where((p) => p.id == product.id).first.status = value ? 'publish' : 'draft';
                                      controller.toggleProductStatus(isActive: value, productId: product.id ?? 0);
                                      controller.update();
                                    },
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
