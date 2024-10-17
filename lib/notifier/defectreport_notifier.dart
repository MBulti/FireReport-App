import 'package:firereport/services/defectreport_service.dart';
import 'package:firereport/utils/helper_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firereport/models/models.dart';
import 'notifier.dart';

class DefectReportNotifier extends ChangeNotifier {
  final Ref ref;
  List<DefectReport> defectReports = [];
  List<AppUser> users = [];
  FilterStatus filterStatus = FilterStatus.all;
  String? errorMessage;
  bool isLoading = false;
  bool isSaveInProgress = false;

  DefectReportNotifier(this.ref) {
    fetchReports();
  }

  Future<void> fetchReports() async {
    isLoading = true;
    notifyListeners();
    try {
      defectReports =
          await ref.read(defectReportServiceProvider).fetchDefectReports();
      users = await ref.read(defectReportServiceProvider).fetchUsers();
      isLoading = false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
    }
    notifyListeners();
  }

  Future<void> upsertReport(DefectReport report) async {
    try {
      isSaveInProgress = true;
      notifyListeners();
      await ref.read(defectReportServiceProvider).upsertDefectReport(report);
      final index =
          defectReports.indexWhere((element) => element.id == report.id);
      if (index != -1) {
        defectReports[index] = report;
      } else {
        defectReports.add(report);
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    isSaveInProgress = false;
    notifyListeners();
  }

  List<DefectReport> get filteredReports {
    var lsReports = defectReports;
    switch (filterStatus) {
      case FilterStatus.open:
        lsReports = defectReports
            .where((report) => report.status == ReportState.open)
            .toList();
      case FilterStatus.inProgress:
        lsReports = defectReports
            .where((report) => report.status == ReportState.inProgress)
            .toList();
      case FilterStatus.done:
        lsReports = defectReports
            .where((report) => report.status == ReportState.done)
            .toList();
      case FilterStatus.assignedToMe:
        lsReports = defectReports
            .where((report) =>
                report.assignedUser == ref.read(authProvider.notifier).user.id)
            .toList();
      case FilterStatus.all:
      default:
        lsReports = defectReports;
    }
    lsReports.sort((a, b) {
      int statusComparison = a.status.compareToEnum(b.status);
      if (statusComparison != 0) {
        return statusComparison;
      } else {
        return a.dueDate.compareNullableTo(b.dueDate);
      }
    });
    return lsReports;
  }

  // Filter ändern
  void setFilter(FilterStatus newFilter) {
    filterStatus = newFilter;
    notifyListeners();
  }
}

final defectReportNotifierProvider =
    ChangeNotifierProvider((ref) => DefectReportNotifier(ref));
