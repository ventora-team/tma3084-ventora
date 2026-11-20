import 'package:material_ui/material_ui.dart';
import '../data/order.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order get o => widget.order;

  OrderStatus? get _next {
    final i = OrderStatus.values.indexOf(o.status);
    return i < OrderStatus.values.length - 1 ? OrderStatus.values[i + 1] : null;
  }

  void _advance() {
    final n = _next;
    if (n == null) return;
    setState(() => o.status = n);
  }

  @override
  Widget build(BuildContext context) {
    final p = o.pickupDate;
    final theme = Theme.of(context);
    final allergy = !o.allergyAnswered
        ? 'Not answered'
        : o.allergyNote.isEmpty
            ? 'No allergy'
            : o.allergyNote;
    final next = _next;

    return Scaffold(
      appBar: AppBar(title: Text(o.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(o.customer, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Pickup ${p.day}/${p.month}/${p.year}'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _row('Total', o.total),
                  _row('Deposit (30%)', o.deposit),
                  _row('Balance', o.balance),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Allergy'),
              subtitle: Text(allergy),
            ),
          ),
          const SizedBox(height: 20),
          Text('Status', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final s in OrderStatus.values)
            ListTile(
              dense: true,
              leading: Icon(s == o.status
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked),
              title: Text(
                s.label,
                style: TextStyle(
                  fontWeight: s == o.status ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: next == null ? null : _advance,
            child: Text(next == null ? 'Collected' : 'Move to: ${next.label}'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value.toStringAsFixed(2))],
        ),
      );
}