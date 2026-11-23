import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/invite/application/invite_code.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The share poster at its logical size, 360×480. Captured at
/// `pixelRatio: 3` it becomes 1080×1440.
class PosterCanvas extends StatelessWidget {
  const new({
    required this.petType,
    required this.code,
    required this.memberCount,
    required this.capacity,
    required this.link,
    super.key,
  });

  static const size = Size(360, 480);

  final String petType;

  /// 8 characters, no hyphen.
  final String code;
  final int memberCount;
  final int capacity;

  /// The QR content, `{SHARE_BASE_URL}/j/{code}`.
  final String link;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox.fromSize(
      size: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primaryContainer, scheme.surface],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            children: [
              Text(
                l.share_headline,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (isKnownPet(petType))
                PetView(petType: petType, size: 120, animate: false)
              else
                const SizedBox.square(dimension: 120),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // One line; shrinks rather than wraps.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatCode(code),
                            maxLines: 1,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.share_room_count(memberCount, capacity),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: QrImageView(
                        data: link,
                        size: 112,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// PNG bytes of the [RepaintBoundary] under [boundaryKey], at 3× its
/// logical size. Waits for a pending frame so the poster is laid out.
Future<Uint8List> capturePng(GlobalKey boundaryKey) async {
  final scheduler = SchedulerBinding.instance;
  if (scheduler.hasScheduledFrame ||
      scheduler.schedulerPhase != SchedulerPhase.idle) {
    await scheduler.endOfFrame;
  }
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
