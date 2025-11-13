import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/common/style/color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'common/raw_data.dart';
import 'common/tow_echarts1.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../common/utils/ble.dart';

class MeasureCow extends StatefulWidget {
  const MeasureCow({super.key});

  @override
  State<MeasureCow> createState() => _MeasureCowState();
}

class _MeasureCowState extends State<MeasureCow> {
  List<FlSpot> xSpots = [];
  List<FlSpot> ySpots = [];
  List<FlSpot> zSpots = [];
  List<FlSpot> ppgSpots = [];

  bool loading = false;

  StreamSubscription? _connectionSubscription; //连接状态
  StreamSubscription? _getData; // 获取数据

  List<String> saveAcc = []; // 缓存中等待保存的ACC
  List<String> savePpg = []; //缓存中等待保存的PPG

  //做蓝牙处理部分开始
  //蓝牙
  late Ble ble1;
  bool scaning = false; //正在扫描中
  bool isConnected = false; //已经连接成功
  BluetoothConnectionState connectStatus = BluetoothConnectionState.connected;
  Timer? disconnectTimer; //监听到的断开连接有可能是连接成功会再走一次断开

  /// ----------------------
  /// 数据包定义（与 Python 保持一致）
  /// ----------------------
  int PACKET_TYPE_ACC = 1; // 加速度数据包
  int PACKET_TYPE_PPG = 2; // 光电容积脉搏波数据包

  /// 采样周期（毫秒）
  /// 与 Python 中的常量对应：
  ///   ACC_SAMPLE_PERIOD_MS = 16  -> 62.5Hz
  ///   PPG_SAMPLE_PERIOD_MS = 2.5 -> 400Hz
  double ACC_SAMPLE_PERIOD_MS = 16.0;
  double PPG_SAMPLE_PERIOD_MS = 2.5;

