import 'package:shared_preferences/shared_preferences.dart';

import 'auth_provider.dart';
import 'form_provider.dart';

class LoginProvider extends FormProvider {
  LoginProvider(this._authProvider);

  static const _rememberedIdentifierKey = 'remembered_identifier';

  final AuthProvider _authProvider;

  bool _rememberMe = false;

  bool get rememberMe => _rememberMe;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Returns the saved email or mobile number, if there is one. The password
  /// is never saved.
  Future<String?> loadRememberedIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    final identifier = prefs.getString(_rememberedIdentifierKey);
    if (identifier != null) setRememberMe(true);
    return identifier;
  }

  Future<bool> login({required String identifier, required String password}) {
    return submit(() async {
      final response = await _authProvider.login(
        identifier: identifier,
        password: password,
      );
      await _saveRememberedIdentifier(identifier);
      return response.message;
    });
  }

  Future<void> _saveRememberedIdentifier(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(_rememberedIdentifierKey, identifier);
    } else {
      await prefs.remove(_rememberedIdentifierKey);
    }
  }
}
