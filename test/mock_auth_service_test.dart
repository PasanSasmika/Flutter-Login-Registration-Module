import 'package:flutter_login_registration/core/exceptions/app_exception.dart';
import 'package:flutter_login_registration/services/mock_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAuthService service;

  setUp(() => service = MockAuthService(delay: Duration.zero));

  Future<void> registerUser({
    String email = 'new@example.com',
    String mobile = '0712345678',
  }) {
    return service.register(
      fullName: 'New User',
      email: email,
      mobile: mobile,
      password: 'Secret@123',
    );
  }

  group('login', () {
    test('succeeds with email, ignoring case', () async {
      final response = await service.login(
        identifier: 'Demo@Example.com',
        password: 'Demo@1234',
      );
      expect(response.user?.fullName, 'Demo User');
      expect(response.token, isNotNull);
    });

    test('succeeds with a formatted mobile number', () async {
      final response = await service.login(
        identifier: '077 123 4567',
        password: 'Demo@1234',
      );
      expect(response.user?.email, 'demo@example.com');
    });

    test('rejects a wrong password and an unknown user', () async {
      await expectLater(
        service.login(identifier: 'demo@example.com', password: 'wrong'),
        throwsA(isA<InvalidCredentialsException>()),
      );
      await expectLater(
        service.login(identifier: 'nobody@example.com', password: 'Demo@1234'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  group('register', () {
    test('new accounts can log in', () async {
      await registerUser();
      final response = await service.login(
        identifier: 'new@example.com',
        password: 'Secret@123',
      );
      expect(response.user?.fullName, 'New User');
    });

    test('reports a duplicate email', () async {
      await expectLater(
        registerUser(email: 'DEMO@example.com'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.fieldErrors.keys,
            'fields',
            ['email'],
          ),
        ),
      );
    });

    test('reports a duplicate mobile number', () async {
      await expectLater(
        registerUser(mobile: '077-123-4567'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.fieldErrors.keys,
            'fields',
            ['mobile'],
          ),
        ),
      );
    });

    test('reports both duplicates together', () async {
      await expectLater(
        registerUser(email: 'demo@example.com', mobile: '0771234567'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.fieldErrors.keys,
            'fields',
            unorderedEquals(['email', 'mobile']),
          ),
        ),
      );
    });
  });

  test('forgotPassword replies the same for unknown accounts', () async {
    final known = await service.forgotPassword(email: 'demo@example.com');
    final unknown = await service.forgotPassword(email: 'nobody@example.com');
    expect(known.message, unknown.message);
  });

  test('special emails simulate failures', () async {
    await expectLater(
      service.login(
        identifier: MockAuthService.networkErrorEmail,
        password: 'x',
      ),
      throwsA(isA<NetworkException>()),
    );
    await expectLater(
      service.forgotPassword(email: MockAuthService.unexpectedErrorEmail),
      throwsStateError,
    );
  });

  test('simulates a response delay', () async {
    final slowService = MockAuthService(
      delay: const Duration(milliseconds: 50),
    );
    final stopwatch = Stopwatch()..start();
    await slowService.forgotPassword(email: 'demo@example.com');
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(45));
  });
}
