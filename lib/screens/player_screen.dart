import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/video_model.dart';
import '../services/database_service.dart';

class PlayerScreen extends StatefulWidget {
  final VideoModel video;

  const PlayerScreen({super.key, required this.video});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    // Add to watch history
    DatabaseService.addToWatchHistory(widget.video.id);
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Gagal memuat video: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
              onTap: (context) => _toggleFavorite(),
              iconData: Icons.favorite,
              title: 'Tambahkan ke Favorit',
            ),
          ];
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Error initializing video player: $e');
    }
  }

  void _toggleFavorite() async {
    await DatabaseService.toggleFavorite(widget.video);

    final isFavorite = DatabaseService.isFavorite(widget.video.id);
    final message =
        isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit';

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final position = await _videoPlayerController.position;
        print('Video stopped at position: ${position?.inSeconds} seconds');
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.video.title),
          actions: [
            IconButton(
              icon: Icon(
                DatabaseService.isFavorite(widget.video.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [Expanded(child: _buildVideoPlayer()), _buildVideoInfo()],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_hasError) {
      return const Center(
        child: Text(
          'Terjadi kesalahan saat memuat video',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Chewie(controller: _chewieController!);
    }
  }

  Widget _buildVideoInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.black87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.video.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 14.0),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
