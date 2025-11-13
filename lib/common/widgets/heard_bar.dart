import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

///登录注册界面的导航栏下方还有一个标题
///[title]. 用中文，组件中会进行多语言转换
///[height].这个组件的高
///[width].这个组件的宽
Widget heardBar({
  String title = '',
  num height = 144,
  num width = 750,
  Widget? leftBtn,
  Widget? rightBtn,
}) {
  return HeardBar(
    title: title,
    height: height,
    width: width,
    leftBtn: leftBtn,
    rightBtn: rightBtn,
  );
}

class HeardBar extends StatelessWidget {
  const HeardBar({
    super.key,
    required this.title,
    required this.height,
    required this.width,
    this.leftBtn,
    this.rightBtn,
  });
  final String title;
  final num height;
  final num width;
  final Widget? leftBtn;
  final Widget? rightBtn;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      // color: Colors.pink,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
        ),
        color: themeData.primaryColor,
      ),
      child: SizedBox(
          height: height.h,
          width: width.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130.w,
                child: leftBtn,
              ),
              Text(
                title.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              SizedBox(
                width: 130.w,
                child: rightBtn,
              ),
            ],
          )),
    );
  }
}
