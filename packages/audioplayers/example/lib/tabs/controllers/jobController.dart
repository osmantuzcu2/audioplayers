// ignore_for_file: avoid_print, unnecessary_overrides, non_constant_identifier_names, prefer_typing_uninitialized_variables, file_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../models/campaignModel.dart';
import '../models/songModel.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../services/remote_services.dart';

class JobController extends GetxController {
  String songsUrl = 'https://novemyazilim.com/music-app.php';
  String campaignsUrl = 'https://novemyazilim.com/music-app-campaings1.php';
  String campaignsUrlTimed =
      'https://novemyazilim.com/music-app-campaings1.php?timed=true';

  final box = GetStorage();
  List<Datum> songs = [];
  List<SongModel>? fullJson;
  int? lastUpdate;
  List<CampData> campaigns = [];
  List<CampaignModel>? fullCampaignJson;
  int? campLastUpdate;
  List<CampData> timedCampaigns = [];
  List<CampaignModel>? fullTimedCampaignJson;
  int? campTimedLastUpdate;

  bool isLoading = false;
  String? progressString;
  List<AudioPlayer> players = List.generate(3, (_) => AudioPlayer());
  double volume = 1.0;
  bool online = true;
  bool neverShowDownloadAlert = false;
  bool downloading = false;
  bool connection = true;
  String downloadText = '';

  int? selectedPlayerIdx;
  changePlayerIdx() {
    if (selectedPlayerIdx == 0) {
      selectedPlayerIdx = 1;
      update();
    } else {
      selectedPlayerIdx = 0;
      update();
    }
  }

  AudioPlayer get player => players[selectedPlayerIdx ?? 0];

  // player states

  List<Duration> durations = [Duration(), Duration(), Duration()];
  List<Duration> positions = [Duration(), Duration(), Duration()];

  List<PlayerState> pss = [
    PlayerState.stopped,
    PlayerState.stopped,
    PlayerState.stopped
  ];

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  StreamSubscription? _durationSubscription2;
  StreamSubscription? _positionSubscription2;
  StreamSubscription? _playerCompleteSubscription2;
  StreamSubscription? _playerStateChangeSubscription2;

  StreamSubscription? _playerCompleteSubscription3;
  int playingSongsId = 0;
  int counter = 1;

  bool isPlaying() => pss[selectedPlayerIdx ?? 0] == PlayerState.playing;
  bool isPaused() => pss[selectedPlayerIdx ?? 0] == PlayerState.paused;
  String get durationText =>
      durations[selectedPlayerIdx ?? 0].toString().split('.').first;
  String get positionText =>
      positions[selectedPlayerIdx ?? 0].toString().split('.').first;
  String get getselectedPlayerIdx => selectedPlayerIdx.toString();

