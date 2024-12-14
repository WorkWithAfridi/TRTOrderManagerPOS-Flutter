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
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Status')),
              ],
              rows: products.isEmpty
                  ? [
                      const DataRow(
                        cells: [
                          DataCell(Text('')),
                          DataCell(Text('No Products Found')),
                          DataCell(Text('')),
                        ],
                      ),
                    ]
                  : products
                      .map(
                        (product) => DataRow(
                          cells: [
                            DataCell(Text('#${product.id ?? ''}')),
                            DataCell(Text(product.name ?? 'N/A')),
                            DataCell(Switch(
                              value: product.status == 'publish',
                              onChanged: (value) {
                                // Handle status toggle logic
                              },
                            )),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        );
      },
    );
  }
}
