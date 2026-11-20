class MenuItem {
  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.available = true,
  });

  final String id;
  final String name;
  final double price;

  // Staff and owner can both change availability (client answer, 10 Nov).
  bool available;
}

// Sample items only. Resets when the app restarts.
// TODO(OI-xx): menu item names and prices come from the client, not confirmed.
// TODO(OI-xx): currency format not confirmed; amounts shown without a symbol.
class MenuRepository {
  static final List<MenuItem> _items = [
    MenuItem(id: 'M1', name: 'Sample item A', price: 30),
    MenuItem(id: 'M2', name: 'Sample item B', price: 45.5),
    MenuItem(id: 'M3', name: 'Sample item C', price: 18, available: false),
  ];

  Future<List<MenuItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_items);
  }
}
