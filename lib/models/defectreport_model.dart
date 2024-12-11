import 'package:firereport/models/models.dart';

class DefectReportModel {
  int id;
  String title;
  String description;
  ReportState status;
  String? assignedUser;
  String? createdBy;
  DateTime? dtDue;
  DateTime? dtLastModified;
  UnitType? assignedUnit;
  bool isNotifyUser;
  bool isNew;
  List<ImageModel> lsImages = [];

  DefectReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.assignedUser,
    this.createdBy,
    this.dtDue,
    this.dtLastModified,
    this.assignedUnit,
    this.isNotifyUser = false,
    this.isNew = false,
    this.lsImages = const [],
  });

  factory DefectReportModel.fromJson(Map<String, dynamic> json) {
    return DefectReportModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] != null ? ReportState.values[json['status']] : ReportState.open,
      dtDue: json['dt_due'] != null ? DateTime.parse(json['dt_due']) : null,
      dtLastModified: json['dt_lastmodified'] != null ? DateTime.parse(json['dt_lastmodified']) : null,
      assignedUser: json['assigned_user'],
      createdBy: json['created_by'],
      assignedUnit: json['assigned_unit'] != null ? UnitType.values[json['assigned_unit']] : UnitType.unset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
      'dt_due': dtDue?.toIso8601String(),
      'dt_lastmodified': dtLastModified?.toIso8601String(),
      'assigned_user': assignedUser,
      'created_by': createdBy,
      'assigned_unit': assignedUnit?.index
    };
  }

    // Copy with method to create a new instance of DefectReport with updated fields
  DefectReportModel copyWith({
    int? id,
    String? title,
    String? description,
    ReportState? status,
    String? assignedUser,
    String? createdBy,
    DateTime? dtDue,
    UnitType? assignedUnit,
    bool? isNotifyUser,
    bool? isNew,
    List<ImageModel>? lsImages
  }) {
    return DefectReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedUser: assignedUser ?? this.assignedUser,
      createdBy: createdBy ?? this.createdBy,
      dtDue: dtDue ?? this.dtDue,
      assignedUnit: assignedUnit ?? this.assignedUnit,
      isNotifyUser: isNotifyUser ?? this.isNotifyUser,
      isNew: isNew ?? this.isNew,
      lsImages: lsImages ?? copyWithImages(this.lsImages),
    );
  }

  List<ImageModel> copyWithImages(List<ImageModel>? lsImages) {
    if (lsImages == null || lsImages.isEmpty) {
      return [];
    }
    return lsImages.map((image) => image.copyWith()).toList();
  }
}