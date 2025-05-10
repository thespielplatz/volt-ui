import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:volt_ui/main.dart' as app;
import 'package:volt_ui/ui/vui_button.dart';
import '../mocks/lndhub_io_server.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockServer = LndhubIoServer();

  setUpAll(() async {
    await mockServer.start();
  });

  tearDownAll(() async {
    await mockServer.stop();
  });

  testWidgets('Show no wallet screen', (tester) async {
    app.runWithConfig();
    await tester.pumpAndSettle();

    expect(find.text('No wallets yet'), findsOneWidget);
  });

  testWidgets('Add new wallet', (tester) async {
    app.runWithConfig();
    await tester.pumpAndSettle();

    final addWalletButton = find.widgetWithText(VUIButton, 'Add Wallet');
    expect(addWalletButton, findsOneWidget);

    // Tap the button
    await tester.tap(addWalletButton);
    await tester.pumpAndSettle(); // wait for navigation or UI changes

    expect(find.text('Add Wallet'), findsOneWidget);
  });
}
