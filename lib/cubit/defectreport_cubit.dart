import 'package:firereport/utils/db_tables.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firereport/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DefectReportState {}

class DefectReportLoading extends DefectReportState {}

class DefectReportLoaded extends DefectReportState {
  final FilterStatus filterStatus;
  final List<DefectReport> defectReports;
  DefectReportLoaded(this.defectReports, this.filterStatus);

  DefectReportLoaded copyWith({
    List<DefectReport>? newDefectReport,
    FilterStatus? newFilterStatus,
  }) {
    return DefectReportLoaded(
      newDefectReport ?? defectReports,
      newFilterStatus ?? filterStatus,
    );
  }
}

class DefectReportError extends DefectReportState {
  final String message;
  DefectReportError(this.message);
}
class DefectReportCubit extends Cubit<DefectReportState> {
  final SupabaseClient client;
  FilterStatus filterStatus = FilterStatus.all;
  DefectReportCubit(this.client) : super(DefectReportState());

  Future<void> fetchReports() async {
    try {
      emit(DefectReportLoading());
      await Future.delayed(const Duration(seconds: 3));
      final lsReports = await client.from(DbTables.tblDefectReport).select();
      //.order('id', ascending: false);
      emit(DefectReportLoaded(
          lsReports.map((report) => DefectReport.fromJson(report)).toList(),
          filterStatus));
    } catch (e) {
      emit(DefectReportError(e.toString()));
    }
  }

  void addReport(DefectReport report) async {
    try {
      await client.from(DbTables.tblDefectReport).insert(report.toJson());
      if (state is DefectReportLoaded) {
        final currentState = state as DefectReportLoaded;
        final updatedReports = List<DefectReport>.from(currentState.defectReports)..add(report);
        emit(currentState.copyWith(newDefectReport: updatedReports));
      }
    } catch (e) {
      emit(DefectReportError(e.toString()));
    }
  }

  void updateReport(DefectReport report) async {
    try {
      await client
          .from(DbTables.tblDefectReport)
          .update(report.toJson())
          .eq('id', report.id);
      if (state is DefectReportLoaded) {
        final currentState = state as DefectReportLoaded;
        final updatedReports = List<DefectReport>.from(currentState.defectReports);
        final index = updatedReports.indexWhere((element) => element.id == report.id);
        if (index != -1) {
          updatedReports[index] = report;
        }
        emit(currentState.copyWith(newDefectReport: updatedReports));
      }
    } catch (e) {
      emit(DefectReportError(e.toString()));
    }
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
      case FilterStatus.all:
      default:
        return reportState.defectReports;
    }
  }
}
