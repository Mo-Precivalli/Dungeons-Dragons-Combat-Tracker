import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';

import '../../data/models/campaign.dart';
import '../../data/monster_database.dart';
import '../providers/combat_tracker_provider.dart';
import '../providers/theme_provider.dart';
import 'campaigns_screen.dart';
import 'combat_detail_screen.dart';
import 'create_combat_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final service = ref.watch(combatTrackerServiceProvider);
    final selectedCampaignId = ref.watch(selectedCampaignFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.groups_outlined),
            tooltip: 'Campanhas e Grupos de Jogadores',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CampaignsScreen(),
                ),
              );
            },
          ),
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
      body: ValueListenableBuilder<Object?>(
        valueListenable: service.campaignsListenable,
        builder: (context, _, __) {
          final campaigns = service.getCampaigns();
          final Campaign? activeCampaign = selectedCampaignId != null
              ? service.getCampaign(selectedCampaignId)
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campaign Selector & Filter Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Campanhas / Grupos de Jogadores',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CampaignsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings_outlined, size: 15),
                          label: const Text(
                            'Gerenciar Grupos',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Todas as Campanhas'),
                            selected: activeCampaign == null,
                            visualDensity: VisualDensity.compact,
                            onSelected: (_) {
                              ref
                                  .read(selectedCampaignFilterProvider.notifier)
                                  .state = null;
                            },
                          ),
                          const SizedBox(width: 8),
                          ...campaigns.map((camp) {
                            final isSelected = activeCampaign?.id == camp.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                    '${camp.name} (${camp.heroes.length})'),
                                selected: isSelected,
                                visualDensity: VisualDensity.compact,
                                onSelected: (_) {
                                  ref
                                      .read(selectedCampaignFilterProvider
                                          .notifier)
                                      .state = camp.id;
                                },
                              ),
                            );
                          }),
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: const Text('Nova Campanha'),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CampaignsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    if (activeCampaign != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: isDark ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.groups,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: activeCampaign.heroes.isEmpty
                                  ? Text(
                                      'Grupo "${activeCampaign.name}" sem heróis cadastrados.',
                                      style: GoogleFonts.inter(fontSize: 12),
                                    )
                                  : Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children:
                                          activeCampaign.heroes.map((hero) {
                                        final cls = getDndClassInfo(
                                            hero.characterClass);
                                        final cColor = cls?.color ??
                                            const Color(0xFF7986CB);
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: cColor.withValues(
                                                alpha: isDark ? 0.24 : 0.16),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: cColor.withValues(
                                                  alpha: 0.55),
                                            ),
                                          ),
                                          child: Text(
                                            '${hero.name} (${hero.characterClass})',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Combats List (filtered by selected Campaign so campaigns never mix)
              Expanded(
                child: ValueListenableBuilder<Object?>(
                  valueListenable: service.combatsListenable,
                  builder: (context, _, __) {
                    final combats = service.getCombats(
                      campaignIdFilter: activeCampaign?.id,
                    );
                    if (combats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              activeCampaign != null
                                  ? 'Nenhum combate na campanha "${activeCampaign.name}"'
                                  : l10n.noActiveCombats,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 17, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => _showAddCombatDialog(
                                  context, activeCampaign?.id),
                              icon: const Icon(Icons.add),
                              label: Text(
                                activeCampaign != null
                                    ? 'Criar Combate para ${activeCampaign.name}'
                                    : 'Novo Combate',
                              ),
                            ),
                          ],
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
                          onDismissed: (_) => service.deleteCombat(combat.id),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    combat.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (combat.campaignName != null &&
                                    combat.campaignName!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      combat.campaignName!,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.indigo[200]
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle:
                                Text('${l10n.round}: ${combat.roundCount}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => service.deleteCombat(combat.id),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CombatDetailScreen(
                                    combatId: combat.id,
                                    combatName: combat.name,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCombatDialog(context, selectedCampaignId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCombatDialog(BuildContext context, int? initialCampaignId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CreateCombatScreen(initialCampaignId: initialCampaignId),
      ),
    );
  }
}
