import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keys come from --dart-define, never hard-coded or committed.
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const ProviderScope(child: VentoraApp()));
}

class VentoraApp extends StatelessWidget {
  const VentoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mawar Cake House',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFB04A6B), // TODO(OI-xx): brand colour from Figma, not confirmed
      ),
      home: const _Placeholder(),
    );
  }
}

// Replaced by LoginScreen once the login mechanism is decided.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Mawar Cake House')));
}