import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/photo.dart';

class PexelsApiService {
  static const String _apiKey =
      'jjDWmgSJyBZ3icneroGkXMHy6EMNe9hukjVCsduVpBLQB5XrpJRnE3yF';
  static const String _baseUrl = 'https://api.pexels.com/v1';

  Future<List<Photo>> getCuratedPhotos({int page = 1, int perPage = 20}) async {
    final uri = Uri.parse('$_baseUrl/curated?page=$page&per_page=$perPage');

    final response = await http.get(uri, headers: {'Authorization': _apiKey});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> photosJson = data['photos'];
      return photosJson.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos: ${response.statusCode}');
    }
  }

  Future<List<Photo>> searchPhotos(
    String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/search?query=$query&page=$page&per_page=$perPage',
    );

    final response = await http.get(uri, headers: {'Authorization': _apiKey});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> photosJson = data['photos'];
      return photosJson.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search photos: ${response.statusCode}');
    }
  }
}
