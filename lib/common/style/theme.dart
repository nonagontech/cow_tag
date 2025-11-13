import 'package:flutter/material.dart';

import 'color.dart';

class AppTheme {
  static const horizontalMargin = 16.0;
  static const radius = 10.0;

  static ThemeData light = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    //页面的背景颜色
    scaffoldBackgroundColor: AppColor.scaffoldBackground,
    splashColor: Colors.transparent,
    highlightColor: const Color.fromARGB(0, 157, 38, 38),
    primaryColor: AppColor.themeColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: AppColor.accentColor,
    ),
    textTheme: ThemeData.light().textTheme.copyWith(
          // 定义全局文本颜色
          bodyLarge: const TextStyle(
            color: Colors.blue, // 设置全局文本颜色
            fontSize: 16,
          ),
        ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColor.themeColor,
      iconTheme: IconThemeData(
        color: AppColor.btnTextColor,
      ),
      titleTextStyle: TextStyle(
        color: AppColor.btnTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      toolbarTextStyle: TextStyle(
        color: AppColor.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      foregroundColor: Colors.pink,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColor.bottomNavigationBarBackground,
      unselectedLabelStyle: TextStyle(fontSize: 12),
      selectedLabelStyle: TextStyle(fontSize: 12),
      unselectedItemColor: Color(0xffA2A5B9),
      selectedItemColor: AppColor.accentColor,
    ),
    tabBarTheme: const TabBarTheme(
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: AppColor.accentColor,
      unselectedLabelColor: AppColor.secondaryText,
    ),
    // buttonTheme: ButtonThemeData(
    //   buttonColor: Colors.pink,
    // ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(AppColor.themeColor),
    ),
    // //输入框的主题色
    // inputDecorationTheme: const InputDecorationTheme(
    //   enabledBorder: UnderlineInputBorder(
    //     borderSide: BorderSide(
    //       color: AppColor.bottomColor, // 修改未选中状态下底部边框颜色
    //     ),
    //   ),
    // ),
  );
  static ThemeData dark = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    //页面的背景颜色
    scaffoldBackgroundColor: const Color.fromRGBO(21, 23, 36, 1),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    primaryColor: DarkAppColor.themeColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: DarkAppColor.accentColor,
      brightness: Brightness.dark,
    ),
    // accentColor: AppColor.themeColor,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: DarkAppColor.themeColor,
      iconTheme: IconThemeData(
        color: DarkAppColor.btnTextColor,
      ),
      titleTextStyle: TextStyle(
        color: DarkAppColor.btnTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      toolbarTextStyle: TextStyle(
        color: DarkAppColor.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DarkAppColor.bottomNavigationBarBackground,
      unselectedLabelStyle: TextStyle(fontSize: 12),
      selectedLabelStyle: TextStyle(fontSize: 12),
      unselectedItemColor: Color(0xffA2A5B9),
      selectedItemColor: DarkAppColor.accentColor,
    ),
    tabBarTheme: const TabBarTheme(
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: DarkAppColor.accentColor,
      unselectedLabelColor: DarkAppColor.secondaryText,
    ),
    // buttonTheme: ButtonThemeData(
    //   buttonColor: Colors.pink,
    // ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(DarkAppColor.btnTextColor),
      overlayColor: MaterialStateProperty.all(DarkAppColor.btnTextColor),
    ),
    // //输入框的主题色
    // inputDecorationTheme: const InputDecorationTheme(
    //   enabledBorder: UnderlineInputBorder(
    //     borderSide: BorderSide(
    //       color: DarkAppColor.bottomColor, // 修改未选中状态下底部边框颜色
    //     ),
    //   ),
    // ),
  );
}
