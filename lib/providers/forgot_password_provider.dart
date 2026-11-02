import 'auth_provider.dart';
import 'form_provider.dart';

class ForgotPasswordProvider extends FormProvider {
  ForgotPasswordProvider(this._authProvider);

  final AuthProvider _authProvider;

  Future<bool> sendResetLink(String email) {
    return submit(() async {
      final response = await _authProvider.forgotPassword(email);
      return response.message;
    });
  }
}
