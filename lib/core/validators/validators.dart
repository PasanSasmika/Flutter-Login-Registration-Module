/// Form validators. Each returns an error message, or null when valid, so they
/// can be passed straight to a [TextFormField].
class Validators {
  const Validators._();

  static const minNameLength = 3;
  static const minPasswordLength = 8;

  static final _emailPattern = RegExp(
    r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
  );

  // Optional leading +, then 9 to 15 digits (the E.164 maximum).
  static final _mobilePattern = RegExp(r'^\+?[0-9]{9,15}$');

  /// Removes the spaces, dashes and brackets people type in phone numbers.
  static String normalizeMobile(String value) {
    return value.replaceAll(RegExp(r'[\s\-()]'), '');
  }

  /// Treats the input as an email unless it looks like a phone number, so the
  /// user sees the error message that matches what they were typing.
  static bool looksLikeMobile(String value) {
    return RegExp(r'^[\d\s\-()+]+$').hasMatch(value.trim());
  }

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Full name is required';
    if (name.length < minNameLength) {
      return 'Name must be at least $minNameLength characters';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  static String? mobile(String? value) {
    final mobile = normalizeMobile(value ?? '');
    if (mobile.isEmpty) return 'Mobile number is required';
    if (!_mobilePattern.hasMatch(mobile)) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  static String? emailOrMobile(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email or mobile number is required';
    return looksLikeMobile(input) ? mobile(input) : email(input);
  }

  /// Used on login, where we only check the password is present. Strength
  /// rules belong to registration.
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Include at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Include at least one number';
    }
    if (!password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Include at least one special character';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
