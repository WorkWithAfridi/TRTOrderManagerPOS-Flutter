import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  /// Generates a demo PDF document
  Future<pw.Document> generateDemoPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('This is a demo PDF for printing!', style: const pw.TextStyle(fontSize: 24)),
        ),
      ),
    );
    return pdf;
  }

  /// Tries to print the PDF to a connected printer.
  /// Shows a popup if no printer is found.
  Future<void> printPdf(BuildContext context) async {
    final pdf = await generateDemoPdf();

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
