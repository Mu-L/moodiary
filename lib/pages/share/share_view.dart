import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodiary/common/values/icons.dart';
import 'package:moodiary/components/mood_icon/mood_icon_view.dart';
import 'package:moodiary/l10n/l10n.dart';
import 'package:moodiary/utils/file_util.dart';

import 'share_logic.dart';

class SharePage extends StatelessWidget {
  const SharePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Bind.find<ShareLogic>();
    final state = Bind.find<ShareLogic>().state;

    final imageColor = state.diary.imageColor;
    final colorScheme =
        imageColor != null
            ? ColorScheme.fromSeed(
              seedColor: Color(imageColor),
              brightness: Theme.of(context).brightness,
            )
            : Theme.of(context).colorScheme;
    const cardSize = 300.0;
    return GetBuilder<ShareLogic>(
      builder: (_) {
        return Theme(
          data:
              imageColor != null
                  ? Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Color(imageColor),
                      brightness: Theme.of(context).brightness,
                    ),
                  )
                  : Theme.of(context),
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(title: Text(context.l10n.shareTitle)),
            extendBodyBehindAppBar: true,
            body: Center(
              child: RepaintBoundary(
                key: state.key,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withAlpha(
                          (255 * 0.5).toInt(),
                        ),
                        blurRadius: 5.0,
                        offset: const Offset(5.0, 10.0),
                      ),
                    ],
                  ),
                  width: cardSize,
                  height: cardSize * 1.618,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (state.diary.imageName.isNotEmpty) ...[
                        Container(
                          height: cardSize * 1.618 * 0.618,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(
                                File(
                                  FileUtil.getRealPath(
                                    'image',
                                    state.diary.imageName.first,
                                  ),
                                ),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              state.diary.contentText,
                              overflow: TextOverflow.fade,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                MoodIconComponent(
                                  value: state.diary.mood,
                                  width:
                                      (context.textTheme.titleSmall!.fontSize! *
                                          context
                                              .textTheme
                                              .titleSmall!
                                              .height!),
                                ),
                                if (state.diary.weather.isNotEmpty) ...[
                                  const SizedBox(
                                    height: 12.0,
                                    child: VerticalDivider(width: 12.0),
                                  ),
                                  Icon(
                                    WeatherIcon.map[state.diary.weather.first],
                                    size:
                                        context
                                            .textTheme
                                            .titleSmall!
                                            .fontSize! *
                                        context.textTheme.titleSmall!.height!,
                                  ),
                                ],
                                const SizedBox(width: 12.0),
                                Text(
                                  state.diary.time.toString().split(' ')[0],
                                  style: context.textTheme.titleSmall,
                                ),
                              ],
                            ),
                            Text(
                              context.l10n.shareName,
                              style: context.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                logic.share(context);
              },
              child: const Icon(Icons.share),
            ),
          ),
        );
      },
    );
  }
}
