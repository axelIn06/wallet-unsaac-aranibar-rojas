import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser(this.uid, this.email, [this.displayName]);
  final String uid;
  final String email;
  final String? displayName;
  String get label => displayName ?? email;
  @override
  List<Object?> get props => [uid, email, displayName];
}
