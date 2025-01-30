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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GetBuilder<StoreController>(
        init: controller,
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Printer",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: controller.availablePrinter.isNotEmpty
                              ? DropdownButtonFormField<Printer>(
                                  value: controller.selectedPrinter,
                                  hint: const Text("Select Printer"),
                                  items: controller.availablePrinter
                                      .map((Printer printer) {
                                    return DropdownMenuItem<Printer>(
                                      value: printer,
                                      child: Text(
                                          "${printer.name} - ${printer.model}"),
                                    );
                                  }).toList(),
                                  onChanged: (Printer? newValue) {
                                    controller.selectedPrinter = newValue;
                                    controller.savePrinterSettings();
                                    controller.update();
                                  },
                                )
                              : const Text("No printer available",
                                  style: TextStyle(color: Colors.grey)),
                        ),
                        const Divider(),
                        _buildPaddingField("Receipt Padding (Right Side)",
                            controller.receiptRightPadding, (value) {
                          controller.onPaddingUpdated(value, "right");
                        }),
                        _buildPaddingField("Receipt Padding (Left Side)",
                            controller.receiptLeftPadding, (value) {
                          controller.onPaddingUpdated(value, "left");
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => PrinterService().printSamplePage(),
                    icon: const Icon(Icons.print),
                    label: const Text("Print Sample Page"),
                  ),
                ),
                const Spacer(),
                _buildLicenseInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaddingField(
      String label, double initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            width: 100,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: onChanged,
              controller: TextEditingController(text: initialValue.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "License Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Divider(),
            _buildLicenseDetail("Store Name", controller.storeModel?.name ?? "N/A"),
            _buildLicenseDetail("Address", controller.storeModel?.address ?? "N/A"),
            _buildLicenseDetail("Contact", controller.storeModel?.contact ?? "N/A"),
            _buildLicenseDetail("Timezone", controller.storeModel?.timezone ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
