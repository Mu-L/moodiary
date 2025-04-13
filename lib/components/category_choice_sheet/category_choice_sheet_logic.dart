import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodiary/pages/home/diary/diary_logic.dart';
import 'package:moodiary/persistence/isar.dart';
import 'package:moodiary/router/app_routes.dart';

import 'category_choice_sheet_state.dart';

class CategoryChoiceSheetLogic extends GetxController {
  final CategoryChoiceSheetState state = CategoryChoiceSheetState();
  late final DiaryLogic diaryLogic = Bind.find<DiaryLogic>();

  @override
  void onReady() async {
    await getCategory();
    super.onReady();
  }

  // 获取分类
  Future<void> getCategory() async {
    state.isFetching.value = true;
    state.categoryList.value = await IsarUtil.getAllCategoryAsync();
    state.isFetching.value = false;
  }

  // 选择分类后跳转到对应位置
  void selectCategory({required String? categoryId}) {
    diaryLogic.jumpToCategory(categoryId: categoryId);
  }

  void toCategoryManage(BuildContext context) {
    Navigator.pop(context);
    Get.toNamed(AppRoutes.categoryManagerPage);
  }
}
