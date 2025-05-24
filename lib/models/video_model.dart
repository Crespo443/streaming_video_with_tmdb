import 'package:hive/hive.dart';

part 'video_model.g.dart';

@HiveType(typeId: 0)
class VideoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String thumbnailUrl;

  @HiveField(4)
  final String backdrop_path;

  @HiveField(5)
  final String videoUrl;

  @HiveField(6)
  final List<String> categories;

  @HiveField(7)
  final String type;


  @HiveField(8)
  final double rating;

  @HiveField(9)
  final List<String> tags;

  @HiveField(10)
  final String releaseDate;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.backdrop_path,
    required this.videoUrl,
    required this.categories,
    required this.type,
    required this.rating,
    required this.tags,
    required this.releaseDate,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      backdrop_path: json['backdrop_path'] as String,
      videoUrl: json['videoUrl'] as String,
      categories: List<String>.from(json['categories'] as List),
      type: json['type'] as String,

      rating: (json['rating'] as num).toDouble(),

      tags: List<String>.from(json['tags'] as List),
      releaseDate: json['releaseDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'backdrop_path': backdrop_path,
      'videoUrl': videoUrl,
      'categories': categories,
      'type': type,
      'rating': rating,
      'tags': tags,
      'releaseDate': releaseDate,
    };
  }
}
