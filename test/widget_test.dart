import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cua_companion/app.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CuaCompanionApp(),
      ),
    );
    expect(find.text('CUA Companion'), findsNothing);
  });
}
