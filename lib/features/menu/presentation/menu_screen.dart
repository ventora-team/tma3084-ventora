import 'package:material_ui/material_ui.dart';

import '../data/menu_repository.dart';
import 'menu_item_form_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // TODO(OI-xx): design shows a "+Add" chip beside the categories. Meaning not confirmed.
  static const _filters = ['All', ...kMenuCategories];

  final _repo = MenuRepository();
  late Future<List<MenuItem>> _items = _repo.fetchItems();
  String _filter = 'All';

  void _reload() => setState(() => _items = _repo.fetchItems());

  Future<void> _openForm([MenuItem? item]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MenuItemFormScreen(item: item)),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              for (final f in _filters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MenuItem>>(
            future: _items,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Could not load menu'));
              }
              final all = snapshot.data ?? const <MenuItem>[];
              final items = _filter == 'All'
                  ? all
                  : all.where((i) => i.category == _filter).toList();
              if (items.isEmpty) {
                return const Center(child: Text('No items in this category.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return _MenuCard(
                    item: item,
                    onEdit: () => _openForm(item),
                    onToggle: (v) => setState(() => item.available = v),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => _openForm(),
            child: const Text('Add item'),
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.item,
    required this.onEdit,
    required this.onToggle,
  });

  final MenuItem item;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stock = item.stock?.toString() ?? '-';
    final price = item.price?.toStringAsFixed(2) ?? '-';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder: the design's photos are not in the project.
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cake_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        item.description.isEmpty
                            ? 'Description'
                            : item.description,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _InfoBox(label: 'STOCK: $stock')),
                const SizedBox(width: 8),
                Expanded(child: _InfoBox(label: 'PRICE: $price')),
              ],
            ),
            Row(
              children: [
                Switch(value: item.available, onChanged: onToggle),
                Text(item.available ? 'Available' : 'Not available'),
                const Spacer(),
                OutlinedButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1412),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
