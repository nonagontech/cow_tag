import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/common/widgets/passward_eye_widget.dart';

///这是没有底部边框的密码输入框，带有小眼睛
///[isShow]. 控制眼睛的睁开和关闭
///[clickEye]. 点击小眼睛后的回调
///[onChanged]. 文本内容变化后的回调
///[defaultHintText]. 占位符文本
///[controller] 输入框控制器
Widget passwardWidget({
  required bool isShow,
  required VoidCallback clickEye,
  // required ValueChanged onChanged,
  String defaultHintText = "输入密码",
  TextEditingController? controller,
  String? labelText,
  bool showPrefixIcon = true,
  bool enabled = true,
}) {
  return TextFormField(
    enabled: enabled,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: defaultHintText.tr,
      border: InputBorder.none,
      suffixIcon: passwardEyeWidget(
        onChanged: clickEye,
        isShow: isShow,
      ),
      prefixIcon: showPrefixIcon ? const Icon(Icons.lock) : null,
    ),
    obscureText: !isShow,
    // onChanged: onChanged,
    controller: controller,
  );
}
