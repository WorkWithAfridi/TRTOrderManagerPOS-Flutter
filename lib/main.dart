import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products & Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Products'),
              Tab(icon: Icon(Icons.receipt), text: 'Orders'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductsPage(),
            OrdersPage(),
          ],
        ),
      ),
    );
  }
}

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

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // List to track the preparation time for each order
  final List<int> preparationTimes = List.generate(10, (_) => 15); // Initial time: 15 minutes

  // Nested list to represent products or menu items for each order
  final List<List<String>> orderDetails = [
    ['Burger', 'Fries', 'Coke'],
    ['Pizza', 'Garlic Bread', 'Lemonade'],
    ['Pasta', 'Salad', 'Wine'],
    ['Steak', 'Mashed Potatoes', 'Water'],
    ['Sushi', 'Miso Soup', 'Green Tea'],
    ['Tacos', 'Nachos', 'Margarita'],
    ['Chicken Wings', 'Coleslaw', 'Beer'],
    ['Pancakes', 'Maple Syrup', 'Orange Juice'],
    ['Fried Rice', 'Spring Rolls', 'Iced Tea'],
    ['Ice Cream', 'Brownie', 'Hot Chocolate'],
  ];

  // List to track the order creation times
  final List<DateTime> orderCreationTimes = List.generate(
    10,
    (_) => DateTime.now().subtract(Duration(minutes: 10 * (_ + 1))),
  ); // Orders created in the past

  // List to track the status of each order
  final List<String> orderStatuses = List.generate(10, (_) => 'Pending'); // Initial status: Pending

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: preparationTimes.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID
                Text(
                  'Order ID: O${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),

                // Order Creation Time
                Text(
                  'Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(orderCreationTimes[index])}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),

                // Order Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ${orderStatuses[index]}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showStatusUpdateDialog(context, index);
                      },
                      child: const Text('Update Status'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Order Details
                Text(
                  'Order Details:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Displaying products in a ListView
                MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  removeTop: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderDetails[index].length,
                    itemBuilder: (context, productIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(orderDetails[index][productIndex]),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Total Preparation Time
                Text(
                  'Total Time to Prepare: ${preparationTimes[index]} minutes',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          preparationTimes[index] += 5; // Increment time by 5 minutes
                        });
                      },
                      child: const Text('+5 minutes'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Print receipt logic
                      },
                      child: const Text('Print Receipt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to show the status update dialog
  void _showStatusUpdateDialog(BuildContext context, int index) {
    final List<String> statuses = ['Pending', 'In Progress', 'Cooking', 'Ready', 'Delivered'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Match card corner radius
          ),
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: double.infinity, // Ensure button takes max width
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        orderStatuses[index] = status; // Update the order status
                      });
                      Navigator.pop(context); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orderStatuses[index] == status ? Colors.blueAccent : Colors.grey[300],
                      foregroundColor: orderStatuses[index] == status ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Button corner styling
                      ),
                    ),
                    child: Text(status),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
