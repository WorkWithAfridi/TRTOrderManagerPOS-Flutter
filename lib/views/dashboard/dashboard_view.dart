import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:order_manager/controllers/dashboard_controller.dart';
import 'package:order_manager/controllers/order_list_controller.dart';
import 'package:order_manager/controllers/product_list_controller.dart';
import 'package:order_manager/controllers/sales_report_controller.dart';
import 'package:order_manager/controllers/store_controller.dart';
import 'package:order_manager/views/dashboard/dashboard_drawer.dart';
import 'package:order_manager/views/order_list/all_orders_view.dart';
import 'package:order_manager/views/order_list/order_list_view.dart';
import 'package:order_manager/views/product_list/product_list_view.dart';
import 'package:order_manager/views/product_list/product_search_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  SalesReportController get salesReportController =>
      Get.find<SalesReportController>();

  DashboardController get dashboardController =>
      Get.find<DashboardController>();
  OrderListController get orderListController =>
      Get.find<OrderListController>();
  ProductListController get productListController =>
      Get.find<ProductListController>();

  @override
  void initState() {
    orderListController.initOrderLoop(context);
    super.initState();
  }

  StoreController get controller => Get.find<StoreController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Obx(() => Text(
            'TRT Order Manager - ${dashboardController.isProductTabSelected.value ? 'Store' : 'Orders'}')),
        actions: [
          Obx(
            () => dashboardController.isProductTabSelected.value
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Accepting Online Orders: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      GetBuilder<StoreController>(
                        init: controller,
                        initState: (_) {},
                        builder: (_) {
                          return Switch(
                            value: controller.isStoreActive,
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
                                          'Are you sure you want to ${controller.isStoreActive ? 'stop receiving online orders' : 'start receiving online orders'}?',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                              ),
                                        ),
                                        const Gap(20),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'NO',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            const Gap(16),
                                            ElevatedButton(
                                              onPressed: () {
                                                controller.toogleStoreStatus();

                                                Get.back();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green),
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'YES',
                                                  style: TextStyle(
                                                      color: Colors.white),
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
                          );
                        },
                      ),
                      Text(
                        controller.isStoreActive ? ' (Yes)' : ' (No)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Gap(20),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.find<OrderListController>().getOrderList(context);
                        },
                        child: const Text(
                          "Refresh",
                        ),
                      ),
                      const Gap(12),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(
                            () => const AllOrdersPage(),
                          );
                        },
                        child: const Text(
                          "View all orders",
                        ),
                      ),
                      const Gap(20),
                    ],
                  ),
          )
        ],
      ),
      drawer: const DashboardDrawer(),
      body: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: dashboardController.isProductTabSelected.value
              ? Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetBuilder<ProductListController>(
                            init: productListController,
                            initState: (_) {},
                            builder: (_) {
                              return Row(
                                children: [
                                  const Text("All products: "),
                                  Switch(
                                    value: productListController
                                        .isAllProductActive,
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
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Are you sure you want to set all products ${productListController.isAllProductActive ? 'out-of-stock' : 'in-stock'}?',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 22,
                                                      ),
                                                ),
                                                const Gap(20),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: Text(
                                                          'NO',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    const Gap(12),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        productListController
                                                            .toggleAllProductStatus();
                                                        Get.back();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.green),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: Text(
                                                          'YES',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
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
                                  Text(
                                    productListController.isAllProductActive
                                        ? ' (in-stock)'
                                        : ' (out-of-stock)',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              );
                            },
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  productListController.isLoading.value = true;
                                  await productListController
                                      .fetchAllProducts();
                                  await Get.find<StoreController>()
                                      .getStoreDetails();
                                  productListController.isLoading.value = false;
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text("Refresh"),
                                ),
                              ),
                              const Gap(12),
                              ElevatedButton(
                                onPressed: () {
                                  Get.to(
                                    const ProductSearchPage(),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text("Search"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: productListController.isLoading.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const ProductsPage(),
                    ),
                  ],
                )
              : const OrdersPage(),
        ),
      ),
    );
  }
}

// run on chrome command
// flutter run -d chrome --dart-define=BASE_URL=https://cp.trttechnologies.net --dart-define=CONSUMER_KEY=ck_bc2663992cdf540bf18572a3b8ed25527b472001 --dart-define=CONSUMER_SECRET=cs_f8dcc9937cb605113bfc0431bbe2c219d1b18ed8 --dart-define=VERSION=wc/v3


// TODO: Add tabs in todays order page for all status,