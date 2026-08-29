/// Typed application exceptions so the UI can show meaningful,
/// localized error states.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Localization key describing the failure.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'error_no_internet']);
}

class FirebaseDataException extends AppException {
  const FirebaseDataException([super.message = 'error_generic']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'error_auth']);
}

class PaymentException extends AppException {
  const PaymentException([super.message = 'error_payment']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
