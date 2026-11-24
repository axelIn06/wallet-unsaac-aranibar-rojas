# Wallet UNSAAC · Sesión 3

**Avance de D2.** Registro, acceso, cierre y restauración de sesión con Firebase Authentication, más recuperación de contraseña, edición del nombre y expiración. La billetera conserva las funciones de la sesión 2. Autor del entregable: Axel Barnaby Aranibar Rojas, código 220547. [Informe de la sesión 3 y capturas](informe/sesion-03/).

## Ejecutar en Android Studio

Abrir la carpeta que contiene este README y arrancar un AVD Android. El equipo de verificación utilizó Flutter 3.41.6, Dart 3.11.4 y Medium Phone API 36.1. El archivo de bloqueo fija firebase_auth 7.0.1 y firebase_core 5.1.0. Desde la terminal del proyecto:

```sh
flutter pub get
flutter analyze
flutter test
flutter devices
```

### Con el SDK y Firebase Authentication Emulator

Este es el entorno utilizado para las evidencias en Android. Instalar la CLI oficial con `npm install -g firebase-tools` si aún no está disponible. Abrir dos terminales en la raíz del proyecto:

```sh
# Terminal 1
firebase emulators:start --only auth --project demo-wallet-unsaac
```

```sh
# Terminal 2, con el AVD en ejecución
flutter run -d emulator-5554 --dart-define=AUTH_EMULATOR=true
```

Crear una cuenta ficticia desde **Registrarme**. El servidor de pruebas queda en el puerto 9099 de la máquina y el SDK de Android accede mediante 10.0.2.2. La excepción de tráfico HTTP se limita a esa dirección y a compilaciones de depuración. La modalidad emulada utiliza el proveedor de correo/contraseña del SDK; las solicitudes de recuperación quedan en el emulador. Para comprobar la persistencia, mantener el servidor encendido, cerrar el proceso Android y abrir la app desde el lanzador. El SDK restaura el usuario. Reiniciar el servidor sin exportar sus datos elimina las cuentas de prueba.

### Demostración solo en memoria

`flutter run` con la plantilla de opciones vacía abre el modo de práctica. Se puede registrar una cuenta temporal o usar la cuenta **ficticia pública de la guía**, `estudiante@unsaac.edu.pe` / `wallet123`. Las cuentas y la sesión desaparecen al terminar el proceso; la recuperación devuelve el mensaje genérico. Los datos introducidos no se escriben en disco. Usar únicamente datos de demostración en esta modalidad.

### Con un proyecto personal de Firebase

1. Iniciar sesión en Firebase CLI con `firebase login`. Identificar el proyecto del curso con `firebase projects:list`.
2. En Firebase Console → Authentication → Sign-in method, habilitar **Correo electrónico/contraseña** y guardar. El repositorio incluye la configuración del emulador. La habilitación en un proyecto personal queda a cargo de su titular.
3. Ejecutar `dart pub global activate flutterfire_cli` y luego `dart pub global run flutterfire_cli:flutterfire configure --project=ID_DEL_PROYECTO --platforms=android`. Verificar el paquete `pe.edu.unsaac.wallet_unsaac`. Las opciones de FlutterFire se generan localmente en `lib/firebase_options.dart`.
4. Ejecutar `flutter run` sin la variable del emulador. Registrar una cuenta de prueba y verificarla en **Authentication → Users**. La aplicación solo muestra «Práctica en memoria» cuando usa el repositorio local.
5. Conservar la plantilla pública en el repositorio. Revisar el diff antes de publicar opciones de un proyecto personal. Los archivos de servicio, claves de firma y google-services.json están excluidos.

