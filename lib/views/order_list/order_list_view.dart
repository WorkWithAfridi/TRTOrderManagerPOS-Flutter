import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_manager/controllers/order_list_controller.dart';
import 'package:order_manager/service/printer_service.dart';

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
      // appBar: AppBar(
      //   actions: [
      //     ElevatedButton(
      //       onPressed: () {
      //         Get.find<StoreController>().getStoreDetails();
      //       },
      //       child: const Text("TEST"),
      //     )
      //   ],
      // ),
      body: GetBuilder<OrderListController>(
        init: controller,
        builder: (_) {
          final orders = controller.orderList;

          return Column(
            children: [
              Row(
                children: [
                  const Gap(16),
                  const Text("Filter by: "),
                  const Gap(6),
                  ElevatedButton(
                    onPressed: () {
                      controller.selectedOrderFilterStatus.value = "all";
                      controller.update();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          controller.selectedOrderFilterStatus.value == "all"
                              ? Colors.teal
                              : Colors.white,
                      foregroundColor:
                          controller.selectedOrderFilterStatus.value == "all"
                              ? Colors.white
                              : Colors.teal,
                    ),
                    child: const Text("All"),
                  ),
                  const Gap(8),
                  ...controller.orderList
                      .map((order) => order.status)
                      .toList()
                      .toSet()
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              controller.selectedOrderFilterStatus.value =
                                  e ?? "all";
                              controller.update();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  controller.selectedOrderFilterStatus.value ==
                                          e
                                      ? Colors.teal
                                      : Colors.white,
                              foregroundColor:
                                  controller.selectedOrderFilterStatus.value ==
                                          e
                                      ? Colors.white
                                      : Colors.teal,
                            ),
                            child: Text(
                                "${e.toString()[0].toUpperCase()}${e.toString().substring(1).toLowerCase()} (${controller.orderList.map((order) => order.status == e).toList().where((element) => element).length})"),
                          ),
                        ),
                      ),
                ],
              ),
              const Gap(12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    return controller.getOrderList(context,
                        shouldLoadFromLocalStorage: false);
                  },
                  child: controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : orders.isEmpty
                          ? const Center(child: Text('No Orders'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];

                                if (controller
                                            .selectedOrderFilterStatus.value !=
                                        "all" &&
                                    order.status !=
                                        controller
                                            .selectedOrderFilterStatus.value) {
                                  return const SizedBox.shrink();
                                }

                                return Card(
                                  elevation: 6,
                                  shadowColor: Colors.black.withOpacity(.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Order ID and Status
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Order #${order.id} : ${order.billing?.firstName} ${order.billing?.lastName}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Chip(
                                              label: Text(
                                                (order.status ?? "NO-STATUS")[0]
                                                        .toUpperCase() +
                                                    (order.status ??
                                                            "NO-STATUS")
                                                        .substring(1),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: _getStatusColor(
                                                  order.status ?? 'NO-STATUS'),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Order Creation Time
                                        Text(
                                          'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(order.dateCreated ?? DateTime.now())}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),

                                        const Divider(height: 20, thickness: 1),

                                        // Order Details
                                        Text(
                                          'Items:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),

                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              (order.lineItems ?? []).length,
                                          itemBuilder: (context, productIndex) {
                                            final product =
                                                order.lineItems?[productIndex];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.check_circle,
                                                      size: 20,
                                                      color: Colors.green),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '${product?.name} x${product?.quantity}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ),
                                                  Text(
                                                    '\$${((product?.price ?? 0) * (product?.quantity ?? 0)).toStringAsFixed(2)}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
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
                                        controller.getMinutesRemaining(
                                                    order.id ?? 0) ==
                                                null
                                            ? const SizedBox.shrink()
                                            : Column(
                                                children: [
                                                  Text(
                                                    controller.getMinutesRemaining(
                                                                order.id ??
                                                                    0) ==
                                                            0
                                                        ? "Timer ended"
                                                        : 'Total Preparation Time: ${controller.getMinutesRemaining(order.id ?? 0) ?? 0} minutes',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                              ),

                                        // Buttons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // controller.getMinutesRemaining(order.id ?? 0) == 0
                                            //     ? const SizedBox.shrink()
                                            //     : ElevatedButton.icon(
                                            //         onPressed: () {
                                            //           // controller.increaseOrderTimerBy5Minutes(order.id ?? 0);
                                            //           showDialog(
                                            //             context: context,
                                            //             barrierDismissible: false,
                                            //             builder: (context) {
                                            //               return AlertDialog(
                                            //                 shape: RoundedRectangleBorder(
                                            //                   borderRadius: BorderRadius.circular(16.0),
                                            //                 ),
                                            //                 content: GetBuilder<OrderListController>(
                                            //                   init: controller,
                                            //                   initState: (_) {},
                                            //                   builder: (_) {
                                            //                     return Column(
                                            //                       mainAxisSize: MainAxisSize.min,
                                            //                       children: [
                                            //                         const Text('Update Order Status'),
                                            //                         const Gap(10),
                                            //                         Text(
                                            //                           'Total Preparation Time: ${controller.getMinutesRemaining(order.id ?? 0) ?? 0} minutes',
                                            //                           style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            //                                 fontWeight: FontWeight.bold,
                                            //                                 fontSize: 22,
                                            //                               ),
                                            //                         ),
                                            //                         const Gap(20),
                                            //                         Row(
                                            //                           mainAxisSize: MainAxisSize.min,
                                            //                           children: [
                                            //                             ElevatedButton(
                                            //                               onPressed: () {
                                            //                                 controller.decreaseOrderTimerBy5Minutes(order.id ?? 0);
                                            //                               },
                                            //                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            //                               child: const Text(
                                            //                                 '- 5 minutes',
                                            //                                 style: TextStyle(color: Colors.white),
                                            //                               ),
                                            //                             ),
                                            //                             const Gap(12),
                                            //                             ElevatedButton(
                                            //                               onPressed: () {
                                            //                                 controller.increaseOrderTimerBy5Minutes(order.id ?? 0);
                                            //                               },
                                            //                               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            //                               child: const Text(
                                            //                                 '+ 5 minutes',
                                            //                                 style: TextStyle(color: Colors.white),
                                            //                               ),
                                            //                             ),
                                            //                           ],
                                            //                         ),
                                            //                         const Gap(20),
                                            //                         ElevatedButton(
                                            //                           onPressed: () {
                                            //                             controller.notifyCustomerOnOrderTimerUpdate(order.id ?? 0);
                                            //                             Get.back();
                                            //                           },
                                            //                           style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                            //                           child: const Text(
                                            //                             'Done',
                                            //                             style: TextStyle(color: Colors.white),
                                            //                           ),
                                            //                         ),
                                            //                       ],
                                            //                     );
                                            //                   },
                                            //                 ),
                                            //               );
                                            //             },
                                            //           );
                                            //         },
                                            //         label: Text(
                                            //           controller.getMinutesRemaining(order.id ?? 0) == null ? "Set timer" : 'Update timer',
                                            //           style: const TextStyle(color: Colors.white),
                                            //         ),
                                            //         style: ElevatedButton.styleFrom(
                                            //           backgroundColor: Colors.red,
                                            //         ),
                                            //       ),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                // controller.increaseOrderTimerBy5Minutes(order.id ?? 0);
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      content: GetBuilder<
                                                          OrderListController>(
                                                        init: controller,
                                                        initState: (_) {},
                                                        builder: (_) {
                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Text(
                                                                  'Update Order Status'),
                                                              const Gap(10),
                                                              Text(
                                                                'Total Preparation Time: ${controller.getMinutesRemaining(order.id ?? 0) ?? 0} minutes',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge!
                                                                    .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          22,
                                                                    ),
                                                              ),
                                                              const Gap(20),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      controller.decreaseOrderTimerBy5Minutes(
                                                                          order.id ??
                                                                              0);
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            Colors.red),
                                                                    child:
                                                                        const Text(
                                                                      '- 5 minutes',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                  const Gap(12),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      controller.increaseOrderTimerBy5Minutes(
                                                                          order.id ??
                                                                              0);
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            Colors.green),
                                                                    child:
                                                                        const Text(
                                                                      '+ 5 minutes',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Gap(20),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  controller
                                                                      .notifyCustomerOnOrderTimerUpdate(
                                                                          order.id ??
                                                                              0);
                                                                  Get.back();
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.black),
                                                                child:
                                                                    const Text(
                                                                  'Done',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              label: Text(
                                                controller.getMinutesRemaining(
                                                            order.id ?? 0) ==
                                                        null
                                                    ? "Set timer"
                                                    : 'Update timer',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                            ),

                                            ElevatedButton.icon(
                                              onPressed: () {
                                                _showStatusUpdateDialog(
                                                    context, order);
                                              },
                                              icon: const Icon(Icons.update),
                                              label:
                                                  const Text('Update Status'),
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                PrinterService()
                                                    .printOrderBill(order);
                                              },
                                              icon: const Icon(Icons.print),
                                              label:
                                                  const Text('Print Receipt'),
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
                            ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.orange;
      case 'on-hold':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.red;
      case 'failed':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  // Function to show status update dialog
  void _showStatusUpdateDialog(BuildContext context, dynamic order) {
    // List of allowed statuses
    final statuses = [
      'Pending',
      'Processing',
      'On-Hold',
      'Completed',
      'Cancelled',
      'Refunded',
      'Failed',
      // 'Trash',
    ];

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
                      order.status = status
                          .toLowerCase(); // Use lowercase to match API convention

                      controller.updateOrderStatus(
                          order.id, status.toLowerCase());
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order.status == status.toLowerCase()
                        ? Colors.blueAccent
                        : Colors.grey[300],
                    foregroundColor: order.status == status.toLowerCase()
                        ? Colors.white
                        : Colors.black,
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
