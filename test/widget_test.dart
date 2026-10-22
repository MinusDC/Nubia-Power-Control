import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_control/screens/home_screen.dart';
import 'package:power_control/services/power_control_service.dart';
import 'package:power_control/widgets/accessibility_status_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(PowerControlService.channelName);

  Future<void> pumpHome(
    WidgetTester tester, {
    required Future<Object?> Function(MethodCall call) handler,
  }) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          powerControlService: PowerControlService(channel: channel),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows both actions and guidance while accessibility is off', (
    tester,
  ) async {
    await pumpHome(tester, handler: (_) async => false);

    expect(find.text('Shutdown'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Accessibility disabled'), findsOneWidget);
    expect(find.textContaining('Bật dịch vụ Trợ năng'), findsOneWidget);

    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    expect(find.text('Cần bật quyền Trợ năng'), findsOneWidget);
    expect(find.text('Bật quyền Trợ năng'), findsOneWidget);
  });

  testWidgets('opens power menu and clearly leaves selection to user', (
    tester,
  ) async {
    var powerMenuCalls = 0;
    await pumpHome(
      tester,
      handler: (call) async {
        if (call.method == 'isAccessibilityServiceEnabled') return true;
        if (call.method == 'openPowerMenu') {
          powerMenuCalls++;
          return true;
        }
        return true;
      },
    );

    expect(find.text('Accessibility enabled'), findsOneWidget);
    await tester.tap(find.text('Shutdown'));
    await tester.pumpAndSettle();

    expect(powerMenuCalls, 1);
    expect(
      find.text('Menu nguồn đã mở. Hãy tự chọn “Power off” trên điện thoại.'),
      findsOneWidget,
    );
  });

  testWidgets('refreshes accessibility state after returning from settings', (
    tester,
  ) async {
    var accessibilityEnabled = false;
    var settingsCalls = 0;
    await pumpHome(
      tester,
      handler: (call) async {
        if (call.method == 'isAccessibilityServiceEnabled') {
          return accessibilityEnabled;
        }
        if (call.method == 'openAccessibilitySettings') {
          settingsCalls++;
          return true;
        }
        return true;
      },
    );

    await tester.tap(find.text('Shutdown'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bật quyền Trợ năng'));
    await tester.pumpAndSettle();
    expect(settingsCalls, 1);

    accessibilityEnabled = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Accessibility enabled'), findsOneWidget);
  });

  testWidgets('does not send duplicate requests while an action is pending', (
    tester,
  ) async {
    final response = Completer<Object?>();
    var powerMenuCalls = 0;
    await pumpHome(
      tester,
      handler: (call) async {
        if (call.method == 'isAccessibilityServiceEnabled') return true;
        if (call.method == 'openPowerMenu') {
          powerMenuCalls++;
          return response.future;
        }
        return true;
      },
    );

    await tester.tap(find.text('Restart'));
    await tester.pump();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();

    expect(powerMenuCalls, 1);
    expect(find.text('Đang xử lý...'), findsNWidgets(2));

    response.complete(true);
    await tester.pumpAndSettle();
  });

  testWidgets('displays native errors without crashing', (tester) async {
    await pumpHome(
      tester,
      handler: (call) async {
        if (call.method == 'isAccessibilityServiceEnabled') return true;
        if (call.method == 'openPowerMenu') {
          throw PlatformException(code: 'service_unavailable');
        }
        return true;
      },
    );

    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Dịch vụ Trợ năng chưa kết nối. Hãy kiểm tra quyền rồi thử lại.',
      ),
      findsNWidgets(2),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets(
    'marks accessibility unavailable when native status check fails',
    (tester) async {
      await pumpHome(
        tester,
        handler: (_) async => throw PlatformException(code: 'status_error'),
      );

      expect(find.text('Accessibility status unavailable'), findsOneWidget);
      expect(find.byType(AccessibilityStatusCard), findsOneWidget);
    },
  );
}
