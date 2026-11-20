import 'package:material_ui/material_ui.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'id': '#1001',
        'customer': 'Sarah Tan',
        'status': 'Ready',
        'date': '24 Nov 2026',
      },
      {
        'id': '#1002',
        'customer': 'Ahmad Ali',
        'status': 'Preparing',
        'date': '25 Nov 2026',
      },
      {
        'id': '#1003',
        'customer': 'Jason Lee',
        'status': 'Received',
        'date': '27 Nov 2026',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders List'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(order['customer']!),
              subtitle: Text(
                '${order['id']}\n${order['date']}',
              ),
              trailing: Chip(
                label: Text(order['status']!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}