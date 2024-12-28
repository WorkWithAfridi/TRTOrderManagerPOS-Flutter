import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_printer/models/order_m.dart';
import 'package:pdf_printer/models/sales_report_m.dart';
import 'package:pdf_printer/prod_env/prod_end.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:printing/printing.dart';

class PrinterService {
  /// Generates a bill receipt PDF document with demo data
  Future<pw.Document> generateBillReceiptPdf(OrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(companyName, style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text('Order #${order.id}', style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold)),
                  pw.Text(order.dateCreated.toString().substring(0, 10), style: const pw.TextStyle(fontSize: 5)),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 6),
                ],
              ),

              // Table Header
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontSize: 4, fontWeight: pw.FontWeight.bold),
                headers: ['Item', 'Quantity', 'Price', 'Total'],
                cellStyle: const pw.TextStyle(fontSize: 4),
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.2),
                data: (order.lineItems ?? []).map((item) {
                  return [
                    "${item.name} ${(item.metaData ?? []).map((e) => (e.key == "_exoptions" ? "" : "\n - ${e.displayValue}")).join("")}",
                    "x${item.quantity ?? 0}",
                    '\$${(item.price ?? 0.0).toStringAsFixed(2)}',
                    '\$${((item.quantity ?? 0) * (item.price ?? 0.0)).toStringAsFixed(2)}'
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 4),

              // Notes
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Notes:', style: const pw.TextStyle(fontSize: 4)),
                  pw.Text('${order.customerNote}', style: const pw.TextStyle(fontSize: 4)),
                ],
              ),
              pw.SizedBox(height: 4),

              // Subtotal, Tax, and Total
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('SUBTOTAL:', style: const pw.TextStyle(fontSize: 4)),
                        pw.Text(
                          '\$${(order.lineItems ?? []).fold(0.0, (sum, item) => sum + (item.quantity ?? 0) * (item.price ?? 0.0))}',
                          style: const pw.TextStyle(fontSize: 4),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('SHIPPING:', style: const pw.TextStyle(fontSize: 4)),
                        pw.Text('\$${order.shippingTotal}', style: const pw.TextStyle(fontSize: 4)),
                      ],
                    ),
                    ...(order.taxLines ?? []).map((e) {
                      return pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${e.label}:', style: const pw.TextStyle(fontSize: 4)),
                          pw.Text('\$${e.taxTotal}', style: const pw.TextStyle(fontSize: 4)),
                        ],
                      );
                    }),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total TAX:', style: const pw.TextStyle(fontSize: 4)),
                        pw.Text('\$${order.totalTax}', style: const pw.TextStyle(fontSize: 4)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('PAYMENT METHOD:', style: const pw.TextStyle(fontSize: 4)),
                        pw.Text('${order.paymentMethodTitle}', style: const pw.TextStyle(fontSize: 4)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total:', style: const pw.TextStyle(fontSize: 4)),
                        pw.Text('\$${order.total}', style: const pw.TextStyle(fontSize: 4)),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                  ],
                ),
              ),

              // Customer Details
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Divider(thickness: 0.5),
                  pw.Text(
                    'Customer:',
                    style: pw.TextStyle(
                      fontSize: 5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${order.billing?.firstName ?? ''} ${order.billing?.lastName ?? ''}',
                    style: const pw.TextStyle(fontSize: 4),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    order.billing?.phone ?? '',
                    style: const pw.TextStyle(fontSize: 4),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${order.billing?.email ?? ''}.',
                    style: const pw.TextStyle(fontSize: 4),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    order.billing?.address1 ?? '',
                    style: const pw.TextStyle(fontSize: 4),
                  ),
                  pw.SizedBox(height: 2),
                ],
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Divider(thickness: 0.5),
                  pw.Text('Powered By TRT Technologies Ltd', style: const pw.TextStyle(fontSize: 4)),
                  pw.SizedBox(height: 2),
                  pw.Text('www.trttech.ca', style: const pw.TextStyle(fontSize: 4)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Prints the PDF, with web and non-web support.
  Future<void> printOrderBill(
    OrderModel order,
  ) async {
    logger.d("Printing order with id: ${order.id}");
    final pdf = await generateBillReceiptPdf(order);

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        format: PdfPageFormat.roll80,
      );
    } else {
      final availablePrinters = await Printing.listPrinters();

      if (availablePrinters.isNotEmpty) {
        await Printing.directPrintPdf(
          format: PdfPageFormat.roll80,
          printer: availablePrinters.first,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        logger.d("No printer found.");
      }
    }
  }

  /// Generates a sales report PDF document
  Future<pw.Document> generateSalesReportPdf(List<SalesReportModel> reports) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Sales Report',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              // Add a table for each report
              for (var report in reports)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Grouped By: ${report.totalsGroupedBy ?? "N/A"}',
                      style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 6),
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
                      headerStyle: pw.TextStyle(fontSize: 4, fontWeight: pw.FontWeight.bold),
                      cellStyle: const pw.TextStyle(fontSize: 4),
                      border: pw.TableBorder.all(width: 0.2),
                    ),
                    pw.SizedBox(height: 8),
                    if (report.totals != null && report.totals!.isNotEmpty)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Totals by Group:',
                            style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 6),
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
                            headerStyle: pw.TextStyle(fontSize: 4, fontWeight: pw.FontWeight.bold),
                            cellStyle: const pw.TextStyle(fontSize: 4),
                            border: pw.TableBorder.all(width: 0.2),
                          ),
                        ],
                      ),
                    pw.Divider(thickness: 1),
                  ],
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Divider(thickness: 0.5),
                  pw.Text('Powered By TRT Technologies Ltd', style: const pw.TextStyle(fontSize: 4)),
                  pw.SizedBox(height: 2),
                  pw.Text('www.trttech.ca', style: const pw.TextStyle(fontSize: 4)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Prints the PDF, with web and non-web support.
  Future<void> printSalesReport(BuildContext context, List<SalesReportModel> reports) async {
    final pdf = await generateSalesReportPdf(reports);

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        format: PdfPageFormat.roll80,
      );
    } else {
      final availablePrinters = await Printing.listPrinters();

      if (availablePrinters.isNotEmpty) {
        await Printing.directPrintPdf(
          printer: availablePrinters.first,
          format: PdfPageFormat.roll80,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('No Printer Found'),
            content: const Text('No printers are currently available. Please check your connection.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
