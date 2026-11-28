import 'package:flutter/foundation.dart';

enum ComplaintStatus { newComplaint, handled }

class Complaint {
  Complaint(this.message, {required this.byHand, DateTime? at})
    : at = at ?? DateTime.now();

  final String message;

  /// True when staff flagged it, false when the app flagged it.
  final bool byHand;
  final DateTime at;
  ComplaintStatus status = ComplaintStatus.newComplaint;
}

// shortcut: kept in memory for Demo 1, move to a Supabase complaints table when FR-AI-02 is built fully.
class ComplaintBox extends ChangeNotifier {
  final List<Complaint> items = [];

  int get newCount =>
      items.where((c) => c.status == ComplaintStatus.newComplaint).length;

  void add(String message, {required bool byHand}) {
    items.insert(0, Complaint(message, byHand: byHand));
    notifyListeners();
  }

  void markHandled(Complaint c) {
    c.status = ComplaintStatus.handled;
    notifyListeners();
  }

  /// Takes a wrongly flagged message out of the list so it can get a normal reply.
  String release(Complaint c) {
    items.remove(c);
    notifyListeners();
    return c.message;
  }
}
