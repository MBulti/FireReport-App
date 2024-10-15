import 'package:firereport/utils/helper_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firereport/models/models.dart';
import 'package:firereport/utils/api_client.dart';
import 'notifier.dart';

// Define the possible states
abstract class DefectReportState {}

class DefectReportLoading extends DefectReportState {}

class DefectReportLoaded extends DefectReportState {
  final FilterStatus filterStatus;
  final List<DefectReport> defectReports;
  final List<AppUser> users;

  DefectReportLoaded(this.defectReports, this.filterStatus, this.users);

  DefectReportLoaded copyWith({
    List<DefectReport>? newDefectReport,
    FilterStatus? newFilterStatus,
    List<AppUser>? newUsers,
  }) {
    return DefectReportLoaded(
      newDefectReport ?? defectReports,
      newFilterStatus ?? filterStatus,
      newUsers ?? users,
    );
  }
}

class DefectReportError extends DefectReportState {
  final String message;
  DefectReportError(this.message);
}

// Notifier to handle the logic
class DefectReportNotifier extends StateNotifier<DefectReportState> {
  final Ref ref; // Ref gives access to other providers like AuthNotifier

  FilterStatus filterStatus = FilterStatus.all;

  DefectReportNotifier(this.ref) : super(DefectReportLoading()) {
    // Fetch the reports when the notifier is initialized
    fetchReports();
  }

  // Fetch defect reports and users from API
  Future<void> fetchReports() async {
    try {
      state = DefectReportLoading();
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      final defectReports = await APIClient.getDefectReports();
      final users = await APIClient.getUsers();

      state = DefectReportLoaded(defectReports, filterStatus, users);
    } catch (e) {
      state = DefectReportError(e.toString());
      await APIClient.addLog(e.toString());
    }
  }

  // Method to upsert (add/update) a defect report
  Future<void> upsertReport(DefectReport report) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay
      if (report.lsImages.isNotEmpty) {
        for (var image in report.lsImages) {
          if (image.dtLastModified == null) {
            await APIClient.uploadImageToStorage(image);
            await APIClient.upsertImage(image);
          }
        }
      }
      await APIClient.upsertDefectReport(report);

      if (state is DefectReportLoaded) {
        final currentState = state as DefectReportLoaded;

        final updatedReports =
            List<DefectReport>.from(currentState.defectReports);
        final index =
            updatedReports.indexWhere((element) => element.id == report.id);

        if (index != -1) {
          updatedReports[index] = report; // Update existing report
        } else {
          updatedReports.add(report); // Add new report
        }

        state = currentState.copyWith(newDefectReport: updatedReports);
      }
    } catch (e) {
      state = DefectReportError(e.toString());
      await APIClient.addLog(e.toString());
    }
  }

  Future<ImageModel> downloadImage(ImageModel image) async {
    image.imageBytes = await APIClient.downloadImageFromStorage(image.url);
    return image;
  }

  // Method to set a filter for the reports
  void setFilter(FilterStatus newFilter) {
    if (state is DefectReportLoaded) {
      filterStatus = newFilter;
      final currentState = state as DefectReportLoaded;
      state = currentState.copyWith(newFilterStatus: filterStatus);
    }
  }

  // Filtered list of defect reports based on the current filter
  List<DefectReport> get filteredReports {
    if (state is! DefectReportLoaded) return [];

    final currentState = state as DefectReportLoaded;

    var lsReports = currentState.defectReports;
    switch (currentState.filterStatus) {
      case FilterStatus.open:
        lsReports = currentState.defectReports
            .where((report) => report.status == ReportState.open)
            .toList();
      case FilterStatus.inProgress:
        lsReports = currentState.defectReports
            .where((report) => report.status == ReportState.inProgress)
            .toList();
      case FilterStatus.done:
        lsReports = currentState.defectReports
            .where((report) => report.status == ReportState.done)
            .toList();
      case FilterStatus.assignedToMe:
        lsReports = currentState.defectReports
            .where((report) =>
                report.assignedUser == ref.read(authProvider.notifier).user.id)
            .toList();
      case FilterStatus.all:
      default:
        lsReports = currentState.defectReports;
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
}

final defectReportNotifierProvider =
    StateNotifierProvider<DefectReportNotifier, DefectReportState>((ref) {
  return DefectReportNotifier(ref);
});
