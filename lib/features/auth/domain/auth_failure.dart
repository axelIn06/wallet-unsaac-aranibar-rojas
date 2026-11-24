enum AuthFailureReason {
  invalidCredentials('Correo o contraseña incorrectos.'),
  invalidEmail('Ingresa un correo válido.'),
  emailInUse('El correo ya está registrado.'),
  weakPassword('Usa al menos 6 caracteres.'),
  disabled('La cuenta está deshabilitada.'),
  network('Revisa tu conexión e inténtalo de nuevo.'),
  limited('Demasiados intentos. Inténtalo más tarde.'),
  provider('El proveedor de acceso no está habilitado.'),
  invalidName('Escribe un nombre para mostrar.'),
  unknown('No se pudo completar la operación.');

  const AuthFailureReason(this.message);
  final String message;
}

class AuthException implements Exception {
  const AuthException(this.reason);
  final AuthFailureReason reason;
}
