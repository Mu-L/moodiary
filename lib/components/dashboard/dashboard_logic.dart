import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:moodiary/router/app_routes.dart';
import 'package:moodiary/utils/array_util.dart';
import 'package:moodiary/utils/data/isar.dart';
import 'package:moodiary/utils/data/pref.dart';
import 'package:refreshed/refreshed.dart';

class DashboardLogic extends GetxController {
  //日记数量
  RxString diaryCount = ''.obs;

  //日记文字总数
  RxString contentCount = ''.obs;

  //使用时间
  RxString useTime = ''.obs;

  //分类数量
  RxString categoryCount = ''.obs;

  RxString recentMood = ''.obs;
  RxString recentWeather = ''.obs;

  @override
  void onReady() {
    getUseTime();
    getDiaryCount();
    //unawaited(getMoodAndWeatherByRange(state.dateRange[0], state.dateRange[1]));
    getCountContent();
    getCategoryCount();
    super.onReady();
  }

  Future<void> getCountContent() async {
    var list = await IsarUtil.getContentList();
    int count = await compute(ArrayUtil.countListItemLength, list);
    contentCount.value = count.toString();
  }

  void getDiaryCount() {
    int count = IsarUtil.countAllDiary();
    diaryCount.value = count.toString();
  }

  void getCategoryCount() {
    int count = IsarUtil.countCategories();
    categoryCount.value = count.toString();
  }

  //选中两个日期后，查询指定范围内的日记
  Future<void> getMoodAndWeatherByRange(DateTime start, DateTime end) async {
    var moodList = await IsarUtil.getMoodByDateRange(
        start, end.subtract(const Duration(days: -1)));
    var weatherList = await IsarUtil.getWeatherByDateRange(
        start, end.subtract(const Duration(days: -1)));

    //去掉没有天气
    weatherList.removeWhere((item) => item.isEmpty);
    if (moodList.isNotEmpty) {
      recentMood.value = ArrayUtil.countList(moodList)
          .entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key
          .toString();
    } else {
      recentMood.value = 'none';
    }
    if (weatherList.isNotEmpty) {
      var weatherCode = List.generate(
          weatherList.length, (index) => weatherList[index].first);
      recentWeather.value = ArrayUtil.countList(weatherCode)
          .entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    } else {
      recentWeather.value = 'none';
    }
  }

  void getUseTime() {
    DateTime firstStart = DateTime.fromMillisecondsSinceEpoch(
        PrefUtil.getValue<int>('startTime')!);
    Duration duration = DateTime.now().difference(firstStart);
    useTime.value = (duration.inDays + 1).toString();
  }

  Future<void> toDiaryManager() async {
    Get.toNamed(AppRoutes.diaryManagerPage);
  }
}
