import 'order.dart';

// Sample orders plus orders added this session. Resets when the app restarts.
// Replace with Supabase once the backend is confirmed.
// TODO(OI-xx): currency format not confirmed; amounts shown without a symbol.
class OrderRepository {
  static final List<Order> _orders = [
    Order(
      id: 'ORD-001',
      customer: 'Sample Customer A',
      pickupDate: DateTime(2026, 11, 22),
      total: 120,
      status: OrderStatus.received,
    ),
    Order(
      id: 'ORD-002',
      customer: 'Sample Customer B',
      pickupDate: DateTime(2026, 11, 23),
      total: 85.5,
      status: OrderStatus.depositPaid,
      allergyAnswered: true,
    ),
    Order(
      id: 'ORD-003',
      customer: 'Sample Customer C',
      pickupDate: DateTime(2026, 11, 24),
      total: 240,
      status: OrderStatus.preparing,
      allergyAnswered: true,
    ),
  ];

  Future<List<Order>> fetchOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_orders);
  }

  String nextId() => 'ORD-${(_orders.length + 1).toString().padLeft(3, '0')}';

  Future<void> add(Order order) async {
    _orders.add(order);
  }
}