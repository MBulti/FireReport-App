class ReportNotificationModel {
  String userId;
  int reportId;
  bool isUpdate;

  ReportNotificationModel({
    required this.userId,
    required this.reportId,
    this.isUpdate = false,
  });

  factory ReportNotificationModel.fromJson(Map<String, dynamic> json) {
    return ReportNotificationModel(
      userId: json['user_id'],
      reportId: json['report_id'],
      isUpdate: json['is_update'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'report_id': reportId,
      'is_update': isUpdate,
    };
  }
}
