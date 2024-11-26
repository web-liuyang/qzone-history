import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Environment {
  static late final Directory temporary;
  static late final Directory applicationSupport;
  static late final Directory applicationDocuments;
  static late final Directory applicationCache;
  // late final Directory downloads;

  static Future<void> ensureInitialized() async {
    final List<Directory> result = await Future.wait([
      getTemporaryDirectory(),
      getApplicationSupportDirectory(),
      getApplicationDocumentsDirectory(),
      getApplicationCacheDirectory(),
      // getDownloadsDirectory(),
    ]);

    final [
      temporary,
      applicationSupport,
      applicationDocuments,
      applicationCache,
      // downloads,
    ] = result;

    Environment.temporary = temporary;
    Environment.applicationSupport = applicationSupport;
    Environment.applicationDocuments = applicationDocuments;
    Environment.applicationCache = applicationCache;
    // Environment.downloads = downloads;
  }
}
