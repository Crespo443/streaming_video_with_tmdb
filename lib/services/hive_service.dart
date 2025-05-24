import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  
  factory HiveService() {
    return _instance;
  }
  
  HiveService._internal();
  final Map<String, Box> _boxes = {};
  

  Future<void> init() async {
    await Hive.initFlutter();
  }
  
  Future<Box> openBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      return _boxes[boxName]!;
    } else {
      final box = await Hive.openBox(boxName);
      _boxes[boxName] = box;
      return box;
    }
  }

  bool isBoxOpen(String boxName) {
    return Hive.isBoxOpen(boxName);
  }
  
  Future<void> closeBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      final box = _boxes[boxName]!;
      await box.close();
      _boxes.remove(boxName);
    }
  }
  
  Future<void> closeAllBoxes() async {
    for (final box in _boxes.values) {
      await box.close();
    }
    _boxes.clear();
  }
}