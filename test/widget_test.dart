import 'package:fish_growth_rpg/app/fish_growth_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the portrait game shell and HUD', (tester) async {
    await tester.pumpWidget(const FishGrowthApp());
    await tester.pump();

    expect(find.text('FISH GROWTH RPG'), findsOneWidget);
    expect(find.text('LV. 1'), findsOneWidget);
    expect(find.text('HP'), findsOneWidget);
    expect(find.text('FULL'), findsOneWidget);
    expect(find.text('EXP'), findsOneWidget);
  });
}
