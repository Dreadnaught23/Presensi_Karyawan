// To parse this JSON data, do
//
//     final homeResponseModel = homeResponseModelFromJson(jsonString);

import 'dart:convert';

HomeResponseModel homeResponseModelFromJson(String str) => HomeResponseModel.fromJson(json.decode(str));

String homeResponseModelToJson(HomeResponseModel data) => json.encode(data.toJson());

class HomeResponseModel {
    bool success;
    String message;
    List<Datum> data;

    HomeResponseModel({
        required this.success,
        required this.message,
        required this.data,
    });

    factory HomeResponseModel.fromJson(Map<String, dynamic> json) => HomeResponseModel(
        success: json["success"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int id;
    int userId;
    String latitude;
    String longitude;
    String tanggal;
    String masuk;
    dynamic pulang;
    DateTime createdAt;
    DateTime updatedAt;
    bool isHariIni;

    Datum({
        required this.id,
        required this.userId,
        required this.latitude,
        required this.longitude,
        required this.tanggal,
        required this.masuk,
        required this.pulang,
        required this.createdAt,
        required this.updatedAt,
        required this.isHariIni,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["user_id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        tanggal: json["tanggal"],
        masuk: json["masuk"],
        pulang: json["pulang"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        isHariIni: json["is_hari_ini"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "latitude": latitude,
        "longitude": longitude,
        "tanggal": tanggal,
        "masuk": masuk,
        "pulang": pulang,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "is_hari_ini": isHariIni,
    };
}
