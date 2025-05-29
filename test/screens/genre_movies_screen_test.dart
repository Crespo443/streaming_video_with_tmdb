import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:flutter_video_app/providers/video_provider.dart';
import 'package:flutter_video_app/screens/genre_movies_screen.dart';
import 'package:flutter_video_app/widgets/video_grid.dart';
import 'package:flutter_video_app/widgets/video_card.dart';

// Manual Mock for VideoProvider
class MockVideoProvider extends ChangeNotifier implements VideoProvider {
  List<Video> _videos = [];
  List<String> _categories = [];
  Map<String, List<Video>> _videosByCategory = {};

  @override
  List<Video> get videos => _videos;

  @override
  List<String> get categories => _categories;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> fetchVideos() async {
    // No-op for mock
  }

  @override
  List<Video> getVideosByCategory(String category) {
    return _videosByCategory[category] ?? [];
  }

  // --- Methods to control the mock ---
  void setVideosForCategory(String category, List<Video> videos) {
    _videosByCategory[category] = videos;
    if (!_categories.contains(category)) {
      _categories.add(category);
    }
    // Add all videos to the general pool as well, for simplicity if needed elsewhere
    _videos.clear(); // Clear to avoid duplicates if called multiple times
    _videos.addAll(videos);
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockVideoProvider mockVideoProvider;

  setUp(() {
    mockVideoProvider = MockVideoProvider();
  });

  testWidgets('GenreMoviesScreen displays genre name, VideoGrid, and correct number of VideoCards', (WidgetTester tester) async {
    // Arrange
    const String testGenreName = 'Action';
    final List<Video> testVideos = [
      Video(id: '1', title: 'Action Movie 1', videoUrl: 'url1', thumbnailUrl: 'thumb1', category: 'Action', duration: '1:20'),
      Video(id: '2', title: 'Action Movie 2', videoUrl: 'url2', thumbnailUrl: 'thumb2', category: 'Action', duration: '1:30'),
    ];

    mockVideoProvider.setVideosForCategory(testGenreName, testVideos);

    // Act
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<VideoProvider>.value(value: mockVideoProvider),
        ],
        child: MaterialApp(
          home: GenreMoviesScreen(genreName: testGenreName),
        ),
      ),
    );

    // Assert
    // Verify AppBar title
    expect(find.text(testGenreName), findsOneWidget);
    // Verify VideoGrid is present
    expect(find.byType(VideoGrid), findsOneWidget);
    // Verify correct number of VideoCard widgets
    expect(find.byType(VideoCard), findsNWidgets(testVideos.length));

    // Also ensure VideoCard content is somewhat reasonable (e.g., finds title of one of the videos)
    expect(find.text('Action Movie 1'), findsOneWidget);
  });
}
