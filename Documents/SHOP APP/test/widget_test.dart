import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towel_shop/core/constants/app_constants.dart';
import 'package:towel_shop/main.dart';

void main() {
  testWidgets('TowelShopApp initial load smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TowelShopApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify shop branding is displayed
    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}
