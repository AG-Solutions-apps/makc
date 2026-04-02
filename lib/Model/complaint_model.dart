// To parse this JSON data, do
//
//     final complaintDataModel = complaintDataModelFromJson(jsonString);

import 'dart:convert';

ComplaintDataModel complaintDataModelFromJson(String str) => ComplaintDataModel.fromJson(json.decode(str));

String complaintDataModelToJson(ComplaintDataModel data) => json.encode(data.toJson());

class ComplaintDataModel {
  DateTime? complaintDate;
  String? complaintSubject;
  String? complaintDescription;
  String? complaintStatus;

  ComplaintDataModel({
    this.complaintDate,
    this.complaintSubject,
    this.complaintDescription,
    this.complaintStatus,
  });

  ComplaintDataModel copyWith({
    DateTime? complaintDate,
    String? complaintSubject,
    String? complaintDescription,
    String? complaintStatus,
  }) =>
      ComplaintDataModel(
        complaintDate: complaintDate ?? this.complaintDate,
        complaintSubject: complaintSubject ?? this.complaintSubject,
        complaintDescription: complaintDescription ?? this.complaintDescription,
        complaintStatus: complaintStatus ?? this.complaintStatus,
      );

  factory ComplaintDataModel.fromJson(Map<String, dynamic> json) => ComplaintDataModel(
    complaintDate: json["complaint_date"] == null ? null : DateTime.parse(json["complaint_date"]),
    complaintSubject: json["complaint_subject"],
    complaintDescription: json["complaint_description"],
    complaintStatus: json["complaint_status"],
  );

  Map<String, dynamic> toJson() => {
    "complaint_date": "${complaintDate!.year.toString().padLeft(4, '0')}-${complaintDate!.month.toString().padLeft(2, '0')}-${complaintDate!.day.toString().padLeft(2, '0')}",
    "complaint_subject": complaintSubject,
    "complaint_description": complaintDescription,
    "complaint_status": complaintStatus,
  };
}
