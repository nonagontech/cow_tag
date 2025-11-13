import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/style/color.dart';
// import '../../../../common/utils/storage.dart';

int num = -1;

class TwoEchart1 extends StatefulWidget {
  const TwoEchart1({
    super.key,
    this.xSpots,
    this.ySpots,
    this.zSpots,
    this.xList = const [],
    this.systolicText = "收缩",
    this.diastolicText = "舒张",
    this.zSpotsText = "床状态",
    this.systolicIsInt = false,
    this.diastolicIsInt = false,
    this.zSpotsIsInt = true,
    this.showX = true,
    this.showHms = false,
    required this.loading,
  });
  final List<FlSpot>? xSpots;
  final List<FlSpot>? ySpots;
  final List<FlSpot>? zSpots;
  final List<double> xList;
  final String systolicText;
  final String diastolicText;
  final String zSpotsText;
  final bool systolicIsInt;
  final bool diastolicIsInt;
  final bool zSpotsIsInt;
  final bool loading;
  final bool showX;
  final bool showHms;

  @override
  State<TwoEchart1> createState() => _TwoEchart1State();
}

class _TwoEchart1State extends State<TwoEchart1> {
  getChart(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      show: true, //是否显示线条
      spots: spots, //线的数据，对应着横纵坐标
      color: color, //线的颜色
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
  }

  List<LineChartBarData> lineChartBarData() {
    List<FlSpot> xSpots = widget.xSpots ?? [];
    List<FlSpot> ySpots = widget.ySpots ?? [];
    List<FlSpot> zSpots = widget.zSpots ?? [];

    LineChartBarData lineChartBarData2 =
        getChart(xSpots, const Color.fromARGB(255, 233, 157, 43));
    LineChartBarData lineChartBarData3 =
        getChart(ySpots, const Color.fromARGB(255, 221, 46, 116));
    LineChartBarData lineChartBarData4 =
        getChart(zSpots, const Color.fromARGB(255, 64, 235, 98));

    return [lineChartBarData2, lineChartBarData3, lineChartBarData4];
  }

  String title() {
    List<FlSpot> xSpots = widget.xSpots ?? [];
    List<FlSpot> ySpots = widget.ySpots ?? [];
    List<FlSpot> zSpots = widget.zSpots ?? [];
    String tit = "";
    if (xSpots.isNotEmpty) {
      tit += widget.systolicIsInt
          ? "${xSpots[xSpots.length - 1].y.toInt()}/"
          : "${xSpots[xSpots.length - 1].y.toStringAsFixed(1)}/";
    } else {
      tit += " /";
    }
    if (ySpots.isNotEmpty) {
      tit += widget.diastolicIsInt
          ? "${ySpots[ySpots.length - 1].y.toInt()}/"
          : "${ySpots[ySpots.length - 1].y.toStringAsFixed(1)}/";
    } else {
      tit += " /";
    }
    if (zSpots.isNotEmpty) {
      tit += widget.zSpotsIsInt
          ? "${zSpots[zSpots.length - 1].y.toInt()}"
          : "${zSpots[zSpots.length - 1].y.toStringAsFixed(1)}";
    }

    return tit;
  }

  @override
  Widget build(BuildContext context) {
    double echartW = 690.w;
    double echartH = 450.h;

    return Container(
      width: echartW,
      height: echartH,
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
                  Text(
                    "ACC: ${widget.systolicText}/${widget.diastolicText}/${widget.zSpotsText}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    title(),
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LineTitle(
                    text: "${widget.systolicText}",
                    lineColor: const Color.fromARGB(255, 233, 157, 43),
                  ),
                  LineTitle(
                    text: "${widget.diastolicText}",
                    lineColor: const Color.fromARGB(255, 221, 46, 116),
                  ),
                  LineTitle(
                    text: "${widget.zSpotsText}",
                    lineColor: const Color.fromARGB(255, 64, 235, 98),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Expanded(
            child: Container(
              height: 500.h,
              width: 600.w,
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
                        bottomTitles: widget.showX
                            ? AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    // if (value.toInt() % 10 == 0) {
                                    if (!widget.showHms) {
                                      int intendtime = value.toInt();
                                      var dateTime =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              intendtime);
                                      String title = "${dateTime.second}";
                                      // String title = "${dateTime.second}";
                                      if (dateTime.second != num &&
                                          dateTime.second % 2 == 0) {
                                        num = dateTime.second.toInt();
                                        return Text(
                                          title,
                                          style: const TextStyle(
                                            color: AppColor.greyText,
                                            fontSize: 10,
                                          ),
                                        );
                                      } else {
                                        num = dateTime.second.toInt();
                                        return Container();
                                      }
                                    } else {
                                      if (widget.xList.contains(value)) {
                                        int intendtime = value.toInt();
                                        var dateTime =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                intendtime);
                                        String title = DateFormat("mm:ss")
                                            .format(dateTime);
                                        return Text(
                                          title,
                                          style: const TextStyle(
                                            color: AppColor.greyText,
                                            fontSize: 10,
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }
                                  },
                                ),
                              )
                            : AxisTitles(),
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
                              String text = "";
                              switch (touchedSpot.barIndex) {
                                case 0:
                                  text =
                                      '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}\n${"${widget.systolicText}"}：${widget.systolicIsInt ? touchedSpot.y.toInt() : touchedSpot.y.toStringAsFixed(1)}';

                                  break;
                                case 1:
                                  text =
                                      '${"${widget.diastolicText}"}：${widget.diastolicIsInt ? touchedSpot.y.toInt() : touchedSpot.y.toStringAsFixed(1)}';

                                  break;
                                case 2:
                                  text =
                                      '${"${widget.zSpotsText}"}：${widget.zSpotsIsInt ? touchedSpot.y.toInt() : touchedSpot.y.toStringAsFixed(1)}';

                                  break;
                              }
                              return LineTooltipItem(text, textStyle);
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
                          ),
                          left: BorderSide.none,
                        ),
                      ), //设置数轴的边框
                    ),
                  ),
                  widget.xSpots!.isNotEmpty ||
                          widget.ySpots!.isNotEmpty ||
                          widget.zSpots!.isNotEmpty
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LineTitle extends StatelessWidget {
  const LineTitle({
    super.key,
    this.text = '',
    this.lineColor = const Color.fromRGBO(0, 111, 255, 1),
  });
  final String text;
  final Color? lineColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.commit,
          color: lineColor,
        ),
        SizedBox(
          width: 5.w,
        ),
        Text(
          text.tr,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
