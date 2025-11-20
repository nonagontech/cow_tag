import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:my_app/common/style/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/common/locale/translation_server.dart';

import 'package:get_storage/get_storage.dart';
import 'package:my_app/pages/measure/measure.dart';

import 'package:responsive_framework/responsive_framework.dart';

//应用入口
void main() async {
  await GetStorage.init();

  // WidgetsFlutterBinding.ensureInitialized(); //不加这个强制横/竖屏会报错
  // SystemChrome.setPreferredOrientations([
  //   // 强制竖屏
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown
  // ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //设置状态栏颜色
    statusBarColor: Colors.transparent,
  ));

  //用于确保Flutter的Widgets绑定已经初始化。
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MyApp(),
  );
}

/// 在 Flutter 中，大多数东西都是 widget（后同“组件”或“部件”），包括对齐(alignment)、填充(padding)和布局(layout)等，它们都是以 widget 的形式提供。
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override

  ///Flutter 在构建页面时，会调用组件的build方法，widget 的主要工作是提供一个 build()方法来描述如何构建 UI 界面（通常是通过组合、拼装其它基础 widget）。
  Widget build(BuildContext context) {
    ThemeData? theme = AppTheme.light;

    ///MaterialApp 是 Material 库中提供的 Flutter APP 框架，通过它可以设置应用的名称、主题、语言、首页及路由列表等。MaterialApp也是一个 widget。
    final easyload = EasyLoading.init();
    return ScreenUtilInit(
      // designSize: const Size(750, 1624), // 初始化设计尺寸 750是高度
      designSize: const Size(750, 1624), // 初始化设计尺寸 750是高度

      //KeyboardDismissOnTap用于点击空白部分自动关闭键盘，不会影响其他组件的点击情况
      builder: (context, chider) => KeyboardDismissOnTap(
        child: GetMaterialApp(
          title: 'Seismi Vet', //软件后台清理时的名称
          translations: TranslationServer(), //多语言字典
          locale: TranslationServer().getLocal(), //当前使用的语言
          fallbackLocale: const Locale("en", "US"), //在选择无效区域设置的情况下指定回退区域设置。
          supportedLocales: const [
            Locale('zh', 'CN'), // 支持的语言和地区
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations
                .delegate, //是Flutter的一个本地化委托，用于提供Material组件库的本地化支持
            GlobalWidgetsLocalizations.delegate, //用于提供通用部件（Widgets）的本地化支持
            GlobalCupertinoLocalizations.delegate, //用于提供Cupertino风格的组件的本地化支持
          ],
          debugShowCheckedModeBanner: false, //删除调试横幅
          //主题
          theme: theme,

          // theme: AppTheme.dark,
          themeMode: ThemeMode.light,
          enableLog: true,

          builder: (context, child) {
            child = ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
              ],
            );
            child = easyload(context, child);
            return child;
          },
          home: const MeasureCow(),
        ),
      ),
    );
  }
}
