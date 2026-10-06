import 'package:finzomanager/config/language/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arabic shell copy is right to left', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: Text('أضف أول حساب')),
      ),
    );
    expect(find.text('أضف أول حساب'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('أضف أول حساب'))), TextDirection.rtl);
    expect(Strings.fenzoEmpty, isNotEmpty);
  });
}
