import '../models/auth_response_model.dart';

/// The contract the app uses to talk to the backend.
///
/// To use a real API, implement this class and pass it to `App` in `main.dart`.
/// Nothing else needs to change as long as failures are thrown as
/// `AppException`s.
abstract class AuthService {
  /// [identifier] is an email address or mobile number.
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  });

  Future<AuthResponseModel> forgotPassword({required String email});
}
