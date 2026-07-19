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
  });
}
