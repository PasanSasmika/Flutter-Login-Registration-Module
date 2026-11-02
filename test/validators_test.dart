import 'package:flutter_login_registration/core/validators/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    test('accepts valid addresses', () {
      for (final email in [
        'demo@example.com',
        'first.last+tag@mail.example.co.uk',
        '  spaced@example.com  ',
      ]) {
        expect(Validators.email(email), isNull, reason: email);
      }
    });

    test('rejects invalid addresses', () {
      expect(Validators.email(''), 'Email is required');
      for (final email in ['plain', 'a@b', '@example.com', 'a b@example.com']) {
        expect(
          Validators.email(email),
          'Enter a valid email address',
          reason: email,
        );
      }
    });
  });

  group('mobile', () {
    test('accepts local, international and formatted numbers', () {
      for (final mobile in ['0771234567', '+94771234567', '077 123-4567']) {
        expect(Validators.mobile(mobile), isNull, reason: mobile);
      }
    });

    test('rejects invalid numbers', () {
      expect(Validators.mobile(''), 'Mobile number is required');
      for (final mobile in ['12345', '1234567890123456', '07712x4567']) {
        expect(
          Validators.mobile(mobile),
          'Enter a valid mobile number',
          reason: mobile,
        );
      }
    });
  });

  group('emailOrMobile', () {
    test('requires a value', () {
      expect(
        Validators.emailOrMobile('  '),
        'Email or mobile number is required',
      );
    });

    test('checks the format that matches the input', () {
      expect(Validators.emailOrMobile('demo@example.com'), isNull);
      expect(Validators.emailOrMobile('0771234567'), isNull);
      expect(Validators.emailOrMobile('demo@'), 'Enter a valid email address');
      expect(Validators.emailOrMobile('12345'), 'Enter a valid mobile number');
    });
  });

  test('fullName requires a minimum length', () {
    expect(Validators.fullName(' '), 'Full name is required');
    expect(Validators.fullName('Al'), 'Name must be at least 3 characters');
    expect(Validators.fullName('Ann'), isNull);
  });

  test('newPassword enforces each rule', () {
    expect(Validators.newPassword(''), 'Password is required');
    expect(
      Validators.newPassword('Ab1!'),
      'Password must be at least 8 characters',
    );
    expect(
      Validators.newPassword('abcdefg1!'),
      'Include at least one uppercase letter',
    );
    expect(
      Validators.newPassword('ABCDEFG1!'),
      'Include at least one lowercase letter',
    );
    expect(Validators.newPassword('Abcdefgh!'), 'Include at least one number');
    expect(
      Validators.newPassword('Abcdefg12'),
      'Include at least one special character',
    );
    expect(Validators.newPassword('Abcdefg1!'), isNull);
  });

  test('confirmPassword must match', () {
    expect(
      Validators.confirmPassword('', 'Secret@123'),
      'Please confirm your password',
    );
    expect(
      Validators.confirmPassword('Other@123', 'Secret@123'),
      'Passwords do not match',
    );
    expect(Validators.confirmPassword('Secret@123', 'Secret@123'), isNull);
  });
}
