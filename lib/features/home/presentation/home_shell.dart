import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';

/// Bottom navigation for the four home tabs: room, chat, backpack, me.
class HomeShell extends StatelessWidget {
  const new({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: l.home_tab_room,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble),
            label: l.home_tab_chat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.backpack),
            label: l.home_tab_bag,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: l.home_tab_me,
          ),
        ],
      ),
    );
  }
}

/// Placeholder for tabs that arrive in later phases.
class ComingSoonTab extends StatelessWidget {
  const new({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(AppLocalizations.of(context).home_coming_soon)),
    );
  }
}
