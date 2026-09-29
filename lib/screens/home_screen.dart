import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/pexels_api_service.dart';
import '../models/photo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PexelsApiService _apiService = PexelsApiService();
  final List<Photo> _photos = [];
  final ScrollController _scrollController = ScrollController();
  
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore &&
        !_hasError) {
      _fetchPhotos();
    }
  }

  Future<void> _fetchPhotos({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _photos.clear();
        _hasMore = true;
        _hasError = false;
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final newPhotos = await _apiService.getCuratedPhotos(page: _currentPage);
      setState(() {
        _currentPage++;
        _photos.addAll(newPhotos);
        if (newPhotos.isEmpty) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snaply'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchPhotos(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_photos.isEmpty) {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (_hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load photos.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchPhotos(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      } else {
        return const Center(child: Text('No photos found.'));
      }
    }

    return Column(
      children: [
        Expanded(
          child: MasonryGridView.count(
            controller: _scrollController,
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    context.push('/photo_detail', extra: photo);
                  },
                  child: Hero(
                    tag: 'photo_${photo.id}',
                    child: AspectRatio(
                      aspectRatio: photo.width / photo.height,
                      child: Image.network(
                        photo.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
            },
          ),
        ),
        if (_isLoading && _photos.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        if (_hasError && _photos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load more.'),
                TextButton(
                  onPressed: () => _fetchPhotos(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
