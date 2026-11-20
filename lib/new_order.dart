import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final customerController = TextEditingController();
  final phoneController = TextEditingController();
  final flavourController = TextEditingController();
  final allergyController = TextEditingController();

  DateTime? collectionDate;

  Future<void> saveOrder() async {
    if (customerController.text.isEmpty) {
      showError('Customer name required');
      return;
    }

    if (phoneController.text.isEmpty) {
      showError('Phone number required');
      return;
    }

    if (allergyController.text.isEmpty) {
      showError('Allergy information required');
      return;
    }

    if (collectionDate == null) {
      showError('Collection date required');
      return;
    }

    try {
      await Supabase.instance.client.from('orders').insert({
        'customer_name': customerController.text,
        'customer_phone': phoneController.text,
        'channel': 'WhatsApp',
        'allergies': allergyController.text,
        'pickup_at': collectionDate!.toIso8601String(),
        'status': 'Received',
        'notes': flavourController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Order Saved')));

        Navigator.pop(context);
      }
    } catch (e) {
      showError(e.toString());
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        collectionDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: customerController,
            decoration: const InputDecoration(labelText: 'Customer Name *'),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number *'),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: flavourController,
            decoration: const InputDecoration(labelText: 'Flavour'),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: allergyController,
            decoration: const InputDecoration(
              labelText: 'Allergy Information *',
            ),
          ),

          const SizedBox(height: 16),

          FilledButton(
            onPressed: chooseDate,
            child: Text(
              collectionDate == null
                  ? 'Choose Collection Date'
                  : collectionDate.toString().split(' ')[0],
            ),
          ),

          const SizedBox(height: 24),

          FilledButton(onPressed: saveOrder, child: const Text('Save Order')),
        ],
      ),
    );
  }
}
