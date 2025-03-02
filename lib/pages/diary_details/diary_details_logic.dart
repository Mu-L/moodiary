import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:moodiary/common/models/isar/diary.dart';
import 'package:moodiary/common/values/diary_type.dart';
import 'package:moodiary/pages/image/image_view.dart';
import 'package:moodiary/pages/video/video_view.dart';
import 'package:moodiary/presentation/isar.dart';
import 'package:moodiary/router/app_routes.dart';
import 'package:refreshed/refreshed.dart';

import 'diary_details_state.dart';

class DiaryDetailsLogic extends GetxController {
  final DiaryDetailsState state = DiaryDetailsState();

  // 编辑器控制器
  QuillController? quillController;

  // 图片预览
  late final PageController pageController = PageController();

  @override
  void onInit() {
    if (state.diary.type != DiaryType.markdown.value) {
      quillController = QuillController(
        document: Document.fromJson(jsonDecode(state.diary.content)),
        readOnly: true,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    super.onInit();
  }

  @override
  void onClose() {
    quillController?.dispose();
    pageController.dispose();
    super.onClose();
  }

  //点击图片跳转到图片预览页面
  Future<void> toPhotoView(
    List<String> imagePathList,
    int index,
    BuildContext context,
    String heroPrefix,
  ) async {
    HapticFeedback.selectionClick();
    await showImageView(
      context,
      imagePathList,
      index,
      heroTagPrefix: heroPrefix,
    );
  }

  //点击视频跳转到视频预览页面
  Future<void> toVideoView(
    List<String> videoPathList,
    int index,
    BuildContext context,
    String heroPrefix,
  ) async {
    HapticFeedback.selectionClick();
    await showVideoView(
      context,
      videoPathList,
      index,
      heroTagPrefix: heroPrefix,
    );
  }

  //点击分享跳转到分享页面
  Future<void> toSharePage() async {
    Get.toNamed(AppRoutes.sharePage, arguments: state.diary);
  }

  //编辑日记
  Future<void> toEditPage(Diary diary) async {
    //这里参数为diary，表示编辑日记，等待跳转结果为changed，重新获取日记
    if ((await Get.toNamed(AppRoutes.editPage, arguments: diary.clone())) ==
        'changed') {
      //重新获取日记
      state.diary = (await IsarUtil.getDiaryByID(state.diary.isarId))!;
      if (state.diary.type != DiaryType.markdown.value) {
        quillController = QuillController(
          document: Document.fromJson(jsonDecode(state.diary.content)),
          readOnly: true,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
      update();
    }
  }

  //放入回收站
  Future<void> delete(Diary diary) async {
    final newDiary = diary.clone()..show = false;
    await IsarUtil.updateADiary(oldDiary: diary, newDiary: newDiary);
    Get.back(result: 'delete');
  }

  Future<void> jumpToPage(int index) async {
    await pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}
