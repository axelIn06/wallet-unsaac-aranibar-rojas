# Wallet UNSAAC

Axel Barnaby Aranibar Rojas · Desarrollo de Software II · Unidad II, Sesión 1.

Aplicación Android de demostración con siete movimientos locales. Muestra un saldo de S/ 1,274.60, ingresos de S/ 1,770.00 y egresos de S/ 495.40. Implementa los cuatro retos sobre una sola pantalla.

## Ejecutar

La guía solicita Flutter 3.44+ y Dart 3.12+. Verificación local inicial con Flutter 3.41.6 y Dart 3.11.4. Desde esta carpeta:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
flutter devices
flutter run
```

Para mostrar carga, error y reintento con un repositorio local, ejecuta `flutter run --dart-define=DEMO_ERROR=true`. La primera consulta tarda diez segundos y falla. El botón **Reintentar** vuelve a consultar y devuelve el resumen tras otros diez segundos.

## Organización

| Ruta | Responsabilidad |
| --- | --- |
| `lib/main.dart` | Inicializa Firebase y carga la preferencia antes de iniciar Flutter. |
| `lib/app.dart` | Inyecta repositorio y Cubits. Aplica el tema a MaterialApp. |
| `lib/core/config/` | Inicialización y estado de Firebase. |
| `lib/core/theme/` | Estado inmutable, persistencia del modo y paletas Material 3. |
| `lib/core/utils/` | Formato de soles. |
| `lib/features/wallet/domain/` | Entidades y contrato del repositorio. El dominio calcula los importes en céntimos. |
| `lib/features/wallet/data/` | Repositorio en memoria con datos, latencia y fallo simulado. |
| `lib/features/wallet/presentation/` | Cubits de privacidad y saldo, pantalla y widgets. |
| `test/` | Pruebas de preferencias, Cubits y widgets. |

## Firebase en Android

El proyecto arranca con una plantilla local y muestra **Firebase: no configurado**. Si el docente solicita la conexión, crea o selecciona tu proyecto en Firebase Console, verifica que tengas la CLI oficial de Firebase y, desde este directorio, ejecuta:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android
flutter run
```

Si `flutterfire` no aparece en el PATH en macOS, usa `dart pub global run flutterfire_cli:flutterfire configure --platforms=android`. El ID Android debe ser `pe.edu.unsaac.wallet_unsaac`. El configurador genera `lib/firebase_options.dart`. Comprueba el estado al pie de la lista de movimientos. La tarjeta «Firebase: conectado» indica que el SDK se inicializó. Los movimientos continúan siendo locales.

Referencia oficial: https://firebase.google.com/docs/flutter/setup

## Evidencias

La carpeta [evidencias](evidencias/) reúne las nueve capturas de los retos y las dos del taller. También contiene la salida del [análisis](evidencias/flutter_analyze.txt), las [15 pruebas aprobadas](evidencias/flutter_test.txt) y el [arranque en Android](evidencias/flutter_run.txt). El código de las pruebas está en [test/](test/).

La versión de entrega se identifica con la etiqueta `sesion-01-retos`.