[Documentación oficial de FlutterFire](https://firebase.google.com/docs/flutter/setup) · [Authentication en Flutter](https://firebase.google.com/docs/auth/flutter/start).

## Flujo de sesión

| Capa | Responsabilidad |
|---|---|
| `lib/features/auth/domain/` | AuthUser con igualdad por valor, contrato AuthRepository, motivos y mensajes de error |
| `lib/features/auth/data/` | Adaptador de Firebase y repositorio de simulación; traducción de errores |
| `lib/features/auth/presentation/` | AuthBloc, estados y eventos, AuthGate, formulario compartido, validadores y menú de cuenta |
| `lib/app.dart` | Inyección de repositorios y creación de una billetera en memoria por sesión autenticada |
| `lib/main.dart` | Selección de SDK emulado, SDK con opciones reales o simulación local |

AuthStarted escucha authStateChanges, incluida la emisión inicial. AuthGate mantiene el formulario mientras una operación espera respuesta. El botón se deshabilita durante el envío. Al recibir una identidad, la app monta la billetera. La confirmación «Salir» provoca el cierre voluntario. Al volver del segundo plano, se recarga el usuario del SDK. Una identidad inválida o deshabilitada sale de la billetera. Un error de red conserva al usuario y muestra el motivo.

**Reto 1.** Recuperar utiliza la misma confirmación para direcciones existentes y ausentes. Firebase gestiona el envío. Un fallo operativo de red permite reintentar.
**Reto 2.** El nombre se recorta y se rechaza si queda vacío. La cuenta conserva su UID y correo. El encabezado usa el nombre y una inicial.
**Reto 3.** Se distingue el cierre solicitado de la pérdida externa de la sesión. El aviso por expiración incluye «Volver a iniciar sesión». El SDK administra los tokens. Los estados de presentación contienen únicamente la identidad y un mensaje opcional.

## Mensajes por código del SDK

| Código | Respuesta de la aplicación |
|---|---|
| wrong-password, invalid-credential, invalid-login-credentials, user-not-found en acceso | Correo o contraseña incorrectos. |
| invalid-email | Ingresa un correo válido. |
| weak-password | Usa al menos 6 caracteres. |
| email-already-in-use al registrar | El correo ya está registrado. |
| user-disabled en acceso | La cuenta está deshabilitada. |
| network-request-failed | Revisa tu conexión e inténtalo de nuevo. |
| too-many-requests | Demasiados intentos. Inténtalo más tarde. |
| operation-not-allowed | El proveedor de acceso no está habilitado. |
| Otros códigos | No se pudo completar la operación. |

## Pruebas y lista de verificación de D2 parcial

| Grupo | Evidencia |
|---|---|
| 17 pruebas de AuthBloc | Estado inicial, restauración, registro, acceso, credenciales inválidas, recuperación, nombre, cierre normal/fallido, expiración y reanudación sin red |
| 13 de validación y traducción | Formato, mínimo de seis caracteres, confirmación, códigos conocidos y desconocidos |
| 5 de widgets de autenticación | Formularios, errores, registro, acceso, recuperación y acción tras expiración |
| 36 heredadas | Billetera, movimientos, filtros, tema y privacidad, con usuario inyectado en las pruebas de interfaz |

- [x] Registro, acceso y cierre con el SDK de Android y Authentication Emulator.
- [x] Persistencia después del cierre completo del proceso Android.
- [x] AuthGate muestra la pantalla apropiada y los errores están traducidos.
- [x] Tres retos implementados con pruebas y capturas.
- [x] Análisis sin observaciones y 71 pruebas aprobadas.
- [x] README con configuración y sin credenciales privadas versionadas.
- [ ] Activación y prueba en un proyecto de Firebase Console del estudiante, si se requiere validar en la nube.

[Resultados de la sesión 3](evidencias/sesion-03/) · [Informe anterior D1](informe/D1_AranibarRojas_AxelBarnaby_IF616BIN.pdf). La navegación con GoRouter y las cinco pruebas de rutas corresponden a la sesión 4.

Se utilizó OpenAI Codex para implementar, probar y documentar la práctica. La declaración de IA y el espacio de firma están en el informe.

Para recompilar el informe desde `informe/sesion-03/`, ejecutar dos veces `pdflatex D2_Parcial_AranibarRojas_AxelBarnaby_IF616BIN.tex`. La carpeta contiene todas las imágenes necesarias.
