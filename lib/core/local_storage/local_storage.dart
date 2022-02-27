import 'dart:async';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage _instance = LocalStorage._();
  static LocalStorage get i => _instance;

  static StreamController<int?> mqttDirectionDataController = StreamController<int?>.broadcast();
  static Stream<int?> get mqttDirectionStream => mqttDirectionDataController.stream;
  static StreamController<int?> mqttRunStopDataController = StreamController<int?>.broadcast();
  static Stream<int?> get mqttRunStopStream => mqttRunStopDataController.stream;
}
