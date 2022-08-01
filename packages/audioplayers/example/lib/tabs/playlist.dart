import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/btn.dart';
import '../components/tab_wrapper.dart';
import 'controllers/jobController.dart';

class Playlist extends GetView<JobController> {
  const Playlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(JobController());
    return TabWrapper(
      children: [
        Btn(
          key: const Key('setSource-from-remote'),
          txt: 'Get CludMedia Remote List',
          onPressed: () async {
            await controller.player
                .setSource(UrlSource(controller.songs[0].music));
            print("selected song is : " + controller.songs[0].music);
          },
        ),
        Btn(
          key: const Key('setSource-from-remote'),
          txt: 'Next',
          onPressed: () async {
            await controller.player
                .setSource(UrlSource(controller.songs[1].music));
            print("selected song is : " + controller.songs[1].music);
            await controller.player.seek(Duration(milliseconds: 0));
          },
        ),
      ],
    );
  }
}
