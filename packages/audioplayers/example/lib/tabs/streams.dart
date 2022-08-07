import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_media/components/btn.dart';
import 'package:cloud_media/components/pad.dart';
import 'package:cloud_media/components/player_widget.dart';
import 'package:cloud_media/components/tab_wrapper.dart';
import 'package:cloud_media/utils.dart';
import 'package:flutter/material.dart';

class StreamsTab extends StatefulWidget {
  final AudioPlayer player;

  const StreamsTab({Key? key, required this.player}) : super(key: key);

  @override
  State<StreamsTab> createState() => _StreamsTabState();
}

class _StreamsTabState extends State<StreamsTab>
    with AutomaticKeepAliveClientMixin<StreamsTab> {
  Duration? position, duration;
  late List<StreamSubscription> streams;

  Duration? streamDuration, streamPosition;
  PlayerState? state;

  @override
  void initState() {
    super.initState();
    streams = <StreamSubscription>[
      widget.player.onDurationChanged
          .listen((it) => setState(() => streamDuration = it)),
      widget.player.onPlayerStateChanged
          .listen((it) => setState(() => state = it)),
      widget.player.onPositionChanged
          .listen((it) => setState(() => streamPosition = it)),
      /*  widget.player.onPlayerComplete.listen((it) => toast('Player complete!')),
      widget.player.onSeekComplete.listen((it) => toast('Seek complete!')), */
    ];
  }

  @override
  void dispose() {
    super.dispose();
    streams.forEach((it) => it.cancel());
  }

  Future<void> getPosition() async {
    final position = await widget.player.getCurrentPosition();
    setState(() => this.position = position);
  }

  Future<void> getDuration() async {
    final duration = await widget.player.getDuration();
    setState(() => this.duration = duration);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return /* TabWrapper(
      children: [ */
        PlayerWidget();
    /* ],
    ) */
    ;
  }

  @override
  bool get wantKeepAlive => true;
}
