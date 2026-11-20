import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown when the AI gives no draft. The app then offers template replies (FR-AI-01).
class AiUnavailable implements Exception {
  const AiUnavailable(this.reason);

  /// `daily_limit` when the shop's 100 drafts for today are used up, otherwise a short cause.
  final String reason;

  String get message => reason == 'daily_limit'
      ? "Today's 100 AI drafts are used up. Use a template reply."
      : 'AI is unavailable. Use a template reply.';
}

typedef DraftReply = Future<String> Function(String question);

/// Asks the gemini-test Edge Function for a draft. The Gemini key stays in Supabase.
Future<String> draftWithSupabase(String question) async {
  try {
    final res = await Supabase.instance.client.functions
        .invoke('gemini-test', body: {'question': question})
        .timeout(const Duration(seconds: 25));
    final data = res.data;
    final draft = data is Map ? data['draft'] : null;
    if (draft is String && draft.trim().isNotEmpty) return draft.trim();
    throw const AiUnavailable('empty');
  } on AiUnavailable {
    rethrow;
  } on FunctionException catch (e) {
    final details = e.details;
    final limit = details is Map && details['reason'] == 'daily_limit';
    throw AiUnavailable(limit ? 'daily_limit' : 'status ${e.status}');
  } catch (_) {
    throw const AiUnavailable('network');
  }
}

// shortcut: keyword list only (English and Malay), upgrade to an AI or rule check when FR-AI-02 is built fully.
final _complaintWords = RegExp(
  r'\b(complain\w*|refund|wrong|late|rude|disappointed|terrible|spoil\w*|'
  r'aduan|rosak|salah|lambat|kecewa|teruk|basi)\b',
  caseSensitive: false,
);

/// True when a message looks like a complaint. Complaints get no AI reply (FR-AI-02).
bool looksLikeComplaint(String message) => _complaintWords.hasMatch(message);

/// Canned replies staff can use when the AI is down or the daily cap is used up.
const templateReplies = [
  'Hi, thank you for messaging Mawar Cake House! Let me check and get back to you shortly.',
  'Sorry, that cake is not available today. Would you like to see what we have instead?',
  'Thank you for your order. A deposit confirms it, and we will message you when it is ready.',
];
