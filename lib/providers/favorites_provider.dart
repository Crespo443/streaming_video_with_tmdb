import 'package:flutter/foundation.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:flutter_video_app/models/review_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class FavoritesProvider with ChangeNotifier {
  List<VideoModel> _favorites = [];
  Map<String, List<ReviewModel>> _reviews = {};
  
  List<VideoModel> get favorites => _favorites;
  
  FavoritesProvider() {
    _loadFavorites();
    _loadReviews();
  }
  
  void _loadFavorites() {
    var box = Hive.box<VideoModel>('favorites');
    _favorites = box.values.toList();
    notifyListeners();
  }
  
  void _loadReviews() {
    var box = Hive.box<ReviewModel>('reviews');
    Map<String, List<ReviewModel>> reviewsMap = {};
    
    for (var review in box.values) {
      if (!reviewsMap.containsKey(review.videoId)) {
        reviewsMap[review.videoId] = [];
      }
      reviewsMap[review.videoId]!.add(review);
    }
    
    _reviews = reviewsMap;
    notifyListeners();
  }
  
  bool isFavorite(String videoId) {
    return _favorites.any((video) => video.id == videoId);
  }
  
  Future<void> toggleFavorite(VideoModel video) async {
    var box = Hive.box<VideoModel>('favorites');
    
    if (isFavorite(video.id)) {
      // Hapus dari favorit
      _favorites.removeWhere((item) => item.id == video.id);
      // Hapus dari Hive box
      for (var key in box.keys) {
        var value = box.get(key);
        if (value != null && value.id == video.id) {
          box.delete(key);
          break;
        }
      }
    } else {
      // Tambahkan ke favorit
      _favorites.add(video);
      // Simpan ke Hive box
      box.add(video);
    }
    
    notifyListeners();
  }
  
  List<ReviewModel> getReviewsForVideo(String videoId) {
    return _reviews[videoId] ?? [];
  }
  
  Future<void> addReview(String videoId, String comment, double rating) async {
    var box = Hive.box<ReviewModel>('reviews');
    
    // Buat ID unik untuk ulasan
    String reviewId = const Uuid().v4();
    
    // Buat ulasan baru
    ReviewModel newReview = ReviewModel(
      id: reviewId,
      videoId: videoId,
      comment: comment,
      rating: rating,
      timestamp: DateTime.now(),
    );
    
    // Tambahkan ke box
    box.add(newReview);
    
    // Tambahkan ke map lokal
    if (!_reviews.containsKey(videoId)) {
      _reviews[videoId] = [];
    }
    _reviews[videoId]!.add(newReview);
    
    notifyListeners();
  }
  
  double getAverageRating(String videoId) {
    var reviews = getReviewsForVideo(videoId);
    if (reviews.isEmpty) {
      return 0.0;
    }
    
    double totalRating = reviews.fold(0.0, (sum, item) => sum + item.rating);
    return totalRating / reviews.length;
  }
}