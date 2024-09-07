import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firereport/models/models.dart';

class DefectReportState {
  final List<DefectReport> defectReports;
  final FilterStatus filterStatus;

  DefectReportState(
      {this.defectReports = const [], this.filterStatus = FilterStatus.all});

  DefectReportState copyWith({
    List<DefectReport>? newDefectReport,
    FilterStatus? newFilterStatus,
  }) {
    return DefectReportState(
      defectReports: newDefectReport ?? defectReports,
      filterStatus: newFilterStatus ?? filterStatus,
    );
  }
}

class DefectReportCubit extends Cubit<DefectReportState> {
  DefectReportCubit() : super(DefectReportState());

  List<DefectReport> get filteredReports {
    switch (state.filterStatus) {
      case FilterStatus.open:
        return state.defectReports.where((report) => report.status == ReportState.open).toList();
      case FilterStatus.inProgress:
        return state.defectReports.where((report) => report.status == ReportState.inProgress).toList();
      case FilterStatus.done:
        return state.defectReports.where((report) => report.status == ReportState.done).toList();
      case FilterStatus.all:
      default:
        return state.defectReports;
    }
  }

  void addReport(DefectReport report) {
    final updatedReports = List<DefectReport>.from(state.defectReports)
      ..add(report);
    emit(state.copyWith(newDefectReport: updatedReports));
  }

  void updateReport(DefectReport report) {
    final updatedReports = List<DefectReport>.from(state.defectReports);

    final index = updatedReports.indexWhere((element) => element.id == report.id);
    updatedReports[index] = report;
    emit(state.copyWith(newDefectReport: updatedReports));
  }

  void filterReports(FilterStatus filterStatus) {
    emit(state.copyWith(newFilterStatus: filterStatus));
  }
}
