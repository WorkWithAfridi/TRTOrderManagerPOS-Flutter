import 'package:get/get.dart';
import 'package:pdf_printer/models/sales_report_m.dart';
import 'package:pdf_printer/prod_env/prod_end.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:pdf_printer/views/report/report_view.dart';

import '../service/network/network-c.dart';

class SalesReportController extends GetxController {
  final NetworkController _networkController = Get.find<NetworkController>();

  // Observables for the report and loading state
  var isLoading = false.obs;
  List<SalesReportModel> salesReportList = [];

  // Method to fetch the sales report
  Future<List<SalesReportModel>> getSalesReport({required String period}) async {
    // period can be "day", "week", "two_weeks", or "month"
    String endpoint = "$baseUrl/wp-json/wc/v3/reports/sales"; // WooCommerce Reports endpoint

    // Determine the date range for the report based on the selected period
    Map<String, String> dateRange = _calculateDateRange(period);

    isLoading.value = true; // Show loading spinner

    try {
      final response = await _networkController.request(
        url: endpoint,
        method: Method.GET,
        params: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
          'after': dateRange['after']!,
          'before': dateRange['before']!,
        },
      );

      if (response != null && response.statusCode == 200) {
        // Parse the response into SalesReportModel
        salesReportList = (response.data as List).map((report) => SalesReportModel.fromJson(report)).toList();
        logger.d("Fetched $period report successfully: $salesReportList");
        Get.to(
          () => SalesReportScreen(),
        );
        return salesReportList;
      } else {
        throw Exception("Failed to fetch $period report. Status code: ${response?.statusCode}");
      }
    } catch (e) {
      logger.e("Error fetching $period report: $e");
    } finally {
      isLoading.value = false; // Hide loading spinner
    }

    update(); // Notify UI of changes

    //show toast
    Get.snackbar('Error', 'Failed to fetch $period report.}');

    return [];
  }

  // Helper method to calculate date range
  Map<String, String> _calculateDateRange(String period) {
    DateTime now = DateTime.now();
    late DateTime startDate;
    late DateTime endDate;

    switch (period) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day); // Today start
        endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)); // Today end
        break;
      case 'week':
        int weekDay = now.weekday; // 1 for Monday, 7 for Sunday
        startDate = now.subtract(Duration(days: weekDay - 1)); // Start of the current week (Monday)
        endDate = startDate.add(const Duration(days: 7)).subtract(const Duration(seconds: 1)); // End of the current week
        break;
      case 'two_weeks':
        int weekDay = now.weekday; // 1 for Monday, 7 for Sunday
        startDate = now.subtract(Duration(days: weekDay - 1)); // Start of the current week (Monday)
        endDate = startDate.add(const Duration(days: 14)).subtract(const Duration(seconds: 1)); // End of the two-week period
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1); // First day of the current month
        endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1)); // Last day of the current month
        break;
      default:
        throw Exception("Invalid period specified");
    }

    return {
      'after': startDate.toIso8601String(),
      'before': endDate.toIso8601String(),
    };
  }
}
