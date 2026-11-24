import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/auth/presentation/auth_form.dart';
import 'package:wallet_unsaac/features/auth/domain/auth_failure.dart';
import 'package:wallet_unsaac/features/auth/data/firebase_auth_repository.dart';

void main() {
  test('Correo vacío o sin dominio válido se rechaza', () {
    for (final email in ['', 'alumna', 'a@', 'a@b']) {
      expect(AuthValidators.email(email), isNotNull);
    }
    expect(AuthValidators.email(' a@example.test '), isNull);
  });
  test('Mínimo de seis caracteres y confirmación exacta', () {
    expect(AuthValidators.password('12345'), isNotNull);
    expect(AuthValidators.password('123456'), isNull);
    expect(AuthValidators.confirmation('123456', '123456'), isNull);
    expect(AuthValidators.confirmation('123457', '123456'), isNotNull);
  });
  for (final entry in {
    'wrong-password': AuthFailureReason.invalidCredentials,
    'user-not-found': AuthFailureReason.invalidCredentials,
    'invalid-credential': AuthFailureReason.invalidCredentials,
    'invalid-email': AuthFailureReason.invalidEmail,
    'email-already-in-use': AuthFailureReason.emailInUse,
    'weak-password': AuthFailureReason.weakPassword,
    'user-disabled': AuthFailureReason.disabled,
    'too-many-requests': AuthFailureReason.limited,
    'network-request-failed': AuthFailureReason.network,
    'operation-not-allowed': AuthFailureReason.provider,
    'unexpected-code': AuthFailureReason.unknown,
  }.entries) {
    test('Traduce ${entry.key}', () {
      expect(mapAuthCode(entry.key), entry.value);
    });
  }
}
