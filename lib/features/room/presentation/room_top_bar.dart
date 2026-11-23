import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';

/// The pill over the room scene: room name, member count, and a switch to
/// the other room when the user is in two. [menu] (the `⋯` button) sits on
/// the right; its slot is kept even while it is empty.
class RoomTopBar extends StatelessWidget {
  const new({
    required this.title,
    required this.memberCount,
    required this.capacity,
    required this.canSwitch,
    required this.onSwitch,
    super.key,
    this.menu,
  });

  final String title;
  final int memberCount;
  final int capacity;
  final bool canSwitch;
  final VoidCallback onSwitch;
  final Widget? menu;

  static const _ink = Color(0xFF3A2E2E);
  static const _pill = Color(0xE6FFFFFF);
  static const _menuSize = 32.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme.labelLarge?.copyWith(color: _ink);
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Material(
              key: const Key('room-switch'),
              color: _pill,
              shape: const StadiumBorder(),
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: canSwitch ? onSwitch : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          key: const Key('room-title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (canSwitch)
                        const Icon(
                          Icons.arrow_drop_down,
                          key: Key('room-switch-arrow'),
                          size: 20,
                          color: _ink,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        l.room_count(memberCount, capacity),
                        style: text?.copyWith(
                          color: _ink.withValues(alpha: .65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox.square(dimension: _menuSize, child: menu),
      ],
    );
  }
}
