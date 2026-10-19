import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/campaign.dart';
import '../../data/monster_database.dart';
import '../providers/combat_tracker_provider.dart';
import 'create_combat_screen.dart';

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(combatTrackerServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campanhas e Grupos',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<Object?>(
        valueListenable: service.campaignsListenable,
        builder: (context, _, __) {
          final campaigns = service.getCampaigns();
          if (campaigns.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 64,
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma campanha ou grupo criado ainda',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crie grupos fixos de jogadores para suas campanhas e inicie combates sem precisar recadastrar os heróis.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _showCampaignDialog(context, service),
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Primeira Campanha'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            thickness: 3.5,
            radius: const Radius.circular(8),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: campaigns.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final campaign = campaigns[index];
                return _buildCampaignCard(context, service, campaign, isDark);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCampaignDialog(context, service),
        icon: const Icon(Icons.group_add),
        label: const Text('Nova Campanha'),
      ),
    );
  }

  Widget _buildCampaignCard(
    BuildContext context,
    CombatTrackerService service,
    Campaign campaign,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (campaign.description.isNotEmpty)
                      Text(
                        campaign.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Editar nome da campanha',
                onPressed: () =>
                    _showCampaignDialog(context, service, campaign: campaign),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent),
                tooltip: 'Excluir campanha',
                onPressed: () => _confirmDeleteCampaign(context, service, campaign),
              ),
            ],
          ),
          const Divider(height: 22),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Personagens da Campanha (${campaign.heroes.length})',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () => _showHeroDialog(context, service, campaign),
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text(
                  'Adicionar Herói',
                  style: TextStyle(fontSize: 12.5),
                ),
              ),
            ],
          ),
          if (campaign.heroes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Nenhum personagem cadastrado neste grupo ainda. Clique em "Adicionar Herói".',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            )
          else
            Column(
              children: campaign.heroes.map((hero) {
                final classInfo = getDndClassInfo(hero.characterClass);
                final cColor = classInfo?.color ?? const Color(0xFF7986CB);
                final cText = isDark
                    ? Color.lerp(cColor, Colors.white, 0.55)!
                    : Color.lerp(cColor, Colors.black, 0.45)!;
                final initSign = hero.initiativeBonus >= 0
                    ? '+${hero.initiativeBonus}'
                    : '${hero.initiativeBonus}';

                return Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: cColor.withValues(alpha: isDark ? 0.14 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: cColor.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        classInfo?.icon ?? Icons.shield,
                        size: 18,
                        color: cText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              '${hero.characterClass} • CA ${hero.armorClass} • PV ${hero.hpMax} • Inic $initSign',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: cText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 17),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _showHeroDialog(
                            context, service, campaign,
                            existingHero: hero),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 17, color: Colors.redAccent),
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          campaign.heroes
                              .removeWhere((h) => h.id == hero.id);
                          await service.updateCampaign(campaign);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () {
              ref.read(selectedCampaignFilterProvider.notifier).state =
                  campaign.id;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      CreateCombatScreen(initialCampaignId: campaign.id),
                ),
              );
            },
            icon: const Icon(Icons.sports_kabaddi, size: 18),
            label: const Text('Criar Combate com este Grupo'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCampaign(
    BuildContext context,
    CombatTrackerService service,
    Campaign campaign,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Campanha?'),
        content: Text(
          'Deseja remover a campanha "${campaign.name}" e a lista fixa de heróis dela?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (ref.read(selectedCampaignFilterProvider) == campaign.id) {
        ref.read(selectedCampaignFilterProvider.notifier).state = null;
      }
      await service.deleteCampaign(campaign.id);
    }
  }

  Future<void> _showCampaignDialog(
    BuildContext context,
    CombatTrackerService service, {
    Campaign? campaign,
  }) async {
    final isEditing = campaign != null;
    final nameCtrl = TextEditingController(text: campaign?.name ?? '');
    final descCtrl = TextEditingController(text: campaign?.description ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Campanha' : 'Nova Campanha / Grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome da Campanha (ex: Campanha X)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição / Notas (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              if (isEditing) {
                campaign
                  ..name = name
                  ..description = descCtrl.text.trim();
                await service.updateCampaign(campaign);
              } else {
                await service.createCampaign(
                  name: name,
                  description: descCtrl.text.trim(),
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showHeroDialog(
    BuildContext context,
    CombatTrackerService service,
    Campaign campaign, {
    PartyHero? existingHero,
  }) async {
    final isEditing = existingHero != null;
    DndClassInfo selectedClass = isEditing
        ? (getDndClassInfo(existingHero.characterClass) ?? dndClasses.first)
        : dndClasses.first;

    final nameCtrl = TextEditingController(text: existingHero?.name ?? '');
    final acCtrl = TextEditingController(
      text: (existingHero?.armorClass ?? selectedClass.defaultAc).toString(),
    );
    final hpCtrl = TextEditingController(
      text: (existingHero?.hpMax ?? (selectedClass.hitDie + 2)).toString(),
    );
    final initBonusCtrl = TextEditingController(
      text: (existingHero?.initiativeBonus ?? 0).toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              isEditing ? 'Editar Herói' : 'Novo Herói em ${campaign.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Personagem / Jogador',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DndClassInfo>(
                  initialValue: selectedClass,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Classe (D&D 5.5e)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: dndClasses.map((cls) {
                    return DropdownMenuItem<DndClassInfo>(
                      value: cls,
                      child: Row(
                        children: [
                          Icon(cls.icon, color: cls.color, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              cls.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (cls) {
                    if (cls == null) return;
                    setState(() {
                      selectedClass = cls;
                      if (!isEditing) {
                        acCtrl.text = cls.defaultAc.toString();
                        hpCtrl.text = (cls.hitDie + 2).toString();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: acCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CA',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: hpCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'PV Máx',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: initBonusCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bônus Inic',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final ac = int.tryParse(acCtrl.text) ?? 10;
                final hp = int.tryParse(hpCtrl.text) ?? 10;
                final initBonus = int.tryParse(initBonusCtrl.text) ?? 0;

                if (isEditing) {
                  final idx = campaign.heroes
                      .indexWhere((h) => h.id == existingHero.id);
                  if (idx != -1) {
                    campaign.heroes[idx] = existingHero.copyWith(
                      name: name,
                      characterClass: selectedClass.name,
                      armorClass: ac,
                      hpMax: hp,
                      initiativeBonus: initBonus,
                    );
                  }
                } else {
                  campaign.heroes.add(
                    PartyHero(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: name,
                      characterClass: selectedClass.name,
                      armorClass: ac,
                      hpMax: hp,
                      initiativeBonus: initBonus,
                    ),
                  );
                }

                await service.updateCampaign(campaign);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Salvar Herói'),
            ),
          ],
        ),
      ),
    );
  }
}
