import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_remote_windows_app/core/mqtt/mqtt_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitialState()) {
    on(homeEventControl);
  }
  Future<void> homeEventControl(HomeEvent event, Emitter<HomeState> emit) async {
    if (event is MqttInitEvent) {
      emit(HomeLoadingState());
      try {
        await MqttService.i.prepareMqttClient();
        emit(HomeLoadedState());
      } catch (e) {
        print(">>>>>>Home Event Catch Error: $e ");
        emit(HomeErrorState());
      }
    }
  }
}
