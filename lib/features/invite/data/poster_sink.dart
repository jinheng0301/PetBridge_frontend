import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum SaveResult { saved, denied }

/// Where a finished poster goes: the gallery or the system share sheet.
abstract interface class PosterSink {
  /// Asks for gallery access when needed (Android 8–10 only).
  Future<SaveResult> saveToGallery(Uint8List png);

  Future<void> share(Uint8List png, String text);
}

class DevicePosterSink implements PosterSink {
  const new();

  @override
  Future<SaveResult> saveToGallery(Uint8List png) async {
    if (!await Gal.hasPermission() && !await Gal.requestPermission()) {
      return SaveResult.denied;
    }
    try {
      await Gal.putImageBytes(png, name: 'petbridge_invite');
    } on GalException catch (e) {
      if (e.type == GalExceptionType.permissionDenied) return SaveResult.denied;
      rethrow;
    }
    return SaveResult.saved;
  }

  @override
  Future<void> share(Uint8List png, String text) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/petbridge_invite.png');
    await file.writeAsBytes(png, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
      ),
    );
  }
}

final posterSinkProvider = Provider<PosterSink>(
  (_) => const DevicePosterSink(),
);
