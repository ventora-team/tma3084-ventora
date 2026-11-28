import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../features/ai/data/ai_service.dart';
import '../features/complaints/domain/complaint_box.dart';
import 'session.dart';
import '../features/menu/presentation/menu_screen.dart';
import '../features/orders/presentation/order_list_screen.dart';

typedef SignIn = Future<void> Function(String username, String password);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.signIn});

  final SignIn signIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter your username and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    // Demo only: the owner tabs are chosen by username. See role.dart.
    currentRole.value = _username.text.trim().toLowerCase() == 'owner'
        ? Role.owner
        : Role.staff;
    try {
      await widget.signIn(_username.text, _password.text);
    } catch (_) {
      if (mounted) setState(() => _error = 'Wrong username or password.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mawar Cake House',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Staff and owner sign in',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _username,
                  decoration: const InputDecoration(labelText: 'Username'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(_busy ? 'Signing in...' : 'Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Section { orders, points, menu, reply, complaints, admin }

extension on _Section {
  String get title => switch (this) {
    _Section.orders => 'Orders',
    _Section.points => 'Points',
    _Section.menu => 'Menu',
    _Section.reply => 'Reply',
    _Section.complaints => 'Complaints',
    _Section.admin => 'Admin',
  };

  IconData get icon => switch (this) {
    _Section.orders => Icons.receipt_long_outlined,
    _Section.points => Icons.stars_outlined,
    _Section.menu => Icons.restaurant_menu_outlined,
    _Section.reply => Icons.chat_bubble_outline,
    _Section.complaints => Icons.report_outlined,
    _Section.admin => Icons.admin_panel_settings_outlined,
  };
}

/// Staff home and owner home. Staff: Orders, Menu, Reply.
/// Owner: Orders, Points, Menu, Complaints, Admin (Points and Admin are not in Demo 1).
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.draft,
    required this.complaints,
    this.onSignOut,
  });

  final DraftReply draft;
  final ComplaintBox complaints;
  final VoidCallback? onSignOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _message = TextEditingController();
  int _tab = 0;

  /// Set when a message comes back from Complaints, so it is not flagged again.
  bool _released = false;

  List<_Section> get _sections => currentRole.value == Role.owner
      ? const [
          _Section.orders,
          _Section.points,
          _Section.menu,
          _Section.complaints,
          _Section.admin,
        ]
      : const [_Section.orders, _Section.menu, _Section.reply];

  void _releaseToReply(Complaint c) {
    final i = _sections.indexOf(_Section.reply);
    if (i < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reply is a staff tab.')));
      return;
    }
    setState(() {
      _message.text = widget.complaints.release(c);
      _released = true;
      _tab = i;
    });
  }

  Widget _bodyFor(_Section s) => switch (s) {
    _Section.orders => const OrderListScreen(),
    _Section.menu => const MenuScreen(),
    _Section.reply => ReplyPage(
      draft: widget.draft,
      complaints: widget.complaints,
      message: _message,
      released: _released,
      onChecked: () => _released = false,
    ),
    _Section.complaints => ComplaintsPage(
      complaints: widget.complaints,
      onRelease: _releaseToReply,
    ),
    _Section.points || _Section.admin => _ComingSoon(s.title),
  };

  Widget _navIcon(_Section s) {
    if (s == _Section.complaints) {
      return Badge(
        isLabelVisible: widget.complaints.newCount > 0,
        label: Text('${widget.complaints.newCount}'),
        child: Icon(s.icon),
      );
    }
    return Icon(s.icon);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Role>(
      valueListenable: currentRole,
      builder: (context, _, _) {
        final sections = _sections;
        final tab = _tab < sections.length ? _tab : 0;
        return Scaffold(
          appBar: AppBar(
            title: Text(sections[tab].title),
            actions: [
              if (widget.onSignOut != null)
                IconButton(
                  tooltip: 'Sign out',
                  icon: const Icon(Icons.logout),
                  onPressed: widget.onSignOut,
                ),
            ],
          ),
          body: IndexedStack(
            index: tab,
            children: [for (final s in sections) _bodyFor(s)],
          ),
          bottomNavigationBar: ListenableBuilder(
            listenable: widget.complaints,
            builder: (context, _) => NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: [
                for (final s in sections)
                  NavigationDestination(icon: _navIcon(s), label: s.title),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '$name is not part of Demo 1.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ReplyPage extends StatefulWidget {
  const ReplyPage({
    super.key,
    required this.draft,
    required this.complaints,
    required this.message,
    required this.released,
    required this.onChecked,
  });

  final DraftReply draft;
  final ComplaintBox complaints;
  final TextEditingController message;
  final bool released;
  final VoidCallback onChecked;

  @override
  State<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  final _reply = TextEditingController();
  bool _busy = false;
  bool _hasDraft = false;
  String? _aiError;

  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _handOver({required bool byHand}) {
    if (widget.message.text.trim().isEmpty) {
      _say("Paste the customer's message first.");
      return;
    }
    widget.complaints.add(widget.message.text.trim(), byHand: byHand);
    widget.message.clear();
    setState(() {
      _hasDraft = false;
      _aiError = null;
      _reply.clear();
    });
    _say(
      byHand
          ? "Sent to the owner's Complaints page. No AI reply."
          : "This looks like a complaint, so it went to the owner's "
                'Complaints page. No AI reply.',
    );
  }

  Future<void> _draft() async {
    final question = widget.message.text.trim();
    if (question.isEmpty) {
      _say("Paste the customer's message first.");
      return;
    }
    if (!widget.released && looksLikeComplaint(question)) {
      _handOver(byHand: false);
      return;
    }
    widget.onChecked();
    setState(() {
      _busy = true;
      _aiError = null;
    });
    try {
      _reply.text = await widget.draft(question);
      _hasDraft = true;
    } on AiUnavailable catch (e) {
      _aiError = e.message;
      _hasDraft = false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _useTemplate(String text) => setState(() {
    _reply.text = text;
    _hasDraft = true;
  });

  Future<void> _approve() async {
    await Clipboard.setData(ClipboardData(text: _reply.text));
    _say('Copied. Paste it to the customer.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: widget.message,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: "Customer's message",
            hintText: 'Paste the WhatsApp or Instagram message here',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : _draft,
                icon: const Icon(Icons.auto_awesome),
                label: Text(_busy ? 'Drafting...' : 'Draft reply'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _handOver(byHand: true),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Mark as complaint'),
            ),
          ],
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_aiError != null) ...[
          const SizedBox(height: 16),
          Text(_aiError!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          for (final t in templateReplies)
            Card(
              child: ListTile(
                title: Text(t),
                trailing: const Icon(Icons.north_west),
                onTap: () => _useTemplate(t),
              ),
            ),
        ],
        if (_hasDraft) ...[
          const SizedBox(height: 16),
          Text(
            'Draft: check and edit before sending',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reply,
            minLines: 3,
            maxLines: 10,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _approve,
            icon: const Icon(Icons.check),
            label: const Text('Approve and copy'),
          ),
        ],
      ],
    );
  }
}

class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({
    super.key,
    required this.complaints,
    required this.onRelease,
  });

  final ComplaintBox complaints;
  final ValueChanged<Complaint> onRelease;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: complaints,
      builder: (context, _) {
        if (complaints.items.isEmpty) {
          return const Center(child: Text('No complaints.'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final c in complaints.items)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              c.status == ComplaintStatus.newComplaint
                                  ? 'New'
                                  : 'Handled',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.byHand ? 'Flagged by staff' : 'Flagged by app',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(c.message),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (c.status == ComplaintStatus.newComplaint)
                            FilledButton(
                              onPressed: () => complaints.markHandled(c),
                              child: const Text('Mark handled'),
                            ),
                          TextButton(
                            onPressed: () => onRelease(c),
                            child: const Text('Release to reply flow'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
