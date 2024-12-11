import 'package:firereport/models/models.dart';
import 'package:firereport/utils/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefectReportService {
  Future<List<DefectReportModel>> fetchDefectReports() async {
    try {
      return await APIClient.getDefectReports();
    } catch (e) {
      await APIClient.addLog(e.toString());
      return [];
    }
  }

  Future<List<AppUserModel>> fetchUsers() async {
    try {
      return await APIClient.getUsers();
    } catch (e) {
      await APIClient.addLog(e.toString());
      return [];
    }
  }

  Future<void> upsertDefectReport(
      DefectReportModel report, List<AppUserModel> users) async {
    final bool isReportNew = report.dtLastModified == null;
    if (report.lsImages.isNotEmpty) {
      for (var image in report.lsImages) {
        if (image.dtLastModified == null) {
          await APIClient.uploadImageToStorage(image);
          image.dtLastModified = DateTime.now();
          await APIClient.upsertImage(image);
        }
      }
    }
    report.dtLastModified = DateTime.now();
    await APIClient.upsertDefectReport(report);
    if (report.isNotifyUser) {
      await APIClient.addReportNotification(report.id, null);
    } else {
      await APIClient.deleteReportNotification(report.id);
    }

    if (isReportNew) {
      final relevantUsers = users.where((user) {
        if (user.id == APIClient.currentUser?.id) return false;

        final isAssignedUnit = report.assignedUnit == user.unitType;
        final isLoeschgruppenfuehrung =
            user.roleType == RoleType.loeschgruppenfuerung;
        final isRoedinghausenUnit = user.unitType == UnitType.roedinghausen;
        final isSpecificRole = user.roleType == RoleType.geraetewart ||
            user.roleType == RoleType.wehrfuerung;

        return (isAssignedUnit && isLoeschgruppenfuehrung) ||
            (isRoedinghausenUnit && isSpecificRole);
      });
      await Future.wait(relevantUsers.map(
          (user) => APIClient.addReportNotification(report.id, user.id)));
    }
    // send updates
    await APIClient.updateReportNotifications(report.id);
  }

  Future<void> markReportNotificationAsRead(int reportId) async {
    await APIClient.markReportNotificationAsRead(reportId);
  }

  Future<ImageModel> downloadImage(ImageModel image) async {
    image.imageBytes = await APIClient.downloadImageFromStorage(image.url);
    return image;
  }
}

final defectReportServiceProvider = Provider((ref) => DefectReportService());
