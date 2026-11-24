# Wallet UNSAAC · Unidad II, sesión 2

Entregable D1 de Axel Barnaby Aranibar Rojas (220547). Billetera Android con movimientos en memoria, estados inmutables y pruebas unitarias y de interfaz. El saldo, los ingresos y los egresos se calculan en céntimos. Al cerrar el proceso se recupera la semilla de demostración. El modo de tema sí se conserva.

## Ejecutar desde cero

Requisitos verificados: Flutter 3.41.6 estable, Dart 3.11.4 y un SDK Android con JDK compatible con Gradle. Para ejecutar la app, iniciar un emulador Android o conectar un teléfono con depuración USB. Trabajar sobre la rama local `sesion-02` o su integración en `main`.

```sh
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d ID_DEL_DISPOSITIVO
```

La semilla trae siete movimientos y S/ 1,274.60 de saldo. Ingreso y Egreso crean operaciones de S/ 10.00. El menú de cada fila permite editar o eliminar. El icono de vaciar pide confirmación. Para observar un error recuperable de alta de forma determinista, ejecutar `flutter run --dart-define=DEMO_FALLO_ALTA=true` y pulsar Ingreso. Reintentar recarga los datos y permite registrar después la operación. Para probar un fallo de carga inicial, usar `--dart-define=DEMO_ERROR=true`.

## Firebase para Android

D1 funciona sin cuenta Google. El código incluye `firebase_core`, una plantilla pública en `lib/firebase_options.dart` y una inicialización que distingue tres estados. Con los marcadores de la plantilla, la tarjeta inferior indica «Firebase: no configurado». Si hay opciones reales, el arranque espera a `Firebase.initializeApp(options: ...)` y muestra el resultado. El repositorio de movimientos sigue en memoria.

Para vincular un proyecto real antes de la sesión 3:

1. Instalar Firebase CLI (por ejemplo, `npm install -g firebase-tools`). Ejecutar `firebase login` y autorizar el acceso desde el navegador con la cuenta del curso.
2. Ejecutar `firebase projects:list` y comprobar el identificador del proyecto que corresponde a la práctica.
3. Ejecutar `dart pub global activate flutterfire_cli`. Desde esta carpeta, ejecutar `dart pub global run flutterfire_cli:flutterfire configure --project=ID_DEL_PROYECTO --platforms=android`. Aceptar la generación local de opciones. El identificador de aplicación Android es `pe.edu.unsaac.wallet_unsaac`.
4. Reconstruir con `flutter run`, bajar al final de la lista y verificar «Firebase: conectado». Comprobar en la consola de Firebase que la aplicación Android registrada coincide con ese paquete. Esta comprobación acredita la inicialización del SDK. El ejercicio no usa Firestore.
5. Conservar en Git la plantilla pública. Revisar `git diff -- lib/firebase_options.dart` antes de preparar un commit y excluir del commit las opciones específicas generadas. El archivo google-services.json, las cuentas de servicio y las claves de firma están excluidos por .gitignore.

Referencia: [configuración oficial de Firebase para Flutter](https://firebase.google.com/docs/flutter/setup).

## Arquitectura y decisiones

| Carpeta bajo lib/ | Responsabilidad |
|---|---|
| core/config y core/theme | Inicialización de Firebase, preferencias y tema |
| features/wallet/domain | Entidades por valor, sumas en céntimos y contrato del repositorio |
| features/wallet/data | Lista privada en memoria y copias inmutables de los resúmenes |
| features/wallet/presentation/bloc | Eventos de carga, alta, edición, baja, limpieza y filtro |
| features/wallet/presentation/pages y widgets | Formulario, selectores, vista de carga, aviso de error y reintento |

WalletApp inyecta WalletRepository por encima de MovementsBloc. La pantalla envía eventos. El dominio no importa Flutter. La cola del bloc conserva el orden de las escrituras. Cada operación devuelve el resumen actualizado. Los Cubit de tema y privacidad conservan su función de presentación.

- **Edición.** El formulario acepta soles con punto o coma, valida el importe y envía MovementUpdated. El repositorio reemplaza la fila por ID en su índice.
- **Guardado.** Ready.copyWith activa isSaving durante el alta. La lista previa sigue visible y el indicador lineal desaparece al resolver la escritura.
- **Error.** Failure lleva un mensaje y el último Ready cuando existe. El listener de BlocConsumer muestra un SnackBar. Reintentar envía MovementsStarted. Una recarga nunca repite una escritura fallida.
- **Filtro.** Ready mantiene all, income o expense. La tarjeta selecciona solo el resumen y la lista selecciona los datos y el filtro. El total sigue incluyendo movimientos de ambos tipos.

## Verificación

La base de la sesión 1 aprobó 15 pruebas. D1 pasa 36. El análisis estático quedó sin observaciones y `flutter build apk --debug` generó el APK. Las salidas están en `evidencias/sesion-02/`. Las evidencias del directorio superior de evidencias corresponden a la sesión 1.

| Archivo de prueba | Comportamiento comprobado |
|---|---|
| movements_bloc_test.dart | 14 casos: inicial, carga, alta y guardado, baja, limpieza, error y recuperación, supresión, edición, duplicado, tres filtros, conservación del filtro y escrituras consecutivas |
| movements_state_test.dart | 5 casos de igualdad de estados, eventos y entidades, y protección de la lista |
| wallet_widget_test.dart | 6 recorridos de interfaz, incluidos edición desde el menú y fallo de alta con reintento |
| balance_cubit_test.dart, privacy_cubit_test.dart, theme_test.dart | 11 pruebas heredadas del saldo, la privacidad y el tema |

Si no aparece un dispositivo, revisar `flutter devices` y el SDK con `flutter doctor -v`. Si Firebase indica error, comprobar el ID de proyecto, el paquete Android y repetir la configuración seguida de un arranque completo. Para instalar dependencias sin red se puede usar `flutter pub get --offline` si ya están en la caché.

## Fuentes y uso de IA

Guía de aplicación y material teórico de la sesión 2 de Desarrollo de Software II, UNSAAC (2026), y documentación oficial de Firebase enlazada arriba. OpenAI Codex participó en la implementación, redacción y verificación con Flutter, Android y LaTeX. La revisión personal, la firma y la presentación corresponden al estudiante.
