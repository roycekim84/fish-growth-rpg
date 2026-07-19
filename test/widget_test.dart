import 'package:fish_growth_rpg/app/fish_growth_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('shows the portrait game shell and HUD', (tester) async {
    await tester.pumpWidget(const FishGrowthApp());
    await tester.pump();

    expect(find.text('FISH GROWTH RPG'), findsOneWidget);
    expect(find.text('LV. 1'), findsOneWidget);
    expect(find.text('HP'), findsOneWidget);
    expect(find.text('FULL'), findsOneWidget);
    expect(find.text('EXP'), findsOneWidget);
    expect(find.text('40 / 40'), findsOneWidget);
    expect(find.text('50 / 100'), findsOneWidget);
    expect(find.text('0 / 30'), findsOneWidget);
    final button = find.byKey(const ValueKey('boost-button'));
    final autoButton = find.byKey(const ValueKey('auto-hunt-button'));
    expect(button, findsOneWidget);
    expect(autoButton, findsOneWidget);

    await tester.tap(autoButton);
    await tester.pump();
    expect(find.textContaining('AUTO ON'), findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    expect(find.text('BOOST!'), findsOneWidget);
    expect(find.textContaining('AUTO OFF'), findsOneWidget);

    await gesture.up();
    await tester.pump();
    expect(find.text('BOOST'), findsOneWidget);

    final collectionButton = find.byKey(const ValueKey('collection-button'));
    expect(collectionButton, findsOneWidget);
    await tester.tap(collectionButton);
    await tester.pump();
    expect(find.text('FISH COLLECTION'), findsOneWidget);
    expect(find.textContaining('0 / 100'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('collection-close-button')));
    await tester.pump();
    final speciesButton = find.byKey(const ValueKey('species-change-button'));
    await tester.tap(speciesButton);
    await tester.pump();
    expect(find.text('SPECIES CHANGE'), findsOneWidget);
    expect(find.text('푸른 치어'), findsWidgets);
    expect(find.text('CURRENT SPECIES'), findsOneWidget);
  });
}
