import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  String status = 'Received';

  Future<void> copyReadyMessage() async {
    const readyMessage = '''
Hello Sarah Tan,

Your cake order is ready for collection.

Collection Date: 24 Nov 2026

Thank you.
''';

    await Clipboard.setData(const ClipboardData(text: readyMessage));

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Message copied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            title: Text('Sarah Tan'),
            subtitle: Text('Order #1001'),
          ),

          const Divider(),

          const ListTile(title: Text('Phone'), subtitle: Text('0123456789')),

          const ListTile(title: Text('Flavour'), subtitle: Text('Chocolate')),

          const ListTile(
            title: Text('Allergy Information'),
            subtitle: Text('No allergies'),
          ),

          const ListTile(
            title: Text('Collection Date'),
            subtitle: Text('24 Nov 2026'),
          ),

          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Order Status'),
            items: const [
              DropdownMenuItem(value: 'Received', child: Text('Received')),
              DropdownMenuItem(
                value: 'Deposit Paid',
                child: Text('Deposit Paid'),
              ),
              DropdownMenuItem(value: 'Preparing', child: Text('Preparing')),
              DropdownMenuItem(value: 'Ready', child: Text('Ready')),
              DropdownMenuItem(value: 'Collected', child: Text('Collected')),
            ],
            onChanged: (value) {
              setState(() {
                status = value!;
              });
            },
          ),

          const SizedBox(height: 20),

          if (status == 'Ready')
            FilledButton.icon(
              onPressed: copyReadyMessage,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Ready Message'),
            ),
        ],
      ),
    );
  }
}
