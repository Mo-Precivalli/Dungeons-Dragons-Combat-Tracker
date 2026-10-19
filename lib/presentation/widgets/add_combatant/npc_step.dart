import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/monster_database.dart';
import 'add_combatant_shared.dart';

class NpcDetailsStep extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onBack;
  final void Function(MonsterTemplate preset) onApplyPreset;
  final VoidCallback onSubmit;
  final AddCombatantStatsForm statsForm;

  const NpcDetailsStep({
    super.key,
    required this.scrollController,
    required this.onBack,
    required this.onApplyPreset,
    required this.onSubmit,
    required this.statsForm,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      key: const ValueKey('npcDetails'),
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 3.5,
      radius: const Radius.circular(8),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AddCombatantStepHeader(
              title: 'Novo NPC',
              subtitle: 'Personagem do Mestre, aliado ou neutro',
              onBack: onBack,
            ),
            const SizedBox(height: 12),
            Text(
              'Modelos rápidos de NPC (opcional):',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: npcPresets.map((preset) {
                return ActionChip(
                  avatar: const Icon(Icons.person_outline, size: 15),
                  visualDensity: VisualDensity.compact,
                  label: Text(preset.name,
                      style: const TextStyle(fontSize: 11.5)),
                  onPressed: () => onApplyPreset(preset),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            statsForm,
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Adicionar NPC'),
                  onPressed: onSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
