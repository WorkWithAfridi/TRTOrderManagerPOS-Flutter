import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf_printer/controllers/sales_report_controller.dart';
import 'package:pdf_printer/service/printer_service.dart';

import '../../models/sales_report_m.dart';

class SalesReportScreen extends StatelessWidget {
  SalesReportScreen({super.key});

  final SalesReportController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: () {
            PrinterService().printSalesReport(context, controller.salesReportList);
          },
          child: const Text("Print Report"),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.salesReportList.isEmpty) {
          return const Center(
            child: Text(
              "No sales reports available.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.builder(
            itemCount: controller.salesReportList.length,
            itemBuilder: (context, index) {
              final report = controller.salesReportList[index];
              return SalesReportCard(report: report);
            },
          ),
        );
      }),
    );
  }
}

class SalesReportCard extends StatelessWidget {
  final SalesReportModel report;

  const SalesReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Sales and Date Range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Sales",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                Text(
                  _formatCurrency(report.totalSales ?? "0"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Summary of Metrics
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildStatCard("Net Sales", _formatCurrency(report.netSales ?? "0"), Icons.attach_money, Colors.green),
                _buildStatCard("Avg. Sales", _formatCurrency(report.averageSales ?? "0"), Icons.trending_up, Colors.blue),
                _buildStatCard("Orders", report.totalOrders?.toString() ?? "0", Icons.shopping_cart, Colors.orange),
                _buildStatCard("Items", report.totalItems?.toString() ?? "0", Icons.inventory, Colors.purple),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            // Tax, Shipping, and Customers
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildStatCard("Tax", _formatCurrency(report.totalTax ?? "0"), Icons.receipt, Colors.red),
                _buildStatCard("Shipping", _formatCurrency(report.totalShipping ?? "0"), Icons.local_shipping, Colors.brown),
                _buildStatCard("Discount", _formatCurrency(report.totalDiscount ?? "0"), Icons.discount, Colors.pink),
                _buildStatCard("Customers", report.totalCustomers?.toString() ?? "0", Icons.people, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatCurrency(String amount) {
    try {
      final double value = double.parse(amount);
      final formatter = NumberFormat.currency(symbol: "\$", decimalDigits: 2);
      return formatter.format(value);
    } catch (e) {
      return amount;
    }
  }
}
