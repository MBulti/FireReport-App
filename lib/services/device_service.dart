import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionProvider = FutureProvider.autoDispose<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return 'Version ${packageInfo.version}';
});