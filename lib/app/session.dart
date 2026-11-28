import 'package:flutter/foundation.dart';

enum Role { staff, owner }

// Demo only: set from the username at login.
// TODO(OI-xx): the real role must come from the staff table (role column)
// returned by the staff-login function.
final ValueNotifier<Role> currentRole = ValueNotifier<Role>(Role.staff);
