import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';

import '../../data/models/campaign.dart';
import '../../data/monster_database.dart';
import '../providers/combat_tracker_provider.dart';
import 'campaigns_screen.dart';
import 'combat_detail_screen.dart';

class CreateCombatScreen extends ConsumerStatefulWidget {
  final int? initialCampaignId;

  const CreateCombatScreen({super.key, this.initialCampaignId});

  @override
  ConsumerState<CreateCombatScreen> createState() => _CreateCombatScreenState();
}

class _CreateCombatScreenState extends ConsumerState<CreateCombatScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final Random _random = Random();

  int? _selectedCampaignId;
  final Map<String, TextEditingController> _heroInitControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedCampaignId =
        widget.initialCampaignId ?? ref.read(selectedCampaignFilterProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    for (final c in _heroInitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncHeroControllers(Campaign? campaign) {
    if (campaign == null) return;
    for (final hero in campaign.heroes) {
      if (!_heroInitControllers.containsKey(hero.id)) {
        final rolled =
            (_random.nextInt(20) + 1 + hero.initiativeBonus).clamp(1, 40);
        _heroInitControllers[hero.id] =
            TextEditingController(text: rolled.toString());
      }
    }
  }

  void _rollAllHeroInitiatives(Campaign campaign) {
    setState(() {
      for (final hero in campaign.heroes) {
        final rolled =
            (_random.nextInt(20) + 1 + hero.initiativeBonus).clamp(1, 40);
        _heroInitControllers[hero.id]?.text = rolled.toString();
      }
    });
  }

  Future<void> _createCombat(
    CombatTrackerService service,
    Campaign? selectedCampaign,
  ) async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    try {
      final Map<String, int> heroInits = {};
      if (selectedCampaign != null) {
        for (final hero in selectedCampaign.heroes) {
          final text = _heroInitControllers[hero.id]?.text.trim() ?? '';
          heroInits[hero.id] =
              int.tryParse(text) ?? (10 + hero.initiativeBonus);
        }
      }

      final created = await service.createCombat(
        name: name,
        campaign: selectedCampaign,
        heroInitiatives: heroInits,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CombatDetailScreen(
              combatId: created.id,
              combatName: created.name,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.watch(combatTrackerServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newCombat,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: ValueListenableBuilder<Object?>(
        valueListenable: service.campaignsListenable,
        builder: (context, _, __) {
          final campaigns = service.getCampaigns();
          final Campaign? selectedCampaign = _selectedCampaignId != null
              ? service.getCampaign(_selectedCampaignId!)
              : null;
          _syncHeroControllers(selectedCampaign);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.encounterName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Ex: Emboscada Goblin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Campaign / Party Selector
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Campanha / Grupo de Jogadores',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
                      icon: const Icon(Icons.groups_outlined, size: 16),
                      label: const Text(
                        'Gerenciar Grupos',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int?>(
                  initialValue: selectedCampaign?.id,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'Sem Campanha (Combate Avulso)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...campaigns.map(
                      (c) => DropdownMenuItem<int?>(
                        value: c.id,
                        child: Text(
                          '${c.name} (${c.heroes.length} personagens)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedCampaignId = val;
                    });
                  },
                ),

                // Campaign Party Initiative Roll Table
                if (selectedCampaign != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Iniciativa do Grupo (${selectedCampaign.name})',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (selectedCampaign.heroes.isNotEmpty)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () =>
                                    _rollAllHeroInitiatives(selectedCampaign),
                                icon:
                                    const Icon(Icons.casino_outlined, size: 16),
                                label: const Text('Rolar Todas'),
                              ),
                          ],
                        ),
                        if (selectedCampaign.heroes.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Esta campanha ainda não tem heróis cadastrados. Clique em "Gerenciar Grupos" para adicionar os personagens.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          ...selectedCampaign.heroes.map((hero) {
                            final cls = getDndClassInfo(hero.characterClass);
                            final cColor =
                                cls?.color ?? const Color(0xFF7986CB);
                            final cText = isDark
                                ? Color.lerp(cColor, Colors.white, 0.55)!
                                : Color.lerp(cColor, Colors.black, 0.45)!;
                            final ctrl = _heroInitControllers[hero.id]!;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    cls?.icon ?? Icons.shield,
                                    color: cText,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hero.name,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '${hero.characterClass} • CA ${hero.armorClass} • PV ${hero.hpMax}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: cText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 96,
                                    child: TextField(
                                      controller: ctrl,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        labelText: 'Inic',
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 8),
                                        border: const OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                              Icons.casino_outlined,
                                              size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            final rolled = (_random
                                                        .nextInt(20) +
                                                    1 +
                                                    hero.initiativeBonus)
                                                .clamp(1, 40);
                                            setState(() {
                                              ctrl.text = rolled.toString();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _createCombat(service, selectedCampaign),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.create,
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
