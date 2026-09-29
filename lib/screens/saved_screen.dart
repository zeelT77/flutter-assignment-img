import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/saved_photos_provider.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedPhotos = context.watch<SavedPhotosProvider>().savedPhotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        centerTitle: true,
      ),
      body: savedPhotos.isEmpty
          ? const Center(
              child: Text(
                'No saved photos yet.\nTap the bookmark icon to save some!',
                textAlign: TextAlign.center,
              ),
            )
          : MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.all(8),
              itemCount: savedPhotos.length,
              itemBuilder: (context, index) {
                final photo = savedPhotos[index];
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
    );
  }
}
