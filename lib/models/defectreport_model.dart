import 'package:firereport/models/models.dart';

class DefectReport {
  String title;
  String description;
  ReportState status;
  DateTime? dueDate;
  String? photo;

  DefectReport({
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    this.photo,
  });
}