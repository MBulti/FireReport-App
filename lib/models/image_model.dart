import 'dart:typed_data';

class ImageModel {
  int id;
  int reportId;
  String url;
  Uint8List? imageBytes;
  DateTime? dtLastModified;

  ImageModel({required this.id, required this.reportId, required this.url, this.imageBytes, this.dtLastModified});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      reportId: json['report_id'],
      url: json['url'],
      dtLastModified: json['dt_lastmodified'] != null ? DateTime.parse(json['dt_lastmodified']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'url': url,
      'dt_lastmodified': dtLastModified?.toIso8601String(),
    };
  }

  ImageModel copyWith({int? id, int? reportId, String? url, Uint8List? imageBytes, DateTime? dtLastModified}) {
    return ImageModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      url: url ?? this.url,
      imageBytes: imageBytes ?? this.imageBytes,
      dtLastModified: dtLastModified ?? this.dtLastModified,
    );
  }
}