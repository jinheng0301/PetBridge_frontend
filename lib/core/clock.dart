import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time. Tests override it to control countdowns.
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);
