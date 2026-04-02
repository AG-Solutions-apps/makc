// To parse this JSON data, do
//
//     final companyDataModel = companyDataModelFromJson(jsonString);

import 'dart:convert';

CompanyDataModel companyDataModelFromJson(String str) => CompanyDataModel.fromJson(json.decode(str));

String companyDataModelToJson(CompanyDataModel data) => json.encode(data.toJson());

class CompanyDataModel {
  int? id;
  String? companyName;
  String? companyEmail;
  String? companyShort;
  String? companyGst;
  String? companyPanNo;
  String? companyMobileNo;
  dynamic companyAddress;
  String? companyLogo;
  dynamic companyBanner;
  String? companyStatus;
  dynamic createdBy;
  dynamic updatedBy;
  dynamic createdAt;
  dynamic updatedAt;

  CompanyDataModel({
    this.id,
    this.companyName,
    this.companyEmail,
    this.companyShort,
    this.companyGst,
    this.companyPanNo,
    this.companyMobileNo,
    this.companyAddress,
    this.companyLogo,
    this.companyBanner,
    this.companyStatus,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  CompanyDataModel copyWith({
    int? id,
    String? companyName,
    String? companyEmail,
    String? companyShort,
    String? companyGst,
    String? companyPanNo,
    String? companyMobileNo,
    dynamic companyAddress,
    String? companyLogo,
    dynamic companyBanner,
    String? companyStatus,
    dynamic createdBy,
    dynamic updatedBy,
    dynamic createdAt,
    dynamic updatedAt,
  }) =>
      CompanyDataModel(
        id: id ?? this.id,
        companyName: companyName ?? this.companyName,
        companyEmail: companyEmail ?? this.companyEmail,
        companyShort: companyShort ?? this.companyShort,
        companyGst: companyGst ?? this.companyGst,
        companyPanNo: companyPanNo ?? this.companyPanNo,
        companyMobileNo: companyMobileNo ?? this.companyMobileNo,
        companyAddress: companyAddress ?? this.companyAddress,
        companyLogo: companyLogo ?? this.companyLogo,
        companyBanner: companyBanner ?? this.companyBanner,
        companyStatus: companyStatus ?? this.companyStatus,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory CompanyDataModel.fromJson(Map<String, dynamic> json) => CompanyDataModel(
    id: json["id"],
    companyName: json["company_name"],
    companyEmail: json["company_email"],
    companyShort: json["company_short"],
    companyGst: json["company_gst"],
    companyPanNo: json["company_pan_no"],
    companyMobileNo: json["company_mobile_no"],
    companyAddress: json["company_address"],
    companyLogo: json["company_logo"],
    companyBanner: json["company_banner"],
    companyStatus: json["company_status"],
    createdBy: json["created_by"],
    updatedBy: json["updated_by"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company_name": companyName,
    "company_email": companyEmail,
    "company_short": companyShort,
    "company_gst": companyGst,
    "company_pan_no": companyPanNo,
    "company_mobile_no": companyMobileNo,
    "company_address": companyAddress,
    "company_logo": companyLogo,
    "company_banner": companyBanner,
    "company_status": companyStatus,
    "created_by": createdBy,
    "updated_by": updatedBy,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
