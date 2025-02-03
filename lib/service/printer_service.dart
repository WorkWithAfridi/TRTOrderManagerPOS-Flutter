import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:order_manager/controllers/order_list_controller.dart';
import 'package:order_manager/controllers/store_controller.dart';
import 'package:order_manager/models/order_m.dart';
import 'package:order_manager/models/sales_report_m.dart';
import 'package:order_manager/service/debug/logger.dart';
import 'package:printing/printing.dart';

class PrinterService {
  Printer? selectedPrinter;

  static const roll80Format =
      PdfPageFormat(72 * PdfPageFormat.mm, double.infinity);
  Future<pw.Document> generateSamplePagePdf() async {
    final pdf = pw.Document();

    pw.TextStyle bodyTS = const pw.TextStyle(
      fontSize: 10,
    );

    pdf.addPage(
      pw.Page(
        clip: false,
        pageFormat: roll80Format,
        margin: pw.EdgeInsets.only(
          right: Get.find<StoreController>().receiptRightPadding,
          left: Get.find<StoreController>().receiptLeftPadding,
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
    // Create the PDF document
    final pdf = pw.Document();

    // ---------- STYLES & SPACING ----------
    // Define consistent text styles
    const double kFontSize = 12;
    const baseTextStyle = pw.TextStyle(fontSize: kFontSize);
    final boldTextStyle =
        baseTextStyle.copyWith(fontWeight: pw.FontWeight.bold);
    final largerBoldStyle = boldTextStyle.copyWith(
      fontSize: 13,
    );

    // Define a set of spacing constants for uniform layout
    const double kGapSmall = 4;
    const double kGapMed = 8;

    // Define a consistent border width
    const double kBorderWidth = 1;

    // ---------- DATA EXTRACTION ----------
    final storeController = Get.find<StoreController>();

    // Pull out order metadata with safe defaults
    final type = order.metaData
            ?.firstWhere(
              (e) => e.key == "exwfood_order_method",
              orElse: () => OrderModelMetaDatum(id: 0, key: "", value: ""),
            )
            .value
            ?.trim() ??
        '';

    final timeTaken = order.metaData
            ?.firstWhere(
              (e) => e.key == "exwfood_time_deli",
              orElse: () => OrderModelMetaDatum(id: 0, key: "", value: ""),
            )
            .value
            ?.trim() ??
        '';

    final tipsFee = order.feeLines
            ?.firstWhere(
              (e) => e.key == "Tips",
              orElse: () => FeeLinesModelDatum(id: 0, key: "", value: ""),
            )
            .value
            ?.trim() ??
        '';

    final deliveryFee = order.feeLines
            ?.firstWhere(
              (e) => e.key == "Shipping fee",
              orElse: () => FeeLinesModelDatum(
                id: 0,
                key: "Shipping fee",
                value: "0.00",
              ),
            )
            .value
            ?.trim() ??
        '0.00';

    // ---------- PAGE BUILD ----------
    pdf.addPage(
      pw.Page(
        clip: false, // for continuous-roll printers
        pageFormat: roll80Format,
        // margin: const pw.EdgeInsets.only(),
        margin: pw.EdgeInsets.only(
          right: Get.find<StoreController>().receiptRightPadding,
          left: Get.find<StoreController>().receiptLeftPadding,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ---------- HEADER SECTION ----------
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      storeController.storeModel?.name ?? "",
                      style: largerBoldStyle,
                    ),
                    pw.Text(
                      storeController.storeModel?.address ?? "",
                      style: baseTextStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      storeController.storeModel?.contact ?? "",
                      style: baseTextStyle,
                    ),
                    pw.SizedBox(height: kGapSmall),
                    pw.Text('Order #${order.id}', style: baseTextStyle),

                    // Order method
                    if (type.isNotEmpty)
                      pw.Text(
                        type.toUpperCase(),
                        style: baseTextStyle.copyWith(
                            fontWeight: pw.FontWeight.bold),
                      ),

                    // Time Taken
                    if (timeTaken.isNotEmpty && timeTaken != "-")
                      pw.Text(
                        'Time: $timeTaken',
                        style: baseTextStyle.copyWith(
                            fontWeight: pw.FontWeight.bold),
                      ),

                    pw.SizedBox(height: kGapSmall),
                    // Date/Time
                    pw.Text(
                      DateFormat('MMM d, yyyy hh:mm a')
                          .format(order.dateCreated ?? DateTime.now()),
                      style: baseTextStyle,
                    ),
                    pw.SizedBox(height: kGapSmall),
                  ],
                ),
              ),

              pw.SizedBox(height: kGapSmall),

              // ---------- ITEMS TABLE ----------
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(4.5),
                  1: const pw.FlexColumnWidth(1.5),
                },
                border: pw.TableBorder.all(
                    color: PdfColors.black, width: kBorderWidth),
                children: [
                  // Table header row
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Item', style: baseTextStyle),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Total',
                            style: baseTextStyle,
                            textAlign: pw.TextAlign.right),
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
                            "${(item.metaData ?? []).map((e) => e.key == '_exoptions' ? '' : '\n - ${e.displayValue}').join('')}",
                            style: largerBoldStyle,
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            "\$${((item.quantity ?? 0) * (item.price ?? 0.0)).toStringAsFixed(2)}",
                            style: baseTextStyle,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              // ---------- TOTALS TABLE ----------
              pw.Table(
                border: const pw.TableBorder(
                  top: pw.BorderSide.none,
                  left: pw.BorderSide(
                      color: PdfColors.black, width: kBorderWidth),
                  right: pw.BorderSide(
                      color: PdfColors.black, width: kBorderWidth),
                  bottom: pw.BorderSide(
                      color: PdfColors.black, width: kBorderWidth),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Subtotal
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Subtotal:', style: baseTextStyle),
                                pw.Text(
                                  '\$${(order.lineItems ?? []).fold(
                                        0.0,
                                        (sum, item) =>
                                            sum +
                                            (item.quantity ?? 0) *
                                                (item.price ?? 0.0),
                                      ).toStringAsFixed(2)}',
                                  style: baseTextStyle,
                                ),
                              ],
                            ),
                            // Delivery Fee
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Delivery Fee:', style: baseTextStyle),
                                pw.Text('\$$deliveryFee', style: baseTextStyle),
                              ],
                            ),
                            // Tips (if present)
                            if (tipsFee.isNotEmpty)
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Tips:', style: baseTextStyle),
                                  pw.Text('\$$tipsFee', style: baseTextStyle),
                                ],
                              ),
                            // Tax lines
                            ...(order.taxLines ?? []).map((e) {
                              return pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('${e.label}:', style: baseTextStyle),
                                  pw.Text('\$${e.taxTotal}',
                                      style: baseTextStyle),
                                ],
                              );
                            }),
                            // Payment
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Payment:', style: baseTextStyle),
                                pw.Text('${order.paymentMethodTitle}',
                                    style: baseTextStyle),
                              ],
                            ),
                            // Total
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Total:', style: baseTextStyle),
                                pw.Text('\$${order.total}',
                                    style: baseTextStyle),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ---------- NOTES ----------
              if (order.customerNote?.isNotEmpty ?? false)
                pw.SizedBox(height: kGapMed),
              if (order.customerNote?.isNotEmpty ?? false)
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                  },
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#000000'),
                    width: kBorderWidth,
                  ),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: kGapSmall),
                              pw.Text('Notes:', style: largerBoldStyle),
                              pw.Text(
                                '${order.customerNote}',
                                style: largerBoldStyle,
                                maxLines: 100,
                              ),
                              pw.SizedBox(height: kGapSmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              pw.SizedBox(height: kGapMed),

              // ---------- CUSTOMER INFO ----------
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                },
                border: pw.TableBorder.all(
                  color: PdfColors.black,
                  width: kBorderWidth,
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Customer:', style: baseTextStyle),
                            pw.Text(
                              '${order.billing?.firstName ?? ''} '
                              '${order.billing?.lastName ?? ''}',
                              style: baseTextStyle,
                            ),
                            pw.Text(
                              order.billing?.phone ?? '',
                              style: baseTextStyle,
                            ),
                            pw.Text(
                              order.billing?.email ?? '',
                              style: baseTextStyle,
                            ),
                            if (type == 'delivery' &&
                                (order.shipping?.address1 ?? '').isNotEmpty)
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    '${order.shipping?.address1 ?? ''} '
                                    '${order.shipping?.address2 ?? ''}, '
                                    '${order.shipping?.city ?? ''}, '
                                    '${order.shipping?.state ?? ''}, '
                                    '${order.shipping?.postcode ?? ''}, '
                                    '${order.shipping?.country ?? ''}',
                                    style: largerBoldStyle,
                                  ),
                                ],
                              ),
                            pw.SizedBox(height: kGapSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ---------- FOOTER ----------
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Divider(thickness: kBorderWidth),
                  pw.Text(
                    'Powered By TRT Technologies Ltd',
                    style: baseTextStyle.copyWith(fontSize: 10),
                  ),
                  pw.SizedBox(height: kGapSmall),
                  pw.Text(
                    'www.trttech.ca',
                    style: baseTextStyle.copyWith(fontSize: 10),
                  ),
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
    // Create the PDF document
    final pdf = pw.Document();

    // ---------- STYLES & SPACING ----------
    const double kFontSize = 10;
    const baseTextStyle = pw.TextStyle(fontSize: kFontSize);

    const double kGapSmall = 4;
    const double kGapMed = 8;
    const double kBorderWidth = 1; // Thin table borders on receipts

    // ---------- BUILD PAGE ----------
    pdf.addPage(
      pw.Page(
        pageFormat: roll80Format,
        // margin: const pw.EdgeInsets.only(),
        margin: pw.EdgeInsets.only(
          right: Get.find<StoreController>().receiptRightPadding,
          left: Get.find<StoreController>().receiptLeftPadding,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // ---------- HEADER ----------
              pw.Text('Sales Report',
                  style: baseTextStyle, textAlign: pw.TextAlign.center),
              pw.SizedBox(height: kGapMed),

              // ---------- REPORTS LOOP ----------
              for (final report in reports)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Grouped by
                    pw.Text(
                        'Duration: ${report.totalsGroupedBy?.capitalize ?? "N/A"}',
                        style: baseTextStyle,
                        textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: kGapSmall),

                    // Table of Key Metrics
                    pw.TableHelper.fromTextArray(
                      headerStyle: baseTextStyle,
                      cellStyle: baseTextStyle,
                      oddCellStyle: baseTextStyle,
                      border: pw.TableBorder.all(width: kBorderWidth),
                      // (Optional) Let both columns share width equally
                      // or adjust if you need one column wider than the other:
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1),
                        1: const pw.FlexColumnWidth(1),
                      },
                      headers: ['Metric', 'Value'],
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
                    ),
                    pw.SizedBox(height: kGapSmall),
                  ],
                ),

              // ---------- FOOTER ----------
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Divider(thickness: kBorderWidth),
                  pw.Text(
                    'Powered By TRT Technologies Ltd',
                    style: baseTextStyle.copyWith(fontSize: 8),
                  ),
                  pw.SizedBox(height: kGapSmall),
                  pw.Text(
                    'www.trttech.ca',
                    style: baseTextStyle.copyWith(fontSize: 8),
                  ),
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
