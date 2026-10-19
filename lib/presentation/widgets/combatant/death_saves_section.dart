import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/combatant.dart';

class DeathSavesSection extends StatelessWidget {
  final Combatant combatant;
  final bool isActive;
  final bool isDark;
  final void Function(int) onPlus;
  final VoidCallback? onDelete;
  final void Function(int successes, int failures)? onDeathSaveChanged;

  const DeathSavesSection({
    super.key,
    required this.combatant,
    required this.isActive,
    required this.isDark,
    required this.onPlus,
    this.onDelete,
    this.onDeathSaveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final successes = combatant.deathSaveSuccesses;
    final failures = combatant.deathSaveFailures;
    final isStabilized = successes >= 3;
    final isDead = failures >= 3;
    final hasAnyMarks = successes > 0 || failures > 0;
    final showCheckboxesBox =
        isActive || hasAnyMarks || isStabilized || isDead;

    if (!showCheckboxesBox) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: isDark ? 0.14 : 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_bottom, size: 16, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Caído (0 PV) — Fazer Teste de Salvaguarda na sua vez do turno',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.amber[200] : Colors.amber[900],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final Color borderColor = isDead
        ? Colors.redAccent
        : isStabilized
            ? Colors.greenAccent
            : isActive
                ? Colors.amber
                : Colors.white24;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor.withValues(alpha: isActive ? 0.8 : 0.45),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDead
                    ? Icons.dangerous
                    : isStabilized
                        ? Icons.auto_awesome
                        : Icons.casino_outlined,
                size: 16,
                color: isDead
                    ? Colors.redAccent
                    : isStabilized
                        ? Colors.greenAccent
                        : Colors.amber,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isDead
                      ? 'Morto em Combate (3 Fracassos)'
                      : isStabilized
                          ? 'Estabilizado! (3 Sucessos)'
                          : isActive
                              ? 'Sua Vez: Teste de Salvaguarda contra a Morte'
                              : 'Teste de Salvaguarda (Aguardando turno)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDead
                        ? Colors.redAccent
                        : isStabilized
                            ? Colors.greenAccent
                            : isActive
                                ? Colors.amber[300]
                                : null,
                  ),
                ),
              ),
              if (isStabilized)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: Colors.greenAccent,
                  ),
                  onPressed: () => onPlus(1),
                  icon: const Icon(Icons.favorite, size: 14),
                  label: const Text(
                    '1 PV',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              if (isDead)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: Colors.redAccent,
                  ),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text(
                    'Remover',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Sucessos
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sucesso:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF81C784),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ...List.generate(3, (index) {
                    final isChecked = index < successes;
                    return InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        final newSuccesses = isChecked ? index : index + 1;
                        onDeathSaveChanged?.call(newSuccesses, failures);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isChecked
                                ? const Color(0xFF66BB6A)
                                    .withValues(alpha: 0.28)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isChecked
                                  ? const Color(0xFF81C784)
                                  : Colors.grey.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: isChecked
                              ? const Icon(
                                  Icons.check,
                                  size: 15,
                                  color: Color(0xFF81C784),
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              // Fracassos
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Fracasso:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF9A9A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ...List.generate(3, (index) {
                    final isChecked = index < failures;
                    return InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        final newFailures = isChecked ? index : index + 1;
                        onDeathSaveChanged?.call(successes, newFailures);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isChecked
                                ? const Color(0xFFEF5350)
                                    .withValues(alpha: 0.28)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isChecked
                                  ? const Color(0xFFEF9A9A)
                                  : Colors.grey.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: isChecked
                              ? const Icon(
                                  Icons.close,
                                  size: 15,
                                  color: Color(0xFFEF9A9A),
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
