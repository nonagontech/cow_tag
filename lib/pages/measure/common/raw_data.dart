import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:my_app/pages/measure/common/tow_echarts1.dart';

import '../../../common/style/color.dart';

class RawData extends StatefulWidget {
  const RawData({
    super.key,
    required this.spots,
    required this.loading,
  });
  final List<FlSpot> spots;
  final bool loading;

  @override
  State<RawData> createState() => _RawDataState();
}

class _RawDataState extends State<RawData> {
  LineChartBarData getLineChartBarDataOne(List<FlSpot> spots,
      {Color lineColor = const Color.fromRGBO(0, 111, 255, 1),
      BarAreaData? belowBarData}) {
    LineChartBarData lineChartBarDataOne = LineChartBarData(
      show: true, //是否显示线条
      spots: spots, //线的数据，对应着横纵坐标
      color: lineColor, //线的颜色
      barWidth: 2, //线的宽度值
      isCurved: false, //线的拐点是否光滑
      curveSmoothness: 0.2, //曲线拐角的平滑度半径
      preventCurveOverShooting: true, //防止在线性序列点上绘制曲线时过冲
      preventCurveOvershootingThreshold: 10,
      isStrokeCapRound: true, //确定条形线的起点和终点是 Qubic 还是 Round    这个没有实验出来
      isStrokeJoinRound: true,
      belowBarData: belowBarData,
      dotData: FlDotData(
        //折线图上的点
        show: false, //是否展示折线图上的点
      ),
      isStepLineChart: false, //设置成true则为柱形图
    );

    return lineChartBarDataOne;
  }

  List<LineChartBarData> lineChartBarData() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      show: true, //是否显示线条
      spots: widget.spots, //线的数据，对应着横纵坐标
      color: const Color.fromRGBO(0, 111, 255, 1), //线的颜色
      barWidth: 2, //线的宽度值
      isCurved: false, //线的拐点是否光滑
      curveSmoothness: 0.2, //曲线拐角的平滑度半径
      preventCurveOverShooting: true, //防止在线性序列点上绘制曲线时过冲
      preventCurveOvershootingThreshold: 10,
      isStrokeCapRound: true, //确定条形线的起点和终点是 Qubic 还是 Round    这个没有实验出来
      isStrokeJoinRound: true,
      // belowBarData: belowBarData,
      dotData: FlDotData(
        //折线图上的点
        show: false, //是否展示折线图上的点
      ),
      isStepLineChart: false, //设置成true则为柱形图
    );

    return [
      lineChartBarData1,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 690.w,
      // height: 700.h,
      margin: EdgeInsets.only(top: 30.h),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : DarkAppColor.themeColor,
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PPG"),
                  Text(
                    widget.spots.isNotEmpty
                        ? widget.spots[widget.spots.length - 1].y
                            .toStringAsFixed(0)
                        : "",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              widget.loading
                  ? const GFLoader(
                      type: GFLoaderType.ios,
                      size: GFSize.SMALL,
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LineTitle(
                    text: "PPG".tr,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Container(
              height: 320.h,
              width: 600.w,
              // color: Colors.white,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : DarkAppColor.themeColor,
              child: Stack(
                children: [
                  LineChart(
                    duration: Duration(milliseconds: 10),
                    curve: Curves.linear,
                    LineChartData(
                      lineBarsData: lineChartBarData(),

                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(),
                        topTitles: AxisTitles(),
                        leftTitles: AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() % 10 == 0) {
                                int intendtime = value.toInt();
                                var dateTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        intendtime);
                                // String title = "${dateTime.minute}:${dateTime.second}";
                                String title = "${dateTime.second}";

                                return Text(
                                  // title,
                                  '',
                                  style: const TextStyle(
                                    color: AppColor.greyText,
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ),
                      ), //左侧、顶部、右侧和底部的侧标题。
                      // minY: -300000,
                      // maxY: 300000,

                      lineTouchData: LineTouchData(
                        enabled: true, //确定启用或禁用触
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: const Color.fromARGB(
                              255, 169, 156, 160), //提示框的背景颜色
                          tooltipRoundedRadius: 10, //提示框的圆角
                          // tooltipPadding:const EdgeInsets.all(40)//提示框的内边距
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              final textStyle = TextStyle(
                                color: touchedSpot.bar.gradient?.colors.first ??
                                    touchedSpot.bar.color ??
                                    Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );
                              int intendtime = touchedSpot.x.toInt();
                              var dateTime =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      intendtime);
                              return LineTooltipItem(
                                  '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}\n${"原始数据".tr}：${touchedSpot.y.toString()}',
                                  textStyle);
                            }).toList();
                          },
                        ),
                      ), //点击触屏操作

                      gridData: FlGridData(
                        show: false,
                        drawHorizontalLine: false,
                        drawVerticalLine: false,
                      ), //配置网格数据
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          right: BorderSide.none,
                          top: BorderSide.none,
                          bottom: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Color.fromRGBO(187, 187, 187, 1)
                                    : Color.fromRGBO(72, 73, 92, 1),
                            // color: Color.fromRGBO(187, 187, 187, 1),
                          ),
                          left: BorderSide.none,
                        ),
                      ), //设置数轴的边框
                    ),
                  ),
                  widget.spots.isNotEmpty
                      ? Container()
                      : Center(
                          child: Text(
                            "无数据".tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ],
              ))
        ],
      ),
    );
  }
}
