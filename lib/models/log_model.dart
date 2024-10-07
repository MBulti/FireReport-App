class LogModel {
  String message;
  DateTime createdAt;

  LogModel({
    required this.message,
    required this.createdAt,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}