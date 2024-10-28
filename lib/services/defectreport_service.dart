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

  Future<void> upsertDefectReport(DefectReportModel report) async {
    if (report.lsImages.isNotEmpty) {
      for (var image in report.lsImages) {
        if (image.dtLastModified == null) {
          await APIClient.uploadImageToStorage(image);
          await APIClient.upsertImage(image);
        }
      }
    }
    await APIClient.upsertDefectReport(report);
    if (report.isNotifyUser) {
      await APIClient.addReportNotification(report.id);
    } else {
      await APIClient.deleteReportNotification(report.id);
    }
  }

  Future<ImageModel> downloadImage(ImageModel image) async {
    image.imageBytes = await APIClient.downloadImageFromStorage(image.url);
    return image;
  }
}

final defectReportServiceProvider = Provider((ref) => DefectReportService());
