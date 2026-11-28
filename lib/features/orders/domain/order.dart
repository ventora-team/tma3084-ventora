enum OrderStatus { received, depositPaid, preparing, ready, collected }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.received => 'Received',
    OrderStatus.depositPaid => 'Deposit paid',
    OrderStatus.preparing => 'Preparing',
    OrderStatus.ready => 'Ready',
    OrderStatus.collected => 'Collected',
  };
}

class Order {
  Order({
    required this.id,
    required this.customer,
    required this.pickupDate,
    required this.total,
    required this.status,
    this.channel = 'WhatsApp',
    this.size = 'Medium',
    this.allergens = const [],
  });

  final String id;
  final String customer;
  final DateTime pickupDate;
  final double total;
  final String channel;
  final String size;
  final List<String> allergens;

  // Status changes as the order moves through the steps (slide 5).
  OrderStatus status;

  // FR-03: allergy must be answered before an order is confirmed.
  bool get allergyAnswered => allergens.isNotEmpty;

  String get allergyNote => (allergens.isEmpty || allergens.contains('None'))
      ? ''
      : allergens.join(', ');

  // FR-05: deposit is 30% of the total. Recorded only, not processed.
  // TODO(OI-xx): cent rounding rule not confirmed.
  double get deposit => total * 0.3;
  double get balance => total - deposit;
}
