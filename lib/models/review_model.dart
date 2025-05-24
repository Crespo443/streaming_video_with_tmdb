import 'package:hive/hive.dart';
part 'review_model.g.dart';

@HiveType(typeId: 1)
class ReviewModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String videoId;
  
  @HiveField(2)
  final String comment;
  
  @HiveField(3)
  final double rating;
  
  @HiveField(4)
  final DateTime timestamp;
  
  ReviewModel({
    required this.id,
    required this.videoId,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });
}