import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/tabs.dart';
import 'package:audioplayers_example/components/tgl.dart';
import 'package:audioplayers_example/tabs/audio_context.dart';
import 'package:audioplayers_example/tabs/controls.dart';
import 'package:audioplayers_example/tabs/logger.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:audioplayers_example/tabs/streams.dart';
import 'package:flutter/material.dart';

import 'tabs/controllers/jobController.dart';
import 'tabs/playlist.dart';
import 'package:get/get.dart';

typedef OnError = void Function(Exception exception);

void main() {
  runApp(MaterialApp(home: ExampleApp()));
}

class ExampleApp extends GetView<JobController> {
  @override
  Widget build(BuildContext context) {
    Get.put(JobController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('audioplayers example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Tgl(
                options: const ['P1', 'P2', 'P3', 'P4'],
                selected: controller.selectedPlayerIdx,
                onChange: (v) {
                  controller.selectedPlayerIdx = v;
                },
              ),
            ),
          ),
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
    );
  }
}
