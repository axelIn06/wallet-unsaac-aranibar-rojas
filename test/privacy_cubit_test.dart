import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';

void main() {
  late PrivacyCubit cubit;
  setUp(() => cubit = PrivacyCubit());
  tearDown(() => cubit.close());

  test('El estado inicial muestra importes', () {
    expect(cubit.state.hideBalance, isFalse);
  });
  test('El primer toque oculta los importes', () {
    cubit.toggle();
    expect(cubit.state.hideBalance, isTrue);
  });
  test('El segundo toque restaura la visibilidad', () {
    cubit.toggle();
    cubit.toggle();
    expect(cubit.state.hideBalance, isFalse);
  });
}
