import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../domain/order.dart';

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

  String _money(double v) => 'RM ${v.toStringAsFixed(2)}';

  String get _readyMessage {
    final p = o.pickupDate;
    return 'Hi ${o.customer}, your order ${o.id} is ready for collection on '
        '${p.day}/${p.month}/${p.year}. Balance due: ${_money(o.balance)}. '
        'Thank you for choosing Mawar Cake House.';
  }

  Future<void> _copyReady() async {
    await Clipboard.setData(ClipboardData(text: _readyMessage));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied. Paste it into WhatsApp.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = o.pickupDate;
    final theme = Theme.of(context);
    final next = _next;

    return Scaffold(
      appBar: AppBar(title: Text(o.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(o.customer, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${o.channel} · ${o.size} · Pickup ${p.day}/${p.month}/${p.year}',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _row('Total', _money(o.total)),
                  _row('Deposit (30%)', _money(o.deposit)),
                  _row('Balance', _money(o.balance)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Allergy'),
              subtitle: Text(
                o.allergens.isEmpty ? 'Not answered' : o.allergens.join(', '),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Status', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final s in OrderStatus.values)
            ListTile(
              dense: true,
              leading: Icon(
                s == o.status
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(
                s.label,
                style: TextStyle(
                  fontWeight: s == o.status
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: next == null ? null : _advance,
            child: Text(next == null ? 'Collected' : 'Move to: ${next.label}'),
          ),
          if (o.status == OrderStatus.ready) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _copyReady,
              icon: const Icon(Icons.copy),
              label: const Text('Copy ready message for WhatsApp'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    ),
  );
}
