import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf_printer/controllers/order_list_controller.dart';
import 'package:pdf_printer/service/printer_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrderListController get controller => Get.find<OrderListController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OrderListController>(
        init: controller,
        builder: (_) {
          final orders = controller.orderList;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Chip(
                            label: Text(
                              order.status ?? "NO-STATUS",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _getStatusColor(order.status ?? 'NO-STATUS'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Order Creation Time
                      Text(
                        'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(order.dateCreated ?? DateTime.now())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                      const Divider(height: 20, thickness: 1),

                      // Order Details
                      Text(
                        'Items:',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (order.lineItems ?? []).length,
                        itemBuilder: (context, productIndex) {
                          final product = order.lineItems?[productIndex];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 20, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${product?.name} x${product?.quantity}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  '\$${((product?.price ?? 0) * (product?.quantity ?? 0)).toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const Divider(height: 20, thickness: 1),

                      // Order Notes
                      // Row(
                      //   children: [
                      //     Text(
                      //       'Notes:',
                      //       style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                      //     ),
                      //     Text(
                      //       '${order.}',
                      //     )
                      //   ],
                      // ),
                      // const SizedBox(height: 8),

                      // const Divider(height: 20, thickness: 1),

                      // Total Preparation Time
                      Text(
                        'Total Preparation Time: ${00} minutes',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 16),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // setState(() {
                              //   order.preparationTime += 5;
                              // });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('+5 minutes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showStatusUpdateDialog(context, order);
                            },
                            icon: const Icon(Icons.update),
                            label: const Text('Update Status'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              PrinterService().printOrderBill(context, order);
                            },
                            icon: const Icon(Icons.print),
                            label: const Text('Print Receipt'),
                            // style: ElevatedButton.styleFrom(
                            //   backgroundColor: Colors.green,
                            // ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.grey;
      case 'in progress':
        return Colors.orange;
      case 'cooking':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  // Function to show status update dialog
  void _showStatusUpdateDialog(BuildContext context, dynamic order) {
    final statuses = ['Pending', 'In Progress', 'Cooking', 'Ready', 'Delivered'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      order.status = status;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order.status == status ? Colors.blueAccent : Colors.grey[300],
                    foregroundColor: order.status == status ? Colors.white : Colors.black,
                  ),
                  child: Text(status),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
