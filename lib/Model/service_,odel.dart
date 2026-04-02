// To parse this JSON data, do
//
//     final serviceDataModel = serviceDataModelFromJson(jsonString);

import 'dart:convert';

ServiceDataModel serviceDataModelFromJson(String str) => ServiceDataModel.fromJson(json.decode(str));

String serviceDataModelToJson(ServiceDataModel data) => json.encode(data.toJson());

class ServiceDataModel {
  String? serviceName;
  String? serviceLogo;
  String? serviceDescription;
  dynamic serviceOther;
  String? serviceUrl;

  ServiceDataModel({
    this.serviceName,
    this.serviceLogo,
    this.serviceDescription,
    this.serviceOther,
    this.serviceUrl,
  });

  ServiceDataModel copyWith({
    String? serviceName,
    String? serviceLogo,
    String? serviceDescription,
    dynamic serviceOther,
    String? serviceUrl,
  }) =>
      ServiceDataModel(
        serviceName: serviceName ?? this.serviceName,
        serviceLogo: serviceLogo ?? this.serviceLogo,
        serviceDescription: serviceDescription ?? this.serviceDescription,
        serviceOther: serviceOther ?? this.serviceOther,
        serviceUrl: serviceUrl ?? this.serviceUrl,
      );

  factory ServiceDataModel.fromJson(Map<String, dynamic> json) => ServiceDataModel(
    serviceName: json["service_name"],
    serviceLogo: json["service_logo"],
    serviceDescription: json["service_description"],
    serviceOther: json["service_other"],
    serviceUrl: json["service_url"],
  );

  Map<String, dynamic> toJson() => {
    "service_name": serviceName,
    "service_logo": serviceLogo,
    "service_description": serviceDescription,
    "service_other": serviceOther,
    "service_url": serviceUrl,
  };
}
