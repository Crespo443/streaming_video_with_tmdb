import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:flutter_video_app/providers/video_provider.dart';
import 'package:flutter_video_app/screens/genre_movies_screen.dart';
import 'package:flutter_video_app/widgets/video_row.dart';
import 'package:flutter_video_app/widgets/video_card.dart';

// Manual Mock for VideoProvider (can be shared or redefined if necessary)
// For simplicity, copying the one from genre_movies_screen_test.dart
// In a real project, this might be in a shared test utility file.
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

  void setVideosForCategory(String category, List<Video> videos) {
    _videosByCategory[category] = videos;
    if (!_categories.contains(category)) {
      _categories.add(category);
    }
    _videos.clear();
    _videos.addAll(videos);
    notifyListeners();
  }

  void setAllVideos(List<Video> videos) {
    _videos = List.from(videos);
    notifyListeners();
  }

  void setCategories(List<String> categories) {
    _categories = List.from(categories);
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockVideoProvider mockVideoProvider;

  setUp(() {
    mockVideoProvider = MockVideoProvider();
  });

  // Test data
  const String testCategoryTitle = 'Featured';
  final List<Video> testCategoryVideos = [
    Video(id: '1', title: 'Movie 1', videoUrl: 'url1', thumbnailUrl: 'thumb1', category: 'Featured', duration: '1:20'),
    Video(id: '2', title: 'Movie 2', videoUrl: 'url2', thumbnailUrl: 'thumb2', category: 'Featured', duration: '1:30'),
  ];
  final List<VideoModel> testVideoModels = testCategoryVideos.map((v) => VideoModel.fromVideo(v)).toList();

  testWidgets('VideoRow displays title and VideoCards correctly', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VideoRow(title: testCategoryTitle, videos: testVideoModels),
        ),
      ),
    );

    // Assert
    expect(find.text(testCategoryTitle), findsOneWidget);
    expect(find.byType(VideoCard), findsNWidgets(testVideoModels.length));
    expect(find.text('Movie 1'), findsOneWidget); // Check for one of the video titles
  });

  testWidgets('VideoRow "See All" button tap navigates to GenreMoviesScreen', (WidgetTester tester) async {
    // Arrange
    // For GenreMoviesScreen to function, it needs videos for the category it's displaying
    mockVideoProvider.setVideosForCategory(testCategoryTitle, testCategoryVideos);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<VideoProvider>.value(value: mockVideoProvider),
        ],
        child: MaterialApp(
          // Define a simple routes map or use home + navigator.push for testing
          // GenreMoviesScreen will be pushed, so it needs a route or direct push.
          home: Scaffold(
            body: VideoRow(title: testCategoryTitle, videos: testVideoModels),
          ),
        ),
      ),
    );

    // Act
    // Ensure the "See All" button is present
    expect(find.text('See All'), findsOneWidget);

    // Tap the "See All" button
    await tester.tap(find.text('See All'));
    await tester.pumpAndSettle(); // pumpAndSettle to allow navigation transition to complete

    // Assert
    // Verify that GenreMoviesScreen is now on screen
    expect(find.byType(GenreMoviesScreen), findsOneWidget);

    // Verify that the genreName passed to GenreMoviesScreen is correct
    // The title "Featured" will appear twice: once in the AppBar of GenreMoviesScreen,
    // and once for the VideoRow (which might be off-screen or still partly visible).
    // To be more specific, we check the one in the AppBar.
    expect(find.descendant(of: find.byType(AppBar), matching: find.text(testCategoryTitle)), findsOneWidget);

    // Verify the content of GenreMoviesScreen (e.g., correct number of cards for that genre)
    expect(find.byType(VideoCard), findsNWidgets(testCategoryVideos.length));
    expect(find.text('Movie 1'), findsOneWidget); // Check one of the movie titles is on GenreMoviesScreen
  });
}
