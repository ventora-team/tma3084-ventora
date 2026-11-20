import 'package:material_ui/material_ui.dart';

import '../data/menu_repository.dart';

// Matches the phone edit screen: Name, Category, Description, Stock,
// Remove by, Price, Save Changes.
class MenuItemFormScreen extends StatefulWidget {
  const MenuItemFormScreen({super.key, this.item});

  final MenuItem? item;

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _repo = MenuRepository();
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late final _description = TextEditingController(
    text: widget.item?.description ?? '',
  );
  late final _stock = TextEditingController(
    text: widget.item?.stock?.toString() ?? '',
  );
  late final _price = TextEditingController(
    text: widget.item?.price?.toStringAsFixed(2) ?? '',
  );
  late String _category = widget.item?.category ?? kMenuCategories.first;
  late DateTime? _removeBy = widget.item?.removeBy;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _stock.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _removeBy ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _removeBy = picked);
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a name.')));
      return;
    }
    // TODO(OI-xx): which fields are required is not confirmed with the client.
    final item =
        widget.item ??
        MenuItem(id: _repo.nextId(), name: name, category: _category);
    item
      ..name = name
      ..category = _category
      ..description = _description.text.trim()
      ..stock = int.tryParse(_stock.text.trim())
      ..price = double.tryParse(_price.text.trim())
      ..removeBy = _removeBy;
    _repo.save(item);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final d = _removeBy;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'New menu item' : 'Edit menu item'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final c in kMenuCategories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stock,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Stock'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event),
            label: Text(
              d == null
                  ? 'Remove by: choose date'
                  : 'Remove by: ${d.day}/${d.month}/${d.year}',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Price'),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save Changes')),
        ],
      ),
    );
  }
}
