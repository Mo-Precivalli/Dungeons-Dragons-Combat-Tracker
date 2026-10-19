import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';

import '../../data/models/combatant.dart';
import '../providers/combat_tracker_provider.dart';
import '../widgets/add_combatant_dialog.dart';
import '../widgets/combat_initiative_dialog.dart';
import '../widgets/combatant_card.dart';
import '../widgets/condition_selector_dialog.dart';
import '../widgets/theme_toggle.dart';

class CombatDetailScreen extends ConsumerStatefulWidget {
  final int combatId;
  final String combatName;
  final bool promptInitiativeOnStart;

  const CombatDetailScreen({
    super.key,
    required this.combatId,
    required this.combatName,
    this.promptInitiativeOnStart = true,
  });

  @override
  ConsumerState<CombatDetailScreen> createState() => _CombatDetailScreenState();
}

class _CombatDetailScreenState extends ConsumerState<CombatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  late final ValueNotifier<int> _activeTurnNotifier;
  late final ValueNotifier<int> _roundNotifier;

  @override
  void initState() {
    super.initState();
    final service = ref.read(combatTrackerServiceProvider);
    final combat = service.getCombat(widget.combatId);
    _activeTurnNotifier = ValueNotifier<int>(combat?.currentTurnIndex ?? 0);
    _roundNotifier = ValueNotifier<int>(combat?.roundCount ?? 1);

    if (widget.promptInitiativeOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showInitiativePrompt();
      });
    }
  }

  Future<void> _showInitiativePrompt() async {
    final service = ref.read(combatTrackerServiceProvider);
    final combat = service.getCombat(widget.combatId);
    final campaign = combat?.campaignId != null
        ? service.getCampaign(combat!.campaignId!)
        : null;

    final confirmed = await CombatInitiativeDialog.show(
      context,
      combatId: widget.combatId,
      combatName: widget.combatName,
      service: service,
      campaign: campaign,
    );

    if (confirmed == true && mounted) {
      _activeTurnNotifier.value = 0;
      _scrollToActiveIfNeeded(0);
    }
  }

  @override
  void dispose() {
    _activeTurnNotifier.dispose();
    _roundNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _getKeyForIndex(int index) {
    return _itemKeys.putIfAbsent(index, () => GlobalKey());
  }

  void _handleNextTurn() {
    final service = ref.read(combatTrackerServiceProvider);
    final result = service.advanceTurn(widget.combatId);

    _activeTurnNotifier.value = result.turnIndex;
    _roundNotifier.value = result.roundCount;

    _scrollToActiveIfNeeded(result.turnIndex);
  }

  Future<void> _handleUndo() async {
    final service = ref.read(combatTrackerServiceProvider);
    final snapshot = await service.undoLastAction(widget.combatId);
    if (snapshot != null) {
      _activeTurnNotifier.value = snapshot.currentTurnIndex;
      _roundNotifier.value = snapshot.roundCount;
      _scrollToActiveIfNeeded(snapshot.currentTurnIndex);
    }
  }

  void _scrollToActiveIfNeeded(int targetIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final position = _scrollController.position;

      if (targetIndex == 0) {
        if (position.pixels > 0) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
        return;
      }

      final key = _itemKeys[targetIndex];
      final ctx = key?.currentContext;
      if (ctx == null) return;

      final renderObject = ctx.findRenderObject();
      if (renderObject == null) return;

      final viewport = RenderAbstractViewport.maybeOf(renderObject);
      if (viewport == null) return;

      final currentOffset = position.pixels;
      final offsetToRevealTop =
          viewport.getOffsetToReveal(renderObject, 0.0).offset - 8.0;
      final offsetToRevealBottom =
          viewport.getOffsetToReveal(renderObject, 1.0).offset + 12.0;

      double? targetOffset;
      if (currentOffset < offsetToRevealBottom) {
        targetOffset = offsetToRevealBottom;
      } else if (currentOffset > offsetToRevealTop) {
        targetOffset = offsetToRevealTop;
      }

      if (targetOffset != null) {
        final clamped = targetOffset.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        if ((clamped - currentOffset).abs() > 1.0) {
          _scrollController.animateTo(
            clamped,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.watch(combatTrackerServiceProvider);
    final combat = service.getCombat(widget.combatId);
    final campaign = combat?.campaignId != null
        ? service.getCampaign(combat!.campaignId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<int>(
          valueListenable: _roundNotifier,
          builder: (context, roundCount, _) {
            final subtitleText = (combat?.campaignName != null &&
                    combat!.campaignName!.isNotEmpty)
                ? '${l10n.round} $roundCount • ${combat.campaignName}'
                : '${l10n.round} $roundCount';
            return Column(
              children: [
                Text(widget.combatName),
                Text(
                  subtitleText,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Definir Iniciativas do Combate',
            onPressed: _showInitiativePrompt,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ThemeToggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Object?>(
              valueListenable: service.combatantsListenable,
              builder: (context, _, __) {
                final combatants = service.getCombatants(widget.combatId);

                if (combatants.isEmpty) {
                  return Center(child: Text(l10n.addCombatantsToStart));
                }

                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  thickness: 3.0,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(right: 4, bottom: 8),
                    child: Column(
                      children: [
                        for (int index = 0; index < combatants.length; index++)
                          KeyedSubtree(
                            key: _getKeyForIndex(index),
                            child: ValueListenableBuilder<int>(
                              valueListenable: _activeTurnNotifier,
                              builder: (context, activeTurnIndex, _) {
                                final item = combatants[index];
                                return CombatantCard(
                                  key: ValueKey(item.id),
                                  combatant: item,
                                  isActive: index == activeTurnIndex,
                                  onMinus: (amount) =>
                                      service.updateHp(item, -amount),
                                  onPlus: (amount) =>
                                      service.updateHp(item, amount),
                                  onDeathSaveChanged: (successes, failures) =>
                                      service.updateDeathSaves(
                                          item, successes, failures),
                                  onConcentrationResolved: (keeps) =>
                                      service.resolveConcentration(
                                    item,
                                    keepsConcentration: keeps,
                                  ),
                                  onEdit: () => _showCombatantDialog(
                                    context,
                                    service,
                                    combatant: item,
                                  ),
                                  onDelete: () {
                                    final nextIdx = service.deleteCombatant(
                                      widget.combatId,
                                      item.id,
                                      _activeTurnNotifier.value,
                                    );
                                    _activeTurnNotifier.value = nextIdx;
                                  },
                                  onConditionTap: () => _showConditionDialog(
                                    context,
                                    service,
                                    item,
                                  ),
                                  onTempHpTap: () => _showTempHpDialog(
                                    context,
                                    service,
                                    item,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Action Bar: Adicionar + Botão Simples de Retornar (Undo) + Próximo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          _showAddCombatantFlow(context, service, campaign),
                      child: const Text(
                        'Adicionar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ValueListenableBuilder<bool>(
                    valueListenable:
                        service.canUndoListenable(widget.combatId),
                    builder: (context, canUndo, _) {
                      return SizedBox(
                        height: 52,
                        width: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: canUndo
                                ? Colors.blueGrey[700]
                                : Colors.grey.withValues(alpha: 0.25),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: canUndo ? _handleUndo : null,
                          child: const Tooltip(
                            message: 'Voltar última movimentação',
                            child: Icon(Icons.undo, size: 24),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _handleNextTurn,
                      child: Text(
                        l10n.nextTurn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTempHpDialog(
    BuildContext context,
    CombatTrackerService service,
    Combatant combatant,
  ) async {
    final hpTempController =
        TextEditingController(text: combatant.hpTemp.toString());
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('HP Temporário: ${combatant.name}'),
        content: TextField(
          controller: hpTempController,
          decoration: const InputDecoration(labelText: 'HP Temp'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final hpTemp = int.tryParse(hpTempController.text) ?? 0;
              service.updateTempHp(combatant, hpTemp);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showConditionDialog(
    BuildContext context,
    CombatTrackerService service,
    Combatant combatant,
  ) async {
    final result = await ConditionSelectorDialog.show(
      context,
      title: 'Condições: ${combatant.name}',
      initialConditions: combatant.conditions,
      characterClass: combatant.characterClass,
    );

    if (result != null) {
      service.updateConditions(combatant, result);
    }
  }

  Future<void> _showAddCombatantFlow(
    BuildContext context,
    CombatTrackerService service,
    dynamic campaign,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AddCombatantDialog(
        combatId: widget.combatId,
        campaign: campaign,
        onAddCombatants: (combatants) async {
          await service.addCombatants(widget.combatId, combatants);
        },
      ),
    );
  }

  Future<void> _showCombatantDialog(
    BuildContext context,
    CombatTrackerService service, {
    Combatant? combatant,
  }) async {
    final isEditing = combatant != null;
    final nameController = TextEditingController(text: combatant?.name ?? '');
    final initController =
        TextEditingController(text: combatant?.initiative.toString() ?? '');
    final hpCurrentController =
        TextEditingController(text: combatant?.hpCurrent.toString() ?? '');
    final hpController =
        TextEditingController(text: combatant?.hpMax.toString() ?? '');
    final acController =
        TextEditingController(text: combatant?.armorClass.toString() ?? '10');
    final hpTempController =
        TextEditingController(text: combatant?.hpTemp.toString() ?? '0');
    bool isPlayer = combatant?.isPlayer ?? false;
    final l10n = AppLocalizations.of(context)!;
    List<String> conditions = List.from(combatant?.conditions ?? []);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              isEditing ? l10n.editCombatantTitle : l10n.addCombatantTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.name),
                  autofocus: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: initController,
                          decoration:
                              InputDecoration(labelText: l10n.initiative),
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: acController,
                          decoration: const InputDecoration(labelText: 'CA'),
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isEditing) ...[
                      Expanded(
                        child: TextField(
                            controller: hpCurrentController,
                            decoration:
                                const InputDecoration(labelText: 'PV Atual'),
                            keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: TextField(
                          controller: hpController,
                          decoration: InputDecoration(labelText: l10n.maxHp),
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: hpTempController,
                          decoration:
                              const InputDecoration(labelText: 'HP Temp'),
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.checklist),
                  label: Text(conditions.isEmpty
                      ? 'Selecionar Condições'
                      : 'Condições Selecionadas (${conditions.length})'),
                  onPressed: () async {
                    final selected = await ConditionSelectorDialog.show(
                      context,
                      title: 'Selecionar Condições',
                      initialConditions: conditions,
                      characterClass: combatant?.characterClass,
                    );
                    if (selected != null) {
                      setState(() {
                        conditions = selected;
                      });
                    }
                  },
                ),
                if (conditions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: conditions
                        .map((c) => Chip(
                              label: Text(c,
                                  style: const TextStyle(fontSize: 12)),
                              visualDensity: VisualDensity.compact,
                              onDeleted: () {
                                setState(() {
                                  conditions.remove(c);
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
                CheckboxListTile(
                  title: Text(l10n.isPlayer),
                  value: isPlayer,
                  onChanged: (val) => setState(() => isPlayer = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel, textAlign: TextAlign.center)),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final init = int.tryParse(initController.text) ?? 0;
                final hp = int.tryParse(hpController.text) ?? 10;
                final ac = int.tryParse(acController.text) ?? 10;
                final hpTemp = int.tryParse(hpTempController.text) ?? 0;

                if (name.isEmpty) return;

                if (isEditing) {
                  service.recordSnapshot(widget.combatId);
                  final parsedCurrentHp =
                      int.tryParse(hpCurrentController.text) ??
                          combatant.hpCurrent;
                  final clampedCurrentHp = parsedCurrentHp.clamp(0, hp);

                  combatant
                    ..name = name
                    ..initiative = init
                    ..hpMax = hp
                    ..hpCurrent = clampedCurrentHp
                    ..armorClass = ac
                    ..hpTemp = hpTemp
                    ..conditions = conditions
                    ..isPlayer = isPlayer;

                  if (isPlayer) {
                    combatant.combatantType = 'player';
                  } else if (combatant.combatantType == 'player') {
                    combatant.combatantType = 'monster';
                  }

                  if (clampedCurrentHp > 0) {
                    combatant.deathSaveSuccesses = 0;
                    combatant.deathSaveFailures = 0;
                  }

                  await service.saveCombatantEdit(combatant);
                } else {
                  final newCombatant = Combatant()
                    ..combatId = widget.combatId
                    ..name = name
                    ..initiative = init
                    ..hpMax = hp
                    ..hpCurrent = hp
                    ..armorClass = ac
                    ..hpTemp = hpTemp
                    ..conditions = conditions
                    ..isPlayer = isPlayer
                    ..combatantType = isPlayer ? 'player' : 'monster';

                  await service.addCombatants(widget.combatId, [newCombatant]);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? l10n.save : l10n.add,
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
