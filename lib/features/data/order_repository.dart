import 'order.dart';

// Sample orders plus orders added this session. Resets when the app restarts.
// TODO(OI-xx): currency and sizes (Small/Medium/Large) not confirmed.
class OrderRepository {
  static final List<Order> _orders = [
    Order(
      id: 'ORD-001',
      customer: 'Sample Customer A',
      pickupDate: DateTime(2026, 11, 22),
      total: 100,
      status: OrderStatus.received,
      channel: 'WhatsApp',
      size: 'Medium',
      allergens: const ['None'],
    ),
    Order(
      id: 'ORD-002',
      customer: 'Sample Customer B',
      pickupDate: DateTime(2026, 11, 23),
      total: 85.5,
      status: OrderStatus.depositPaid,
      channel: 'Walk-in',
      size: 'Large',
      allergens: const ['Nuts'],
    ),
    Order(
      id: 'ORD-003',
      customer: 'Sample Customer C',
      pickupDate: DateTime(2026, 11, 24),
      total: 240,
      status: OrderStatus.preparing,
      channel: 'TikTok',
      size: 'Small',
      allergens: const ['Dairy', 'Eggs'],
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
