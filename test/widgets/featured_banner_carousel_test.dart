import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:flutter_video_app/widgets/featured_banner_carousel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test data
  final videoWithBackdrop = VideoModel(
    id: '1',
    title: 'Movie with Backdrop',
    videoUrl: 'url1',
    thumbnailUrl: 'thumb1.jpg',
    category: 'Featured',
    duration: '1:00',
    backdropPath: 'backdrop1.jpg', // Valid backdrop
  );

  final videoWithoutBackdrop = VideoModel(
    id: '2',
    title: 'Movie without Backdrop',
    videoUrl: 'url2',
    thumbnailUrl: 'thumb2.jpg', // Fallback thumbnail
    category: 'Featured',
    duration: '1:00',
    backdropPath: null, // Null backdrop
  );

  final videoWithEmptyBackdrop = VideoModel(
    id: '3',
    title: 'Movie with Empty Backdrop',
    videoUrl: 'url3',
    thumbnailUrl: 'thumb3.jpg', // Fallback thumbnail
    category: 'Featured',
    duration: '1:00',
    backdropPath: '', // Empty string backdrop
  );

  final List<VideoModel> testVideos = [
    videoWithBackdrop,
    videoWithoutBackdrop,
    videoWithEmptyBackdrop,
  ];

  testWidgets('FeaturedBannerCarousel uses backdropPath first, then thumbnailUrl', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeaturedBannerCarousel(featuredVideos: testVideos),
        ),
      ),
    );

    // Act & Assert
    // Find all CachedNetworkImage widgets
    final imageWidgets = tester.widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage));

    // Expect to find one image per video initially visible (or pre-cached by PageView)
    // PageView with viewportFraction < 1.0 might render more than one.
    // We check the ones that are part of the banner items.
    // For simplicity, we'll check based on the order if PageView renders them sequentially.
    // A more robust way might involve finding the specific banner item then the image within it.

    expect(imageWidgets.length, greaterThanOrEqualTo(1)); // At least the first one

    // 1. Check video with backdropPath
    // The PageView might build items out of order or more than what's visible.
    // We need to find the specific CachedNetworkImage associated with videoWithBackdrop.
    // One way is to find the Text of the title, then go up to the common ancestor (banner item)
    // and then down to find the CachedNetworkImage.

    final bannerItem1Finder = find.ancestor(
      of: find.text('Movie with Backdrop'),
      matching: find.byType(GestureDetector), // Banner item's GestureDetector
    );
    final imageInBanner1 = find.descendant(
      of: bannerItem1Finder,
      matching: find.byType(CachedNetworkImage),
    );
    CachedNetworkImage image1 = tester.widget(imageInBanner1.first);
    expect(image1.imageUrl, videoWithBackdrop.backdropPath);

    // For the other items, we might need to scroll or ensure PageView has built them.
    // Let's pumpAndSettle to ensure animations are done and additional pages might be laid out.
    await tester.pumpAndSettle();
    
    // Re-query after settle
    final allImageWidgetsAfterSettle = tester.widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage));

    // 2. Check video without backdropPath (should use thumbnailUrl)
     final bannerItem2Finder = find.ancestor(
      of: find.text('Movie without Backdrop'),
      matching: find.byType(GestureDetector),
    );
    final imageInBanner2 = find.descendant(
      of: bannerItem2Finder,
      matching: find.byType(CachedNetworkImage),
    );
    CachedNetworkImage image2 = tester.widget(imageInBanner2.first);
    expect(image2.imageUrl, videoWithoutBackdrop.thumbnailUrl);


    // 3. Check video with empty backdropPath (should use thumbnailUrl)
    final bannerItem3Finder = find.ancestor(
      of: find.text('Movie with Empty Backdrop'),
      matching: find.byType(GestureDetector),
    );
     final imageInBanner3 = find.descendant(
      of: bannerItem3Finder,
      matching: find.byType(CachedNetworkImage),
    );
    CachedNetworkImage image3 = tester.widget(imageInBanner3.first);
    expect(image3.imageUrl, videoWithEmptyBackdrop.thumbnailUrl);

    // Ensure no overflow errors
    expect(tester.takeException(), isNull);
  });
}
