import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/campaign.dart';
import '../../data/models/combatant.dart';
import '../../data/monster_database.dart';
import 'add_combatant/add_combatant_shared.dart';
import 'add_combatant/monster_steps.dart';
import 'add_combatant/npc_step.dart';
import 'add_combatant/player_steps.dart';

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
  final Campaign? campaign;
  final Future<void> Function(List<Combatant> combatants) onAddCombatants;

  const AddCombatantDialog({
    super.key,
    required this.combatId,
    required this.onAddCombatants,
    this.campaign,
  });

  @override
  State<AddCombatantDialog> createState() => _AddCombatantDialogState();
}

class _AddCombatantDialogState extends State<AddCombatantDialog> {
  _AddStep _currentStep = _AddStep.selectType;
  final Random _random = Random();

  // Player state
  DndClassInfo? _selectedClass;

  // Monster state
  final TextEditingController _monsterSearchController =
      TextEditingController();
  String _selectedMonsterTypeFilter = 'Todos';
  MonsterTemplate? _selectedMonster;
  int _monsterQuantity = 1;

  // Shared form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _initController = TextEditingController();
  final TextEditingController _acController =
      TextEditingController(text: '10');
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _hpTempController =
      TextEditingController(text: '0');
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

  void _onSelectCampaignHero(PartyHero hero) {
    final classInfo = getDndClassInfo(hero.characterClass) ?? dndClasses.first;
    _selectedClass = classInfo;
    final rolledInit =
        (_random.nextInt(20) + 1 + hero.initiativeBonus).clamp(1, 40);
    _resetForm(
      name: hero.name,
      init: rolledInit.toString(),
      ac: hero.armorClass.toString(),
      hp: hero.hpMax.toString(),
    );
    setState(() {
      _currentStep = _AddStep.playerDetails;
    });
  }

  void _onSelectMonsterTemplate(MonsterTemplate monster) {
    _selectedMonster = monster;
    final rolledInit =
        (_random.nextInt(20) + 1 + monster.initiativeBonus).clamp(1, 40);
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
    final rolledInit =
        (_random.nextInt(20) + 1 + preset.initiativeBonus).clamp(1, 30);
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

  AddCombatantStatsForm _buildStatsForm({
    required String nameLabel,
    bool autoFocusName = false,
    bool showRoleField = false,
    String roleLabel = 'Papel',
    int initiativeBonus = 0,
    String? characterClassForConditions,
  }) {
    return AddCombatantStatsForm(
      nameController: _nameController,
      roleController: _roleController,
      initController: _initController,
      acController: _acController,
      hpController: _hpController,
      hpTempController: _hpTempController,
      conditions: _conditions,
      nameLabel: nameLabel,
      autoFocusName: autoFocusName,
      showRoleField: showRoleField,
      roleLabel: roleLabel,
      initiativeBonus: initiativeBonus,
      characterClassForConditions: characterClassForConditions,
      onRollInitiative: _rollInitiative,
      onConditionsChanged: (updated) {
        setState(() {
          _conditions
            ..clear()
            ..addAll(updated);
        });
      },
    );
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
        return SelectPlayerClassStep(
          scrollController: _classScrollController,
          onBack: () => setState(() => _currentStep = _AddStep.selectType),
          onSelectClass: _onSelectClass,
        );
      case _AddStep.playerDetails:
        return PlayerDetailsStep(
          dndClass: _selectedClass!,
          scrollController: _playerFormScrollController,
          onBack: () =>
              setState(() => _currentStep = _AddStep.selectPlayerClass),
          onSubmit: () => _submitCombatant(
            type: 'player',
            isPlayer: true,
            characterClass: _selectedClass!.name,
          ),
          statsForm: _buildStatsForm(
            nameLabel: 'Nome do Personagem / Jogador',
            autoFocusName: _nameController.text.isEmpty,
            characterClassForConditions: _selectedClass!.name,
          ),
        );
      case _AddStep.selectMonster:
        return SelectMonsterStep(
          searchController: _monsterSearchController,
          scrollController: _monsterScrollController,
          monsterTypes: _monsterTypes,
          selectedTypeFilter: _selectedMonsterTypeFilter,
          onBack: () => setState(() => _currentStep = _AddStep.selectType),
          onSearchChanged: () => setState(() {}),
          onFilterSelected: (type) =>
              setState(() => _selectedMonsterTypeFilter = type),
          onSelectMonster: _onSelectMonsterTemplate,
          onCustomMonster: _onCustomMonster,
        );
      case _AddStep.monsterConfirm:
        return MonsterConfirmStep(
          monster: _selectedMonster,
          quantity: _monsterQuantity,
          scrollController: _monsterFormScrollController,
          onBack: () => setState(() => _currentStep = _AddStep.selectMonster),
          onQuantityChanged: (qty) => setState(() => _monsterQuantity = qty),
          onSubmit: () => _submitCombatant(
            type: 'monster',
            isPlayer: false,
            characterClass: _roleController.text.isNotEmpty
                ? _roleController.text
                : 'Monstro',
            quantity: _monsterQuantity,
          ),
          statsForm: _buildStatsForm(
            nameLabel: 'Nome do Monstro',
            autoFocusName: _selectedMonster == null,
            initiativeBonus: _selectedMonster?.initiativeBonus ?? 0,
          ),
        );
      case _AddStep.npcDetails:
        return NpcDetailsStep(
          scrollController: _npcFormScrollController,
          onBack: () => setState(() => _currentStep = _AddStep.selectType),
          onApplyPreset: _applyNpcPreset,
          onSubmit: () => _submitCombatant(
            type: 'npc',
            isPlayer: false,
            characterClass: _roleController.text.trim().isNotEmpty
                ? _roleController.text.trim()
                : 'NPC',
          ),
          statsForm: _buildStatsForm(
            nameLabel: 'Nome do NPC',
            autoFocusName: true,
            showRoleField: true,
            roleLabel: 'Papel / Ocupação (ex: Aliado, Guarda, Mercador)',
          ),
        );
    }
  }

  Widget _buildSelectTypeStep(BuildContext context) {
    final campaignHeroes = widget.campaign?.heroes ?? const <PartyHero>[];

    return SingleChildScrollView(
      child: Column(
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
          if (campaignHeroes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF5C6BC0).withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personagens de ${widget.campaign!.name}:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: campaignHeroes.map((hero) {
                      final cls = getDndClassInfo(hero.characterClass);
                      return ActionChip(
                        avatar: Icon(
                          cls?.icon ?? Icons.shield,
                          size: 14,
                          color: cls?.color ?? const Color(0xFF5C6BC0),
                        ),
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          '${hero.name} (${hero.characterClass})',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        onPressed: () => _onSelectCampaignHero(hero),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TypeOptionCard(
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
          TypeOptionCard(
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
          TypeOptionCard(
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
      ),
    );
  }
}
