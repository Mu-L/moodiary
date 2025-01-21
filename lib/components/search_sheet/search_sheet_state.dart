import 'package:moodiary/common/models/isar/diary.dart';
import 'package:refreshed/refreshed.dart';

class SearchSheetState {
  //日记搜索数组
  late List<Diary> searchList;

  late RxBool isSearching;

  late RxInt totalCount;

  SearchSheetState() {
    searchList = [];
    isSearching = false.obs;
    totalCount = 0.obs;

    ///Initialize variables
  }
}
