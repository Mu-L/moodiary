import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:moodiary/pages/diary_details/diary_details_logic.dart';
import 'package:moodiary/persistence/isar.dart';
import 'package:moodiary/router/app_routes.dart';
import 'package:moodiary/utils/notice_util.dart';
import 'package:moodiary/utils/permission_util.dart';
import 'package:permission_handler/permission_handler.dart';

import 'map_state.dart';

class MapLogic extends GetxController {
  final MapState state = MapState();

  late final MapController mapController = MapController();

  @override
  void onReady() async {
    state.currentLatLng = await getLocation();
    await getAllItem();
    update();
    super.onReady();
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }

  Future<LatLng?> getLocation() async {
    if (await PermissionUtil.checkPermission(Permission.location)) {
      Position? position;
      position = await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true,
      );
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(forceLocationManager: true),
      );
      return LatLng(position.latitude, position.longitude);
    }
    return null;
  }

  Future<void> getAllItem() async {
    state.diaryMapItemList = await IsarUtil.getAllMapItem();
  }

  Future<void> toCurrentPosition() async {
    toast.info(message: '定位中');
    final currentPosition = await getLocation();
    toast.success(message: '定位成功');
    mapController.move(currentPosition!, mapController.camera.maxZoom!);
  }

  Future<void> toDiaryPage({required int isarId}) async {
    await HapticFeedback.mediumImpact();
    final diary = await IsarUtil.getDiaryByID(isarId);
    Bind.lazyPut(() => DiaryDetailsLogic(), tag: diary!.id);
    await Get.toNamed(AppRoutes.diaryPage, arguments: [diary.clone(), false]);
  }
}
