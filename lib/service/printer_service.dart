import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_printer/controllers/store_controller.dart';
import 'package:pdf_printer/models/order_m.dart';
import 'package:pdf_printer/models/sales_report_m.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:printing/printing.dart';

class PrinterService {
  Printer? selectedPrinter;

  getListOfAvailablePrinters() async {
    final availablePrinters = await Printing.listPrinters();
    for (var printer in availablePrinters) {
      logger.d(
        "Printer: ${printer.name} - ${printer.model} - ${printer.isDefault ? "Default" : ""}",
      );
    }
  }

  Future<pw.Document> generateBillReceiptPdf(OrderModel order) async {
    final pdf = pw.Document();

    pw.TextStyle bodyTS = const pw.TextStyle(
      fontSize: 10,
    );
    pw.TextStyle headerTS = const pw.TextStyle(
      fontSize: 10,
    );

    StoreController storeController = Get.find<StoreController>();

    pdf.addPage(
      pw.Page(
        clip: true,
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.only(right: 50),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      storeController.storeModel?.name ?? "",
                      style: headerTS.copyWith(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      storeController.storeModel?.address ?? "- -",
                      style: headerTS,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      storeController.storeModel?.contact ?? "- -",
                      style: headerTS,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Order #${order.id}', style: headerTS),
                    pw.Text(
                        'Order type: #${order.metaData?.firstWhere(
                              (e) => e.key == "exwfood_order_method",
                              orElse: () {
                                return OrderModelMetaDatum(id: 0, key: "", value: "");
                              },
                            ).value ?? ''}',
                        style: headerTS),
                    pw.Text(
                        'Time taken: #${order.metaData?.firstWhere(
                              (e) => e.key == "exwfood_time_deli",
                              orElse: () {
                                return OrderModelMetaDatum(id: 0, key: "", value: "");
                              },
                            ).value ?? ''}',
                        style: headerTS),
                    pw.SizedBox(height: 4),
                    pw.Text(order.dateCreated.toString().substring(0, 10), style: headerTS),
                    pw.SizedBox(height: 4),
                  ],
                ),
              ),

              // Table Header
              pw.TableHelper.fromTextArray(
                headerStyle: bodyTS,
                headers: ['Item', 'Total'],
                headerAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 4, height: .8),
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.2),
                cellPadding: const pw.EdgeInsets.all(2),
                data: (order.lineItems ?? []).map((item) {
                  return [
                    pw.Text(
                      "${item.name} ${"x${item.quantity ?? 0}"} ${(item.metaData ?? []).map((e) => (e.key == "_exoptions" ? "" : "\n - ${e.displayValue}")).join("")}",
                      style: bodyTS,
                    ),
                    // pw.SizedBox(

                    pw.SizedBox(
                      width: 55,
                      child: pw.Text(
                        '\$${((item.quantity ?? 0) * (item.price ?? 0.0)).toStringAsFixed(2)}',
                        style: bodyTS,
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ];
                }).toList(),
              ),

              pw.TableHelper.fromTextArray(
                headerStyle: bodyTS,
                headerAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 4, height: .8),
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.2),
                cellPadding: const pw.EdgeInsets.all(2),
                data: [
                  [
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Subtotal:',
                                style: bodyTS,
                              ),
                              pw.Text(
                                '\$${(order.lineItems ?? []).fold(0.0, (sum, item) => sum + (item.quantity ?? 0) * (item.price ?? 0.0)).toStringAsFixed(2)}',
                                style: bodyTS,
                              ),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Shipping:',
                                style: bodyTS,
                              ),
                              pw.Text(
                                '\$${order.shippingTotal}',
                                style: bodyTS,
                              ),
                            ],
                          ),
                          ...(order.taxLines ?? []).map((e) {
                            return pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  '${e.label}:',
                                  style: bodyTS,
                                ),
                                pw.Text(
                                  '\$${e.taxTotal}',
                                  style: bodyTS,
                                ),
                              ],
                            );
                          }),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Payment:',
                                style: bodyTS,
                              ),
                              pw.Text('${order.paymentMethodTitle}', style: bodyTS),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Total:',
                                style: bodyTS,
                              ),
                              pw.Text('\$${order.total}', style: bodyTS),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                        ],
                      ),
                    )
                  ]
                ],
              ),

              // Notes
              order.customerNote != null
                  ? pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 4),
                        pw.Text('Notes: ', style: headerTS),
                        pw.Text(
                          '${order.customerNote}',
                          style: headerTS,
                          maxLines: 100,
                        ),
                        pw.SizedBox(height: 4),
                      ],
                    )
                  : pw.SizedBox.shrink(),

              // pw.ListView.builder(
              //   itemCount: (order.lineItems ?? []).length,
              //   itemBuilder: (context, index) {
              //     final item = order.lineItems![index];
              //     return pw.Row(
              //       crossAxisAlignment: pw.CrossAxisAlignment.start,
              //       children: [
              //         pw.Expanded(
              //           child: pw.Text(
              //             "${item.name} ${"x${item.quantity ?? 0}"} ${(item.metaData ?? []).map((e) => (e.key == "_exoptions" ? "" : "\n - ${e.displayValue}")).join("")}",
              //             style: pw.TextStyle(fontSize: 4, fontWeight: pw.FontWeight.bold),
              //           ),
              //         ),
              //         // pw.SizedBox(
              //         //   width: 30,
              //         //   child: pw.Text(
              //         //     style: pw.TextStyle(fontSize: 4, fontWeight: pw.FontWeight.bold),
              //         //   ),
              //         // ),
              //         // pw.Text('\$${(item.price ?? 0.0).toStringAsFixed(2)}'),
              //         pw.SizedBox(
              //           width: 60,
              //           child: pw.Text(
              //             '\$${((item.quantity ?? 0) * (item.price ?? 0.0)).toStringAsFixed(2)}',
              //             style: pw.TextStyle(fontSize: 4, fontWeight: pw.FontWeight.bold),
              //             textAlign: pw.TextAlign.right,
              //           ),
              //         )
              //       ],
              //     );
              //   },
              // ),

              // ...(order.lineItems ?? []).map((item) {
              //   return ;
              // }),
              // pw.SizedBox(height: 4),

              // Subtotal, Tax, and Total

              // Customer Details
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 4),
                  pw.Container(
                    height: 0.5,
                    color: PdfColor.fromHex('#000000'),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Customer:',
                    style: bodyTS,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${order.billing?.firstName ?? ''} ${order.billing?.lastName ?? ''}',
                    style: bodyTS,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    order.billing?.phone ?? '',
                    style: bodyTS,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${order.billing?.email ?? ''}.',
                    style: bodyTS,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    order.billing?.address1 ?? '',
                    style: bodyTS,
                  ),
                  pw.SizedBox(height: 2),
                ],
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Divider(thickness: 0.5),
                  pw.Text('Powered By TRT Technologies Ltd', style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 2),
                  pw.Text('www.trttech.ca', style: const pw.TextStyle(fontSize: 8)),
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

      for (var printer in availablePrinters) {
        logger.d(
          "Printer: ${printer.name} - ${printer.model} - ${printer.isDefault ? "Default" : ""}",
        );
      }

      // Printing.pickPrinter(context: context)

      if (availablePrinters.isNotEmpty) {
        await Printing.directPrintPdf(
          printer: availablePrinters.first,
          format: PdfPageFormat.roll80,
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
        margin: const pw.EdgeInsets.all(4),
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
                    pw.SizedBox(height: 4),
                    pw.Container(
                      height: 0.5,
                      color: PdfColor.fromHex('#000000'),
                    ),
                    pw.SizedBox(height: 4),
                  ],
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 4),
                  pw.Container(
                    height: 0.5,
                    color: PdfColor.fromHex('#000000'),
                  ),
                  pw.SizedBox(height: 4),
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
          usePrinterSettings: true,
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
