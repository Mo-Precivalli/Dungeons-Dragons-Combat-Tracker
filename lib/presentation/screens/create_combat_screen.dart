import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';
import '../../data/models/combat.dart';

class CreateCombatScreen extends ConsumerStatefulWidget {
  const CreateCombatScreen({super.key});

  @override
  ConsumerState<CreateCombatScreen> createState() => _CreateCombatScreenState();
}

class _CreateCombatScreenState extends ConsumerState<CreateCombatScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Removed automatic focus to prevent crash
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _createCombat() async {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      try {
        final combat = Combat()
          ..name = name
          ..createdAt = DateTime.now()
          ..status = CombatStatus.active;
        await Hive.box<Combat>('combats').add(combat);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent layout resizing when keyboard opens
      appBar: AppBar(
        title: Text(l10n.newCombat,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.encounterName,
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: l10n.encounterName,
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(), // Use default system font to avoid crash
              enableIMEPersonalizedLearning: false, // Fix for Android 14/15 crash
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _createCombat(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _createCombat,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                l10n.create,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
