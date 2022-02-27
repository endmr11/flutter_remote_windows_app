import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_remote_windows_app/constants/ascii_keyboard.dart';
import 'package:win32/win32.dart';

part 'key_event.dart';
part 'key_state.dart';

class KeyBloc extends Bloc<KeyEvent, KeyState> {
  KeyBloc() : super(KeyInitialState()) {
    on(keyEventControl);
  }

  Future<void> keyEventControl(KeyEvent event, Emitter<KeyState> emit) async {
    if (event is AddKeyEvent) {
      try {
        if (event.keyEvent == 1) {
          await rotate1(event.keyEvent);
        } else if (event.keyEvent == 2) {
          await rotate1(event.keyEvent);
        } else if (event.keyEvent == 3) {
          await rotate2(event.keyEvent);
        } else if (event.keyEvent == 4) {
          await rotate2(event.keyEvent);
        } else if (event.keyEvent == 0) {
          await rotate1(event.keyEvent);
          await rotate2(event.keyEvent);
        }

        emit(KeyAddedState(event.keyEvent));
      } catch (e) {
        print(">>>>>>Key Event Catch Error: $e ");
        emit(KeyAddErrorState());
      }
    }
  }
}

int temp1 = 0;
int temp2 = 0;
Future<void> rotate1(int? data) async {
  if (data == 1) {
    print("1 -- SOL");
    rotateKey1(AsciiKeyboardConstants.keyA);
  } else if (data == 2) {
    print("2 -- SAĞ");
    rotateKey1(AsciiKeyboardConstants.keyD);
  } else {
    print("empty");
    rotateKey1(999);
  }
}

Future<void> rotate2(int? data) async {
  if (data == 3) {
    print("3 -- İLERİ");
    rotateKey2(AsciiKeyboardConstants.keyW);
  } else if (data == 4) {
    print("4 -- GERİ");
    rotateKey2(AsciiKeyboardConstants.keyS);
  } else {
    print("empty");
    rotateKey2(999);
  }
}

Future<void> rotateKey1(int key) async {
  final kbd = calloc<INPUT>();
  kbd.ref.type = INPUT_KEYBOARD;
  kbd.ref.ki.wVk = key;
  var result = SendInput(1, kbd, sizeOf<INPUT>());
  if (result != TRUE) print('Error: ${GetLastError()}');
  await Future.delayed(const Duration(milliseconds: 100));
  if (temp1 != key) {
    kbd.ref.ki.wVk = temp1;
    var result = SendInput(1, kbd, sizeOf<INPUT>());
    if (result != TRUE) print('Error: ${GetLastError()}');
    kbd.ref.ki.dwFlags = KEYEVENTF_KEYUP;
    result = SendInput(1, kbd, sizeOf<INPUT>());
    if (result != TRUE) print('Error: ${GetLastError()}');
  }

  free(kbd);
  temp1 = key;
}

Future<void> rotateKey2(int key) async {
  final kbd = calloc<INPUT>();
  kbd.ref.type = INPUT_KEYBOARD;
  kbd.ref.ki.wVk = key;
  var result = SendInput(1, kbd, sizeOf<INPUT>());
  if (result != TRUE) print('Error: ${GetLastError()}');
  await Future.delayed(const Duration(milliseconds: 100));
  kbd.ref.ki.dwFlags = KEYEVENTF_KEYUP;
  result = SendInput(1, kbd, sizeOf<INPUT>());
  if (result != TRUE) print('Error: ${GetLastError()}');

  free(kbd);
  temp2 = key;
}
