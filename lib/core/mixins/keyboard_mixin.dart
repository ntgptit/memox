import 'package:flutter/widgets.dart';

mixin KeyboardMixin<T extends StatefulWidget> on State<T> {
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(context).bottom > 0;

  void dismissKeyboard() => FocusScope.of(context).unfocus();
}
