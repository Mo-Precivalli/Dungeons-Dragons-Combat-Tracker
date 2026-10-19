import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';
import 'package:dnd_combat_tracker/data/models/combatant.dart';
import 'package:dnd_combat_tracker/presentation/widgets/combatant_card.dart';

void main() {
  testWidgets('CombatantCard displays combatant and 3-dots menu without duplicate condition item',
      (WidgetTester tester) async {
    final combatant = Combatant()
      ..id = 1
      ..combatId = 1
      ..name = 'Grog'
      ..initiative = 18
      ..hpCurrent = 35
      ..hpMax = 45
      ..armorClass = 16
      ..isPlayer = true
      ..combatantType = 'player'
      ..characterClass = 'barbaro';

    int lastDelta = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt')],
        locale: const Locale('pt'),
        home: Scaffold(
          body: CombatantCard(
            combatant: combatant,
            isActive: true,
            onMinus: (val) => lastDelta = -val,
            onPlus: (val) => lastDelta = val,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Grog'), findsOneWidget);
    expect(find.text('35 / 45 HP'), findsOneWidget);

    // Clicking '-' with empty text field defaults to subtracting 1
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pump();
    expect(lastDelta, -1);

    // Open 3-dots PopupMenuButton and verify 'Condições' is not in the menu
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenuItem<String>), findsNWidgets(2));
  });
}
