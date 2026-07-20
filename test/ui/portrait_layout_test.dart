import 'package:fish_growth_rpg/app/fish_growth_app.dart';
import 'package:fish_growth_rpg/data/save/player_save_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('keeps the HUD visible across portrait phone sizes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const FishGrowthApp(saveRepository: NoopPlayerSaveRepository()),
    );
    for (
      var i = 0;
      i < 180 && find.text('FISH ADVENTURE RPG').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    _expectHudVisible(tester);

    tester.view.physicalSize = const Size(430, 932);
    await tester.pump();

    _expectHudVisible(tester);
  });
}

void _expectHudVisible(WidgetTester tester) {
  expect(find.text('FISH ADVENTURE RPG'), findsOneWidget);
  expect(find.byKey(const ValueKey('auto-hunt-button')), findsOneWidget);
  expect(find.byKey(const ValueKey('boost-button')), findsOneWidget);
  expect(find.byKey(const ValueKey('collection-button')), findsOneWidget);
  expect(find.byKey(const ValueKey('species-change-button')), findsOneWidget);
  expect(tester.takeException(), isNull);
}
