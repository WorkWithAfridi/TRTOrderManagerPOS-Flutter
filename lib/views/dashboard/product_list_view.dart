import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Product Name')),
            DataColumn(label: Text('Status')),
          ],
          rows: List.generate(
            20,
            (index) => DataRow(
              cells: [
                DataCell(Text('#${index + 1}')),
                DataCell(Text('Product ${index + 1}')),
                DataCell(Switch(
                  value: index % 2 == 0,
                  onChanged: (value) {
                    // Handle status toggle
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
