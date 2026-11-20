import 'package:material_ui/material_ui.dart';

import '../data/order.dart';
import '../data/order_repository.dart';

// Channels from the client meeting notes (15 Oct).
const kChannels = ['WhatsApp', 'TikTok', 'Facebook', 'Grab', 'Walk-in'];
// TODO(OI-xx): sizes and the "day-type" option are not confirmed.
const kSizes = ['Small', 'Medium', 'Large'];
// Allergy options from the design. Mandatory before confirming (FR-03).
const kAllergens = ['None', 'Nuts', 'Dairy', 'Eggs', 'Gluten', 'Other'];

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _repo = OrderRepository();
  final _customer = TextEditingController();
  final _total = TextEditingController();
  final _other = TextEditingController();
  DateTime? _pickup;
  String _channel = kChannels.first;
  String _size = 'Medium';
  final Set<String> _allergens = {};
  bool _saving = false;

  @override
  void dispose() {
    _customer.dispose();
    _total.dispose();
    _other.dispose();
    super.dispose();
  }

  double? get _totalValue {
    final t = double.tryParse(_total.text.trim());
    return (t != null && t > 0) ? t : null;
  }

  bool get _allergyAnswered =>
      _allergens.isNotEmpty &&
      (!_allergens.contains('Other') || _other.text.trim().isNotEmpty);

  bool get _canConfirm =>
      _customer.text.trim().isNotEmpty &&
      _pickup != null &&
      _totalValue != null &&
      _allergyAnswered;

  void _toggleAllergen(String a, bool on) {
    setState(() {
      if (a == 'None') {
        // "None" is exclusive: choosing it clears the others.
        _allergens.clear();
        if (on) _allergens.add('None');
      } else {
        _allergens.remove('None');
        if (on) {
          _allergens.add(a);
        } else {
          _allergens.remove(a);
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickup ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _pickup = picked);
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    final allergens = _allergens
        .map((a) => a == 'Other' ? 'Other: ${_other.text.trim()}' : a)
        .toList();
    await _repo.add(
      Order(
        id: _repo.nextId(),
        customer: _customer.text.trim(),
        pickupDate: _pickup!,
        total: _totalValue!,
        status: OrderStatus.received,
        channel: _channel,
        size: _size,
        allergens: allergens,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = _totalValue ?? 0;
    final deposit = t * 0.3;
    final balance = t - deposit;
    final theme = Theme.of(context);
    final p = _pickup;

    return Scaffold(
      appBar: AppBar(title: const Text('New order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _customer,
            decoration: const InputDecoration(
              labelText: 'Customer name and phone',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _channel,
            decoration: const InputDecoration(labelText: 'Channel'),
            items: [
              for (final c in kChannels)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _channel = v);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _size,
            decoration: const InputDecoration(labelText: 'Size'),
            items: [
              for (final s in kSizes)
                DropdownMenuItem(value: s, child: Text(s)),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _size = v);
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              p == null
                  ? 'Choose collection date'
                  : 'Collection ${p.day}/${p.month}/${p.year}',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _total,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Total (RM)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _sumRow('Deposit (30%)', deposit),
                  _sumRow('Balance', balance),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Allergies · ask first (required)',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final a in kAllergens)
                FilterChip(
                  label: Text(a),
                  selected: _allergens.contains(a),
                  onSelected: (on) => _toggleAllergen(a, on),
                ),
            ],
          ),
          if (_allergens.contains('Other')) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _other,
              decoration: const InputDecoration(
                labelText: 'Describe the other allergy',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          if (!_allergyAnswered)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Choose None or at least one allergy to continue.'),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _canConfirm && !_saving ? _confirm : null,
            child: const Text('Confirm order'),
          ),
        ],
      ),
    );
  }

  Widget _sumRow(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text('RM ${value.toStringAsFixed(2)}')],
    ),
  );
}
