import 'dart:typed_data';
import 'package:firereport/utils/db_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firereport/models/models.dart';

class APIClient {
  static final supabase = Supabase.instance.client;
  static AppUserModel? currentUser;

  static Future<void> init() async {
    await Supabase.initialize(
        url: "https://gtjwpkqnehchegvxesva.supabase.co",
        anonKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0andwa3FuZWhjaGVndnhlc3ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1Mzg0OTYsImV4cCI6MjAzOTExNDQ5Nn0.7ZAHS7OOwcJy3ooTwhMVKhgbih6bLYvSvQ44A8-vC3M");
  }

  // #region Logging
  static Future<void> addLog(String message) async {
    final log = LogModel(
      message: message,
      createdAt: DateTime.now(),
    );
    await Supabase.instance.client.from(DbTables.tblLog).insert(
          log.toJson(),
        );
  }
  // #endregion

  // #region Auth
  static Future<void> setCurrentUser(User user) async {
    currentUser = await getUser(user);
  }

  static Future<AuthResponse> login(String email, String password) async {
    final authResponse = await supabase.auth
        .signInWithPassword(email: email, password: password);

    await setCurrentUser(authResponse.user!);
    return authResponse;
  }

  static Future<AuthResponse> loginAnonymously() async {
    return await supabase.auth.signInAnonymously();
  }

  static Future<void> logout() async {
    return await supabase.auth.signOut();
  }

  static Future<AppUserModel> getUser(User user) async {
    final userResponse = await supabase
        .from(DbTables.tblUser)
        .select()
        .eq('id', user.id)
        .single();
    final appUser = AppUserModel.fromJson(userResponse);
    appUser.email = user.email;
    return appUser;
  }
  // #endregion

  // #region DefectReport
  static Future<List<DefectReportModel>> getDefectReports() async {
    final lsReports = await supabase.from(DbTables.tblDefectReport).select();
    // .order('status', ascending: true)
    // .order('dt_due', ascending: true);

    final lsDefectReports =
        lsReports.map((report) => DefectReportModel.fromJson(report)).toList();

    for (var report in lsDefectReports) {
      report.lsImages = await getImages(report.id);
      var reportNotification =
          await getReportNotification(currentUser!.id!, report.id);

      report.isNotifyUser = reportNotification != null;
      report.isNew = reportNotification?.isUpdate ?? false;
    }
    return lsDefectReports;
  }

  static Future<void> upsertDefectReport(DefectReportModel report) async {
    await supabase.from(DbTables.tblDefectReport).upsert(report.toJson());
  }

  static Future<List<AppUserModel>> getUsers() async {
    final lsUsers =
        await supabase.from(DbTables.tblUser).select().order('last_name');
    return lsUsers.map((user) => AppUserModel.fromJson(user)).toList();
  }
  // #endregion

  // #region Image
  static Future<List<ImageModel>> getImages(int reportId) async {
    final lsImages = await Supabase.instance.client
        .from(DbTables.tblImage)
        .select()
        .eq('report_id', reportId);
    return lsImages.map((image) => ImageModel.fromJson(image)).toList();
  }

  static Future<void> upsertImage(ImageModel image) async {
    image.dtLastModified = DateTime.now();
    await Supabase.instance.client
        .from(DbTables.tblImage)
        .upsert(image.toJson());
  }

  static Future<String> uploadImageToStorage(ImageModel image) async {
    final response = await Supabase.instance.client.storage
        .from(StorageBuckets.dataImages)
        .uploadBinary(image.url, image.imageBytes!);

    return response;
  }

  static Future<Uint8List?> downloadImageFromStorage(String url) async {
    final response = await Supabase.instance.client.storage
        .from(StorageBuckets.dataImages)
        .download(url);
    return response;
  }
  // #endregion

  // #region Notification
  static Future<ReportNotificationModel?> getReportNotification(
      String userId, int reportId) async {
    final userReportNotification = await supabase
        .from(DbTables.tblUserReportNotification)
        .select()
        .eq('user_id', userId)
        .eq('report_id', reportId)
        .maybeSingle();

    return userReportNotification != null
        ? ReportNotificationModel.fromJson(userReportNotification)
        : null;
  }

  static Future<void> addReportNotification(int reportId) async {
    await Future.delayed(const Duration(seconds: 1));
    final notification = ReportNotificationModel(
      userId: currentUser!.id!,
      reportId: reportId,
      isUpdate: false,
    );
    await supabase.from(DbTables.tblUserReportNotification).upsert(
          notification.toJson(),
        );
  }

  static Future<void> deleteReportNotification(int reportId) async {
    await Future.delayed(const Duration(seconds: 1));
    await supabase
        .from(DbTables.tblUserReportNotification)
        .delete()
        .eq('user_id', currentUser!.id!)
        .eq('report_id', reportId);
  }
  // #endregion
}
