import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: products.isEmpty
              ? const Center(child: Text('No Products Found'))
              : RefreshIndicator(
                  onRefresh: () {
                    return controller.fetchAllProducts();
                  },
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Number of columns
                      crossAxisSpacing: 8.0, // Horizontal spacing
                      mainAxisSpacing: 8.0, // Vertical spacing
                      childAspectRatio: 3 / 2, // Aspect ratio of each grid item
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          // Toggle the product status
                          final newStatus = product.stockStatus == 'instock' ? 'outofstock' : 'instock';
                          controller.products.where((p) => p.id == product.id).first.stockStatus = newStatus;
                          controller.toggleProductStatus(
                            isActive: newStatus == 'instock',
                            productId: product.id ?? 0,
                          );
                          controller.update();
                        },
                        child: Card(
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(.6),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: SizedBox(
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: (product.images ?? []).isEmpty || product.images == null ? '' : product.images?.first.src ?? '',
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 12,
                                    bottom: 12,
                                    right: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '#${product.id ?? ''}',
                                        style: const TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        product.name ?? 'N/A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product.stockStatus == 'instock' ? 'In-Stock' : 'Out of Stock',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Switch(
                                            value: product.stockStatus == 'instock',
                                            activeTrackColor: Colors.green,
                                            activeColor: Colors.white,
                                            inactiveTrackColor: Colors.red,
                                            inactiveThumbColor: Colors.white,
                                            onChanged: (value) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16.0),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Are you sure you want to set product to ${product.stockStatus == 'instock' ? 'out-of-stock' : 'in-stock'}?',
                                                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 22,
                                                              ),
                                                        ),
                                                        const Gap(20),
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                              child: const Padding(
                                                                padding: EdgeInsets.all(12.0),
                                                                child: Text(
                                                                  'NO',
                                                                  style: TextStyle(color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                            const Gap(12),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                controller.products.where((p) => p.id == product.id).first.stockStatus =
                                                                    value ? 'instock' : 'outofstock';
                                                                controller.toggleProductStatus(
                                                                  isActive: value,
                                                                  productId: product.id ?? 0,
                                                                );
                                                                controller.update();
                                                                Get.back();
                                                              },
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                              child: const Padding(
                                                                padding: EdgeInsets.all(12.0),
                                                                child: Text(
                                                                  'YES',
                                                                  style: TextStyle(color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
