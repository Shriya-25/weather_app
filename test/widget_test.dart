import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('Weather app renders search field', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherApp());
    await tester.pump();

    expect(find.text('Atmos'), findsOneWidget);
    expect(find.text('Search city'), findsOneWidget);
  });
}
