import 'dart:io';

import 'package:flutter_remote_windows_app/core/local_storage/local_storage.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../../constants/mqtt_settings.dart';

class MqttService {
  MqttService._();
  static final MqttService _instance = MqttService._();
  static MqttService get i => _instance;

  static var username = MqttSettingsConstants.username;
  static var password = MqttSettingsConstants.password;
  static var topic1 = MqttSettingsConstants.topic1;
  static var topic2 = MqttSettingsConstants.topic2;
  static var serverUrl = MqttSettingsConstants.serverUrl;

  MqttServerClient client = MqttServerClient.withPort(serverUrl, username, 8883);

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.idle;

  MqttSubscriptionState subscriptionState = MqttSubscriptionState.idle;

  Future<void> prepareMqttClient() async {
    await _setupMqttClient();
    await _connectClient();
    await _subscribeToTopic(topic1);
    await _subscribeToTopic(topic2);
  }

  Future<void> _setupMqttClient() async {
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  Future<void> _connectClient() async {
    try {
      print('Mqtt Client Bağlanıyor....');
      connectionState = MqttCurrentConnectionState.connecting;
      await client.connect(username, password);
    } on Exception catch (e) {
      print('Mqtt Client Hata: - $e');
      connectionState = MqttCurrentConnectionState.errorWhenConnecting;
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.connected;
      print('Mqtt Client Bağlandı');
    } else {
      print('HATA! Mqtt Client bağlantısı başarısız - bağlantı kesiliyor, durum: ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.errorWhenConnecting;
      client.disconnect();
    }
  }

  void _onSubscribed(String topic) {
    print('Abone olunan başlık: $topic');
    subscriptionState = MqttSubscriptionState.subscribed;
  }

  void _onDisconnected() {
    print('Mqtt Client bağlantı kesildi.');
    connectionState = MqttCurrentConnectionState.disconnected;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.connected;
    print('Mqtt Client bağlantısı başarılı.');
  }

  Future<void> _subscribeToTopic(String topicName) async {
    if (topicName == "testtopic/1") {
      print('Abone olunacak başlık: $topicName ');
      client.subscribe(topicName, MqttQos.atMostOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        LocalStorage.mqttDirectionDataController.add(int.tryParse(pt)?.toInt());
        //rotate(int.tryParse(pt)?.toInt());
        print('VERİ: başık = <${c[0].topic}>, gelen içerik <-- $pt -->');
      });
    } else {
      print('Abone olunacak başlık: $topicName ');
      client.subscribe(topicName, MqttQos.atMostOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        LocalStorage.mqttRunStopDataController.add(int.tryParse(pt)?.toInt());
        //rotate(int.tryParse(pt)?.toInt());
        print('VERİ: başık = <${c[0].topic}>, gelen içerik <-- $pt -->');
      });
    }
  }
}

enum MqttCurrentConnectionState { idle, connecting, connected, disconnected, errorWhenConnecting }

enum MqttSubscriptionState { idle, subscribed }
