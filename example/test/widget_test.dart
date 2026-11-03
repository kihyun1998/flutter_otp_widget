import 'package:example/main.dart';
import 'package:flutter_otp_widget/flutter_otp_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the examples page opens an OTP dialog', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('OTP TextField Examples'), findsOneWidget);
    expect(find.byType(OTPTextField), findsNothing);

    await tester.tap(find.text('Basic Box'));
    await tester.pumpAndSettle();

    expect(find.byType(OTPTextField), findsOneWidget);
  });
}
