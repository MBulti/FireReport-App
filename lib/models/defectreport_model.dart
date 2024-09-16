import 'package:firereport/models/models.dart';

class DefectReport {
  int id;
  String title;
  String description;
  ReportState status;
  String? assignedUser;
  DateTime? dueDate;

  DefectReport({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.assignedUser,
    this.dueDate,
  });

  factory DefectReport.fromJson(Map<String, dynamic> json) {
    return DefectReport(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] != null ? ReportState.values[json['status']] : ReportState.open,
      assignedUser: json['assigned_user'],
      dueDate: json['dt_due'] != null ? DateTime.parse(json['dt_due']) : null,
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
}