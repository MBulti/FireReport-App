import 'package:firereport/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firereport/models/models.dart';
import 'package:image_picker/image_picker.dart';
import 'notifier.dart';

class DefectReportDetailNotifier extends ChangeNotifier {
  final DefectReportService defectReportService;
  final DefectReportModel? oldReport;
  late DefectReportModel _report;
  late DateTime firstDate;
  bool isLoadImagesInProgress = false;
  bool isImagesFetched = false;

  DefectReportModel get report => _report;

  void setNotifyUser(bool notifyUser) {
    _report.isNotifyUser = notifyUser;
    notifyListeners();
  }

  DefectReportDetailNotifier(this.defectReportService, this.oldReport, String? user) {
    _report = oldReport != null
        ? oldReport!.copyWith()
        : DefectReportModel(
            id: DateTime.now().millisecondsSinceEpoch,
            title: "",
            description: "",
            status: ReportState.open,
            lsImages: [],
            createdBy: user,
          );
    if (_report.dueDate != null && _report.dueDate!.isBefore(DateTime.now())) {
      firstDate = _report.dueDate!;
    } else {
      firstDate = DateTime.now();
    }
  }

  bool isReportChanged() {
  if (oldReport == null) {
    return true; // no old report, its always changed
  }
  if (oldReport!.title != _report.title) return true;
  if (oldReport!.description != _report.description) return true;
  if (oldReport!.status != _report.status) return true;
  if (oldReport!.dueDate != _report.dueDate) return true;
  if (oldReport!.isNotifyUser != _report.isNotifyUser) return true;
  if (oldReport!.createdBy != _report.createdBy) return true;

  if (oldReport!.lsImages.length != _report.lsImages.length) return true;
  for (int i = 0; i < oldReport!.lsImages.length; i++) {
    final oldImage = oldReport!.lsImages[i];
    final newImage = _report.lsImages[i];
    if (oldImage.id != newImage.id ||
        oldImage.url != newImage.url ||
        oldImage.imageBytes != newImage.imageBytes) {
      return true;
    }
  }
  return false;
}

  Future<void> selectDueDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _report.dueDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime(2101),
      locale: const Locale('de', 'DE'),
    );
    if (selectedDate != null) {
      _report.dueDate = selectedDate;
      notifyListeners();
    }
  }

  Future<void> downloadImages() async {
    isLoadImagesInProgress = true;
    notifyListeners();
    for (var image in _report.lsImages) {
      if (image.dtLastModified != null) {
        image = await defectReportService.downloadImage(image);
      }
    }
    isLoadImagesInProgress = false;
    isImagesFetched = true;
    notifyListeners();
  }

  Future<void> addImage(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.add_a_photo_outlined),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_photo_alternate_outlined),
                  title: const Text('Galerie'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final fileExtension = pickedFile.name.split('.').last;
      final image = ImageModel(
        id: DateTime.now().millisecondsSinceEpoch,
        reportId: _report.id,
        url:
            "report_${_report.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension",
        imageBytes: await pickedFile.readAsBytes(),
      );
      _report.lsImages.add(image);
      notifyListeners();
    }
  }
}

final defectReportDetailProvider = ChangeNotifierProvider.autoDispose
    .family<DefectReportDetailNotifier, DefectReportModel?>(
  (ref, report) {
    final defectReportService = ref.read(defectReportServiceProvider);
    final user = ref.read(authProvider.notifier).user.id;
    return DefectReportDetailNotifier(defectReportService, report, user);
  },
);
