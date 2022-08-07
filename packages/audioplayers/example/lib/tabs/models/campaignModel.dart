// To parse this JSON data, do
//
//     final campaignModel = campaignModelFromJson(jsonString);

import 'dart:convert';

List<CampaignModel> campaignModelFromJson(String str) =>
    List<CampaignModel>.from(
        json.decode(str).map((x) => CampaignModel.fromJson(x)));

String campaignModelToJson(List<CampaignModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CampaignModel {
  CampaignModel({
    required this.status,
    required this.lastUpdate,
    required this.data,
  });

  bool status;
  int lastUpdate;
  List<CampData> data;

  factory CampaignModel.fromJson(Map<String, dynamic> json) => CampaignModel(
        status: json["status"],
        lastUpdate: json["last_update"],
        data:
            List<CampData>.from(json["data"].map((x) => CampData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "last_update": lastUpdate,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CampData {
  CampData({
    required this.id,
    required this.file,
    required this.playAfterXSongs,
    required this.playAtTheTime,
    required this.banner,
    required this.name,
  });

  int id;
  String file;
  int playAfterXSongs;
  String playAtTheTime;
  String banner;
  String name;

  factory CampData.fromJson(Map<String, dynamic> json) => CampData(
        id: json["id"],
        file: json["file"],
        playAfterXSongs: json["playAfterXSongs"],
        playAtTheTime: json["playAtTheTime"],
        banner: json["banner"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file": file,
        "playAfterXSongs": playAfterXSongs,
        "playAtTheTime": playAtTheTime,
        "banner": banner,
        "name": name,
      };
}
