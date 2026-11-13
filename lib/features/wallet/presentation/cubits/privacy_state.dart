import 'package:equatable/equatable.dart';

class PrivacyState extends Equatable {
  const PrivacyState({this.hideBalance = false});

  final bool hideBalance;

  @override
  List<Object> get props => [hideBalance];
}
