// To parse this JSON data, do
//
//     final songModel = songModelFromJson(jsonString);

import 'dart:convert';

List<SongModel> songModelFromJson(String str) =>
    List<SongModel>.from(json.decode(str).map((x) => SongModel.fromJson(x)));

String songModelToJson(List<SongModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SongModel {
  SongModel({
    required this.status,
    required this.lastUpdate,
    required this.data,
  });

  bool status;
  int lastUpdate;
  List<Datum> data;

  factory SongModel.fromJson(Map<String, dynamic> json) => SongModel(
        status: json["status"],
        lastUpdate: json["last_update"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "last_update": lastUpdate,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.name,
    required this.music,
  });

  String id;
  String name;
  String music;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        music: json["music"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "music": music,
      };
}
