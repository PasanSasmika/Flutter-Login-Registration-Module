import 'package:flutter/foundation.dart';

import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// App-wide session state: who is signed in. Each screen's own form state
/// lives in its provider (see [FormProvider]).
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null;

  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _authService.login(
      identifier: identifier,
      password: password,
    );
    _user = response.user;
    _token = response.token;
    notifyListeners();
    return response;
  }

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) {
    return _authService.register(
      fullName: fullName,
      email: email,
      mobile: mobile,
      password: password,
    );
  }

  Future<AuthResponseModel> forgotPassword(String email) {
    return _authService.forgotPassword(email: email);
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
