import 'dart:typed_data';
import 'package:firereport/utils/db_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firereport/models/models.dart';

class APIClient {
  static final supabase = Supabase.instance.client;
  static AppUser? currentUser;

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

  static Future<AppUser> getUser(User user) async {
    final userResponse = await supabase
        .from(DbTables.tblUser)
        .select()
        .eq('id', user.id)
        .single();
    final appUser = AppUser.fromJson(userResponse);
    appUser.email = user.email;
    return appUser;
  }
  // #endregion

  // #region DefectReport
  static Future<List<DefectReport>> getDefectReports() async {
    final lsReports =
        await Supabase.instance.client.from(DbTables.tblDefectReport).select();
    // .order('status', ascending: true)
    // .order('dt_due', ascending: true);

    final lsDefectReports =
        lsReports.map((report) => DefectReport.fromJson(report)).toList();

    for (var report in lsDefectReports) {
      report.lsImages = await getImages(report.id);
    }

    return lsDefectReports;
  }

  static Future<void> upsertDefectReport(DefectReport report) async {
    await Supabase.instance.client
        .from(DbTables.tblDefectReport)
        .upsert(report.toJson());
  }

  static Future<List<AppUser>> getUsers() async {
    final lsUsers = await Supabase.instance.client
        .from(DbTables.tblUser)
        .select()
        .order('last_name');
    return lsUsers.map((user) => AppUser.fromJson(user)).toList();
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
}
