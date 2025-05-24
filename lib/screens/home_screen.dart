import 'package:flutter/material.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_video_app/providers/video_provider.dart';
import 'package:flutter_video_app/screens/favorites_screen.dart';
import 'package:flutter_video_app/widgets/video_grid.dart';
import 'package:flutter_video_app/widgets/featured_banner_carousel.dart';
import 'package:flutter_video_app/widgets/video_row.dart';
import 'package:flutter_video_app/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    if (videoProvider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              _isSearching
                  ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: Constants.searchHint,
                      hintStyle: const TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {});
                    },
                  )
                  : Text(
                    _currentIndex == 0
                        ? Constants.homeScreenTitle
                        : Constants.favoritesScreenTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
          actions: [
            if (_currentIndex == 0)
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                    }
                  });
                },
              ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _isSearching = false;
              _searchController.clear();
            });
          },
          backgroundColor: Colors.black,
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
      );
    }
    final List<VideoModel> carouselVideos;
    List<VideoModel> potentialFeaturedVideos = videoProvider
        .getVideosByCategory('Featured');

    if (potentialFeaturedVideos.isNotEmpty) {
      carouselVideos = potentialFeaturedVideos.take(5).toList();
    } else if (videoProvider.allVideos.isNotEmpty) {
      carouselVideos = videoProvider.allVideos.take(5).toList();
    } else {
      carouselVideos = [];
    }
    final List<String> categoriesForRows = videoProvider.getCategories();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: Constants.searchHint,
                    hintStyle: const TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {});
                  },
                )
                : Text(
                  _currentIndex == 0
                      ? Constants.homeScreenTitle
                      : Constants.favoritesScreenTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                  }
                });
              },
            ),
        ],
      ),
      body:
          _currentIndex == 0
              ? _isSearching
                  ? _searchController.text.isEmpty
                      ? const Center(
                        child: Text(
                          'Start typing to search for videos...',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : VideoGrid(
                        videos: videoProvider.searchVideos(
                          _searchController.text,
                        ),
                      )
                  : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (carouselVideos.isNotEmpty)
                          FeaturedBannerCarousel(
                            featuredVideos: carouselVideos,
                          ),

                        const SizedBox(height: 10),
                        ...categoriesForRows.map((categoryName) {
                          if (categoryName.toLowerCase() == 'featured' &&
                              potentialFeaturedVideos.isNotEmpty &&
                              carouselVideos.any(
                                (v) => v.categories.contains('Featured'),
                              )) {
                            return const SizedBox.shrink();
                          }
                          final List<VideoModel> videosForThisCategory =
                              videoProvider.getVideosByCategory(categoryName);
                          if (videosForThisCategory.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return VideoRow(
                            title: categoryName,
                            videos: videosForThisCategory,
                          );
                        }).toList(),

                        const SizedBox(height: 20), // Padding di bagian bawah
                      ],
                    ),
                  )
              : const FavoritesScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _isSearching = false;
            _searchController.clear();
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
