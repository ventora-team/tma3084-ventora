import 'package:material_ui/material_ui.dart';

import '../data/order.dart';
import '../data/order_repository.dart';
import 'new_order_screen.dart';
import 'order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final _repo = OrderRepository();
  late Future<List<Order>> _orders = _repo.fetchOrders();

  void _reload() {
    setState(() => _orders = _repo.fetchOrders());
  }

  Future<void> _openNewOrder() async {
    final added = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const NewOrderScreen()));
    if (added == true) _reload();
  }

  Future<void> _openDetails(Order order) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)));
    // Status may have changed, so rebuild the list
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewOrder,
        icon: const Icon(Icons.add),
        label: const Text('New order'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load orders'));
          }
          final orders = snapshot.data ?? const <Order>[];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _OrderCard(
              order: orders[i],
              onTap: () => _openDetails(orders[i]),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = order.pickupDate;
    final allergy = !order.allergyAnswered
        ? 'Allergy not answered'
        : order.allergyNote.isEmpty
        ? 'No allergy'
        : 'Allergy: ${order.allergyNote}';
    return Card(
      child: ListTile(
        isThreeLine: true,
        onTap: onTap,
        title: Text('${order.id} · ${order.customer}'),
        subtitle: Text(
          'Pickup ${p.day}/${p.month}/${p.year}\n'
          'Deposit ${order.deposit.toStringAsFixed(2)} · '
          'Balance ${order.balance.toStringAsFixed(2)}\n'
          '$allergy',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusPill(status: order.status),
            Text(order.total.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final OrderStatus status;

  Color get _color => switch (status) {
    OrderStatus.received => const Color(0xFFE8C872),
    OrderStatus.depositPaid => const Color(0xFFA8D4F0),
    OrderStatus.preparing => const Color(0xFF8EC5FF),
    OrderStatus.ready => const Color(0xFF9BDB9B),
    OrderStatus.collected => const Color(0xFFBDBDBD),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: const TextStyle(color: Color(0xFF1C1412), fontSize: 12),
      ),
    );
  }
}
