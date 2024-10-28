import 'package:firereport/services/defectreport_service.dart';
import 'package:firereport/utils/helper_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firereport/models/models.dart';
import 'notifier.dart';

class DefectReportNotifier extends ChangeNotifier {
  final Ref ref;
  List<DefectReportModel> defectReports = [];
  List<AppUserModel> users = [];
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

  Future<void> upsertReport(DefectReportModel report) async {
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
}

// Provider für DefectReportNotifier
final defectReportNotifierProvider =
    ChangeNotifierProvider((ref) => DefectReportNotifier(ref));

// Provider für den FilterStatus
final filterStatusProvider =
    StateProvider<FilterStatus>((ref) => FilterStatus.all);

// Gefilterte Liste basierend auf dem FilterStatus
final filteredDefectReportProvider = Provider<List<DefectReportModel>>((ref) {
  final filter = ref.watch(filterStatusProvider);
  final defectReports = ref.watch(defectReportNotifierProvider
      .select((notifier) => notifier.defectReports));

  var lsReports = defectReports;
  switch (filter) {
    case FilterStatus.open:
      lsReports = defectReports
          .where((report) => report.status == ReportState.open)
          .toList();
      break;
    case FilterStatus.inProgress:
      lsReports = defectReports
          .where((report) => report.status == ReportState.inProgress)
          .toList();
      break;
    case FilterStatus.done:
      lsReports = defectReports
          .where((report) => report.status == ReportState.done)
          .toList();
      break;
    case FilterStatus.assignedToMe:
      lsReports = defectReports
          .where((report) => report.assignedUser == ref.read(authProvider.notifier).user.id)
          .toList();
      break;
    case FilterStatus.createdByMe:
      lsReports = defectReports
          .where((report) => report.createdBy == ref.read(authProvider.notifier).user.id)
          .toList();
      break;
    case FilterStatus.all:
    default:
      lsReports = defectReports;
      break;
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
});
