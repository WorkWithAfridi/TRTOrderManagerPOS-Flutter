import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_printer/models/sales_report_m.dart';
import 'package:printing/printing.dart';

class PrinterService {
  /// Generates a bill receipt PDF document with demo data
  Future<pw.Document> generateBillReceiptPdf() async {
    final pdf = pw.Document();

    // Sample data
    const String companyName = 'Tech Store';
    const String customerName = 'John Doe';
    const String date = '2024-11-06';
    final List<Map<String, dynamic>> items = [
      {'name': 'Laptop', 'quantity': 1, 'price': 1200.0},
      {'name': 'Mouse', 'quantity': 2, 'price': 25.0},
      {'name': 'Keyboard', 'quantity': 1, 'price': 45.0},
    ];
    const double subtotal = 1295.0;
    const double tax = 103.6;
    const double total = 1398.6;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Bill Receipt', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 8),

              // Customer and Date Information
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Customer: $customerName', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('Date: $date', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 16),

              // Table Header
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                headers: ['Item', 'Quantity', 'Price', 'Total'],
                data: items.map((item) {
                  return [
                    item['name'],
                    item['quantity'].toString(),
                    '\$${item['price'].toStringAsFixed(2)}',
                    '\$${(item['quantity'] * item['price']).toStringAsFixed(2)}'
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 16),

              // Subtotal, Tax, and Total
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('\$${subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Tax:', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('\$${tax.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 1),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('\$${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Prints the PDF, with web and non-web support.
  Future<void> printPdf(BuildContext context) async {
    final pdf = await generateBillReceiptPdf();

    if (kIsWeb) {
      // On Web, use Printing.layoutPdf to show a print preview dialog
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } else {
      // On mobile (iOS/Android), continue as before
      final availablePrinters = await Printing.listPrinters();

      if (availablePrinters.isNotEmpty) {
        await Printing.directPrintPdf(
          printer: availablePrinters.first,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        // Show popup if no printer is available
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('No Printer Found'),
            content: const Text('Please connect to a printer to print this document.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Generates a sales report PDF document
  Future<pw.Document> _generateSalesReportPdf(List<SalesReportModel> reports) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return [
            pw.Text(
              'Sales Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),

            // Add a table for each report
            for (var report in reports)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Grouped By: ${report.totalsGroupedBy ?? "N/A"}',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table.fromTextArray(
                    headers: [
                      'Metric',
                      'Value',
                    ],
                    data: [
                      ['Total Sales', report.totalSales ?? "N/A"],
                      ['Net Sales', report.netSales ?? "N/A"],
                      ['Average Sales', report.averageSales ?? "N/A"],
                      ['Total Orders', report.totalOrders?.toString() ?? "N/A"],
                      ['Total Items', report.totalItems?.toString() ?? "N/A"],
                      ['Total Tax', report.totalTax ?? "N/A"],
                      ['Total Shipping', report.totalShipping ?? "N/A"],
                      ['Total Refunds', report.totalRefunds?.toString() ?? "N/A"],
                      ['Total Discount', report.totalDiscount ?? "N/A"],
                      ['Total Customers', report.totalCustomers?.toString() ?? "N/A"],
                    ],
                    headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    cellStyle: const pw.TextStyle(fontSize: 12),
                    border: pw.TableBorder.all(width: 0.5),
                  ),
                  pw.SizedBox(height: 16),
                  if (report.totals != null && report.totals!.isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Totals by Group:',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Table.fromTextArray(
                          headers: ['Group', 'Sales', 'Orders', 'Items', 'Tax', 'Shipping', 'Discount', 'Customers'],
                          data: report.totals!.entries.map((entry) {
                            final total = entry.value;
                            return [
                              entry.key,
                              total.sales ?? "N/A",
                              total.orders?.toString() ?? "N/A",
                              total.items?.toString() ?? "N/A",
                              total.tax ?? "N/A",
                              total.shipping ?? "N/A",
                              total.discount ?? "N/A",
                              total.customers?.toString() ?? "N/A",
                            ];
                          }).toList(),
                          headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                          cellStyle: const pw.TextStyle(fontSize: 12),
                          border: pw.TableBorder.all(width: 0.5),
                        ),
                      ],
                    ),
                  pw.Divider(thickness: 1),
                ],
              ),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Prints the PDF, with web and non-web support.
  Future<void> printSalesReport(BuildContext context, List<SalesReportModel> reports) async {
    final pdf = await _generateSalesReportPdf(reports);

    if (kIsWeb) {
      // On Web, use Printing.layoutPdf to show a print preview dialog
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } else {
      // On mobile (iOS/Android), continue as before
      final availablePrinters = await Printing.listPrinters();

      if (availablePrinters.isNotEmpty) {
        await Printing.directPrintPdf(
          printer: availablePrinters.first,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        // Show popup if no printer is available
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('No Printer Found'),
            content: const Text('Please connect to a printer to print this document.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
