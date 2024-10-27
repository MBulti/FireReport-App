import 'package:firereport/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firereport/models/models.dart';
import 'package:image_picker/image_picker.dart';

class DefectReportDetailNotifier extends ChangeNotifier {
  final DefectReportService defectReportService;
  late DefectReport _report;
  late DateTime firstDate;
  bool isLoadImagesInProgress = false;
  bool isImagesFetched = false;

  DefectReport get report => _report;

  void setNotifyUser(bool notifyUser) {
    _report.isNotifyUser = notifyUser;
    notifyListeners();
  }

  DefectReportDetailNotifier(this.defectReportService, DefectReport? report) {
    _report = report != null
        ? report.copyWith()
        : DefectReport(
            id: DateTime.now().millisecondsSinceEpoch,
            title: "",
            description: "",
            status: ReportState.open,
            lsImages: [],
          );
    if (_report.dueDate != null && _report.dueDate!.isBefore(DateTime.now())) {
      firstDate = _report.dueDate!;
    } else {
      firstDate = DateTime.now();
    }
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
      image = await defectReportService.downloadImage(image);
    }
    isLoadImagesInProgress = false;
    isImagesFetched = true;
    notifyListeners();
  }

  Future<void> addImage(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
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
    .family<DefectReportDetailNotifier, DefectReport?>(
  (ref, report) {
    final defectReportService = ref.read(defectReportServiceProvider);
    return DefectReportDetailNotifier(defectReportService, report);
  },
);
