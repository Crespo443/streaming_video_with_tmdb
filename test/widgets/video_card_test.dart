import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:flutter_video_app/widgets/video_card.dart';
// Import CachedNetworkImage to check its properties if necessary, though not directly used in this file's assertions.
// import 'package:cached_network_image/cached_network_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test data
  final testVideo = VideoModel(
    id: '1',
    title: 'Sample Movie Title',
    videoUrl: 'url1',
    thumbnailUrl: 'thumb1.jpg', // Ensure this is a non-empty string for image related widgets
    category: 'Test',
    duration: '1:30',
    backdropPath: 'backdrop1.jpg',
  );

  final videoWithLongTitle = VideoModel(
    id: '2',
    title: 'This is a Very Very Very Long Movie Title That Is Intended to Overflow The Available Space in The VideoCard Widget To Test Ellipsis',
    videoUrl: 'url2',
    thumbnailUrl: 'thumb2.jpg', // Ensure this is a non-empty string
    category: 'Test',
    duration: '2:00',
    backdropPath: 'backdrop2.jpg',
  );

  testWidgets('VideoCard displays title and thumbnail placeholder', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VideoCard(video: testVideo),
        ),
      ),
    );

    // Assert
    expect(find.text(testVideo.title), findsOneWidget);
    // Initially, CachedNetworkImage shows a placeholder.
    expect(find.byType(CircularProgressIndicator), findsOneWidget); 
    
    // Allow time for image to load/error
    await tester.pumpAndSettle(); 
    // After pumpAndSettle, either the image or an error widget would be shown.
    // For this test, we're primarily concerned with the structure and title.
  });

  testWidgets('VideoCard handles long titles without overflow and shows ellipsis', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center( 
            child: SizedBox( 
              width: 130, // Default width of VideoCard from its implementation
              // Height calculation: Image (130 * 3/2 = 195) + Padding (top 6, bottom 4) + Text (2 lines * ~14-16 font height)
              // Approximate height needed: 195 + 10 + (2 * 14) = 195 + 10 + 28 = 233.
              // Let's give it a bit less to ensure truncation or proper fit. Or a bit more to ensure no overflow.
              // The key is that the VideoCard itself now uses MainAxisSize.min, so it will wrap its content.
              // We are testing that *within* the card, the text handles itself.
              // The SizedBox here is more to simulate a common parent constraint.
              height: 250, // Generous height to avoid external overflow, focusing on internal handling.
              child: VideoCard(video: videoWithLongTitle, showTitle: true),
            ),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();

    // Assert
    // 1. Check for overflow error from the Flutter framework
    expect(tester.takeException(), isNull, reason: "VideoCard or its children reported an overflow error.");

    // 2. Verify the title Text widget's properties
    final titleFinder = find.text(videoWithLongTitle.title);
    expect(titleFinder, findsOneWidget, reason: "The long title was not found. It might be missing or completely invisible.");
    
    final Text textWidget = tester.widget<Text>(titleFinder);
    expect(textWidget.overflow, TextOverflow.ellipsis, reason: "Title Text widget does not have TextOverflow.ellipsis.");
    expect(textWidget.maxLines, 2, reason: "Title Text widget does not have maxLines set to 2.");

    // 3. Optional: Check if the text is actually truncated by looking for ellipsis character
    // This requires the title to be definitively too long for 2 lines at 130px width.
    // RichText rtext = tester.firstWidget(find.byType(RichText));
    // expect(rtext.text.toPlainText().contains('\u2026'), isTrue, reason: "Ellipsis character not found, text may not be truncated as expected.");
    // The above check is more complex. For now, relying on no overflow and properties is sufficient.
  });
}
