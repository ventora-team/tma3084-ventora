const kMenuCategories = ['Limited', 'Cake', 'Cookie', 'Special'];

class MenuItem {
  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.stock,
    this.price,
    this.removeBy,
    this.available = true,
  });

  final String id;
  String name;
  String category;
  String description;
  int? stock;
  double? price;
  DateTime? removeBy;

  // Staff and owner can both change availability (client answer, 10 Nov).
  bool available;
}

// Sample items only. Resets when the app restarts.
// TODO(OI-xx): menu item names, categories and prices come from the client.
// TODO(OI-xx): currency format not confirmed; amounts shown without a symbol.
class MenuRepository {
  static final List<MenuItem> _items = [
    MenuItem(
      id: 'M1',
      name: 'Sample chocolate cake',
      category: 'Cake',
      description: 'Sample description',
      stock: 10,
      price: 30,
    ),
    MenuItem(
      id: 'M2',
      name: 'Sample chocolate cookie',
      category: 'Cookie',
      description: 'Sample description',
      stock: 24,
      price: 4.5,
    ),
    MenuItem(
      id: 'M3',
      name: 'Sample limited cake',
      category: 'Limited',
      description: 'Sample description',
      stock: 0,
      price: 45.5,
      available: false,
    ),
  ];

  Future<List<MenuItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_items);
  }

  String nextId() => 'M${_items.length + 1}';

  void save(MenuItem item) {
    if (!_items.contains(item)) _items.add(item);
  }
}
