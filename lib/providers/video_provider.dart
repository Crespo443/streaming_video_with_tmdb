import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_video_app/models/video_model.dart';

class VideoProvider with ChangeNotifier {
  List<VideoModel> _allVideos = [];
  String _selectedCategory = "All";
  bool _isLoading = true;

  List<VideoModel> get allVideos => List<VideoModel>.from(_allVideos);

  List<VideoModel> get videos {
    if (_selectedCategory == "All" || _allVideos.isEmpty) {
      return _allVideos;
    } else {
      return _allVideos
          .where(
            (video) => video.categories.any(
              (cat) => cat.toLowerCase() == _selectedCategory.toLowerCase(),
            ),
          )
          .toList();
    }
  }

  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  VideoProvider() {
    _loadVideosFromJson();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Fungsi ini menjadi kunci: mendapatkan video yang MEMILIKI kategori tertentu
  List<VideoModel> getVideosByCategory(String categoryName) {
    if (categoryName.toLowerCase() == 'all') {
      return _allVideos;
    }
    // Cari video yang list 'categories'-nya mengandung 'categoryName'
    return _allVideos
        .where(
          (video) => video.categories.any(
            (cat) => cat.toLowerCase() == categoryName.toLowerCase(),
          ),
        )
        .toList();
  }

  Future<void> _loadVideosFromJson() async {
    try {
      _isLoading = true;
      // notifyListeners(); // Tidak perlu di sini jika pakai if (isLoading) di UI

      final String jsonString = await rootBundle.loadString(
        'assets/data/video.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _allVideos =
          jsonList
              .map(
                (jsonItem) =>
                    VideoModel.fromJson(jsonItem as Map<String, dynamic>),
              )
              .toList();

      _isLoading = false;
    } catch (e) {
      print("Error loading videos from JSON: $e");
      _allVideos = [];
      _isLoading = false;
    }
    notifyListeners();
  }

  // Fungsi ini mendapatkan SEMUA kategori unik dari semua video
  List<String> getCategories() {
    Set<String> uniqueCategories = {};
    for (var video in _allVideos) {
      for (var category in video.categories) {
        uniqueCategories.add(category);
      }
    }
    return uniqueCategories.toList()..sort();
  }

  VideoModel? getVideoById(String id) {
    try {
      return _allVideos.firstWhere((video) => video.id == id);
    } catch (e) {
      return null;
    }
  }

  List<VideoModel> searchVideos(String query) {
    if (query.isEmpty) return [];
    String lowerQuery = query.toLowerCase();
    return _allVideos.where((video) {
      return video.title.toLowerCase().contains(lowerQuery) ||
          video.description.toLowerCase().contains(lowerQuery) ||
          video.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
          // Cari juga di dalam list categories
          video.categories.any((cat) => cat.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
