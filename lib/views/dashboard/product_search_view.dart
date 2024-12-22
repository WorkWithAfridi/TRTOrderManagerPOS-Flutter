import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pdf_printer/controllers/product_list_controller.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  ProductListController get controller => Get.find<ProductListController>();

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
        shadowColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      body: GetBuilder<ProductListController>(
        init: controller,
        builder: (_) {
          final products = controller.products;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: products.isEmpty
                ? const Center(child: Text('No Products Found'))
                : Column(
                    children: [
                      const Gap(4),
                      // Add a rounded text field to search for products
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6, left: 12, right: 12),
                              child: TextField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  // border: OutlineInputBorder(
                                  //   borderRadius: BorderRadius.circular(24.0),
                                  // ),
                                  hintText: 'Search for products',
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          const Gap(8),
                          ElevatedButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.clear),
                                Gap(6),
                                Text('Clear'),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Gap(12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () {
                            return controller.fetchAllProducts();
                          },
                          child: ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              if (searchController.text.isNotEmpty && !(product.name ?? "").toLowerCase().contains(searchController.text.toLowerCase())) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6, left: 6, right: 6),
                                child: SizedBox(
                                  height: 220,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Toggle the product status
                                      final newStatus = product.status == 'publish' ? 'draft' : 'publish';
                                      controller.products.where((p) => p.id == product.id).first.status = newStatus;
                                      controller.toggleProductStatus(
                                        isActive: newStatus == 'publish',
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
                                                  imageUrl: product.images?.first.src ?? '',
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context, url, error) => const Icon(
                                                    Icons.error,
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
                                                      fontSize: 24,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  const Spacer(),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'Status',
                                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                      ),
                                                      Switch(
                                                        value: product.status == 'publish',
                                                        activeTrackColor: Colors.green,
                                                        activeColor: Colors.white,
                                                        inactiveTrackColor: Colors.red,
                                                        inactiveThumbColor: Colors.white,
                                                        onChanged: (value) {
                                                          controller.products.where((p) => p.id == product.id).first.status = value ? 'publish' : 'draft';
                                                          controller.toggleProductStatus(
                                                            isActive: value,
                                                            productId: product.id ?? 0,
                                                          );
                                                          controller.update();
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
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
