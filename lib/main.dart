import 'package:flutter/material.dart';
import 'package:flutter_video_app/services/hive_service.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:flutter_video_app/models/review_model.dart';
import 'package:flutter_video_app/providers/video_provider.dart';
import 'package:flutter_video_app/providers/favorites_provider.dart';
import 'package:flutter_video_app/screens/home_screen.dart';
import 'package:flutter_video_app/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();
  await Hive.initFlutter();

  Hive.registerAdapter(VideoModelAdapter());
  Hive.registerAdapter(ReviewModelAdapter());

  
  await Hive.openBox<VideoModel>('favorites');
  await Hive.openBox<ReviewModel>('reviews');
  await Hive.openBox<String>('watchHistory');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Video Streaming',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}