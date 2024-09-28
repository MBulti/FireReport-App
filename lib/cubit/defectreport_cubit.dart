import 'package:firereport/cubit/cubit.dart';
import 'package:firereport/utils/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firereport/models/models.dart';

class DefectReportState {}

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

class DefectReportCubit extends Cubit<DefectReportState> {
  final AuthCubit authCubit;
  FilterStatus filterStatus = FilterStatus.all;
  DefectReportCubit(this.authCubit) : super(DefectReportState());

  Future<void> fetchReports() async {
    try {
      emit(DefectReportLoading());
      await Future.delayed(const Duration(seconds: 1));
      final lsReports = await APIClient.getDefectReports();
      final lsUsers = await APIClient.getUsers();
      emit(DefectReportLoaded(lsReports, filterStatus, lsUsers));
    } catch (e) {
      emit(DefectReportError(e.toString()));
    }
  }

  Future<void> upsertReport(DefectReport report) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
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
          updatedReports[index] = report;
        } else {
          updatedReports.add(report);
        }
        emit(currentState.copyWith(newDefectReport: updatedReports));
      }
    } catch (e) {
      emit(DefectReportError(e.toString()));
    }
  }

  Future<ImageModel> downloadImage(ImageModel image) async {
    image.imageBytes = await APIClient.downloadImageFromStorage(image.url);
    return image;
  }

  void setFilter(FilterStatus newFilter) {
    if (state is! DefectReportLoaded) {
      return;
    }
    filterStatus = newFilter;
    final reportState = state as DefectReportLoaded;
    emit(reportState.copyWith(newFilterStatus: filterStatus));
  }

  List<DefectReport> get filteredReports {
    if (state is! DefectReportLoaded) {
      return [];
    }

    final reportState = state as DefectReportLoaded;
    switch (reportState.filterStatus) {
      case FilterStatus.open:
        return reportState.defectReports
            .where((report) => report.status == ReportState.open)
            .toList();
      case FilterStatus.inProgress:
        return reportState.defectReports
            .where((report) => report.status == ReportState.inProgress)
            .toList();
      case FilterStatus.done:
        return reportState.defectReports
            .where((report) => report.status == ReportState.done)
            .toList();
      case FilterStatus.assignedToMe:
        return reportState.defectReports
          .where((report) => report.assignedUser == authCubit.user.id)
          .toList();
      case FilterStatus.all:
      default:
        return reportState.defectReports;
    }
  }
}
