import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/monster_database.dart';
import 'add_combatant_shared.dart';

class SelectMonsterStep extends StatelessWidget {
  final TextEditingController searchController;
  final ScrollController scrollController;
  final List<String> monsterTypes;
  final String selectedTypeFilter;
  final VoidCallback onBack;
  final VoidCallback onSearchChanged;
  final void Function(String type) onFilterSelected;
  final void Function(MonsterTemplate monster) onSelectMonster;
  final VoidCallback onCustomMonster;

  const SelectMonsterStep({
    super.key,
    required this.searchController,
    required this.scrollController,
    required this.monsterTypes,
    required this.selectedTypeFilter,
    required this.onBack,
    required this.onSearchChanged,
    required this.onFilterSelected,
    required this.onSelectMonster,
    required this.onCustomMonster,
  });

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final filteredMonsters = monsterDatabase.where((m) {
      final matchesFilter = selectedTypeFilter == 'Todos' ||
          m.type.toLowerCase() == selectedTypeFilter.toLowerCase();
      final matchesQuery = query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.type.toLowerCase().contains(query) ||
          'nd ${m.challengeRating}'.contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    return Column(
      key: const ValueKey('selectMonster'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AddCombatantStepHeader(
          title: 'Base de Monstros (D&D 5.5e)',
          subtitle: 'Selecione um monstro para adicionar ao combate',
          onBack: onBack,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: searchController,
          autofocus: true,
          onChanged: (_) => onSearchChanged(),
          decoration: InputDecoration(
            hintText: 'Pesquisar monstro por nome, tipo ou ND...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged();
                    },
                  )
                : null,
            filled: true,
            fillColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: monsterTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final type = monsterTypes[index];
              final isSelected = selectedTypeFilter == type;
              return ChoiceChip(
                label: Text(type, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => onFilterSelected(type),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filteredMonsters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum monstro encontrado para "$query"',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Monstro Personalizado'),
                        onPressed: onCustomMonster,
                      ),
                    ],
                  ),
                )
              : Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  thickness: 3.5,
                  radius: const Radius.circular(8),
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.only(right: 8),
                    itemCount: filteredMonsters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final monster = filteredMonsters[index];
                      final initSign = monster.initiativeBonus >= 0
                          ? '+${monster.initiativeBonus}'
                          : '${monster.initiativeBonus}';
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onSelectMonster(monster),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    Colors.redAccent.withValues(alpha: 0.15),
                                child: const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      monster.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${monster.type} • ND ${monster.challengeRating}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        StatPill(
                                          label: 'CA ${monster.armorClass}',
                                          color: Colors.blueAccent,
                                        ),
                                        StatPill(
                                          label: 'PV ${monster.hpMax}',
                                          color: Colors.green,
                                        ),
                                        StatPill(
                                          label: 'Inic $initSign',
                                          color: Colors.amber[700]!,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('Monstro Personalizado'),
              onPressed: onCustomMonster,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ],
    );
  }
}

class MonsterConfirmStep extends StatelessWidget {
  final MonsterTemplate? monster;
  final int quantity;
  final ScrollController scrollController;
  final VoidCallback onBack;
  final void Function(int newQuantity) onQuantityChanged;
  final VoidCallback onSubmit;
  final AddCombatantStatsForm statsForm;

  const MonsterConfirmStep({
    super.key,
    required this.monster,
    required this.quantity,
    required this.scrollController,
    required this.onBack,
    required this.onQuantityChanged,
    required this.onSubmit,
    required this.statsForm,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      key: const ValueKey('monsterConfirm'),
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
              title: monster != null ? monster!.name : 'Monstro Personalizado',
              subtitle: monster != null
                  ? '${monster!.type} • ND ${monster!.challengeRating}'
                  : 'Defina os atributos do monstro',
              onBack: onBack,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Quantidade:',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    visualDensity: VisualDensity.compact,
                    onPressed: quantity > 1
                        ? () => onQuantityChanged(quantity - 1)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '$quantity',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    visualDensity: VisualDensity.compact,
                    onPressed: quantity < 20
                        ? () => onQuantityChanged(quantity + 1)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            statsForm,
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: onBack,
                  child: const Text('Trocar'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(quantity > 1
                      ? 'Adicionar ($quantity)'
                      : 'Adicionar Monstro'),
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
