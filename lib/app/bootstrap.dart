import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/app.dart';

/// Wires global setup, then starts the app inside a [ProviderScope].
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PetBridgeApp()));
}
