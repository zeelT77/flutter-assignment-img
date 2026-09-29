import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/photo.dart';
import '../providers/saved_photos_provider.dart';

class PhotoDetailScreen extends StatefulWidget {
  final Photo photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  bool _isFollowing = false;

  void _sharePhoto(BuildContext context) {
    // ignore: deprecated_member_use
    Share.share('Check out this photo by ${widget.photo.photographer} on Snaply!\n${widget.photo.originalUrl}');
  }

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedPhotosProvider>();
    final isSaved = savedProvider.isSaved(widget.photo.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // Removed actions from here, they are now at the bottom
      ),
      body: Column(
        children: [
          // Top Section: The Image
          Expanded(
            child: Hero(
              tag: 'photo_${widget.photo.id}',
              child: Image.network(
                widget.photo.originalUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Icon(Icons.error, size: 50)),
              ),
            ),
          ),
          
          // Bottom Section: Contrasting Information Panel
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Owner and Follow Button
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withAlpha(25),
                        child: Text(
                          widget.photo.photographer.isNotEmpty 
                              ? widget.photo.photographer[0].toUpperCase() 
                              : '?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.photo.photographer,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _isFollowing = !_isFollowing;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isFollowing ? Colors.grey : theme.colorScheme.primary,
                          side: BorderSide(
                            color: _isFollowing ? Colors.grey : theme.colorScheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(_isFollowing ? 'Following' : 'Follow'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 2. Save and Share Options
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            savedProvider.toggleSave(widget.photo);
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              key: ValueKey<bool>(isSaved),
                            ),
                          ),
                          label: Text(isSaved ? 'Saved' : 'Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaved 
                                ? theme.colorScheme.primary 
                                : (isDark ? Colors.grey[800] : Colors.grey[200]),
                            foregroundColor: isSaved 
                                ? theme.colorScheme.onPrimary 
                                : (isDark ? Colors.white : Colors.black),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _sharePhoto(context),
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                            foregroundColor: isDark ? Colors.white : Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 3. Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.photo.altText.isEmpty 
                        ? 'No description available for this beautiful photograph.'
                        : widget.photo.altText,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
