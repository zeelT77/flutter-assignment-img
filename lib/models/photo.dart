class Photo {
  final int id;
  final String photographer;
  final String imageUrl;
  final String originalUrl;
  final String altText;
  final int width;
  final int height;

  Photo({
    required this.id,
    required this.photographer,
    required this.imageUrl,
    required this.originalUrl,
    required this.altText,
    required this.width,
    required this.height,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      photographer: json['photographer'] ?? 'Unknown',
      imageUrl: json['src'] != null ? (json['src']['medium'] ?? json['src']['original']) : json['imageUrl'],
      originalUrl: json['src'] != null ? (json['src']['large2x'] ?? json['src']['original']) : json['originalUrl'],
      altText: json['alt'] ?? json['altText'] ?? 'A photo',
      width: json['width'] ?? 1,
      height: json['height'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photographer': photographer,
      'imageUrl': imageUrl,
      'originalUrl': originalUrl,
      'altText': altText,
      'width': width,
      'height': height,
    };
  }
}
