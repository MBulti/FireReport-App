import 'package:firereport/models/models.dart';

class DefectReport {
  int id;
  String title;
  String description;
  ReportState status;
  String? assignedUser;
  DateTime? dueDate;
  bool isNotifyUser;
  List<ImageModel> lsImages = [];

  DefectReport({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.assignedUser,
    this.dueDate,
    this.isNotifyUser = false,
    this.lsImages = const [],
  });

  factory DefectReport.fromJson(Map<String, dynamic> json) {
    return DefectReport(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] != null ? ReportState.values[json['status']] : ReportState.open,
      dueDate: json['dt_due'] != null ? DateTime.parse(json['dt_due']) : null,
      assignedUser: json['assigned_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
      'dt_due': dueDate?.toIso8601String(),
      'assigned_user': assignedUser
    };
  }

    // Copy with method to create a new instance of DefectReport with updated fields
  DefectReport copyWith({
    int? id,
    String? title,
    String? description,
    ReportState? status,
    String? assignedUser,
    DateTime? dueDate,
    List<ImageModel>? lsImages,
  }) {
    return DefectReport(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedUser: assignedUser ?? this.assignedUser,
      dueDate: dueDate ?? this.dueDate,
      lsImages: lsImages ?? this.lsImages,
    );
  }
}