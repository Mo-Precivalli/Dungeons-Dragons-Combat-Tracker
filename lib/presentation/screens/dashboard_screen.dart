import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/combat.dart';
import '../../data/models/combatant.dart';
import 'combat_detail_screen.dart';
import 'create_combat_screen.dart';

import 'package:dnd_combat_tracker/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final Box<Combat> _combatBox;
  late final Box<Combatant> _combatantBox;
  late final ValueListenable<Box<Combat>> _combatListenable;

  @override
  void initState() {
    super.initState();
    _combatBox = Hive.box<Combat>('combats');
    _combatantBox = Hive.box<Combatant>('combatants');
    _combatListenable = _combatBox.listenable();
  }

  void _deleteCombat(int id) {
    _combatBox.delete(id);
    final combatantsToDelete = _combatantBox.values
        .where((c) => c.combatId == id)
        .map((c) => c.key)
        .toList();
    _combatantBox.deleteAll(combatantsToDelete);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) {
              ref.read(localeProvider.notifier).state = locale;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Locale('pt', 'BR'),
                child: Text('Português (Brasil)'),
              ),
              const PopupMenuItem(
                value: Locale('en', ''),
                child: Text('English'),
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Combat>>(
        valueListenable: _combatListenable,
        builder: (context, box, _) {
          final combats = box.values.toList();
          if (combats.isEmpty) {
            return Center(
              child: Text(
                l10n.noActiveCombats,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: combats.length,
            itemBuilder: (context, index) {
              final combat = combats[index];
              return Dismissible(
                key: ValueKey(combat.id),
                background: Container(color: Colors.red),
                onDismissed: (_) => _deleteCombat(combat.id),
                child: ListTile(
                  title: Text(combat.name,
                      style: GoogleFonts.inter(fontSize: 18)),
                  subtitle: Text('${l10n.round}: ${combat.roundCount}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCombat(combat.id),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CombatDetailScreen(
                            combatId: combat.id, combatName: combat.name),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCombatDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCombatDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateCombatScreen(),
      ),
    );
  }
}
