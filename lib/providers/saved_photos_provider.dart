import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo.dart';

class SavedPhotosProvider extends ChangeNotifier {
  Map<int, Photo> _savedPhotos = {};

  List<Photo> get savedPhotos => _savedPhotos.values.toList();
  int get savedCount => _savedPhotos.length;

  SavedPhotosProvider() {
    _loadSavedPhotos();
  }

  bool isSaved(int id) {
    return _savedPhotos.containsKey(id);
  }

  void toggleSave(Photo photo) {
    if (_savedPhotos.containsKey(photo.id)) {
      _savedPhotos.remove(photo.id);
    } else {
      _savedPhotos[photo.id] = photo;
    }
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadSavedPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_photos');
    if (savedData != null) {
      try {
        final List<dynamic> decoded = json.decode(savedData);
        _savedPhotos = {
          for (var item in decoded)
            item['id']: Photo.fromJson(item)
        };
        notifyListeners();
      } catch (e) {
        // Handle corrupt data by clearing it
        prefs.remove('saved_photos');
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encodedList = 
        _savedPhotos.values.map((p) => p.toJson()).toList();
    prefs.setString('saved_photos', json.encode(encodedList));
  }
}
