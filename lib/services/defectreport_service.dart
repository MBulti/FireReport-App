import 'package:firereport/models/models.dart';
import 'package:firereport/utils/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefectReportService {
  Future<List<DefectReport>> fetchDefectReports() async {
    return await APIClient.getDefectReports();
  }

  Future<List<AppUser>> fetchUsers() async {
    return await APIClient.getUsers();
  }

  Future<void> upsertDefectReport(DefectReport report) async {
    if (report.lsImages.isNotEmpty) {
      for (var image in report.lsImages) {
        if (image.dtLastModified == null) {
          await APIClient.uploadImageToStorage(image);
          await APIClient.upsertImage(image);
        }
      }
    }
    await APIClient.upsertDefectReport(report);
  }

  Future<ImageModel> downloadImage(ImageModel image) async {
    image.imageBytes = await APIClient.downloadImageFromStorage(image.url);
    return image;
  }
}

final defectReportServiceProvider = Provider((ref) => DefectReportService());
