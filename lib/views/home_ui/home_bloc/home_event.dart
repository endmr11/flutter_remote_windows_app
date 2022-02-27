part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [UniqueKey()];
}

class MqttInitEvent extends HomeEvent {}
