// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_daily_sudoku/app/sudoku_app.dart';
import 'package:my_daily_sudoku/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('App shows the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(SudokuApp());
    await tester.pump();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
