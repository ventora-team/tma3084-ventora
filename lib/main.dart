import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ai.dart';
import 'complaints.dart';
import 'app/router.dart';
import 'core/theme/theme.dart';

const supabaseUrl = 'https://pdnhqcjlyszohoxnxzeg.supabase.co';

// Publishable key: safe to ship in the app, the database access rules do the protecting.
const supabaseKey = 'sb_publishable_vRkxG31woLGV4b4GakiGGw_zWkYL-Uk';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  runApp(MawarApp(complaints: ComplaintBox()));
}

/// Supabase has no username login, so each username maps to a hidden email (docs/BACKEND_SUPABASE.md).
Future<void> signInWithUsername(String username, String password) =>
    Supabase.instance.client.auth.signInWithPassword(
      email: '${username.trim().toLowerCase()}@mawarcake.example.com',
      password: password,
    );

class MawarApp extends StatelessWidget {
  const MawarApp({super.key, required this.complaints});

  final ComplaintBox complaints;

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return MaterialApp(
      title: 'Mawar Cake House',
      theme: mawarTheme(),
      home: StreamBuilder<AuthState>(
        stream: auth.onAuthStateChange,
        builder: (context, _) => auth.currentSession == null
            ? const LoginPage(signIn: signInWithUsername)
            : HomePage(
                draft: draftWithSupabase,
                complaints: complaints,
                onSignOut: auth.signOut,
              ),
      ),
    );
  }
}
