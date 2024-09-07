import 'package:firereport/models/models.dart';

class DefectReport {
  int id;
  String title;
  String description;
  ReportState status;
  DateTime? dueDate;

  DefectReport({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
  });
}