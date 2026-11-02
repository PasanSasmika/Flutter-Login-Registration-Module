import 'package:flutter/material.dart';
import 'package:flutter_login_registration/app.dart';
import 'package:flutter_login_registration/models/auth_response_model.dart';
import 'package:flutter_login_registration/services/mock_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Counts calls so tests can prove a double tap sends one request.
class CountingAuthService extends MockAuthService {
  CountingAuthService() : super(delay: const Duration(milliseconds: 200));

  int loginCalls = 0;

  @override
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) {
    loginCalls++;
    return super.login(identifier: identifier, password: password);
  }
}

const demoEmail = 'demo@example.com';
const demoPassword = 'Demo@1234';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpApp(WidgetTester tester, {MockAuthService? service}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      App(
        authService:
            service ??
            MockAuthService(delay: const Duration(milliseconds: 100)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(int index) => find.byType(TextFormField).at(index);

  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.widgetWithText(FilledButton, label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> tapLink(WidgetTester tester, String label) async {
    final link = find.widgetWithText(TextButton, label);
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();
  }

  Future<void> enterLogin(
    WidgetTester tester,
    String identifier,
    String password,
  ) async {
    await tester.enterText(field(0), identifier);
    await tester.enterText(field(1), password);
  }

  Future<void> fillRegistration(
    WidgetTester tester, {
    String name = 'New User',
    String email = 'new@example.com',
    String mobile = '0712345678',
    String password = 'Secret@123',
    String? confirm,
  }) async {
    await tester.enterText(field(0), name);
    await tester.enterText(field(1), email);
    await tester.enterText(field(2), mobile);
    await tester.enterText(field(3), password);
    await tester.enterText(field(4), confirm ?? password);
  }

  group('login', () {
    testWidgets('empty form shows required errors', (tester) async {
      await pumpApp(tester);
      await tapButton(tester, 'Sign in');

      expect(find.text('Email or mobile number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('invalid email and mobile show format errors', (tester) async {
      await pumpApp(tester);

      await enterLogin(tester, 'demo@', 'x');
      await tapButton(tester, 'Sign in');
      expect(find.text('Enter a valid email address'), findsOneWidget);

      await tester.enterText(field(0), '12345');
      await tester.pump();
      expect(find.text('Enter a valid mobile number'), findsOneWidget);
    });

    testWidgets('errors clear as the user fixes them', (tester) async {
      await pumpApp(tester);
      await tapButton(tester, 'Sign in');

      await tester.enterText(field(0), demoEmail);
      await tester.pump();
      expect(find.text('Email or mobile number is required'), findsNothing);
    });

    testWidgets('wrong password shows an error and stays', (tester) async {
      await pumpApp(tester);
      await enterLogin(tester, demoEmail, 'wrong-password');
      await tapButton(tester, 'Sign in');

      expect(
        find.text('Incorrect email/mobile number or password.'),
        findsOneWidget,
      );
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('valid login shows loading, opens home, then logs out', (
      tester,
    ) async {
      await pumpApp(tester);
      await enterLogin(tester, demoEmail, demoPassword);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Hello, Demo'), findsOneWidget);
      expect(find.text('Welcome back, Demo User!'), findsOneWidget);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('mobile number can be used to log in', (tester) async {
      await pumpApp(tester);
      await enterLogin(tester, '0771234567', demoPassword);
      await tapButton(tester, 'Sign in');

      expect(find.text('Hello, Demo'), findsOneWidget);
    });

    testWidgets('tapping twice sends one request', (tester) async {
      final service = CountingAuthService();
      await pumpApp(tester, service: service);
      await enterLogin(tester, demoEmail, demoPassword);

      final button = find.byType(FilledButton);
      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.tap(button, warnIfMissed: false);
      // Submitting from the keyboard must not get past the guard either.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(service.loginCalls, 1);
    });

    testWidgets('network and unexpected errors show friendly messages', (
      tester,
    ) async {
      await pumpApp(tester);

      await enterLogin(tester, MockAuthService.networkErrorEmail, 'x');
      await tapButton(tester, 'Sign in');
      expect(
        find.text(
          'Unable to connect. Check your internet connection and try again.',
        ),
        findsOneWidget,
      );

      await enterLogin(tester, MockAuthService.unexpectedErrorEmail, 'x');
      await tapButton(tester, 'Sign in');
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );

      // The form still works after a failure.
      await enterLogin(tester, demoEmail, demoPassword);
      await tapButton(tester, 'Sign in');
      expect(find.text('Hello, Demo'), findsOneWidget);
    });

    testWidgets('password visibility can be toggled', (tester) async {
      await pumpApp(tester);
      bool isObscured() => tester
          .widget<EditableText>(
            find.descendant(of: field(1), matching: find.byType(EditableText)),
          )
          .obscureText;

      expect(isObscured(), isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(isObscured(), isFalse);
      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();
      expect(isObscured(), isTrue);
    });

    testWidgets('remember me restores the identifier, not the password', (
      tester,
    ) async {
      await pumpApp(tester);
      await enterLogin(tester, demoEmail, demoPassword);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapButton(tester, 'Sign in');
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), {'remembered_identifier'});
      expect(prefs.getString('remembered_identifier'), demoEmail);
      expect(find.text(demoEmail), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

      // Signing in with the box unticked forgets the saved value.
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.enterText(field(1), demoPassword);
      await tapButton(tester, 'Sign in');
      expect(prefs.getString('remembered_identifier'), isNull);
    });
  });

  group('registration', () {
    Future<void> openRegister(WidgetTester tester) async {
      await pumpApp(tester);
      await tapLink(tester, 'Create account');
    }

    testWidgets('links go there and back', (tester) async {
      await openRegister(tester);
      expect(find.text('Fill in your details to get started.'), findsOneWidget);

      await tapLink(tester, 'Sign in');
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('empty form shows an error on every field', (tester) async {
      await openRegister(tester);
      await tapButton(tester, 'Create account');

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Mobile number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('invalid values show field errors', (tester) async {
      await openRegister(tester);
      await fillRegistration(
        tester,
        name: 'Al',
        email: 'bad-email',
        mobile: '123',
        password: 'weak',
        confirm: 'different',
      );
      await tapButton(tester, 'Create account');

      expect(find.text('Name must be at least 3 characters'), findsOneWidget);
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Enter a valid mobile number'), findsOneWidget);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('mismatch clears when the passwords are made equal', (
      tester,
    ) async {
      await openRegister(tester);
      await fillRegistration(tester, confirm: 'Other@123');
      await tapButton(tester, 'Create account');
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.enterText(field(3), 'Other@123');
      await tester.pump();
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('duplicates show on their fields until edited', (tester) async {
      await openRegister(tester);
      await fillRegistration(tester, email: demoEmail, mobile: '0771234567');
      await tapButton(tester, 'Create account');

      expect(find.text('This email is already registered'), findsOneWidget);
      expect(
        find.text('This mobile number is already registered'),
        findsOneWidget,
      );

      await tester.enterText(field(1), 'fresh@example.com');
      await tester.pumpAndSettle();
      expect(find.text('This email is already registered'), findsNothing);

      await tester.enterText(field(2), '0719998888');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create account');
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('success returns to login, where the account works', (
      tester,
    ) async {
      await openRegister(tester);
      await fillRegistration(tester);
      await tapButton(tester, 'Create account');

      expect(find.text('Account created. Please sign in.'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('new@example.com'), findsOneWidget);

      await tester.enterText(field(1), 'Secret@123');
      await tapButton(tester, 'Sign in');
      expect(find.text('Hello, New'), findsOneWidget);
    });

    testWidgets('back is blocked until the request finishes', (tester) async {
      await openRegister(tester);
      await fillRegistration(tester);
      final button = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 20));

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      expect(find.text('Fill in your details to get started.'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Account created. Please sign in.'), findsOneWidget);
    });
  });

  group('forgot password', () {
    Future<void> openForgotPassword(WidgetTester tester) async {
      await pumpApp(tester);
      await tapLink(tester, 'Forgot password?');
    }

    testWidgets('validates the email', (tester) async {
      await openForgotPassword(tester);
      await tapButton(tester, 'Send reset link');
      expect(find.text('Email is required'), findsOneWidget);

      await tester.enterText(field(0), 'bad');
      await tester.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('confirms the request and returns to login', (tester) async {
      await openForgotPassword(tester);
      await tester.enterText(field(0), demoEmail);
      await tapButton(tester, 'Send reset link');

      expect(
        find.text('If an account exists, a reset link has been sent.'),
        findsOneWidget,
      );

      await tapButton(tester, 'Back to sign in');
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('leaving mid-request does not crash', (tester) async {
      await openForgotPassword(tester);
      await tester.enterText(field(0), demoEmail);
      await tester.tap(find.widgetWithText(FilledButton, 'Send reset link'));
      await tester.pump(const Duration(milliseconds: 20));

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows network errors and keeps the form', (tester) async {
      await openForgotPassword(tester);
      await tester.enterText(field(0), MockAuthService.networkErrorEmail);
      await tapButton(tester, 'Send reset link');

      expect(find.textContaining('Unable to connect'), findsOneWidget);
      expect(find.text('Send reset link'), findsOneWidget);
    });
  });

  group('layout', () {
    const screens = {
      'small phone': Size(320, 568),
      'medium phone': Size(360, 640),
      'large phone': Size(412, 915),
      'tablet': Size(768, 1024),
      'landscape phone': Size(740, 360),
    };

    for (final MapEntry(key: name, value: size) in screens.entries) {
      testWidgets('no overflow on $name with keyboard and large text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        await tester.pumpWidget(
          App(authService: MockAuthService(delay: Duration.zero)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Validation errors make the forms taller, so check that state too.
        await tapButton(tester, 'Sign in');
        expect(tester.takeException(), isNull);

        await tapLink(tester, 'Create account');
        await tapButton(tester, 'Create account');
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tapLink(tester, 'Forgot password?');
        await tapButton(tester, 'Send reset link');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('form width is limited on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        App(authService: MockAuthService(delay: Duration.zero)),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(FilledButton)).width,
        lessThanOrEqualTo(440),
      );
    });
  });
}
