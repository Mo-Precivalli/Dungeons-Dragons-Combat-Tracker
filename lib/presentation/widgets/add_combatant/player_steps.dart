import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/monster_database.dart';
import 'add_combatant_shared.dart';

class SelectPlayerClassStep extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onBack;
  final void Function(DndClassInfo dndClass) onSelectClass;

  const SelectPlayerClassStep({
    super.key,
    required this.scrollController,
    required this.onBack,
    required this.onSelectClass,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('selectPlayerClass'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AddCombatantStepHeader(
          title: 'Qual a classe do Jogador?',
          subtitle: 'Classes oficiais do D&D 5.5e (2024)',
          onBack: onBack,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            thickness: 3.5,
            radius: const Radius.circular(8),
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(right: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.1,
              ),
              itemCount: dndClasses.length,
              itemBuilder: (context, index) {
                final dndClass = dndClasses[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelectClass(dndClass),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: dndClass.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dndClass.color.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              dndClass.color.withValues(alpha: 0.25),
                          child: Icon(dndClass.icon,
                              color: dndClass.color, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dndClass.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'd${dndClass.hitDie} • CA ~${dndClass.defaultAc}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class PlayerDetailsStep extends StatelessWidget {
  final DndClassInfo dndClass;
  final ScrollController scrollController;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final AddCombatantStatsForm statsForm;

  const PlayerDetailsStep({
    super.key,
    required this.dndClass,
    required this.scrollController,
    required this.onBack,
    required this.onSubmit,
    required this.statsForm,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      key: const ValueKey('playerDetails'),
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
              title: 'Novo Jogador',
              subtitle: 'Preencha os dados do herói',
              onBack: onBack,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: dndClass.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dndClass.color.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(dndClass.icon, color: dndClass.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Classe: ${dndClass.name}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          dndClass.description,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onBack,
                    child: const Text('Trocar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Adicionar Jogador'),
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
