import 'package:material_ui/material_ui.dart';

import '../data/order.dart';
import '../data/order_repository.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _repo = OrderRepository();
  final _customer = TextEditingController();
  final _total = TextEditingController();
  final _allergyNote = TextEditingController();
  DateTime? _pickup;
  bool? _hasAllergy; // FR-03: must be answered before confirming
  bool _saving = false;

  @override
  void dispose() {
    _customer.dispose();
    _total.dispose();
    _allergyNote.dispose();
    super.dispose();
  }

  double? get _totalValue {
    final t = double.tryParse(_total.text.trim());
    return (t != null && t > 0) ? t : null;
  }

  bool get _canConfirm =>
      _customer.text.trim().isNotEmpty &&
      _pickup != null &&
      _totalValue != null &&
      _hasAllergy != null &&
      (_hasAllergy == false || _allergyNote.text.trim().isNotEmpty);

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
    await _repo.add(
      Order(
        id: _repo.nextId(),
        customer: _customer.text.trim(),
        pickupDate: _pickup!,
        total: _totalValue!,
        status: OrderStatus.received,
        allergyAnswered: true,
        allergyNote: _hasAllergy == true ? _allergyNote.text.trim() : '',
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

    return Scaffold(
      appBar: AppBar(title: const Text('New order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _customer,
            decoration: const InputDecoration(labelText: 'Customer name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _pickup == null
                  ? 'Choose pickup date'
                  : 'Pickup ${_pickup!.day}/${_pickup!.month}/${_pickup!.year}',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _total,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Total (no currency symbol)',
            ),
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
            'Any allergy to tell us about? (required)',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            emptySelectionAllowed: true,
            segments: const [
              ButtonSegment(value: true, label: Text('Yes')),
              ButtonSegment(value: false, label: Text('No')),
            ],
            selected: _hasAllergy == null ? <bool>{} : {_hasAllergy!},
            onSelectionChanged: (s) =>
                setState(() => _hasAllergy = s.isEmpty ? null : s.first),
          ),
          if (_hasAllergy == true) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _allergyNote,
              decoration: const InputDecoration(
                labelText: 'Describe the allergy',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
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
      children: [Text(label), Text(value.toStringAsFixed(2))],
    ),
  );
}
