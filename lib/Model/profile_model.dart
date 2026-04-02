// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  int? id;
  String? mId;
  String? name;
  String? mobile;
  String? email;
  String? whatsapp;
  String? area;
  String? description;
  String? services;

  ProfileModel({
    this.id,
    this.mId,
    this.name,
    this.mobile,
    this.email,
    this.whatsapp,
    this.area,
    this.description,
    this.services,
  });

  ProfileModel copyWith({
    int? id,
    String? mId,
    String? name,
    String? mobile,
    String? email,
    String? whatsapp,
    String? area,
    String? description,
    String? services,
  }) =>
      ProfileModel(
        id: id ?? this.id,
        mId: mId ?? this.mId,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        email: email ?? this.email,
        whatsapp: whatsapp ?? this.whatsapp,
        area: area ?? this.area,
        description: description ?? this.description,
        services: services ?? this.services,
      );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json["id"],
    mId: json["m_id"],
    name: json["name"],
    mobile: json["mobile"],
    email: json["email"],
    whatsapp: json["whatsapp"],
    area: json["area"],
    description: json["description"],
    services: json["services"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "m_id": mId,
    "name": name,
    "mobile": mobile,
    "email": email,
    "whatsapp": whatsapp,
    "area": area,
    "description": description,
    "services": services,
  };
}
