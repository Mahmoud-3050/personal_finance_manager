import 'package:finzomanager/shared/widgets/dialogs/show_modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_util/screen_util.dart';

void main() {
  testWidgets('sheet is presented above the tab shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            home: Scaffold(
              body: Navigator(
                onGenerateRoute: (RouteSettings settings) {
                  return MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: TextButton(
                              onPressed: () {
                                showAppModalBottomSheet(
                                  context: context,
                                  child: const SizedBox(
                                    height: 320,
                                    child: Text('Filter sheet'),
                                  ),
                                );
                              },
                              child: const Text('Open'),
                            ),
                          ),
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: SizedBox(height: 80, child: Text('Tab bar')),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final BuildContext sheetContext = tester.element(find.text('Filter sheet'));
    expect(
      Navigator.of(sheetContext),
      Navigator.of(sheetContext, rootNavigator: true),
    );
  });
}
