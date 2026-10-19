import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/combatant.dart';
import '../../data/monster_database.dart';
import 'condition_selector_dialog.dart';

enum _AddStep {
  selectType,
  selectPlayerClass,
  playerDetails,
  selectMonster,
  monsterConfirm,
  npcDetails,
}

class AddCombatantDialog extends StatefulWidget {
  final int combatId;
  final Future<void> Function(List<Combatant> combatants) onAddCombatants;

  const AddCombatantDialog({
    super.key,
    required this.combatId,
    required this.onAddCombatants,
  });

  @override
  State<AddCombatantDialog> createState() => _AddCombatantDialogState();
}

class _AddCombatantDialogState extends State<AddCombatantDialog> {
  _AddStep _currentStep = _AddStep.selectType;
  final Random _random = Random();

  // Player state
  DndClassInfo? _selectedClass;

  // Monster search & selection state
  final TextEditingController _monsterSearchController = TextEditingController();
  String _selectedMonsterTypeFilter = 'Todos';
  MonsterTemplate? _selectedMonster;
  int _monsterQuantity = 1;

  // Shared form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _initController = TextEditingController();
  final TextEditingController _acController = TextEditingController(text: '10');
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _hpTempController = TextEditingController(text: '0');
  final List<String> _conditions = [];

  final ScrollController _classScrollController = ScrollController();
  final ScrollController _playerFormScrollController = ScrollController();
  final ScrollController _monsterScrollController = ScrollController();
  final ScrollController _monsterFormScrollController = ScrollController();
  final ScrollController _npcFormScrollController = ScrollController();

  static const List<String> _monsterTypes = [
    'Todos',
    'Fada',
    'Humanoide',
    'Morto-Vivo',
    'Besta',
    'Dragão',
    'Monstruosidade',
    'Gigante',
    'Corruptor',
    'Aberração',
    'Constructo',
    'Elemental',
    'Limo',
  ];

  @override
  void dispose() {
    _monsterSearchController.dispose();
    _nameController.dispose();
    _roleController.dispose();
    _initController.dispose();
    _acController.dispose();
    _hpController.dispose();
    _hpTempController.dispose();
    _classScrollController.dispose();
    _playerFormScrollController.dispose();
    _monsterScrollController.dispose();
    _monsterFormScrollController.dispose();
    _npcFormScrollController.dispose();
    super.dispose();
  }

  void _rollInitiative([int bonus = 0]) {
    final roll = _random.nextInt(20) + 1 + bonus;
    setState(() {
      _initController.text = roll.toString();
    });
  }

  void _resetForm({
    String name = '',
    String role = '',
    String init = '',
    String ac = '10',
    String hp = '',
  }) {
    _nameController.text = name;
    _roleController.text = role;
    _initController.text = init;
    _acController.text = ac;
    _hpController.text = hp;
    _hpTempController.text = '0';
    _conditions.clear();
    _monsterQuantity = 1;
  }

  void _onSelectClass(DndClassInfo dndClass) {
    _selectedClass = dndClass;
    _resetForm(
      ac: dndClass.defaultAc.toString(),
      hp: (dndClass.hitDie + 2).toString(),
    );
    setState(() {
      _currentStep = _AddStep.playerDetails;
    });
  }

  void _onSelectMonsterTemplate(MonsterTemplate monster) {
    _selectedMonster = monster;
    final rolledInit = (_random.nextInt(20) + 1 + monster.initiativeBonus).clamp(1, 40);
    _resetForm(
      name: monster.name,
      role: '${monster.type} • ND ${monster.challengeRating}',
      init: rolledInit.toString(),
      ac: monster.armorClass.toString(),
      hp: monster.hpMax.toString(),
    );
    setState(() {
      _currentStep = _AddStep.monsterConfirm;
    });
  }

  void _onCustomMonster() {
    _selectedMonster = null;
    _resetForm(
      name: _monsterSearchController.text.trim(),
      role: 'Monstro',
      init: (_random.nextInt(20) + 1).toString(),
      ac: '13',
      hp: '20',
    );
    setState(() {
      _currentStep = _AddStep.monsterConfirm;
    });
  }

