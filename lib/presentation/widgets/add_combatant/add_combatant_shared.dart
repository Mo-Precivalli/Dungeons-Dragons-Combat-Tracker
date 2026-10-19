import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../condition_selector_dialog.dart';

class AddCombatantStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const AddCombatantStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
          tooltip: 'Voltar',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddCombatantStatsForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController roleController;
  final TextEditingController initController;
  final TextEditingController acController;
  final TextEditingController hpController;
  final TextEditingController hpTempController;
  final List<String> conditions;
  final String nameLabel;
  final bool autoFocusName;
  final bool showRoleField;
  final String roleLabel;
  final int initiativeBonus;
  final String? characterClassForConditions;
  final void Function(int bonus) onRollInitiative;
  final void Function(List<String> updated) onConditionsChanged;

  const AddCombatantStatsForm({
    super.key,
    required this.nameController,
    required this.roleController,
    required this.initController,
    required this.acController,
    required this.hpController,
    required this.hpTempController,
    required this.conditions,
    required this.nameLabel,
    required this.onRollInitiative,
    required this.onConditionsChanged,
    this.autoFocusName = false,
    this.showRoleField = false,
    this.roleLabel = 'Papel',
    this.initiativeBonus = 0,
    this.characterClassForConditions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          autofocus: autoFocusName,
          decoration: InputDecoration(
            labelText: nameLabel,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        if (showRoleField) ...[
          const SizedBox(height: 12),
          TextField(
            controller: roleController,
            decoration: InputDecoration(
              labelText: roleLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: initController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Iniciativa',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.casino_outlined),
                    tooltip: 'Rolar 1d20',
                    onPressed: () => onRollInitiative(initiativeBonus),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: acController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CA (Defesa)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: hpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'PV Máximo',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: hpTempController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'HP Temp',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.checklist),
          label: Text(conditions.isEmpty
              ? 'Selecionar Condições (opcional)'
              : 'Condições Selecionadas (${conditions.length})'),
          onPressed: () async {
            final selected = await ConditionSelectorDialog.show(
              context,
              title: 'Selecionar Condições',
              initialConditions: conditions,
              characterClass: characterClassForConditions,
            );
            if (selected != null) {
              onConditionsChanged(selected);
            }
          },
        ),
        if (conditions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: conditions
                .map(
                  (c) => Chip(
                    label: Text(c, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    onDeleted: () {
                      final updated = List<String>.from(conditions)..remove(c);
                      onConditionsChanged(updated);
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class TypeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const TypeOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.45),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accentColor),
          ],
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatPill({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
