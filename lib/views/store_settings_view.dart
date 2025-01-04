import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_printer/controllers/store_controller.dart';

class StoreSettingsView extends StatefulWidget {
  const StoreSettingsView({super.key});

  @override
  State<StoreSettingsView> createState() => _StoreSettingsViewState();
}

class _StoreSettingsViewState extends State<StoreSettingsView> {
  StoreController get controller => Get.find<StoreController>();

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store settings'),
        shadowColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      body: GetBuilder<StoreController>(
        init: controller,
        builder: (_) {
          return SizedBox(
            height: Get.height,
            width: Get.width,
            child: const Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Printer: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Dropdown with a list of string,
                    // when selected, should print the selected value
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