  void _applyNpcPreset(MonsterTemplate preset) {
    final rolledInit = (_random.nextInt(20) + 1 + preset.initiativeBonus).clamp(1, 30);
    setState(() {
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = preset.name;
      }
      _roleController.text = preset.type;
      _acController.text = preset.armorClass.toString();
      _hpController.text = preset.hpMax.toString();
      _initController.text = rolledInit.toString();
    });
  }

  Future<void> _submitCombatant({
    required String type,
    required bool isPlayer,
    String? characterClass,
    int quantity = 1,
  }) async {
    final baseName = _nameController.text.trim();
    if (baseName.isEmpty) return;

    final init = int.tryParse(_initController.text) ?? 10;
    final hp = int.tryParse(_hpController.text) ?? 10;
    final ac = int.tryParse(_acController.text) ?? 10;
    final hpTemp = int.tryParse(_hpTempController.text) ?? 0;

    final List<Combatant> created = [];
    for (int i = 0; i < quantity; i++) {
      final name = quantity > 1 ? '$baseName ${i + 1}' : baseName;
      final c = Combatant()
        ..combatId = widget.combatId
        ..name = name
        ..initiative = init
        ..hpMax = hp
        ..hpCurrent = hp
        ..armorClass = ac
        ..hpTemp = hpTemp
        ..conditions = List<String>.from(_conditions)
        ..isPlayer = isPlayer
        ..combatantType = type
        ..characterClass = characterClass;
      created.add(c);
    }

    await widget.onAddCombatants(created);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildCurrentStep(context),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case _AddStep.selectType:
        return _buildSelectTypeStep(context);
      case _AddStep.selectPlayerClass:
        return _buildSelectPlayerClassStep(context);
      case _AddStep.playerDetails:
        return _buildPlayerDetailsStep(context);
      case _AddStep.selectMonster:
        return _buildSelectMonsterStep(context);
      case _AddStep.monsterConfirm:
        return _buildMonsterConfirmStep(context);
      case _AddStep.npcDetails:
        return _buildNpcDetailsStep(context);
    }
  }

  // ===========================================================================
  // STEP 1: SELECT TYPE (JOGADOR / MONSTRO / NPC)
  // ===========================================================================
  Widget _buildSelectTypeStep(BuildContext context) {
    return Column(
      key: const ValueKey('selectType'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Adicionar ao Combate',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Fechar',
            ),
          ],
        ),
        Text(
          'Escolha quem você deseja adicionar ao encontro:',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _TypeOptionCard(
          title: 'Jogador',
          subtitle: 'Selecionar classe de D&D 5.5e e atributos do herói',
          icon: Icons.shield,
          accentColor: const Color(0xFF5C6BC0),
          onTap: () {
            setState(() {
              _currentStep = _AddStep.selectPlayerClass;
            });
          },
        ),
        const SizedBox(height: 12),
        _TypeOptionCard(
          title: 'Monstro',
          subtitle: 'Pesquisar e escolher na Base de Monstros D&D 5.5e',
          icon: Icons.local_fire_department,
          accentColor: const Color(0xFFE53935),
          onTap: () {
            setState(() {
              _monsterSearchController.clear();
              _selectedMonsterTypeFilter = 'Todos';
              _currentStep = _AddStep.selectMonster;
            });
          },
        ),
        const SizedBox(height: 12),
        _TypeOptionCard(
          title: 'NPC',
          subtitle: 'Adicionar aliado, mercador ou personagem do Mestre',
          icon: Icons.record_voice_over,
          accentColor: const Color(0xFF26A69A),
          onTap: () {
            _resetForm(
              role: 'Aliado / Neutro',
              init: (_random.nextInt(20) + 1).toString(),
              ac: '12',
              hp: '15',
            );
            setState(() {
              _currentStep = _AddStep.npcDetails;
            });
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // STEP 2A.1: SELECT PLAYER CLASS (D&D 5.5e)
  // ===========================================================================
  Widget _buildSelectPlayerClassStep(BuildContext context) {
    return Column(
      key: const ValueKey('selectPlayerClass'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          title: 'Qual a classe do Jogador?',
          subtitle: 'Classes oficiais do D&D 5.5e (2024)',
          onBack: () => setState(() => _currentStep = _AddStep.selectType),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Scrollbar(
            controller: _classScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            thickness: 3.5,
            radius: const Radius.circular(8),
            child: GridView.builder(
              controller: _classScrollController,
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
                  onTap: () => _onSelectClass(dndClass),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          backgroundColor: dndClass.color.withValues(alpha: 0.25),
                          child: Icon(dndClass.icon, color: dndClass.color, size: 18),
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
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  // ===========================================================================
  // STEP 2A.2: PLAYER DETAILS FORM
  // ===========================================================================
  Widget _buildPlayerDetailsStep(BuildContext context) {
    final dndClass = _selectedClass!;
    return Scrollbar(
      key: const ValueKey('playerDetails'),
      controller: _playerFormScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 3.5,
      radius: const Radius.circular(8),
      child: SingleChildScrollView(
        controller: _playerFormScrollController,
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader(
              title: 'Novo Jogador',
              subtitle: 'Preencha os dados do herói',
              onBack: () => setState(() => _currentStep = _AddStep.selectPlayerClass),
            ),
            const SizedBox(height: 12),
            // Selected class banner
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
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _currentStep = _AddStep.selectPlayerClass),
                    child: const Text('Trocar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCommonStatsForm(
              nameLabel: 'Nome do Personagem / Jogador',
              autoFocusName: true,
            ),
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
                  onPressed: () => _submitCombatant(
                    type: 'player',
                    isPlayer: true,
                    characterClass: dndClass.name,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STEP 2B.1: MONSTER DATABASE WITH TOP SEARCH BAR (D&D 5.5e)
  // ===========================================================================
  Widget _buildSelectMonsterStep(BuildContext context) {
    final query = _monsterSearchController.text.trim().toLowerCase();
    final filteredMonsters = monsterDatabase.where((m) {
      final matchesFilter = _selectedMonsterTypeFilter == 'Todos' ||
          m.type.toLowerCase() == _selectedMonsterTypeFilter.toLowerCase();
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
        _buildStepHeader(
          title: 'Base de Monstros (D&D 5.5e)',
          subtitle: 'Selecione um monstro para adicionar ao combate',
          onBack: () => setState(() => _currentStep = _AddStep.selectType),
        ),
        const SizedBox(height: 12),
        // BARRA DE PESQUISA NA PARTE DE CIMA
        TextField(
          controller: _monsterSearchController,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Pesquisar monstro por nome, tipo ou ND...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _monsterSearchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _monsterSearchController.clear();
                      setState(() {});
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
        // Filtros rápidos por tipo de monstro
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _monsterTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final type = _monsterTypes[index];
              final isSelected = _selectedMonsterTypeFilter == type;
              return ChoiceChip(
                label: Text(type, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                visualDensity: VisualDensity.compact,
                onSelected: (_) {
                  setState(() {
                    _selectedMonsterTypeFilter = type;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Lista de monstros
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
                        onPressed: _onCustomMonster,
                      ),
                    ],
                  ),
                )
              : Scrollbar(
                  controller: _monsterScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  thickness: 3.5,
                  radius: const Radius.circular(8),
                  child: ListView.separated(
                    controller: _monsterScrollController,
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
                        onTap: () => _onSelectMonsterTemplate(monster),
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
                                        _StatPill(
                                          label: 'CA ${monster.armorClass}',
                                          color: Colors.blueAccent,
                                        ),
                                        _StatPill(
                                          label: 'PV ${monster.hpMax}',
                                          color: Colors.green,
                                        ),
                                        _StatPill(
                                          label: 'Inic $initSign',
                                          color: Colors.amber[700]!,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
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
              onPressed: _onCustomMonster,
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

  // ===========================================================================
  // STEP 2B.2: CONFIRM / CUSTOMIZE SELECTED MONSTER
  // ===========================================================================
  Widget _buildMonsterConfirmStep(BuildContext context) {
    final monster = _selectedMonster;
    return Scrollbar(
      key: const ValueKey('monsterConfirm'),
      controller: _monsterFormScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 3.5,
      radius: const Radius.circular(8),
      child: SingleChildScrollView(
        controller: _monsterFormScrollController,
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader(
              title: monster != null ? monster.name : 'Monstro Personalizado',
              subtitle: monster != null
                  ? '${monster.type} • ND ${monster.challengeRating}'
                  : 'Defina os atributos do monstro',
              onBack: () => setState(() => _currentStep = _AddStep.selectMonster),
            ),
            const SizedBox(height: 12),
            // Quantity selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
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
                    onPressed: _monsterQuantity > 1
                        ? () => setState(() => _monsterQuantity--)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '$_monsterQuantity',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    visualDensity: VisualDensity.compact,
                    onPressed: _monsterQuantity < 20
                        ? () => setState(() => _monsterQuantity++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildCommonStatsForm(
              nameLabel: 'Nome do Monstro',
              autoFocusName: monster == null,
              initiativeBonus: monster?.initiativeBonus ?? 0,
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () =>
                      setState(() => _currentStep = _AddStep.selectMonster),
                  child: const Text('Trocar'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(_monsterQuantity > 1
                      ? 'Adicionar ($_monsterQuantity)'
                      : 'Adicionar Monstro'),
                  onPressed: () => _submitCombatant(
                    type: 'monster',
                    isPlayer: false,
                    characterClass: _roleController.text.isNotEmpty
                        ? _roleController.text
                        : 'Monstro',
                    quantity: _monsterQuantity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STEP 2C: NPC DETAILS FORM
  // ===========================================================================
  Widget _buildNpcDetailsStep(BuildContext context) {
    return Scrollbar(
      key: const ValueKey('npcDetails'),
      controller: _npcFormScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 3.5,
      radius: const Radius.circular(8),
      child: SingleChildScrollView(
        controller: _npcFormScrollController,
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader(
              title: 'Novo NPC',
              subtitle: 'Personagem do Mestre, aliado ou neutro',
              onBack: () => setState(() => _currentStep = _AddStep.selectType),
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
                  label: Text(preset.name, style: const TextStyle(fontSize: 11.5)),
                  onPressed: () => _applyNpcPreset(preset),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _buildCommonStatsForm(
              nameLabel: 'Nome do NPC',
              autoFocusName: true,
              showRoleField: true,
              roleLabel: 'Papel / Ocupação (ex: Aliado, Guarda, Mercador)',
            ),
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
                  onPressed: () => _submitCombatant(
                    type: 'npc',
                    isPlayer: false,
                    characterClass: _roleController.text.trim().isNotEmpty
                        ? _roleController.text.trim()
                        : 'NPC',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SHARED UI HELPERS
  // ===========================================================================
  Widget _buildStepHeader({
    required String title,
    required String subtitle,
    required VoidCallback onBack,
  }) {
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

  Widget _buildCommonStatsForm({
    required String nameLabel,
    bool autoFocusName = false,
    bool showRoleField = false,
    String roleLabel = 'Papel',
    int initiativeBonus = 0,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
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
            controller: _roleController,
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
                controller: _initController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Iniciativa',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.casino_outlined),
                    tooltip: 'Rolar 1d20',
                    onPressed: () => _rollInitiative(initiativeBonus),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _acController,
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
                controller: _hpController,
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
                controller: _hpTempController,
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
          label: Text(_conditions.isEmpty
              ? 'Selecionar Condições (opcional)'
              : 'Condições Selecionadas (${_conditions.length})'),
          onPressed: () async {
            final selected = await ConditionSelectorDialog.show(
              context,
              title: 'Selecionar Condições',
              initialConditions: _conditions,
              characterClass: _currentStep == _AddStep.playerDetails
                  ? _selectedClass?.name
                  : null,
            );
            if (selected != null) {
              setState(() {
                _conditions
                  ..clear()
                  ..addAll(selected);
              });
            }
          },
        ),
        if (_conditions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _conditions
                .map(
                  (c) => Chip(
                    label: Text(c, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    onDeleted: () {
                      setState(() {
                        _conditions.remove(c);
                      });
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

class _TypeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _TypeOptionCard({
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

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatPill({
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
