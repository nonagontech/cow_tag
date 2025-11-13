import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

///这是密码中隐藏密码个展开密码的widget
///这个组件是通过富文本来展示，将图标以文本的形式传入
///[isShow]. 控制睁眼还是闭眼
///[onChanged]. 点击眼睛图标调用的函数
Widget passwardEyeWidget({
  required bool isShow,
  required VoidCallback onChanged,
}) {
  return IconButton(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(0.0),
    iconSize: 18.0,
    icon: isShow
        ? const Icon(Icons.visibility)
        : const Icon(Icons.visibility_off),
    onPressed: onChanged,
  );
}
