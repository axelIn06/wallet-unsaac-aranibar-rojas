import 'package:flutter_bloc/flutter_bloc.dart';

import 'privacy_state.dart';

class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState());

  void toggle() => emit(PrivacyState(hideBalance: !state.hideBalance));
}
