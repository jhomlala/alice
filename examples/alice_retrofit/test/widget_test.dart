import 'package:flutter_test/flutter_test.dart';
import 'package:alice_retrofit/main.dart';

void main() {
  testWidgets('Retrofit example loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Alice + Retrofit - Example'), findsOneWidget);
    expect(find.text('Run Retrofit HTTP Requests'), findsOneWidget);
    expect(find.text('Run HTTP Inspector'), findsOneWidget);
  });
}
