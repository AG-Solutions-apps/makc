// To parse this JSON data, do
//
//     final familyMemberDataModel = familyMemberDataModelFromJson(jsonString);

import 'dart:convert';

FamilyMemberDataModel familyMemberDataModelFromJson(String str) => FamilyMemberDataModel.fromJson(json.decode(str));

String familyMemberDataModelToJson(FamilyMemberDataModel data) => json.encode(data.toJson());

class FamilyMemberDataModel {
  int? id;
  String? mId;
  String? rId;
  String? name;
  String? mobile;
  String? email;
  String? whatsapp;
  String? area;
  String? description;

  FamilyMemberDataModel({
    this.id,
    this.mId,
    this.rId,
    this.name,
    this.mobile,
    this.email,
    this.whatsapp,
    this.area,
    this.description,
  });

  FamilyMemberDataModel copyWith({
    int? id,
    String? mId,
    String? rId,
    String? name,
    String? mobile,
    String? email,
    String? whatsapp,
    String? area,
    String? description,
  }) =>
      FamilyMemberDataModel(
        id: id ?? this.id,
        mId: mId ?? this.mId,
        rId: rId ?? this.rId,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        email: email ?? this.email,
        whatsapp: whatsapp ?? this.whatsapp,
        area: area ?? this.area,
        description: description ?? this.description,
      );

  factory FamilyMemberDataModel.fromJson(Map<String, dynamic> json) => FamilyMemberDataModel(
    id: json["id"],
    mId: json["m_id"],
    rId: json["r_id"],
    name: json["name"],
    mobile: json["mobile"],
    email: json["email"],
    whatsapp: json["whatsapp"],
    area: json["area"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "m_id": mId,
    "r_id": rId,
    "name": name,
    "mobile": mobile,
    "email": email,
    "whatsapp": whatsapp,
    "area": area,
    "description": description,
  };
}
