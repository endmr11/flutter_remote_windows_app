import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remote_windows_app/core/local_storage/local_storage.dart';
import 'package:flutter_remote_windows_app/views/home_ui/home_bloc/home_bloc.dart';
import 'package:flutter_remote_windows_app/views/key_bloc/key_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc homeBloc;
  late KeyBloc keyBloc;

  bool isStarted = false;
  bool isLoading = false;
  int? keyData;

  late StreamSubscription dataSubsDirection;
  late StreamSubscription dataSubsRunStop;
  int temp = 0;
  

  @override
  void initState() {
    super.initState();
    homeBloc = HomeBloc();
    keyBloc = KeyBloc();
    dataSubsDirection = LocalStorage.mqttDirectionStream.listen((event) {
      keyBloc.add(AddKeyEvent(event ?? 555));
    });
    dataSubsRunStop = LocalStorage.mqttRunStopStream.listen((event) {
      keyBloc.add(AddKeyEvent(event ?? 555));
    });
  }

  @override
  void dispose() {
    super.dispose();
    homeBloc.close();
    keyBloc.close();
    dataSubsDirection.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeBloc, HomeState>(
            bloc: homeBloc,
            listener: (context, state) {
              if (state is HomeLoadingState) {
                setState(() {
                  isStarted = false;
                  isLoading = true;
                });
              } else if (state is HomeLoadedState) {
                setState(() {
                  isStarted = true;
                  isLoading = false;
                });
              } else if (state is HomeErrorState) {
                setState(() {
                  isStarted = false;
                  isLoading = false;
                });
              }
            },
          ),
          BlocListener<KeyBloc, KeyState>(
            bloc: keyBloc,
            listener: (context, state) {
              if (state is KeyAddedState) {
                setState(() {
                  keyData = state.keyEvent;
                });
              } else if (state is KeyAddErrorState) {
                setState(() {
                  keyData = 666;
                });
              }
            },
          ),
        ],
        child: Scaffold(
          body: isLoading
              ? loadingMainFrame()
              : isStarted
                  ? initialedMainFrame()
                  : startMainFrame(),
        ),
      ),
    );
  }

  Widget startMainFrame() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "EREN DEMİR",
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.040),
          ),
          ElevatedButton(
            onPressed: () => homeBloc.add(MqttInitEvent()),
            child: const Text("Bağlantıyı başlat"),
          ),
        ],
      ),
    );
  }

  Widget initialedMainFrame() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Gelen Veri:",
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.040),
          ),
          Text(
            keyData != null ? getDirectionText(keyData!) : "Boş",
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.018),
          ),
        ],
      ),
    );
  }

  Widget loadingMainFrame() {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  String getDirectionText(int num) {
    switch (num) {
      case 1:
        return "Sol";
      case 2:
        return "Sağ";
      case 3:
        return "İleri";
      case 4:
        return "Geri";
      default:
        return "Düz";
    }
  }
}
