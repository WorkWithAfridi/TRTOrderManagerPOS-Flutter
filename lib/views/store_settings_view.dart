import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_printer/controllers/store_controller.dart';
import 'package:pdf_printer/service/printer_service.dart';
import 'package:printing/printing.dart';

class StoreSettingsView extends StatefulWidget {
  const StoreSettingsView({super.key});

  @override
  State<StoreSettingsView> createState() => _StoreSettingsViewState();
}

class _StoreSettingsViewState extends State<StoreSettingsView> {
  StoreController get controller => Get.find<StoreController>();

  @override
  Widget build(BuildContext context) {
    TextEditingController paddingRightController = TextEditingController(
      text: controller.receiptRightPadding.toString(),
    );

    TextEditingController paddingLeftController = TextEditingController(
      text: controller.receiptLeftPadding.toString(),
    );

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
          return Container(
            padding: const EdgeInsets.all(16),
            height: Get.height,
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Printer: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    controller.availablePrinter.isNotEmpty
                        ? DropdownButton<Printer>(
                            value: controller.selectedPrinter,
                            hint: const Text("Select Printer"),
                            items: controller.availablePrinter
                                .map((Printer printer) {
                              return DropdownMenuItem<Printer>(
                                value: printer,
                                child:
                                    Text("${printer.name} - ${printer.model}"),
                              );
                            }).toList(),
                            onChanged: (Printer? newValue) {
                              controller.selectedPrinter = newValue;
                              controller.savePrinterSettings();
                              controller.update();
                            },
                          )
                        : const Text("No printer available"),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Receipt padding (right side): ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: paddingRightController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          controller.onPaddingUpdated(value, "right");
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Receipt padding (left side): ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: paddingLeftController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          controller.onPaddingUpdated(value, "left");
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    PrinterService().printSamplePage();
                  },
                  child: const Text(
                    "Print sample page",
                  ),
                ),
                const Spacer(),
                Text(
                  "Single User Licensed:\n${controller.storeModel?.name}\n${controller.storeModel?.address}\n${controller.storeModel?.contact}\n${controller.storeModel?.timezone}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
