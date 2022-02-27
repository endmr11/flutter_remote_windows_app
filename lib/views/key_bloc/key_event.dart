part of 'key_bloc.dart';

abstract class KeyEvent extends Equatable {
  const KeyEvent();

  @override
  List<Object> get props => [UniqueKey()];
}

class AddKeyEvent extends KeyEvent {
  final int keyEvent;

  const AddKeyEvent(this.keyEvent);
  @override
  List<Object> get props => [UniqueKey()];
}
