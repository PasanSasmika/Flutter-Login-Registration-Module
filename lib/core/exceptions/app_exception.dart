/// Failures the service layer reports. Anything else is treated as unexpected.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Wrong email/mobile or password.
class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException()
    : super('Incorrect email/mobile number or password.');
}

/// The server rejected specific fields, e.g. an email already in use.
/// Keys are field names: `email`, `mobile`.
class ValidationException extends AppException {
  const ValidationException(this.fieldErrors)
    : super('Please check the highlighted fields.');

  final Map<String, String> fieldErrors;
}

/// The request never reached the server, or timed out.
class NetworkException extends AppException {
  const NetworkException()
    : super('Unable to connect. Check your internet connection and try again.');
}