  late StreamSubscription<ConnectivityResult> subscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    await dirCreate();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        connection = false;
        update();
      } else {
        connection = true;
        update();
        print("connection established");
      }
      ;
    });
    getSongs();
    getXCampaigns();
    getTimedCampaigns();
    selectedPlayerIdx = 0;
    _initStreams();

    if (box.read("neverShowDownloadAlert"))
      neverShowDownloadAlert = true;
    else
      neverShowDownloadAlert = false;
    bool offlineMod = box.read("offlineMod") ?? false;
    //offline mod açık ve liste güncel değilse
    if (offlineMod && !await isUptoDate()) downloadAll(false);
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
    _durationSubscription2?.cancel();
    _positionSubscription2?.cancel();
    _playerCompleteSubscription2?.cancel();
    _playerStateChangeSubscription2?.cancel();
    super.dispose();
  }

  bool only = false;
  void _initStreams() {
    _durationSubscription = players[0].onDurationChanged.listen((d) {
      durations[0] = d;
      update();
    });

    _positionSubscription = players[0].onPositionChanged.listen(
      (p) {
        positions[0] = p;
        Duration fark = durations[0] - p;
        if (fark < Duration(seconds: 10)) {
          //volume dec
          if (only == false) {
            next();
            only = true;
          }
          players[0].setVolume(fadeEffect(fark));
          //print(durations[0] - p);
        }
        if (p < Duration(seconds: 6)) {
          //volume inc
          players[0].setVolume(fadeEffect(p));
          //print(p);
        } else {
          players[0].setVolume(volume);
        }

        update();
      },
    );

    _playerCompleteSubscription = players[0].onPlayerComplete.listen((event) {
      players[0].stop();

      pss[0] = PlayerState.stopped;
      positions[0] = durations[0];
      //print("bitti");
    });

    _durationSubscription2 = players[1].onDurationChanged.listen((d) {
      durations[1] = d;
    });

    _positionSubscription2 = players[1].onPositionChanged.listen(
      (p) {
        positions[1] = p;
        Duration fark = durations[1] - p;
        if (fark < Duration(seconds: 10)) {
          //volume dec
          if (only == false) {
            next();
            only = true;
          }
          players[1].setVolume(fadeEffect(fark));
          //print(durations[1] - p);
        }
        if (p < Duration(seconds: 6)) {
          //volume inc
          players[1].setVolume(fadeEffect(p));
          //print(p);
        } else {
          players[1].setVolume(volume);
        }

        update();
      },
    );

    _playerCompleteSubscription2 = players[1].onPlayerComplete.listen((event) {
      players[1].stop();

      pss[1] = PlayerState.stopped;
      positions[1] = durations[1];
      //print("ends");
    });
    _playerCompleteSubscription3 = players[2].onPlayerComplete.listen((event) {
      players[2].stop();
      next();
      //print("ends");
    });
  }

  Future<void> randomMusic() async {
    int ret;
    do {
      var rnd = Random();
      ret = rnd.nextInt(songs.length);
    } while (ret == playingSongsId);
    if (online == true)
      await player.setSource(UrlSource(songs[ret].music));
    else {
      var directory = await getApplicationDocumentsDirectory();
      //print(directory.path + "\\.arsiv\\" + songs[ret].music);

      await player.setSourceDeviceFile(
          directory.path + "\\.arsiv\\" + songs[ret].name + ".mp3");
    }

    playingSongsId = ret;
    //print(ret);
  }

  double fadeEffect(Duration d) {
    if (d == Duration(seconds: 5)) {
      return 1.0;
    } else if (d == Duration(seconds: 4)) {
      return 0.80;
    } else if (d == Duration(seconds: 3)) {
      return 0.60;
    } else if (d == Duration(seconds: 2)) {
      return 0.40;
    } else if (d == Duration(seconds: 1)) {
      return 0.20;
    } else if (d == Duration(seconds: 0)) {
      return 0.05;
    } else {
      return 1.0;
    }
  }

  volumeChanger(double v) {
    player.setVolume(v);
    volume = v;
  }

  Future<void> play() async {
    isLoading = true;
    update();
    if (!isPaused()) randomMusic();
    final _position = positions[selectedPlayerIdx!];
    if (_position.inMilliseconds > 0) {
      await player.seek(_position);
    }
    await player.resume();
    pss[selectedPlayerIdx!] = PlayerState.playing;

    isLoading = false;
    update();
  }

  Future<int> isCampShouldPlay() async {
    int ret = -1;
    for (var i = 0; i < campaigns.length; i++) {
      if (counter.remainder(campaigns[i].playAfterXSongs + 1) == 0 &&
          counter != 0) {
        ret = i;

        break;
      }
    }
    return ret;
  }

  Future<void> next() async {
    Future.delayed(Duration(seconds: 10), () {
      selectedPlayerIdx == 0 ? stopOnly(1) : stopOnly(0);
      only = false;
    });
    if (await isCampShouldPlay() != -1) {
      int i = await isCampShouldPlay();
      selectedPlayerIdx = 2;
      update();
      await player.setSource(UrlSource(campaigns[i].file));
      await player.seek(Duration(milliseconds: 0));
      await player.resume();
      print('reklam çalınıyor');
    } else {
      changePlayerIdx();
      randomMusic();
      await player.seek(Duration(milliseconds: 0));

      await player.resume();
      pss[selectedPlayerIdx!] = PlayerState.playing;
      print("reklam yok.");
    }
    counter++;
    print("counter= " + counter.toString());
  }

  Future<void> pause() async {
    await player.pause();
    pss[selectedPlayerIdx!] = PlayerState.paused;
  }

  Future<void> stop() async {
    await player.stop();

    pss[selectedPlayerIdx!] = PlayerState.stopped;
    positions[selectedPlayerIdx!] = Duration.zero;
  }

  Future<void> stopOnly(int a) async {
    await players[a].stop();

    pss[a] = PlayerState.stopped;
    positions[a] = Duration.zero;
  }

  Future<void> stopAll() async {
    await players[0].stop();
    await players[1].stop();

    pss[0] = PlayerState.stopped;
    positions[0] = Duration.zero;

    pss[1] = PlayerState.stopped;
    positions[1] = Duration.zero;
  }

  bool isSourceSet = false;

  Future<void> getSongs() async {
    try {
      isLoading = true;

      var result = await RemoteServices.getSongs(songsUrl);
      //print(result);
      if (result != null && result != 'null' && result != '[]') {
        songs = songModelFromJson(result).first.data;
        lastUpdate = songModelFromJson(result).first.lastUpdate;
        fullJson = songModelFromJson(result);
        for (var item in songs) {
          // print(item.name);

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

  Future<void> getXCampaigns() async {
    try {
      isLoading = true;

      var result = await RemoteServices.getSongs(campaignsUrl);
      //print(result);
      if (result != null && result != 'null' && result != '[]') {
        campaigns = campaignModelFromJson(result).first.data;
        campLastUpdate = campaignModelFromJson(result).first.lastUpdate;
        fullCampaignJson = campaignModelFromJson(result);
        for (var item in campaigns) {
          print(item.file);

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

  Future<void> getTimedCampaigns() async {
    try {
      isLoading = true;

      var result = await RemoteServices.getSongs(campaignsUrlTimed);
      //print(result);
      if (result != null && result != 'null' && result != '[]') {
        timedCampaigns = campaignModelFromJson(result).first.data;
        campTimedLastUpdate = campaignModelFromJson(result).first.lastUpdate;
        fullTimedCampaignJson = campaignModelFromJson(result);
        for (var item in timedCampaigns) {
          print(item.file);
          Timer(
              DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      int.parse(item.playAtTheTime.split(":").first),
                      int.parse(item.playAtTheTime.split(":").last))
                  .difference(DateTime.now()), () async {
            print("Zamanlanmış reklam çalınıyor");
            selectedPlayerIdx = 2;
            update();
            await player.setSource(UrlSource(item.file));
            await player.seek(Duration(milliseconds: 0));
            await player.resume();
          });
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

  initDownloadableSong() async {
    if (await anyOfflineSong() == false && neverShowDownloadAlert == false) {
      dialog(
          title: "Uyarı",
          desc:
              "Bilgisayarınızda offline liste bulunmadığını görüyorum.İnternet kesintilerinde müziğin devam etmesi için listeleri bilgisayarınıza indirmek ister misiniz?",
          widgets: [
            TextButton(
              child: Text("Arkaplanda indir"),
              onPressed: () {},
            ),
            TextButton(
              child: Text("Birdaha gösterme"),
              onPressed: () {
                neverShowDownloadAlert = true;
                box.write("neverShowDownloadAlert", true);
                Get.back();
              },
            ),
            TextButton(
              child: Text("Daha sonra hatırlat"),
              onPressed: () {
                Get.back();
              },
            )
          ]);
    } else {
      // print("var");
      // print("box neverShowDownloadAlert " + box.read("neverShowDownloadAlert").toString());
    }
  }

  forceDownload() {
    dialog(
        title: "Uyarı",
        desc: "Offline listeler indirilecektir onaylıyor musun?",
        widgets: [
          TextButton(
            child: Text("Arkaplanda indir"),
            onPressed: () {
              downloadAll(true);
              Get.back();
            },
          ),
          TextButton(
            child: Text("Vazgeç"),
            onPressed: () {
              Get.back();
            },
          ),
        ]);
  }

  dialog({String? title, String? desc, List<Widget>? widgets}) {
    Get.defaultDialog(
        title: title ?? "",
        middleText: desc ?? "",
        backgroundColor: Colors.green[100],
        titleStyle: TextStyle(color: Colors.black),
        middleTextStyle: TextStyle(color: Colors.black),
        actions: widgets);
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen((file) {
      files.add(file);
      //print(file);
      //print(file.path);
    },
        // should also register onError

        onDone: () {
      completer.complete(files);
    });
    return completer.future;
  }

  onlineOffline() async {
    if (online == true) {
      if (await anyOfflineSong() == true) {
        box.write("offlineMod", true);
        //json dosyasından oku
        var directory = await getApplicationDocumentsDirectory();
        File file = File(await directory.path + "/.arsiv/list.json");
        if (file.existsSync()) {
          songs = songModelFromJson(file.readAsStringSync()).first.data;
          online = false;
          update();
        } else
          dialog(
              title: "Uyarı",
              desc: "Offline liste bulunamadı. İndirmek istiyor musun?",
              widgets: [
                TextButton(
                  child: Text("Arkaplanda indir"),
                  onPressed: () {
                    downloadAll(true);
                    Get.back();
                  },
                ),
                TextButton(
                  child: Text("Vazgeç"),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ]);
      } else {
        dialog(
            title: "Uyarı",
            desc: "Offline liste bulunamadı. İndirmek istiyor musun?",
            widgets: [
              TextButton(
                child: Text("Arkaplanda indir"),
                onPressed: () {
                  downloadAll(true);
                  Get.back();
                },
              ),
              TextButton(
                child: Text("Vazgeç"),
                onPressed: () {
                  Get.back();
                },
              ),
            ]);
      }
    } else {
      online = true;
      update();
    }
  }

  Future<bool> anyOfflineSong() async {
    var directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files =
        Directory(directory.path + "/.arsiv/").listSync();
    if (files.length != 0) {
      if (files[0].path.split(".").last == "mp3")
        return true;
      else
        return false;
    } else
      return false;
  }

  downloadAll(bool first) async {
    downloading = true;
    var directory = await getApplicationDocumentsDirectory();
    File file = File(await directory.path + "/.arsiv/list.json"); // 1
    File file2 = File(await directory.path + "/.arsiv/online.json"); // 1
    if (first == true)
      for (var song in songs) {
        await download(song.name, song.music);
      }
    else {
      List<Datum> offlineSongs =
          songModelFromJson(file.readAsStringSync()).first.data;

      for (var i = 0; i < songs.length; i++) {
        if (offlineSongs.where((element) => songs[i].id == element.id).length <
            1) {
          print("indirilecek " + songs[i].name);
          await download(songs[i].name, songs[i].music);
        }
      }
      for (var i = 0; i < offlineSongs.length; i++) {
        if (songs.where((element) => offlineSongs[i].id == element.id).length <
            1) {
          print("silinecek " + offlineSongs[i].name);
          File delFile = File(await directory.path +
              "/.arsiv/" +
              offlineSongs[i].name +
              ".mp3");
          delFile.delete();
        }
      }
      //indirilmiş müzikler varsa sadece değişenleri indir eskileri sil

    }
    //json dosyasına yaz

    await getSongs();
    file.writeAsStringSync(jsonEncode(fullJson)); // 2

    downloading = false;
  }

  download(String title, String downloadurl) async {
    var directory = await getApplicationDocumentsDirectory();
    Dio dio = Dio();
    try {
      //print(downloadurl);
      //print(directory.path);
      await dio.download(downloadurl, "${directory.path}/.arsiv/$title.mp3",
          onReceiveProgress: (rec, total) {
        //print("Rec: $rec, Total:$total");
        progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";

        //print(progressString);
        update();
      });
    } catch (e) {
      //print(e);
//Catch your error here
    }
    progressString = "";
    update();
  }

  Future<bool> isUptoDate() async {
    var directory = await getApplicationDocumentsDirectory();
    File file = File(await directory.path + "/.arsiv/list.json");
    if (file.existsSync()) {
      await getSongs();
      int lastUpdateInFile =
          songModelFromJson(file.readAsStringSync()).first.lastUpdate;
      if (lastUpdate == lastUpdateInFile)
        return true;
      else
        return false;
    } else
      return false;
  }

  dirCreate() async {
    var directory = await getApplicationDocumentsDirectory();
    if (!await await Directory(directory.path + "/.arsiv").exists()) ;
    Directory(directory.path + "/.arsiv").create();
  }
}
