part of 'key_bloc.dart';

abstract class KeyState extends Equatable {
  const KeyState();

  @override
  List<Object> get props => [UniqueKey()];
}

class KeyInitialState extends KeyState {}

class KeyAddedState extends KeyState {
  final int keyEvent;

  const KeyAddedState(this.keyEvent);
  @override
  List<Object> get props => [UniqueKey()];
}

class KeyAddErrorState extends KeyState {}
