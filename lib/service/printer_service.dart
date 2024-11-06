import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
        pageFormat: PdfPageFormat.a4,
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

  /// Tries to print the PDF to a connected printer.
  /// Shows a popup if no printer is found.
  Future<void> printPdf(BuildContext context) async {
    final pdf = await generateBillReceiptPdf();

    // Check for available printers
    final availablePrinters = await Printing.listPrinters();

    if (availablePrinters.isNotEmpty) {
      // If printers are available, select the first one (for demo purposes)
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
