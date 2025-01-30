import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_printer/controllers/order_list_controller.dart';
import 'package:pdf_printer/controllers/store_controller.dart';
import 'package:pdf_printer/models/order_m.dart';
import 'package:pdf_printer/models/sales_report_m.dart';
import 'package:pdf_printer/service/debug/logger.dart';
import 'package:printing/printing.dart';

class PrinterService {
  Printer? selectedPrinter;
  Future<pw.Document> generateSamplePagePdf() async {
    final pdf = pw.Document();

    pw.TextStyle bodyTS = const pw.TextStyle(
      fontSize: 10,
    );

    pdf.addPage(
      pw.Page(
        clip: false,
        pageFormat: PdfPageFormat.roll80,
        margin: pw.EdgeInsets.only(
          right: Get.find<StoreController>().receiptPadding,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                """"Commodo consectetur dolore qui aliquip consequat aliquip veniam velit sunt esse occaecat proident. Dolore ex est ad pariatur aute consectetur Lorem enim ut reprehenderit non aliqua cupidatat in enim. Fugiat proident duis sunt velit cupidatat elit ad. Exercitation eu voluptate mollit. Ex amet duis aute exercitation dolor ea Lorem enim ea consequat quis do. Do reprehenderit Lorem officia veniam ullamco consectetur ut ex sint.

Id adipisicing eu ullamco deserunt sint irure excepteur Lorem magna magna amet dolore adipisicing mollit fugiat. Aliquip deserunt adipisicing ullamco commodo qui commodo officia. Cillum in duis quis voluptate. Irure tempor pariatur et. Esse do ipsum in nulla excepteur deserunt ex magna qui eu dolor. Ipsum proident irure adipisicing nulla cupidatat cupidatat occaecat. Tempor commodo culpa irure amet incididunt. Excepteur amet eu adipisicing incididunt elit cupidatat nostrud in elit.""",
                style: bodyTS,
              )
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Prints the PDF, with web and non-web support.
  Future<void> printSamplePage() async {
    List<OrderModel> orders = Get.find<OrderListController>().orderList;

    if (orders.isNotEmpty) {
      PrinterService().printOrderBill(
        orders[Random().nextInt(orders.length)],
      );
      return;
    }

    final pdf = await generateSamplePagePdf();

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
          printer: Get.find<StoreController>().selectedPrinter ??
              availablePrinters.first,
          format: PdfPageFormat.roll80,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        logger.d("No printer found.");
      }
    }
  }

  Future<pw.Document> generateBillReceiptPdf(OrderModel order) async {
    final pdf = pw.Document();

    pw.TextStyle headerTS = const pw.TextStyle(
      fontSize: 12,
    );
    pw.TextStyle bodyTS = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
    );
    pw.TextStyle footerTS = const pw.TextStyle(
      fontSize: 12,
    );

    StoreController storeController = Get.find<StoreController>();

    String type = order.metaData?.firstWhere(
          (e) => e.key == "exwfood_order_method",
          orElse: () {
            return OrderModelMetaDatum(id: 0, key: "", value: "");
          },
        ).value ??
        '';

    String timeTaken = order.metaData?.firstWhere(
          (e) => e.key == "exwfood_time_deli",
          orElse: () {
            return OrderModelMetaDatum(id: 0, key: "", value: "");
          },
        ).value ??
        '';

    String tipsFee = order.feeLines?.firstWhere(
          (e) => e.key == "Tips",
          orElse: () {
            return FeeLinesModelDatum(id: 0, key: "", value: "");
          },
        ).value ??
        '';

    String deliveryFee = order.feeLines?.firstWhere(
          (e) => e.key == "Shipping fee",
          orElse: () {
            return FeeLinesModelDatum(
                id: 0, key: "Shipping fee", value: "0.00");
          },
        ).value ??
        '0.00';

    pdf.addPage(
      pw.Page(
        clip: false,
        pageFormat: PdfPageFormat.roll80,
        // margin: pw.EdgeInsets.only(
        //   right: Get.find<StoreController>().receiptPadding,
        // ),
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
                      style: bodyTS,
                    ),
                    pw.Text(
                      storeController.storeModel?.address ?? "",
                      style: headerTS,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      storeController.storeModel?.contact ?? "",
                      style: headerTS,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Order #${order.id}', style: headerTS),
                    (type != "")
                        ? pw.Text(type.toUpperCase(),
                            style: headerTS.copyWith(
                              fontWeight: pw.FontWeight.bold,
                            ))
                        : pw.Container(),
                    (timeTaken != "" && timeTaken != "-")
                        ? pw.Text('Time: $timeTaken',
                            style: headerTS.copyWith(
                              fontWeight: pw.FontWeight.bold,
                            ))
                        : pw.Container(),
                    pw.SizedBox(height: 4),
                    // pw.Text(order.dateCreated.toString().substring(0, 10), style: headerTS),
                    pw.Text(
                        DateFormat('MMM d, yyyy hh:mm a')
                            .format(order.dateCreated ?? DateTime.now()),
                        style: headerTS),
                    pw.SizedBox(height: 4),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),

              // Table Header your 'Item'/'Total' table
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(4.5),
                  1: const pw.FlexColumnWidth(1.5),
                },
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                children: [
                  // Header row
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Item', style: headerTS),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Total', style: headerTS),
                      ),
                    ],
                  ),

                  // Dynamically build rows for each line item
                  ...(order.lineItems ?? []).map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            "${item.name} x${item.quantity ?? 0}"
                            // Example for variations or metadata
                            "${(item.metaData ?? []).map((e) => e.key == '_exoptions' ? '' : '\n - ${e.displayValue}').join('')}",
                            style: bodyTS,
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            "\$${((item.quantity ?? 0) * (item.price ?? 0.0)).toStringAsFixed(2)}",
                            style: headerTS,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.Table(
                border: const pw.TableBorder(
                  top: pw.BorderSide.none,
                  left: pw.BorderSide(color: PdfColors.black, width: 1),
                  right: pw.BorderSide(color: PdfColors.black, width: 1),
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
                children: [
                  // We only have one row, which contains all the totals in a single cell
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Subtotal:', style: footerTS),
                                  pw.Text(
                                    '\$${(order.lineItems ?? []).fold(0.0, (sum, item) => sum + (item.quantity ?? 0) * (item.price ?? 0.0)).toStringAsFixed(2)}',
                                    style: footerTS,
                                  ),
                                ],
                              ),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Delivery Fee:', style: footerTS),
                                  pw.Text('\$$deliveryFee', style: footerTS),
                                ],
                              ),
                              if (tipsFee.isNotEmpty)
                                pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('Tips:', style: footerTS),
                                    pw.Text('\$$tipsFee', style: footerTS),
                                  ],
                                ),
                              ...(order.taxLines ?? []).map((e) {
                                return pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('${e.label}:', style: footerTS),
                                    pw.Text('\$${e.taxTotal}', style: footerTS),
                                  ],
                                );
                              }),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Payment:', style: footerTS),
                                  pw.Text('${order.paymentMethodTitle}',
                                      style: footerTS),
                                ],
                              ),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Total:', style: footerTS),
                                  pw.Text('\$${order.total}', style: footerTS),
                                ],
                              ),
                              pw.SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              order.customerNote != null && order.customerNote!.isNotEmpty
                  ? pw.SizedBox(height: 10)
                  : pw.SizedBox.shrink(),
              // Notes
              order.customerNote != null && order.customerNote!.isNotEmpty
                  ? pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColor.fromHex('#000000'),
                          width: 1,
                        ),
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(height: 4),
                          pw.Text('Notes: ', style: bodyTS),
                          pw.Text(
                            '${order.customerNote}',
                            style: bodyTS,
                            maxLines: 100,
                          ),
                          pw.SizedBox(height: 4),
                        ],
                      ),
                    )
                  : pw.SizedBox.shrink(),

              // Subtotal, Tax, and Total
              pw.SizedBox(height: 10),

              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#000000'),
                    width: 1,
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Customer:',
                      style: footerTS,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${order.billing?.firstName ?? ''} ${order.billing?.lastName ?? ''}',
                      style: footerTS,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      order.billing?.phone ?? '',
                      style: footerTS,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${order.billing?.email ?? ''}.',
                      style: footerTS,
                    ),
                    pw.SizedBox(height: 2),
                    (type == 'delivery' &&
                            (order.shipping?.address1 ?? '') != '')
                        ? pw.Column(children: [
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '${order.shipping?.address1 ?? ''} ${order.shipping?.address2 ?? ''}, ${order.shipping?.city ?? ''}, ${order.shipping?.state ?? ''}, ${order.shipping?.postcode ?? ''}, ${order.shipping?.country ?? ''}',
                              style: footerTS.copyWith(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ])
                        : pw.Container(),
                    pw.SizedBox(height: 2),
                  ],
                ),
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Divider(thickness: 0.1),
                  pw.Text('Powered By TRT Technologies Ltd',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 2),
                  pw.Text('www.trttech.ca',
                      style: const pw.TextStyle(fontSize: 10)),
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
          printer: Get.find<StoreController>().selectedPrinter ??
              availablePrinters.first,
          format: PdfPageFormat.roll80,
          onLayout: (PdfPageFormat format) async => pdf.save(),
          usePrinterSettings: true,
        );
      } else {
        logger.d("No printer found.");
      }
    }
  }

  /// Generates a sales report PDF document
  Future<pw.Document> generateSalesReportPdf(
      List<SalesReportModel> reports) async {
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
        margin: pw.EdgeInsets.only(
          right: Get.find<StoreController>().receiptPadding,
        ),
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Sales Report',
                style: headerTS,
              ),
              pw.SizedBox(height: 8),

              // Add a table for each report
              for (var report in reports)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Grouped By: ${report.totalsGroupedBy ?? "N/A"}',
                      style: bodyTS,
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
                        [
                          'Total Orders',
                          report.totalOrders?.toString() ?? "N/A"
                        ],
                        ['Total Items', report.totalItems?.toString() ?? "N/A"],
                        ['Total Tax', report.totalTax ?? "N/A"],
                        ['Total Shipping', report.totalShipping ?? "N/A"],
                        [
                          'Total Refunds',
                          report.totalRefunds?.toString() ?? "N/A"
                        ],
                        ['Total Discount', report.totalDiscount ?? "N/A"],
                        [
                          'Total Customers',
                          report.totalCustomers?.toString() ?? "N/A"
                        ],
                      ],
                      headerStyle: bodyTS,
                      cellStyle: bodyTS,
                      oddCellStyle: bodyTS,
                      border: pw.TableBorder.all(width: 0.2),
                    ),
                    pw.SizedBox(height: 8),
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
                  pw.Divider(thickness: 0.5),
                  pw.Text('Powered By TRT Technologies Ltd',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 2),
                  pw.Text('www.trttech.ca',
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<List<Printer>> getPrinters() async {
    return await Printing.listPrinters();
  }

  /// Prints the PDF, with web and non-web support.
  Future<void> printSalesReport(
      BuildContext context, List<SalesReportModel> reports) async {
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
          printer: Get.find<StoreController>().selectedPrinter ??
              availablePrinters.first,
          format: PdfPageFormat.roll80,
          usePrinterSettings: true,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        logger.d("No printer found.");
      }
    }
  }
}
