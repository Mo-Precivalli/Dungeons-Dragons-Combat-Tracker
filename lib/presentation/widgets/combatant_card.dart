import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';
import '../../data/conditions_database.dart';
import '../../data/models/combatant.dart';
import '../../data/monster_database.dart';

class CombatantCard extends StatefulWidget {
  final Combatant combatant;
  final bool isActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onConditionTap;
  final VoidCallback? onTempHpTap;
  final void Function(int) onMinus;
  final void Function(int) onPlus;
  final void Function(int successes, int failures)? onDeathSaveChanged;

  const CombatantCard({
    super.key,
    required this.combatant,
    required this.onMinus,
    required this.onPlus,
    this.isActive = false,
    this.onEdit,
    this.onDelete,
    this.onConditionTap,
    this.onTempHpTap,
    this.onDeathSaveChanged,
  });

  @override
  State<CombatantCard> createState() => _CombatantCardState();
}

class _CombatantCardState extends State<CombatantCard> {
  late TextEditingController _hpController;
  late FocusNode _hpFocusNode;

  @override
  void initState() {
    super.initState();
    _hpController = TextEditingController();
    _hpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _hpController.dispose();
    _hpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isZeroHp = widget.combatant.hpCurrent == 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlayerType =
        widget.combatant.combatantType == 'player' || widget.combatant.isPlayer;
    final isNpcType = widget.combatant.combatantType == 'npc';
    final hasDeathSaves = isPlayerType || isNpcType;
    final isMonsterDead = !hasDeathSaves && isZeroHp;
    final isCharacterDead =
        hasDeathSaves && isZeroHp && widget.combatant.deathSaveFailures >= 3;

    final classInfo =
        isPlayerType ? getDndClassInfo(widget.combatant.characterClass) : null;

    final Color badgeColor = isPlayerType
        ? (classInfo?.color ?? const Color(0xFF7986CB))
        : isNpcType
            ? const Color(0xFF4DB6AC)
            : const Color(0xFFEF5350);

    final Color badgeTextColor = isDark
        ? Color.lerp(badgeColor, Colors.white, 0.55)!
        : Color.lerp(badgeColor, Colors.black, 0.45)!;

    final IconData typeIcon = isPlayerType
        ? (classInfo?.icon ?? Icons.shield)
        : isNpcType
            ? Icons.record_voice_over
            : Icons.local_fire_department;

    final Color activeAccent = (isZeroHp && hasDeathSaves)
        ? Colors.amber
        : Theme.of(context).colorScheme.primary;
    final Color baseCardColor = Theme.of(context).cardColor;
    final Color activeCardColor = Color.lerp(
      baseCardColor,
      activeAccent,
      isDark ? 0.22 : 0.14,
    )!;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: (isMonsterDead || isCharacterDead)
              ? Color.lerp(baseCardColor, Colors.black, 0.35)
              : (widget.isActive ? activeCardColor : baseCardColor),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activeAccent.withValues(alpha: widget.isActive ? 1.0 : 0.0),
            width: 2,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Initiative Badge
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${widget.combatant.initiative}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.combatant.armorClass > 0) ...[
                            Text(
                              'CA ${widget.combatant.armorClass}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Icon(
                            typeIcon,
                            size: 16,
                            color: badgeColor,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Name & Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.combatant.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: (isMonsterDead || isCharacterDead)
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (widget.combatant.characterClass != null &&
                                widget.combatant.characterClass!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(
                                      alpha: isDark ? 0.22 : 0.16),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: badgeColor.withValues(alpha: 0.55),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      typeIcon,
                                      size: 11,
                                      color: badgeTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        widget.combatant.characterClass!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: badgeTextColor,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            if (widget.combatant.conditions.isNotEmpty ||
                                widget.combatant.hpTemp > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    if (widget.combatant.hpTemp > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '+${widget.combatant.hpTemp} TP',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                      ),
                                    ...widget.combatant.conditions.map(
                                      (c) {
                                        final condInfo = getDndConditionInfo(c);
                                        final cColor =
                                            condInfo?.color ?? Colors.teal;
                                        final cTextColor = isDark
                                            ? Color.lerp(
                                                cColor, Colors.white, 0.55)!
                                            : Color.lerp(
                                                cColor, Colors.black, 0.45)!;
                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          onTap: widget.onConditionTap,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: cColor.withValues(
                                                  alpha: isDark ? 0.22 : 0.16),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: cColor.withValues(
                                                      alpha: 0.55),
                                                  width: 1),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (condInfo != null) ...[
                                                  Icon(
                                                    condInfo.icon,
                                                    size: 10,
                                                    color: cTextColor,
                                                  ),
                                                  const SizedBox(width: 3),
                                                ],
                                                Flexible(
                                                  child: Text(
                                                    c,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: cTextColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: widget.combatant.hpMax > 0
                                      ? (widget.combatant.hpCurrent /
                                              widget.combatant.hpMax)
                                          .clamp(0.0, 1.0)
                                      : 0,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          isZeroHp ? Colors.red : Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.combatant.hpCurrent} / ${widget.combatant.hpMax} HP',
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

                      // Controls
                      const SizedBox(width: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    color: Colors.redAccent,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () {
                                      final text = _hpController.text.trim();
                                      final val =
                                          text.isEmpty ? 1 : int.tryParse(text);
                                      if (val != null && val > 0) {
                                        widget.onMinus(val);
                                        if (text.isNotEmpty) {
                                          _hpController.clear();
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.greenAccent,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () {
                                      final text = _hpController.text.trim();
                                      final val =
                                          text.isEmpty ? 1 : int.tryParse(text);
                                      if (val != null && val > 0) {
                                        widget.onPlus(val);
                                        if (text.isNotEmpty) {
                                          _hpController.clear();
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 50,
                                height: 30,
                                child: TextField(
                                  controller: _hpController,
                                  focusNode: _hpFocusNode,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: '1',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 8),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shield_outlined),
                                color: Colors.blue,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                onPressed: widget.onTempHpTap,
                              ),
                              IconButton(
                                icon: const Icon(Icons.label_outline),
                                color: Colors.teal,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                onPressed: widget.onConditionTap,
                              ),
                            ],
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            onSelected: (value) {
                              if (value == 'edit') widget.onEdit?.call();
                              if (value == 'delete') widget.onDelete?.call();
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(AppLocalizations.of(context)!.edit),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child:
                                    Text(AppLocalizations.of(context)!.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Death Saving Throws section for Players & NPCs at 0 HP
                  if (hasDeathSaves && isZeroHp) ...[
                    const SizedBox(height: 10),
                    _buildDeathSavesSection(context, isDark),
                  ],
                ],
              ),
            ),

            // Monster Dead Overlay (Monsters die immediately at 0 HP)
            if (isMonsterDead)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.dangerous,
                          size: 48, color: Colors.white54),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete),
                        label: const Text('Remover'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeathSavesSection(BuildContext context, bool isDark) {
    final successes = widget.combatant.deathSaveSuccesses;
    final failures = widget.combatant.deathSaveFailures;
    final isStabilized = successes >= 3;
    final isDead = failures >= 3;
    final hasAnyMarks = successes > 0 || failures > 0;
    final showCheckboxesBox = widget.isActive || hasAnyMarks || isStabilized || isDead;

    // 1. If HP just hit 0 and it's NOT their turn yet (and no marks ticked yet):
    // Show the notice that they will roll their Death Save on their next turn!
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

    // 2. When it IS their turn in the turn order (or they already have marks):
    // Show the interactive box with Sucesso and Fracasso checkboxes!
    final Color borderColor = isDead
        ? Colors.redAccent
        : isStabilized
            ? Colors.greenAccent
            : widget.isActive
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
          color: borderColor.withValues(alpha: widget.isActive ? 0.8 : 0.45),
          width: widget.isActive ? 1.5 : 1,
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
                          : widget.isActive
                              ? 'Sua Vez: Teste de Salvaguarda contra a Morte'
                              : 'Teste de Salvaguarda (Aguardando turno)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDead
                        ? Colors.redAccent
                        : isStabilized
                            ? Colors.greenAccent
                            : widget.isActive
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
                  onPressed: () => widget.onPlus(1),
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
                  onPressed: widget.onDelete,
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
                        widget.onDeathSaveChanged?.call(newSuccesses, failures);
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
                        widget.onDeathSaveChanged?.call(successes, newFailures);
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
