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
    case FilterStatus.assignedToMe:
      return "Mir zugewiesen";
    case FilterStatus.createdByMe:
      return "Von mir erstellt";
    case FilterStatus.unread:
      return "Neue Änderungen";
    default:
      return "Alle";
  }
}

String formatRequestType(RequestType requestType) {
  switch (requestType) {
    case RequestType.normalUniform:
      return "Dienstkleidung";
    case RequestType.operationalUniform:
      return "Einsatzkleidung";
  }
}

String formatUnitType(UnitType? unitType) {
  switch (unitType) {
    case UnitType.kilver:
      return "Kilver";
    case UnitType.roedinghausen:
      return "Rödinghausen";
    case UnitType.bieren:
      return "Bieren";
    case UnitType.schwenningdorf:
      return "Schwenningdorf";
    case UnitType.jfSued:
      return "JF Süd";
    case UnitType.jfNord:
      return "JF Nord";
    case UnitType.kinderfeuerwehr:
      return "Kinderfeuerwehr";
    default:
      return "";
  }
}

String formatRoleType(RoleType? roleType, bool isKilver) {
  switch (roleType) {
    case RoleType.admin:
      return "Admin";
    case RoleType.wehrfuerung:
      return "Wehrfürung";
    case RoleType.loeschgruppenfuerung:
      return isKilver ? "Löschzugführung" : "Löschgruppenführung";
    case RoleType.geraetewart:
      return "Gerätewart";
    default:
      return "Anwender";
  }
}