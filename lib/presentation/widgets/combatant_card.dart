import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/conditions_database.dart';
import '../../data/models/combatant.dart';
import '../../data/monster_database.dart';
import 'combatant/concentration_alert_banner.dart';
import 'combatant/death_saves_section.dart';
import 'combatant/hp_controls_section.dart';

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
  final void Function(bool keepsConcentration)? onConcentrationResolved;

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
    this.onConcentrationResolved,
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
    final concentrationDc = widget.combatant.pendingConcentrationDc;

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

    final Color activeAccent = concentrationDc != null
        ? Colors.redAccent
        : (isZeroHp && hasDeathSaves)
            ? Colors.amber
            : Theme.of(context).colorScheme.primary;
    final Color baseCardColor = Theme.of(context).cardColor;
    final Color activeCardColor = Color.lerp(
      baseCardColor,
      activeAccent,
      isDark ? 0.22 : 0.14,
    )!;

    final double hpRatio = widget.combatant.hpMax > 0
        ? (widget.combatant.hpCurrent / widget.combatant.hpMax).clamp(0.0, 1.0)
        : 0.0;
    final Color hpBarColor = isZeroHp
        ? Colors.red
        : hpRatio <= 0.25
            ? Colors.redAccent
            : hpRatio <= 0.5
                ? Colors.amber[700]!
                : Colors.green;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: (isMonsterDead || isCharacterDead)
              ? Color.lerp(baseCardColor, Colors.black, 0.35)
              : (widget.isActive ? activeCardColor : baseCardColor),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activeAccent.withValues(
              alpha: (widget.isActive || concentrationDc != null) ? 1.0 : 0.0,
            ),
            width: 2,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TOP ROW: Initiative + Full-width Name/Class/Conditions + Quick Actions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Initiative & CA
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${widget.combatant.initiative}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (widget.combatant.armorClass > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CA ${widget.combatant.armorClass}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(width: 10),

                        // Center: Name, Class/Role Badge, and Conditions
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    widget.combatant.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: concentrationDc != null
                                          ? Colors.redAccent
                                          : null,
                                      decoration:
                                          (isMonsterDead || isCharacterDead)
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                  if (widget.combatant.characterClass != null &&
                                      widget.combatant.characterClass!
                                          .isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: badgeColor.withValues(
                                            alpha: isDark ? 0.22 : 0.16),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: badgeColor.withValues(
                                              alpha: 0.55),
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
                                          Text(
                                            widget.combatant.characterClass!,
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: badgeTextColor,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (concentrationDc != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: Colors.redAccent,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '⚠️ Concentração CD $concentrationDc',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              // Conditions & Temp HP chips
                              if (widget.combatant.conditions.isNotEmpty ||
                                  widget.combatant.hpTemp > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
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
                                          final condInfo =
                                              getDndConditionInfo(c);
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: cColor.withValues(
                                                    alpha:
                                                        isDark ? 0.22 : 0.16),
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
                                                  Text(
                                                    c,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: cTextColor,
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
                            ],
                          ),
                        ),

                        // Top-Right Quick Actions (Temp HP, Conditions, 3-dots)
                        CombatantQuickActions(
                          onTempHpTap: widget.onTempHpTap,
                          onConditionTap: widget.onConditionTap,
                          onEdit: widget.onEdit,
                          onDelete: widget.onDelete,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // BOTTOM ROW: Full-width HP Progress Bar + Compact Stepper
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${widget.combatant.hpCurrent} / ${widget.combatant.hpMax} HP',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${(hpRatio * 100).round()}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
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
                                    widthFactor: hpRatio,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: hpBarColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        HpControlsSection(
                          hpController: _hpController,
                          hpFocusNode: _hpFocusNode,
                          onMinus: widget.onMinus,
                          onPlus: widget.onPlus,
                        ),
                      ],
                    ),

                    // Concentration Check Alert Banner (Permanece / Perde)
                    if (concentrationDc != null && !isZeroHp) ...[
                      const SizedBox(height: 10),
                      ConcentrationAlertBanner(
                        dc: concentrationDc,
                        onKeep: () =>
                            widget.onConcentrationResolved?.call(true),
                        onLose: () =>
                            widget.onConcentrationResolved?.call(false),
                      ),
                    ],

                    // Death Saving Throws section for Players & NPCs at 0 HP
                    if (hasDeathSaves && isZeroHp) ...[
                      const SizedBox(height: 10),
                      DeathSavesSection(
                        combatant: widget.combatant,
                        isActive: widget.isActive,
                        isDark: isDark,
                        onPlus: widget.onPlus,
                        onDelete: widget.onDelete,
                        onDeathSaveChanged: widget.onDeathSaveChanged,
                      ),
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
                            size: 44, color: Colors.white54),
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
}
