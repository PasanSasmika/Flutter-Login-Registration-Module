import 'user_model.dart';

/// The body of a successful auth request. Failures are thrown as
/// `AppException`s instead, so callers only handle this on success.
class AuthResponseModel {
  const AuthResponseModel({required this.message, this.user, this.token});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return AuthResponseModel(
      message: json['message'] as String,
      user: user == null ? null : UserModel.fromJson(user),
      token: json['token'] as String?,
    );
  }

  final String message;
  final UserModel? user;
  final String? token;
}
