import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_media/components/tabs.dart';
import 'package:cloud_media/components/tgl.dart';
import 'package:cloud_media/tabs/audio_context.dart';
import 'package:cloud_media/tabs/controls.dart';
import 'package:cloud_media/tabs/logger.dart';
import 'package:cloud_media/tabs/sources.dart';
import 'package:cloud_media/tabs/streams.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'tabs/controllers/jobController.dart';
import 'tabs/playlist.dart';
import 'package:get/get.dart';

typedef OnError = void Function(Exception exception);

Future<void> main() async {
  await GetStorage.init();
  runApp(GetMaterialApp(home: ExampleApp()));
}

class ExampleApp extends GetView<JobController> {
  @override
  Widget build(BuildContext context) {
    Get.put(JobController());
    return Scaffold(
        /*   appBar: AppBar(
        title: const Text('audioplayers example'),
      ), */
        body: Stack(
      children: [
        StreamsTab(
          player: controller.player,
        ),
        controller.isLoading
            ? Center(
                child: Container(
                    width: 50, height: 50, child: CircularProgressIndicator()),
              )
            : Container()
      ],
    ) /* Column(
        children: [
          Expanded(
            child: Tabs(
              tabs: [
                TabData(
                  key: 'playlistTab',
                  label: 'Plist',
                  content: Playlist(),
                ),
                TabData(
                  key: 'sourcesTab',
                  label: 'Src',
                  content: SourcesTab(
                    player: controller.player,
                  ),
                ),
                TabData(
                  key: 'controlsTab',
                  label: 'Ctrl',
                  content: ControlsTab(
                    player: controller.player,
                  ),
                ),
                TabData(
                  key: 'streamsTab',
                  label: 'Stream',
                  content: StreamsTab(
                    player: controller.player,
                  ),
                ),
                TabData(
                  key: 'audioContextTab',
                  label: 'Ctx',
                  content: AudioContextTab(
                    player: controller.player,
                  ),
                ),
                TabData(
                  key: 'loggerTab',
                  label: 'Log',
                  content: const LoggerTab(),
                ),
              ],
            ),
          ),
        ],
      ),
     */
        );
  }
}
