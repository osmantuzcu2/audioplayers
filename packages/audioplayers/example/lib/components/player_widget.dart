import 'package:audioplayers_example/tabs/controllers/jobController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerWidget extends GetView<JobController> {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(JobController());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: controller.isPlaying ? null : controller.play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: controller.isPlaying ? controller.pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: controller.isPlaying || controller.isPaused
                  ? controller.stop
                  : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('next_button'),
              onPressed: controller.isPlaying || controller.isPaused
                  ? controller.next
                  : null,
              iconSize: 48.0,
              icon: const Icon(Icons.skip_next),
              color: Colors.cyan,
            ),
          ],
        ),
        Slider(
          onChanged: (v) {
            final duration = controller.duration;
            if (duration == null) {
              return;
            }
            final position = v * duration.inMilliseconds;
            controller.player.seek(Duration(milliseconds: position.round()));
          },
          value: (controller.position != null &&
                  controller.duration != null &&
                  controller.position!.inMilliseconds > 0 &&
                  controller.position!.inMilliseconds <
                      controller.duration!.inMilliseconds)
              ? controller.position!.inMilliseconds /
                  controller.duration!.inMilliseconds
              : 0.0,
        ),
        Text(
          controller.position != null
              ? controller.positionText.toString() +
                  '/' +
                  controller.duration.toString().split('.').first
              : controller.duration != null
                  ? controller.durationText
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
        Text('State:' + controller.audioPlayerState.toString()),
      ],
    );
  }
}
