import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:moodiary/components/base/button.dart';
import 'package:moodiary/components/bubble/bubble_view.dart';
import 'package:moodiary/l10n/l10n.dart';
import 'package:moodiary/utils/file_util.dart';
import 'package:moodiary/utils/http_util.dart';

import 'map_logic.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Bind.find<MapLogic>();
    final state = Bind.find<MapLogic>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingFunctionTrailMap),
        leading: const PageBackButton(),
      ),
      body: GetBuilder<MapLogic>(
        builder: (_) {
          return state.currentLatLng != null && state.tiandituKey != null
              ? FlutterMap(
                mapController: logic.mapController,
                options: MapOptions(
                  initialCenter: state.currentLatLng!,
                  minZoom: 4.0,
                  initialZoom: 16.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'http://t6.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=${state.tiandituKey}',
                    tileProvider: CachedTileProvider(
                      store: HiveCacheStore(
                        FileUtil.getRealPath('hive_cache', ''),
                        hiveBoxName: 'HiveCache',
                      ),
                      dio: HttpUtil().dio,
                    ),
                    tileSize: 256,
                  ),
                  TileLayer(
                    urlTemplate:
                        'http://t6.tianditu.gov.cn/cva_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=${state.tiandituKey}',
                    tileProvider: CachedTileProvider(
                      store: HiveCacheStore(
                        FileUtil.getRealPath('hive_cache', ''),
                        hiveBoxName: 'HiveCache',
                      ),
                      dio: HttpUtil().dio,
                    ),
                    tileSize: 256,
                  ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      markers: List.generate(state.diaryMapItemList.length, (
                        index,
                      ) {
                        return Marker(
                          point: state.diaryMapItemList[index].latLng,
                          child: GestureDetector(
                            onTap: () async {
                              await logic.toDiaryPage(
                                isarId: state.diaryMapItemList[index].id,
                              );
                            },
                            child:
                                state
                                        .diaryMapItemList[index]
                                        .coverImageName
                                        .isNotEmpty
                                    ? Bubble(
                                      backgroundColor:
                                          context.theme.colorScheme.tertiary,
                                      borderRadius: 8,
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          image: DecorationImage(
                                            image: FileImage(
                                              File(
                                                FileUtil.getRealPath(
                                                  'image',
                                                  state
                                                      .diaryMapItemList[index]
                                                      .coverImageName,
                                                ),
                                              ),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                    : FaIcon(
                                      FontAwesomeIcons.locationDot,
                                      color: context.theme.colorScheme.tertiary,
                                    ),
                          ),
                          width:
                              state
                                      .diaryMapItemList[index]
                                      .coverImageName
                                      .isNotEmpty
                                  ? 56
                                  : 30,
                          height:
                              state
                                      .diaryMapItemList[index]
                                      .coverImageName
                                      .isNotEmpty
                                  ? 64
                                  : 30,
                        );
                      }),
                      rotate: true,
                      maxZoom: 18.0,
                      forceIntegerZoomLevel: true,
                      showPolygon: false,
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: context.theme.colorScheme.tertiaryContainer,
                            border: Border.all(
                              color: context.theme.colorScheme.tertiary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: TextStyle(
                                color:
                                    context
                                        .theme
                                        .colorScheme
                                        .onTertiaryContainer,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          logic.toCurrentPosition();
        },
        child: const FaIcon(FontAwesomeIcons.locationCrosshairs),
      ),
    );
  }
}
