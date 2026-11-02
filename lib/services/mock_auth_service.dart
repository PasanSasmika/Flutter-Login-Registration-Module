import '../core/exceptions/app_exception.dart';
import '../core/validators/validators.dart';
import '../models/auth_response_model.dart';
import 'auth_service.dart';

/// In-memory stand-in for a backend. Registered accounts last until the app
/// restarts. Passwords are stored as plain text because this is demo data.
class MockAuthService implements AuthService {
  MockAuthService({this.delay = const Duration(milliseconds: 1200)});

  /// Entering this email anywhere simulates having no connection.
  static const networkErrorEmail = 'network@example.com';

  /// Entering this email anywhere simulates a bug or server crash.
  static const unexpectedErrorEmail = 'crash@example.com';

  final Duration delay;

  final List<Map<String, String>> _accounts = [
    {
      'id': '1',
      'fullName': 'Demo User',
      'email': 'demo@example.com',
      'mobile': '0771234567',
      'password': 'Demo@1234',
    },
  ];

  @override
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    await _simulateRequest(identifier);

    final account = _findAccount(identifier);
    if (account == null || account['password'] != password) {
      throw const InvalidCredentialsException();
    }
    return _authResponse(account, 'Welcome back, ${account['fullName']}!');
  }

  @override
  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    await _simulateRequest(email);

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedMobile = Validators.normalizeMobile(mobile);

    final fieldErrors = <String, String>{};
    if (_accounts.any((a) => a['email'] == normalizedEmail)) {
      fieldErrors['email'] = 'This email is already registered';
    }
    if (_accounts.any((a) => a['mobile'] == normalizedMobile)) {
      fieldErrors['mobile'] = 'This mobile number is already registered';
    }
    if (fieldErrors.isNotEmpty) throw ValidationException(fieldErrors);

    final account = {
      'id': '${_accounts.length + 1}',
      'fullName': fullName.trim(),
      'email': normalizedEmail,
      'mobile': normalizedMobile,
      'password': password,
    };
    _accounts.add(account);
    return _authResponse(account, 'Account created. Please sign in.');
  }

  @override
  Future<AuthResponseModel> forgotPassword({required String email}) async {
    await _simulateRequest(email);

    // The reply is the same whether or not the account exists, so this form
    // can't be used to find out who has registered.
    return AuthResponseModel.fromJson({
      'message': 'If an account exists, a reset link has been sent.',
    });
  }

  Future<void> _simulateRequest(String input) async {
    await Future<void>.delayed(delay);

    final email = input.trim().toLowerCase();
    if (email == networkErrorEmail) throw const NetworkException();
    if (email == unexpectedErrorEmail) {
      throw StateError('Simulated server failure');
    }
  }

  Map<String, String>? _findAccount(String identifier) {
    final email = identifier.trim().toLowerCase();
    final mobile = Validators.normalizeMobile(identifier);
    for (final account in _accounts) {
      if (account['email'] == email || account['mobile'] == mobile) {
        return account;
      }
    }
    return null;
  }

  AuthResponseModel _authResponse(
    Map<String, String> account,
    String message,
  ) {
    return AuthResponseModel.fromJson({
      'message': message,
      'token': 'mock-token-${account['id']}',
      'user': {
        'id': account['id'],
        'fullName': account['fullName'],
        'email': account['email'],
        'mobile': account['mobile'],
      },
    });
  }
}
