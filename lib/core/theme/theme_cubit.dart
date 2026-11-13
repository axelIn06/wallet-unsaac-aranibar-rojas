import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._preferences, ThemeMode initialMode)
    : super(ThemeState(mode: initialMode));

  final ThemePreferences _preferences;
  Future<void> _pendingWrite = Future.value();

  Future<void> toggle() => setMode(switch (state.mode) {
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
    ThemeMode.system => ThemeMode.light,
  });

  Future<void> setMode(ThemeMode mode) {
    emit(state.copyWith(mode: mode));
    // Las escrituras siguen el orden de los toques, incluso si una falla.
    final write = _pendingWrite.then((_) => _preferences.saveMode(mode));
    _pendingWrite = write.then<void>((_) {}, onError: (Object _) {});
    return write;
  }

  Future<void> useSystemMode() => setMode(ThemeMode.system);

  void setSeedColor(Color color) => emit(state.copyWith(seedColor: color));
}
