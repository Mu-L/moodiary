import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:moodiary/common/values/webdav.dart';
import 'package:moodiary/l10n/l10n.dart';
import 'package:moodiary/pages/home/diary/diary_logic.dart';
import 'package:moodiary/persistence/isar.dart';
import 'package:moodiary/router/app_routes.dart';
import 'package:moodiary/utils/notice_util.dart';
import 'package:moodiary/utils/webdav_util.dart';

import 'web_dav_dashboard_state.dart';

class WebDavDashboardLogic extends GetxController {
  final WebDavDashboardState state = WebDavDashboardState();

  @override
  void onReady() async {
    await updateWebdav(isInit: true, context: Get.context!);
    super.onReady();
  }

  Future<void> updateWebdav({
    required BuildContext context,
    required bool isInit,
  }) async {
    state.isFetching = true;
    if (!isInit) update();
    await checkConnectivity();
    if (state.connectivityStatus.value == WebDavConnectivityStatus.connected) {
      try {
        await fetchingWebDavSyncFlag();
      } catch (e) {
        if (context.mounted) {
          toast.error(message: context.l10n.webdavSyncGetConfigError);
        }

        return;
      }
      if (isInit) await fetchDiaryList();
    }
    state.isFetching = false;
    update();
  }

  Future<void> fetchDiaryList() async {
    // 获取所有日记
    state.diaryList = await IsarUtil.getAllDiaries();
    state.toUploadDiaries.clear();
    state.toDownloadIds.clear();
    // 本地日记 Map，id 对应最后修改时间
    final Map<String, DateTime> localDiaryMap = {
      for (final diary in state.diaryList) diary.id: diary.lastModified,
    };
    // 查找待上传的日记
    _findToUploadDiaries(localDiaryMap);
    // 查找待下载的日记
    _findToDownloadIds(localDiaryMap);
  }

  void _findToUploadDiaries(Map<String, DateTime> localDiaryMap) {
    for (final diary in state.diaryList) {
      final remoteModifiedTime = state.webdavSyncMap[diary.id];
      if (remoteModifiedTime == 'delete') continue;
      if (remoteModifiedTime == null ||
          DateTime.parse(remoteModifiedTime).isBefore(diary.lastModified)) {
        state.toUploadDiaries.add(diary);
      }
    }
    state.toUploadDiariesCount.value = state.toUploadDiaries.length.toString();
  }

  void _findToDownloadIds(Map<String, DateTime> localDiaryMap) {
    for (final entry in state.webdavSyncMap.entries) {
      if (entry.value == 'delete') continue;
      final id = entry.key;
      final remoteModifiedTime = DateTime.parse(entry.value);

      // 本地没有该日记，或者本地修改时间早于服务器
      if (!localDiaryMap.containsKey(id) ||
          remoteModifiedTime.isAfter(localDiaryMap[id]!)) {
        state.toDownloadIds.add(id);
      }
    }

    state.toDownloadIdsCount.value = state.toDownloadIds.length.toString();
  }

  Future<void> checkConnectivity() async {
    state.connectivityStatus.value = WebDavConnectivityStatus.connecting;
    final res = await WebDavUtil().checkConnectivity();
    state.connectivityStatus.value =
        res
            ? WebDavConnectivityStatus.connected
            : WebDavConnectivityStatus.unconnected;
  }

  Future<void> fetchingWebDavSyncFlag() async {
    state.webdavSyncMap = await WebDavUtil().fetchServerSyncData();
    state.webDavDiaryCount.value =
        state.webdavSyncMap.values
            .where((element) => element != 'delete')
            .length
            .toString();
  }

  void toWebDavPage() async {
    await Get.toNamed(AppRoutes.backupSyncPage);
    await updateWebdav(isInit: false, context: Get.context!);
  }

  // 同步日记

  Future<void> syncDiary({required BuildContext context}) async {
    checkIsUploading();
    checkIsDownloading();
    await WebDavUtil().syncDiary(
      state.diaryList,
      onUpload: () {
        state.toUploadDiariesCount.value =
            (int.parse(state.toUploadDiariesCount.value) - 1).toString();
        checkIsUploading();
      },
      onDownload: () async {
        state.toDownloadIdsCount.value =
            (int.parse(state.toDownloadIdsCount.value) - 1).toString();
        checkIsDownloading();
        await Bind.find<DiaryLogic>().refreshAll();
      },
      onComplete: () {
        toast.success(message: context.l10n.webdavSyncSuccess);
      },
    );
  }

  void checkIsUploading() {
    state.isUploading.value = int.parse(state.toUploadDiariesCount.value) > 0;
  }

  void checkIsDownloading() {
    state.isDownloading.value = int.parse(state.toDownloadIdsCount.value) > 0;
  }

  // Future<void> uploadDiary() async {
  //   state.isUploading.value = true;
  //   await WebDavUtil().syncDiary(state.toUploadDiaries);
  //   state.isUploading.value = false;
  //   await fetchingWebDavSyncFlag();
  //   await fetchDiaryList();
  // }
  //
  // // 下载日记
  // Future<void> downloadDiary() async {
  //   state.isDownloading.value = true;
  //   await WebDavUtil().syncDiary();
  //   state.isDownloading.value = false;
  //   await fetchingWebDavSyncFlag();
  //   await fetchDiaryList();
  // }
}
