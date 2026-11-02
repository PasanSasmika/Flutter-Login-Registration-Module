import 'auth_provider.dart';
import 'form_provider.dart';

class RegisterProvider extends FormProvider {
  RegisterProvider(this._authProvider);

  final AuthProvider _authProvider;

  Future<bool> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) {
    return submit(() async {
      final response = await _authProvider.register(
        fullName: fullName,
        email: email,
        mobile: mobile,
        password: password,
      );
      return response.message;
    });
  }
}
