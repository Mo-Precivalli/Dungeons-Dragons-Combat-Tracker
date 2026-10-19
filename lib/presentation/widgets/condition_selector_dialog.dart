import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/conditions_database.dart';
import '../../data/monster_database.dart';

class ConditionSelectorDialog extends StatefulWidget {
  final String title;
  final List<String> initialConditions;
  final String? characterClass;

  const ConditionSelectorDialog({
    super.key,
    required this.title,
    required this.initialConditions,
    this.characterClass,
  });

  static Future<List<String>?> show(
    BuildContext context, {
    required String title,
    required List<String> initialConditions,
    String? characterClass,
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => ConditionSelectorDialog(
        title: title,
        initialConditions: initialConditions,
        characterClass: characterClass,
      ),
    );
  }

  @override
  State<ConditionSelectorDialog> createState() =>
      _ConditionSelectorDialogState();
}

class _ConditionSelectorDialogState extends State<ConditionSelectorDialog> {
  late List<String> _selected;
  String _selectedTab = 'Todas';
  String _selectedClassFilter = 'Todas as Classes';
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.initialConditions);
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  void _toggleCondition(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playerClassInfo = getDndClassInfo(widget.characterClass);

    final List<String> tabs = [
      'Todas',
      if (playerClassInfo != null) 'Da Classe (${playerClassInfo.name})',
      'Condições D&D 5.5e',
      'Ativadas por Classes',
    ];

    final filteredConditions = dndConditions.where((c) {
      if (_selectedTab == 'Condições D&D 5.5e') {
        return c.category == ConditionCategory.standard;
      }
      if (_selectedTab == 'Ativadas por Classes') {
        if (c.category != ConditionCategory.classEffect) return false;
        if (_selectedClassFilter != 'Todas as Classes') {
          return c.relatedClasses.contains(_selectedClassFilter);
        }
        return true;
      }
      if (playerClassInfo != null &&
          _selectedTab == 'Da Classe (${playerClassInfo.name})') {
        return c.relatedClasses.contains(playerClassInfo.name);
      }
      return true;
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 660),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.label_important_outline, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              // Active conditions summary bar
              if (_selected.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ativas (${_selected.length}):',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[300],
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _selected.clear()),
                            child: Text(
                              'Limpar tudo',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _selected.map((name) {
                          final info = getDndConditionInfo(name);
                          final chipColor = info?.color ?? Colors.teal;
                          return InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () => _toggleCondition(name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: chipColor.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: chipColor.withValues(alpha: 0.55),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Color.lerp(
                                              chipColor, Colors.white, 0.55)
                                          : Color.lerp(
                                              chipColor, Colors.black, 0.45),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.close,
                                    size: 13,
                                    color: isDark
                                        ? Color.lerp(
                                            chipColor, Colors.white, 0.55)
                                        : Color.lerp(
                                            chipColor, Colors.black, 0.45),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Category Filter Chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return ChoiceChip(
                    label: Text(tab, style: const TextStyle(fontSize: 11.5)),
                    selected: isSelected,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) {
                      setState(() {
                        _selectedTab = tab;
                      });
                    },
                  );
                }).toList(),
              ),

              // Sub-filter by Class when on "Ativadas por Classes" tab
              if (_selectedTab == 'Ativadas por Classes') ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: List.generate(dndClasses.length + 1, (index) {
                    final className = index == 0
                        ? 'Todas as Classes'
                        : dndClasses[index - 1].name;
                    final isSelected = _selectedClassFilter == className;
                    return ChoiceChip(
                      label: Text(className,
                          style: const TextStyle(fontSize: 10.5)),
                      selected: isSelected,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) {
                        setState(() {
                          _selectedClassFilter = className;
                        });
                      },
                    );
                  }),
                ),
              ],

              const SizedBox(height: 10),

              // Checkboxes list of conditions
              Expanded(
                child: Scrollbar(
                  controller: _listScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  thickness: 3.5,
                  radius: const Radius.circular(8),
                  child: ListView.separated(
                    controller: _listScrollController,
                    padding: const EdgeInsets.only(right: 8),
                    itemCount: filteredConditions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final condition = filteredConditions[index];
                      final isChecked = _selected.contains(condition.name);
                      final accent = condition.color;
                      final textColor = isDark
                          ? Color.lerp(accent, Colors.white, 0.55)!
                          : Color.lerp(accent, Colors.black, 0.45)!;

                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _toggleCondition(condition.name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? accent.withValues(alpha: isDark ? 0.22 : 0.16)
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isChecked
                                ? accent.withValues(alpha: 0.65)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                condition.icon,
                                color: textColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          condition.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: isChecked ? textColor : null,
                                          ),
                                        ),
                                      ),
                                      if (condition.category ==
                                          ConditionCategory.classEffect) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color:
                                                accent.withValues(alpha: 0.18),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Classe',
                                            style: GoogleFonts.inter(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    condition.description,
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
                            Checkbox(
                              value: isChecked,
                              activeColor: accent,
                              checkColor: Colors.black87,
                              visualDensity: VisualDensity.compact,
                              onChanged: (_) =>
                                  _toggleCondition(condition.name),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

              const SizedBox(height: 12),

              // Footer buttons
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
                    label: Text(_selected.isEmpty
                        ? 'Salvar'
                        : 'Salvar (${_selected.length})'),
                    onPressed: () => Navigator.pop(context, _selected),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
