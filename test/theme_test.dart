import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Un valor ausente o corrupto inicia en sistema', () async {
    for (final values in <Map<String, Object>>[
      {},
      {ThemePreferences.key: 'invalido'},
      {ThemePreferences.key: 42},
    ]) {
      SharedPreferences.setMockInitialValues(values);
      final preferences = ThemePreferences(
        await SharedPreferences.getInstance(),
      );
      expect(preferences.loadMode(), ThemeMode.system);
    }
  });

  test('La preferencia guarda y recupera el modo', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await SharedPreferences.getInstance();
    await ThemePreferences(storage).saveMode(ThemeMode.dark);
    await storage.reload();
    expect(ThemePreferences(storage).loadMode(), ThemeMode.dark);
  });

  test('El Cubit recorre el ciclo y persiste cada cambio', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = ThemePreferences(await SharedPreferences.getInstance());
    final cubit = ThemeCubit(preferences, preferences.loadMode());
    addTearDown(cubit.close);
    for (final mode in [ThemeMode.light, ThemeMode.dark, ThemeMode.system]) {
      await cubit.toggle();
      expect(cubit.state.mode, mode);
      expect(preferences.loadMode(), mode);
    }
    await Future.wait([cubit.toggle(), cubit.toggle()]);
    expect(preferences.loadMode(), ThemeMode.dark);
  });

  test('El primary se deriva de la semilla en claro y oscuro', () {
    const granate = AppTheme.seed;
    const azul = Color(0xFF1565C0);
    expect(
      const ThemeState(seedColor: granate),
      isNot(const ThemeState(seedColor: azul)),
    );
    for (final (brightness, build) in [
      (Brightness.light, AppTheme.light),
      (Brightness.dark, AppTheme.dark),
    ]) {
      final expected = ColorScheme.fromSeed(
        seedColor: azul,
        brightness: brightness,
      );
      expect(build(azul).colorScheme.primary, expected.primary);
      expect(
        build(azul).colorScheme.primary,
        isNot(build(granate).colorScheme.primary),
      );
    }
  });
}
