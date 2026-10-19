import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/campaign.dart';
import '../../data/models/combatant.dart';
import '../../data/monster_database.dart';
import '../providers/combat_tracker_provider.dart';
import 'add_combatant_dialog.dart';

class CombatInitiativeDialog extends StatefulWidget {
  final int combatId;
  final String combatName;
  final Campaign? campaign;
  final CombatTrackerService service;

  const CombatInitiativeDialog({
    super.key,
    required this.combatId,
    required this.combatName,
    required this.service,
    this.campaign,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int combatId,
    required String combatName,
    required CombatTrackerService service,
    Campaign? campaign,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CombatInitiativeDialog(
        combatId: combatId,
        combatName: combatName,
        service: service,
        campaign: campaign,
      ),
    );
  }

  @override
  State<CombatInitiativeDialog> createState() => _CombatInitiativeDialogState();
}

class _CombatInitiativeDialogState extends State<CombatInitiativeDialog> {
  final Random _random = Random();
  final ScrollController _scrollController = ScrollController();
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    _scrollController.dispose();
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<Combatant> combatants) {
    for (final c in combatants) {
      _controllers.putIfAbsent(
        c.id,
        () => TextEditingController(
          text: c.initiative > 0 ? c.initiative.toString() : '',
        ),
      );
    }
  }

  void _rollSingle(Combatant c) {
    final roll = _random.nextInt(20) + 1;
    setState(() {
      _controllers[c.id]?.text = roll.toString();
    });
  }

  void _rollAll(List<Combatant> combatants, {bool onlyNonPlayers = false}) {
    setState(() {
      for (final c in combatants) {
        final isPlayer = c.isPlayer || c.combatantType == 'player';
        if (onlyNonPlayers && isPlayer) continue;
        final roll = _random.nextInt(20) + 1;
        _controllers[c.id]?.text = roll.toString();
      }
    });
  }

  Future<void> _openAddCombatant(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AddCombatantDialog(
        combatId: widget.combatId,
        campaign: widget.campaign,
        onAddCombatants: (newCombatants) async {
          await widget.service.addCombatants(widget.combatId, newCombatants);
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  Future<void> _confirmInitiatives(List<Combatant> combatants) async {
    final Map<int, int> initiatives = {};
    for (final c in combatants) {
      final text = _controllers[c.id]?.text.trim() ?? '';
      initiatives[c.id] = int.tryParse(text) ?? c.initiative;
    }
    await widget.service.applyCombatInitiatives(widget.combatId, initiatives);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<Object?>(
      valueListenable: widget.service.combatantsListenable,
      builder: (context, _, __) {
        final combatants = widget.service.getCombatants(widget.combatId);
        _syncControllers(combatants);

        final players = combatants
            .where((c) => c.isPlayer || c.combatantType == 'player')
            .toList();
        final monstersAndNpcs = combatants
            .where((c) => !c.isPlayer && c.combatantType != 'player')
            .toList();

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 660),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.casino_outlined,
                          color: Colors.amber,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Iniciativa da Luta',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Defina a iniciativa dos jogadores, monstros e NPCs',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Manter iniciativas atuais',
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Quick Roll & Add Bar
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                        ),
                        onPressed: () => _openAddCombatant(context),
                        icon: const Icon(Icons.person_add_alt_1, size: 15),
                        label: const Text(
                          'Adicionar Monstro / NPC / Jogador',
                          style: TextStyle(fontSize: 11.5),
                        ),
                      ),
                      if (combatants.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (monstersAndNpcs.isNotEmpty)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onPressed: () => _rollAll(
                                  combatants,
                                  onlyNonPlayers: true,
                                ),
                                icon: const Icon(Icons.casino, size: 15),
                                label: const Text(
                                  'Rolar Monstros',
                                  style: TextStyle(fontSize: 11.5),
                                ),
                              ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onPressed: () => _rollAll(combatants),
                              icon: const Icon(Icons.casino_outlined, size: 15),
                              label: const Text(
                                'Rolar Todos',
                                style: TextStyle(fontSize: 11.5),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Divider(height: 18),

                  if (combatants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28.0),
                      child: Column(
                        children: [
                          const Icon(Icons.group_add_outlined,
                              size: 44, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            'Adicione os jogadores, monstros ou NPCs para definir a iniciativa da luta.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        thickness: 3.5,
                        radius: const Radius.circular(8),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(right: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (players.isNotEmpty) ...[
                                Text(
                                  'JOGADORES (${players.length})',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: const Color(0xFF7986CB),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...players.map(
                                  (p) => _buildInitiativeRow(
                                    context,
                                    p,
                                    isDark: isDark,
                                    isPlayer: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (monstersAndNpcs.isNotEmpty) ...[
                                Text(
                                  'MONSTROS E NPCS (${monstersAndNpcs.length})',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: const Color(0xFFEF5350),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...monstersAndNpcs.map(
                                  (m) => _buildInitiativeRow(
                                    context,
                                    m,
                                    isDark: isDark,
                                    isPlayer: false,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: combatants.isEmpty
                        ? null
                        : () => _confirmInitiatives(combatants),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      'Começar Luta!',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitiativeRow(
    BuildContext context,
    Combatant c, {
    required bool isDark,
    required bool isPlayer,
  }) {
    final isNpc = c.combatantType == 'npc';
    final classInfo = isPlayer ? getDndClassInfo(c.characterClass) : null;
    final Color accent = isPlayer
        ? (classInfo?.color ?? const Color(0xFF7986CB))
        : isNpc
            ? const Color(0xFF4DB6AC)
            : const Color(0xFFEF5350);
    final IconData icon = isPlayer
        ? (classInfo?.icon ?? Icons.shield)
        : isNpc
            ? Icons.record_voice_over
            : Icons.local_fire_department;
    final ctrl = _controllers[c.id]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${c.characterClass ?? (isPlayer ? "Jogador" : isNpc ? "NPC" : "Monstro")} • CA ${c.armorClass} • ${c.hpCurrent}/${c.hpMax} HP',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            height: 36,
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Inic',
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.casino_outlined, size: 16),
                  tooltip: 'Rolar 1d20',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _rollSingle(c),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
