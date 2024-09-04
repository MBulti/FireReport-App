import 'package:firereport/models/enums.dart';

String formatDate(DateTime date) {
  String day = date.day.toString().padLeft(2, '0');
  String month = date.month.toString().padLeft(2, '0');
  String year = date.year.toString();
  return "$day.$month.$year";
}

String formatReportState(ReportState reportState) {
  switch (reportState) {
    case ReportState.open:
      return "Offen";
    case ReportState.inProgress:
      return "In Bearbeitung";
    case ReportState.done:
      return "Abgeschlossen";
  }
}

String formatFilterState(FilterStatus status) {
  switch (status) {
    case FilterStatus.open:
      return "Offen";
    case FilterStatus.inProgress:
      return "In Bearbeitung";
    case FilterStatus.done:
      return "Abgeschlossen";
    default:
      return "Alle";
  }
}
