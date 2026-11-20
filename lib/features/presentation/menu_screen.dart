import 'package:material_ui/material_ui.dart';
import '../data/menu_repository.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _repo = MenuRepository();
  late final Future<List<MenuItem>> _items = _repo.fetchItems();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuItem>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load menu'));
        }
        final items = snapshot.data ?? const <MenuItem>[];
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final item = items[i];
            return Card(
              child: SwitchListTile(
                title: Text(item.name),
                subtitle: Text(
                  '${item.price.toStringAsFixed(2)} · '
                  '${item.available ? 'Available' : 'Not available today'}',
                ),
                value: item.available,
                onChanged: (v) => setState(() => item.available = v),
              ),
            );
          },
        );
      },
    );
  }
}