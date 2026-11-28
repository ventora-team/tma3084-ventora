// Order rules from the SRS. Pure Dart, no UI, so they can be tested directly.

// Parses the total staff type in. Null when it is not a positive number (FR-05).
double? parseTotal(String text) {
  final t = double.tryParse(text.trim());
  return (t != null && t > 0) ? t : null;
}

// 30% deposit (BR-01).
double depositOf(double total) => total * 0.3;

// The rest of the total is the balance (FR-05).
double balanceOf(double total) => total - depositOf(total);

// Answered when at least one allergy option is chosen, and "Other" has text (FR-03, BR-02).
bool allergyAnswered(Set<String> allergens, String otherText) =>
    allergens.isNotEmpty &&
    (!allergens.contains('Other') || otherText.trim().isNotEmpty);
