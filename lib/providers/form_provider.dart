import 'package:flutter/foundation.dart';

import '../core/exceptions/app_exception.dart';

/// Loading, success and error handling shared by the login, register and
/// forgot password forms.
abstract class FormProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, String> _fieldErrors = {};
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Server errors for one field, e.g. `fieldError('email')`.
  String? fieldError(String field) => _fieldErrors[field];
  bool get hasFieldErrors => _fieldErrors.isNotEmpty;

  /// Removes a server error once the user starts correcting the field.
  void clearFieldError(String field) {
    if (_fieldErrors.remove(field) != null) notifyListeners();
  }

  /// Runs [request] and returns true if it succeeded. A call made while
  /// another is in progress is ignored, which prevents duplicate submissions.
  @protected
  Future<bool> submit(Future<String> Function() request) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = {};
    notifyListeners();

    var succeeded = false;
    try {
      _successMessage = await request();
      succeeded = true;
    } on ValidationException catch (e) {
      _fieldErrors = Map.of(e.fieldErrors);
      _errorMessage = e.message;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e\n$stackTrace');
      _errorMessage = 'Something went wrong. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return succeeded;
  }

  // The user can leave a screen while its request is still running.
  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
