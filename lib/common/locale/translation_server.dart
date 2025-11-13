import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/get.dart';
import 'package:my_app/common/locale/es.dart';
import './en_US.dart';
import './zh_Hans.dart';

class TranslationServer extends Translations {
  Locale getLocal() {
    var local = "";
    if (local == "") {
      local = Get.deviceLocale?.languageCode ?? "";
    }

    switch (local) {
      case "zh":
        return const Locale("zh", "Hans");
      case 'es':
        return const Locale("es");
      default:
        return const Locale("en", "en_US");
    }
  }

  @override
  Map<String, Map<String, String>> get keys => {
        "en_US": en_US,
        "zh_Hans": zh_Hans,
        "es": es,
      };
}
