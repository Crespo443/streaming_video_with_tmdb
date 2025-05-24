import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:flutter_video_app/models/review_model.dart';

class DatabaseService {
  static const String favoritesBoxName = 'favorites';
  static const String reviewsBoxName = 'reviews';
  static const String watchHistoryBoxName = 'watchHistory';

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(VideoModelAdapter());
    Hive.registerAdapter(ReviewModelAdapter());

    await Hive.openBox<ReviewModel>(reviewsBoxName);
    await Hive.openBox<String>(watchHistoryBoxName);
  }

  static Future<void> toggleFavorite(VideoModel video) async {
    final box = Hive.box<VideoModel>(favoritesBoxName);

    if (isFavorite(video.id)) {
      box.values.where((v) => v.id == video.id).forEach((v) {
        final key = box.keyAt(box.values.toList().indexOf(v));
        box.delete(key);
      });
    } else {
      await box.add(video);
    }
  }

  static bool isFavorite(String videoId) {
    final box = Hive.box<VideoModel>(favoritesBoxName);
    return box.values.any((video) => video.id == videoId);
  }

  static List<VideoModel> getFavorites() {
    final box = Hive.box<VideoModel>(favoritesBoxName);
    return box.values.toList();
  }

  static Future<void> saveReview(ReviewModel review) async {
    final box = Hive.box<ReviewModel>(reviewsBoxName);
    await box.put(review.id, review);
  }

  static List<ReviewModel> getReviewsForVideo(String videoId) {
    final box = Hive.box<ReviewModel>(reviewsBoxName);
    return box.values.where((review) => review.videoId == videoId).toList();
  }

  static Future<void> deleteReview(String reviewId) async {
    final box = Hive.box<ReviewModel>(reviewsBoxName);
    await box.delete(reviewId);
  }

  static Future<void> addToWatchHistory(String videoId) async {
    final box = Hive.box<String>(watchHistoryBoxName);

    final List<String> history = box.values.toList();
    history.remove(videoId);    
    history.insert(0, videoId);
    
    await box.clear();
    await box.addAll(history);

    if (box.length > 50) {
      final keysToRemove = box.keys.toList().sublist(50);
      await box.deleteAll(keysToRemove);
    }
  }

  static List<String> getWatchHistory() {
    final box = Hive.box<String>(watchHistoryBoxName);
    return box.values.toList();
  }
}