  File? currentAccFile; //当前ACC文件
  File? currentPpgFile; //当前PPG文件
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSaveFile();
      initBle();
    });
  }

  initSaveFile() async {
    Directory directory = await getTemporaryDirectory();
    if (currentAccFile == null) {
      String path = '${directory.path}${Platform.pathSeparator}acc.csv';
      // 判断这个文件是否存在
      if (await File(path).exists()) {
        // 如果存在，则直接打开
        currentAccFile = File(path);
      } else {
        // 如果不存在，则创建一个新文件,并添加表头
        currentAccFile = File(path);
        try {
          IOSink sink = currentAccFile!.openWrite(mode: FileMode.append);
          sink.writeln("unix,packet_counter,value");
          await sink.flush();
          await sink.close();
        } catch (e) {
          print('写入异常----> $e');
        }
      }
    }
    if (currentPpgFile == null) {
      String path = '${directory.path}${Platform.pathSeparator}ppg.csv';
      // 判断这个文件是否存在
      if (await File(path).exists()) {
        // 如果存在，则直接打开
        currentPpgFile = File(path);
      } else {
        // 如果不存在，则创建一个新文件,并添加表头
        currentPpgFile = File(path);
        try {
          IOSink sink = currentPpgFile!.openWrite(mode: FileMode.append);
          sink.writeln("unix,packet_counter,value");
          await sink.flush();
          await sink.close();
        } catch (e) {
          print('写入异常----> $e');
        }
      }
    }
  }

  //结束时情况
  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _getData?.cancel();
    disconnectTimer?.cancel();
    super.dispose();
    ble1.disconnect();
  }

  initBle() {
    //蓝牙初始化
    ble1 = Ble.instance;
    ble1.onScanResults(callbackLast: (event) {
      String name = event.advertisementData.advName.trim().toUpperCase();

      String cowName = "Seism";

      if (name != '' && name.contains(cowName)) {
        ble1.stopScan();
        ble1.connect(
          event.device,
          serviceUUID: "0001",
          readCharacteristicUUID: "0003",
          writeCharacteristicUUID: "0002",
        );
      }
    });
    ble1.isScaning((event) {
      if (mounted) {
        setState(() {
          scaning = event;
        });
      }
      if (!event && !isConnected) {
        ble1.status(
          timeout: const Duration(seconds: 30),
        );
      }
    });

    ble1.status(
      timeout: const Duration(seconds: 30),
    );
    //监听是否和设备断开
    _connectionSubscription?.cancel();
    _connectionSubscription = ble1.connectController.stream.listen((event) {
      if (event is BluetoothConnectionState) {
        if (mounted) {
          setState(() {
            connectStatus = event;
            switch (event) {
              case BluetoothConnectionState.connected:
                isConnected = true;
                break;
              case BluetoothConnectionState.disconnected:
                disconnectTimer?.cancel();
                disconnectTimer = Timer(const Duration(milliseconds: 400), () {
                  if (connectStatus == BluetoothConnectionState.disconnected) {
                    //400毫秒后还是未连接才代表断开了连接,回到以前的界面
                    isConnected = false;
                    ble1.status(
                      timeout: const Duration(seconds: 30),
                    );
                  }
                });

                break;

              default:
            }
          });
        }
      }
    });
    //监听接收的数据
    _getData?.cancel();
    _getData = ble1.getBleDateController.stream.listen((event) {
      if (event is List<int>) {
        List<int> data = event;
        // 至少需要3字节：1字节类型 + 2字节计数器
        if (data.length < 3) return;

        /// ----------------------
        /// 1️⃣ 解析包头信息
        /// ----------------------

        // 数据包类型（1=ACC，2=PPG）
        final packetType = data[0];

        // 包计数器（2字节，小端序）
        // Python: packet_counter = int.from_bytes(data[1:3], 'little')
        int packetCounter = data[1] | (data[2] << 8);

        // 每个样本3字节，剩余字节数除以3得到样本数量
        // Python: n_samples = (len(data) - 3) // 3
        final nSamples = (data.length - 3) ~/ 3;
        if (nSamples == 0) return;

        /// ----------------------
        /// 2️⃣ 时间戳初始化
        /// ----------------------

        // 当前系统时间（毫秒）
        final now = DateTime.now().millisecondsSinceEpoch;

        /// ----------------------
        /// 3️⃣ 样本数据解析循环
        /// ----------------------
        for (int i = 0; i < nSamples; i++) {
          // 每个样本3字节：低字节在前（小端序）
          final start = 3 + i * 3;
          final end = start + 3;
          final sampleBytes = data.sublist(start, end);
          final value =
              sampleBytes[0] | (sampleBytes[1] << 8) | (sampleBytes[2] << 16);

          /// ----------------------
          /// 4️⃣ 时间戳计算
          /// ----------------------

          double ts = 0;

          if (packetType == PACKET_TYPE_ACC) {
            // 加速度包：基于采样周期计算时间
            ts = now + 5 * i * 1.0;

            // 放入折线图中
            switch (i) {
              case 0:
                xSpots.add(FlSpot(ts, value.toDouble()));
                if (i == nSamples - 1) {
                  ySpots.add(FlSpot(ts, 0.0));
                  zSpots.add(FlSpot(ts, 0.0));
                }

                break;
              case 1:
                ySpots.add(FlSpot(ts, value.toDouble()));
                if (i == nSamples - 1) {
                  zSpots.add(FlSpot(ts, 0.0));
                }
                break;
              case 2:
                zSpots.add(FlSpot(ts, value.toDouble()));
                break;
              default:
            }
            // 保存进入数组
            saveAcc.add("$now,$packetCounter,$value");
          } else if (packetType == PACKET_TYPE_PPG) {
            // 光电容积包（PPG）
            ts = now + i * 1.0;
            ppgSpots.add(FlSpot(ts, value.toDouble()));
            // 保存进入数组
            savePpg.add("$now,$packetCounter,$value");
          }
        }

        setState(() {});

        if (ppgSpots.length > (2 * 1000 / PPG_SAMPLE_PERIOD_MS)) {
          // 一下移除nSamples个元素
          ppgSpots.removeRange(0, nSamples);
        }
        if (xSpots.length > 3 * (1000 / ACC_SAMPLE_PERIOD_MS)) {
          xSpots.removeAt(0);
          ySpots.removeAt(0);
          zSpots.removeAt(0);
        }

        // 5秒钟保存一次数据
        int ppgLength = 5 * (1000 / PPG_SAMPLE_PERIOD_MS).toInt();
        if (savePpg.length > ppgLength) {
          String str = savePpg.join("\n");
          savePpg.clear();
          sendDataFun(str, currentPpgFile);
        }

        int accLength = 5 * (1000 / ACC_SAMPLE_PERIOD_MS).toInt();
        if (saveAcc.length > accLength) {
          String str = saveAcc.join("\n");
          saveAcc.clear();
          sendDataFun(str, currentAccFile);
        }
      }
    });
  }

  sendDataFun(String data, File? file) async {
    if (file != null) {
      try {
        IOSink sink = file.openWrite(mode: FileMode.append);
        sink.writeln(data);
        await sink.flush();
        await sink.close();
      } catch (e) {
        print('写入异常----> $e');
      }
    }
  }

  share() async {
    //分享
    EasyLoading.show(status: 'loading...');
    // 1. 获取临时目录
    final directory = await getTemporaryDirectory();

    // 2. 指定 CSV 文件路径
    final accPath = '${directory.path}${Platform.pathSeparator}acc.csv';
    final ppgPath = '${directory.path}${Platform.pathSeparator}ppg.csv';

    final accFile = File(accPath);
    final ppgFile = File(ppgPath);

    // 如果文件不存在可以先做判断
    if (!await accFile.exists() || !await ppgFile.exists()) {
      debugPrint('❌ CSV 文件不存在');
      EasyLoading.dismiss();
      return;
    }

    // 3. 创建压缩对象
    final archive = Archive();

    // 添加 acc.csv
    archive.addFile(ArchiveFile(
      'acc.csv',
      await accFile.length(),
      await accFile.readAsBytes(),
    ));

    // 添加 ppg.csv
    archive.addFile(ArchiveFile(
      'ppg.csv',
      await ppgFile.length(),
      await ppgFile.readAsBytes(),
    ));

    // 4. 将内容压缩为 zip 格式
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    // 5. 写入 zip 文件
    final zipFilePath = '${directory.path}${Platform.pathSeparator}data.zip';
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(zipData);

    // 6. 分享 zip 文件
    await Share.shareXFiles(
      [XFile(zipFile.path)],
      text: '这是导出的数据文件',
    );
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("测量".tr),
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColor.themeColor
              : const Color.fromRGBO(16, 41, 79, 1),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: share, icon: const Icon(Icons.share))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Stack(
              children: [
                Image(
                  image: Theme.of(context).brightness == Brightness.light
                      ? const AssetImage("assets/images/measureBG.png")
                      : const AssetImage("assets/images/measureBGDark.png"),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      children: [
                        //顶部
                        Container(
                          height: 120.h,
                          margin: EdgeInsets.only(top: 20.h),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.h),
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : DarkAppColor.themeColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text("连接状态:".tr),
                                  const SizedBox(width: 10),
                                  isConnected
                                      ? Text("已连接".tr)
                                      : scaning
                                          ? Text("正在搜索".tr)
                                          : Text("未连接".tr),
                                ],
                              ),
                              // 刷新按钮
                              if (!isConnected && !scaning)
                                IconButton(
                                  onPressed: () {
                                    ble1.status(
                                      timeout: const Duration(seconds: 30),
                                    );
                                  },
                                  icon: const Icon(Icons.refresh),
                                ),
                            ],
                          ),
                        ),

                        Container(
                          height: 30.h,
                        ),

                        Column(children: [
                          // x/y/z轴
                          TwoEchart1(
                            xSpots: xSpots,
                            ySpots: ySpots,
                            zSpots: zSpots,
                            loading: loading,
                            systolicText: "x轴".tr,
                            diastolicText: "y轴".tr,
                            zSpotsText: "z轴".tr,
                            systolicIsInt: true,
                            diastolicIsInt: true,
                            zSpotsIsInt: true,
                            showX: false,
                            showHms: false,
                          ),

                          RawData(
                            spots: ppgSpots,
                            loading: loading,
                          )
                        ]),

                        SizedBox(
                          height: 100.h,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ]),
        ));
  }
}
