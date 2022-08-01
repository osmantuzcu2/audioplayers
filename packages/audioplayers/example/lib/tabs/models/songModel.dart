// To parse this JSON data, do
//
//     final songModel = songModelFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

List<SongModel> songModelFromJson(String str) => List<SongModel>.from(json.decode(str).map((x) => SongModel.fromJson(x)));

String songModelToJson(List<SongModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SongModel {
    SongModel({
        required this.id,
        required this.name,
        required this.music,
    });

    String id;
    String name;
    String music;

    factory SongModel.fromJson(Map<String, dynamic> json) => SongModel(
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
