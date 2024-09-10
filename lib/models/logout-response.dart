// To parse this JSON data, do
//
//     final logoutResponseModel = logoutResponseModelFromJson(jsonString);

import 'dart:convert';

LogoutResponseModel logoutResponseModelFromJson(String str) => LogoutResponseModel.fromJson(json.decode(str));

String logoutResponseModelToJson(LogoutResponseModel data) => json.encode(data.toJson());

class LogoutResponseModel {
    String message;

    LogoutResponseModel({
        required this.message,
    });

    factory LogoutResponseModel.fromJson(Map<String, dynamic> json) => LogoutResponseModel(
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
    };
}
