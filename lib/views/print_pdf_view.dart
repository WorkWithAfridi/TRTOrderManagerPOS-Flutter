import 'package:flutter/material.dart';
import 'package:pdf_printer/service/printer_service.dart';

class PrintPdfView extends StatelessWidget {
  final printService = PrinterService();

  PrintPdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => printService.printPdf(context),
          child: const Text('Print Demo PDF'),
        ),
      ),
    );
  }
}
