import 'package:flutter/material.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';

/// Quick utility actions shown in the top-right corner of [CombatantCard].
class CombatantQuickActions extends StatelessWidget {
  final VoidCallback? onTempHpTap;
  final VoidCallback? onConditionTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CombatantQuickActions({
    super.key,
    this.onTempHpTap,
    this.onConditionTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.shield_outlined, size: 19),
          color: Colors.blueAccent,
          tooltip: 'HP Temporário',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.all(4),
          onPressed: onTempHpTap,
        ),
        IconButton(
          icon: const Icon(Icons.label_outline, size: 19),
          color: Colors.tealAccent[400] ?? Colors.teal,
          tooltip: 'Condições',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.all(4),
          onPressed: onConditionTap,
        ),
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          iconSize: 20,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 32),
          onSelected: (value) {
            if (value == 'edit') onEdit?.call();
            if (value == 'delete') onDelete?.call();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(AppLocalizations.of(context)!.edit),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact horizontal HP stepper `[-] [ 1 ] [+]` shown next to the HP bar.
class HpControlsSection extends StatelessWidget {
  final TextEditingController hpController;
  final FocusNode hpFocusNode;
  final void Function(int) onMinus;
  final void Function(int) onPlus;

  const HpControlsSection({
    super.key,
    required this.hpController,
    required this.hpFocusNode,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            color: Colors.redAccent,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            padding: EdgeInsets.zero,
            onPressed: () {
              final text = hpController.text.trim();
              final val = text.isEmpty ? 1 : int.tryParse(text);
              if (val != null && val > 0) {
                onMinus(val);
                if (text.isNotEmpty) {
                  hpController.clear();
                }
              }
            },
          ),
          SizedBox(
            width: 40,
            height: 26,
            child: TextField(
              controller: hpController,
              focusNode: hpFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '1',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.6),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            color: Colors.greenAccent[400] ?? Colors.green,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            padding: EdgeInsets.zero,
            onPressed: () {
              final text = hpController.text.trim();
              final val = text.isEmpty ? 1 : int.tryParse(text);
              if (val != null && val > 0) {
                onPlus(val);
                if (text.isNotEmpty) {
                  hpController.clear();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
