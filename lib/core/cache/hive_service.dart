import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();

  static const String opusCacheBox = 'opus_cache';
  static const String userDataBox = 'user_data';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(opusCacheBox),
      Hive.openBox<Map>(userDataBox),
    ]);
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }

  static Box<Map> get cacheBox => Hive.box<Map>(opusCacheBox);
  static Box<Map> get userBox => Hive.box<Map>(userDataBox);
}
