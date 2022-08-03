// ignore_for_file: unnecessary_null_comparison

import 'package:audioplayers_example/tabs/controllers/jobController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobController>(
        init: JobController(),
        builder: (controller) => Container(
              child: Stack(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          controller.onlineOffline();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          child: controller.online == true
                              ? Icon(Icons.wifi)
                              : Icon(Icons.wifi_off),
                        ),
                      ),
                      /* InkWell(
                        onTap: () async {
                          print(await controller.isUptoDate());
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.textsms_sharp),
                        ),
                      ), */
                      controller.downloading
                          ? Container(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: Container(
                                    width: 25,
                                    height: 25,
                                    child:
                                        Lottie.asset("assets/download.json")),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                controller.forceDownload();
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                child: Icon(Icons.download),
                              ),
                            ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        controller.changePlayerIdx();
                                        print("from ui " +
                                            controller.selectedPlayerIdx
                                                .toString());
                                        controller.update();
                                      },
                                      iconSize: 48.0,
                                      icon: const Icon(Icons.filter_1),
                                      color: controller.selectedPlayerIdx == 0
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        controller.changePlayerIdx();
                                        print("from ui " +
                                            controller.selectedPlayerIdx
                                                .toString());
                                        controller.update();
                                      },
                                      iconSize: 48.0,
                                      icon: const Icon(Icons.filter_2),
                                      color: controller.selectedPlayerIdx == 1
                                          ? Colors.amber
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                                controller.selectedPlayerIdx == 0
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                              key: const Key('play_button'),
                                              onPressed: controller.isPlaying()
                                                  ? null
                                                  : controller.play,
                                              iconSize: 48.0,
                                              icon:
                                                  const Icon(Icons.play_arrow),
                                              color: Colors.green),
                                          IconButton(
                                              key: const Key('pause_button'),
                                              onPressed: controller.isPlaying()
                                                  ? controller.pause
                                                  : null,
                                              iconSize: 48.0,
                                              icon: const Icon(Icons.pause),
                                              color: Colors.green),
                                          IconButton(
                                              key: const Key('stop_button'),
                                              onPressed:
                                                  controller.isPlaying() ||
                                                          controller.isPaused()
                                                      ? controller.stop
                                                      : null,
                                              iconSize: 48.0,
                                              icon: const Icon(Icons.stop),
                                              color: Colors.green),
                                          IconButton(
                                              key: const Key('next_button'),
                                              onPressed:
                                                  controller.isPlaying() ||
                                                          controller.isPaused()
                                                      ? controller.next
                                                      : null,
                                              iconSize: 48.0,
                                              icon: const Icon(Icons.skip_next),
                                              color: Colors.green),
                                          /* IconButton(
                                            key: const Key('stop_all'),
                                            onPressed: controller.stopAll,
                                            iconSize: 48.0,
                                            icon: const Icon(Icons.stop),
                                            color: Colors.red,
                                          ), */
                                        ],
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            key: const Key('play_button'),
                                            onPressed: controller.isPlaying()
                                                ? null
                                                : controller.play,
                                            iconSize: 48.0,
                                            icon: const Icon(Icons.play_arrow),
                                            color: Colors.amber,
                                          ),
                                          IconButton(
                                            key: const Key('pause_button'),
                                            onPressed: controller.isPlaying()
                                                ? controller.pause
                                                : null,
                                            iconSize: 48.0,
                                            icon: const Icon(Icons.pause),
                                            color: Colors.amber,
                                          ),
                                          IconButton(
                                            key: const Key('stop_button'),
                                            onPressed: controller.isPlaying() ||
                                                    controller.isPaused()
                                                ? controller.stop
                                                : null,
                                            iconSize: 48.0,
                                            icon: const Icon(Icons.stop),
                                            color: Colors.amber,
                                          ),
                                          IconButton(
                                            key: const Key('next_button'),
                                            onPressed: controller.isPlaying() ||
                                                    controller.isPaused()
                                                ? controller.next
                                                : null,
                                            iconSize: 48.0,
                                            icon: const Icon(Icons.skip_next),
                                            color: Colors.amber,
                                          ),
                                          /* IconButton(
                                            key: const Key('stop_all'),
                                            onPressed: controller.stopAll,
                                            iconSize: 48.0,
                                            icon: const Icon(Icons.stop),
                                            color: Colors.red,
                                          ), */
                                        ],
                                      ),
                                controller.selectedPlayerIdx == 0
                                    ? Slider(
                                        activeColor: Colors.green,
                                        onChanged: (v) {
                                          final duration = controller.durations[
                                              controller.selectedPlayerIdx!];
                                          if (duration == null) {
                                            return;
                                          }
                                          final position =
                                              v * duration.inMilliseconds;
                                          controller.player.seek(Duration(
                                              milliseconds: position.round()));
                                        },
                                        value: (controller
                                                        .positions[controller
                                                            .selectedPlayerIdx!]
                                                        .inMilliseconds >
                                                    0 &&
                                                controller
                                                        .positions[controller
                                                            .selectedPlayerIdx!]
                                                        .inMilliseconds <
                                                    controller
                                                        .durations[controller
                                                            .selectedPlayerIdx!]
                                                        .inMilliseconds)
                                            ? controller
                                                    .positions[controller
                                                        .selectedPlayerIdx!]
                                                    .inMilliseconds /
                                                controller
                                                    .durations[controller
                                                        .selectedPlayerIdx!]
                                                    .inMilliseconds
                                            : 0.0,
                                      )
                                    : Slider(
                                        activeColor: Colors.amber,
                                        onChanged: (v) {
                                          final duration =
                                              controller.durations[1];
                                          if (duration == null) {
                                            return;
                                          }
                                          final position =
                                              v * duration.inMilliseconds;
                                          controller.players[1].seek(Duration(
                                              milliseconds: position.round()));
                                        },
                                        value: (controller.positions[1]
                                                        .inMilliseconds >
                                                    0 &&
                                                controller.positions[1]
                                                        .inMilliseconds <
                                                    controller.durations[1]
                                                        .inMilliseconds)
                                            ? controller.positions[1]
                                                    .inMilliseconds /
                                                controller
                                                    .durations[1].inMilliseconds
                                            : 0.0,
                                      ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Icon(Icons.volume_up),
                              RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                    value: controller.volume,
                                    onChanged: (v) {
                                      controller.volumeChanger(v);
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        controller.positions[controller.selectedPlayerIdx!] !=
                                null
                            ? controller.positionText.toString() +
                                '/' +
                                controller
                                    .durations[controller.selectedPlayerIdx!]
                                    .toString()
                                    .split('.')
                                    .first
                            : controller.durations[
                                        controller.selectedPlayerIdx!] !=
                                    null
                                ? controller.durationText
                                : '',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      Text('State: Selected state ' +
                          controller.getselectedPlayerIdx +
                          controller.pss[controller.selectedPlayerIdx!]
                              .toString()),
                      Text('Active Player Id:' +
                          controller.getselectedPlayerIdx),
                    ],
                  ),
                  controller.online && !controller.connection
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            alignment: Alignment.center,
                            height: 30,
                            color: Colors.red[400],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                context.width < 320
                                    ? Text("")
                                    : Text("İnternete bağlı gözükmüyor."),
                                TextButton(
                                  child: Text(
                                    "OfflineModa Geç",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    //controller.onlineOffline();
                                    //controller.update();
                                    print(Get.width);
                                  },
                                )
                              ],
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ));
  }
}
