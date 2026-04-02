// To parse this JSON data, do
//
//     final bannerDataModel = bannerDataModelFromJson(jsonString);

import 'dart:convert';

BannerDataModel bannerDataModelFromJson(String str) => BannerDataModel.fromJson(json.decode(str));

String bannerDataModelToJson(BannerDataModel data) => json.encode(data.toJson());

class BannerDataModel {
  String? serviceSubBanner;
  dynamic serviceSubLink;

  BannerDataModel({
    this.serviceSubBanner,
    this.serviceSubLink,
  });

  BannerDataModel copyWith({
    String? serviceSubBanner,
    dynamic serviceSubLink,
  }) =>
      BannerDataModel(
        serviceSubBanner: serviceSubBanner ?? this.serviceSubBanner,
        serviceSubLink: serviceSubLink ?? this.serviceSubLink,
      );

  factory BannerDataModel.fromJson(Map<String, dynamic> json) => BannerDataModel(
    serviceSubBanner: json["service_sub_banner"],
    serviceSubLink: json["service_sub_link"],
  );

  Map<String, dynamic> toJson() => {
    "service_sub_banner": serviceSubBanner,
    "service_sub_link": serviceSubLink,
  };
}
