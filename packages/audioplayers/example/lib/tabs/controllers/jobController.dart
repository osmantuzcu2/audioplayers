// ignore_for_file: avoid_print, unnecessary_overrides, non_constant_identifier_names, prefer_typing_uninitialized_variables, file_names

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import '../models/songModel.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../services/remote_services.dart';

class JobController extends GetxController {
  List<SongModel> songs = [];
  bool isLoading = false;
  String? progressString;
  List<AudioPlayer> players = List.generate(4, (_) => AudioPlayer());
  int selectedPlayerIdx = 0;
  AudioPlayer get player => players[selectedPlayerIdx];

  // player states
  PlayerState? audioPlayerState;
  Duration? duration;
  Duration? position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  int playingSongsId = 0;

  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  String get durationText => duration?.toString().split('.').first ?? '';
  String get positionText => position?.toString().split('.').first ?? '';

  @override
  Future<void> onInit() async {
    super.onInit();
    getSongs();
    _initStreams();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void dispose() {
    //
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((d) {
      duration = d;
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => position = p,
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      player.stop();

      _playerState = PlayerState.stopped;
      position = duration;
      print("bitti");
      next();
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      audioPlayerState = state;
    });
  }

  Future<void> randomMusic() async {
    int ret;
    do {
      var rnd = Random();
      ret = rnd.nextInt(songs.length);
    } while (ret == playingSongsId);

    await player.setSource(UrlSource(songs[ret].music));
    playingSongsId = ret;
    //print(ret);
  }

  Future<void> play() async {
    if (!isPaused) randomMusic();
    final _position = position;
    if (_position != null && _position.inMilliseconds > 0) {
      await player.seek(_position);
    }
    await player.resume();
    _playerState = PlayerState.playing;
  }

  Future<void> next() async {
    randomMusic();
    await player.seek(Duration(milliseconds: 0));

    await player.resume();
    _playerState = PlayerState.playing;
  }

  Future<void> pause() async {
    await player.pause();
    _playerState = PlayerState.paused;
  }

  Future<void> stop() async {
    await player.stop();

    _playerState = PlayerState.stopped;
    position = Duration.zero;
  }

  bool isSourceSet = false;

  Future<void> setSource(Source source) async {
    isSourceSet = false;
    await player.setSource(source);
    isSourceSet = true;
  }

  Future<void> getSongs() async {
    try {
      isLoading = true;
      var directory = await getApplicationDocumentsDirectory();
      dirContents(Directory(directory.path + '/.arsiv/'));

      var result = await RemoteServices.getSongs();
      print(result);
      if (result != null && result != 'null' && result != '[]') {
        songs = songModelFromJson(result);
        for (var item in songs) {
          print(item.name);

          //  Download(item.name, item.music);
        }
        // print(songs[0].name + songs[0].music);
        update();
      } else {
        //   Get.snackbar('Uyarı', 'Hareket bulunamadı');
      }
    } finally {
      isLoading = false;
    }
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen((file) {
      files.add(file);
      print(file);
      print(file.path);
    },
        // should also register onError

        onDone: () {
      completer.complete(files);
    });
    return completer.future;
  }

  void Download(String title, String downloadurl) async {
    var directory = await getApplicationDocumentsDirectory();
    Dio dio = Dio();
    try {
      print(downloadurl);
      print(directory.path);
      await dio.download(downloadurl, "${directory.path}/.arsiv/$title.mp3",
          onReceiveProgress: (rec, total) {
        // print("Rec: $rec, Total:$total");
        progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        //  print(progressString);
        update();
      });
    } catch (e) {
      print(e);
//Catch your error here
    }
  }
}
