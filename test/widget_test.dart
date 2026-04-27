import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:page_begin/views/home_view.dart';

void main() {
  testWidgets('HomeView carga', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    expect(find.text("INICIAR SESIÓN"), findsOneWidget);
  });
}
