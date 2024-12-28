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
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Store status: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                Switch(
                  value: controller.isStoreActive,
                  activeTrackColor: Colors.green,
                  activeColor: Colors.white,
                  inactiveTrackColor: Colors.red,
                  inactiveThumbColor: Colors.white,
                  onChanged: (value) {
                    controller.toogleStoreStatus();
                  },
                ),
                Text(
                  controller.isStoreActive ? ' (open)' : ' (closed)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
