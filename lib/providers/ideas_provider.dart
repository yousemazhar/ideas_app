import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../models/idea.dart';
import '../services/ideas_cache_service.dart';

class IdeasProvider extends ChangeNotifier {
  IdeasProvider({IdeasCacheService? cacheService})
    : _cacheService = cacheService ?? IdeasCacheService();

  final IdeasCacheService _cacheService;
  final List<Idea> _ideas = [];

  bool _isLoading = false;
  bool _isFetching = false;
  String? _errorMessage;
  bool _hasInitialized = false;

  List<Idea> get ideas => List.unmodifiable(_ideas);
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  String? get errorMessage => _errorMessage;
  bool get hasInitialized => _hasInitialized;

  Future<void> initializeIdeas() async {
    if (_hasInitialized) {
      return;
    }

    _hasInitialized = true;
    await loadCachedIdeas();
    await fetchIdeas();
  }

  Future<void> loadCachedIdeas() async {
    _errorMessage = null;
    final List<Idea> cachedIdeas = await _cacheService.loadIdeas();
    _ideas
      ..clear()
      ..addAll(cachedIdeas);
    notifyListeners();
  }

  Future<void> fetchIdeas() async {
    _isLoading = _ideas.isEmpty;
    _isFetching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri url = Uri.parse(
        '${AppConfig.firebaseBaseUrl}${AppConfig.ideasCollectionPath}.json',
      );
      final http.Response response = await http.get(url);

      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch ideas from the server.');
      }

      final dynamic decodedBody = jsonDecode(response.body);
      final List<Idea> fetchedIdeas = [];

      if (decodedBody is Map) {
        decodedBody.forEach((key, value) {
          if (value is Map) {
            fetchedIdeas.add(
              Idea.fromFirebase(
                key.toString(),
                Map<String, dynamic>.from(value),
              ),
            );
          }
        });
      }

      _ideas
        ..clear()
        ..addAll(fetchedIdeas);

      await _cacheService.saveIdeas(_ideas);
    } catch (_) {
      _errorMessage = 'Could not load ideas. Please try again.';
    } finally {
      _isLoading = false;
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> addIdea(String title, String description) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri url = Uri.parse(
        '${AppConfig.firebaseBaseUrl}${AppConfig.ideasCollectionPath}.json',
      );
      final http.Response response = await http.post(
        url,
        body: jsonEncode(
          Idea(id: '', title: title, description: description).toFirebaseJson(),
        ),
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to add idea.');
      }

      final Map<String, dynamic> responseData = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map<dynamic, dynamic>,
      );
      final String generatedId = responseData['name'] as String? ?? '';

      if (generatedId.isEmpty) {
        throw Exception('Invalid server response.');
      }

      _ideas.add(Idea(id: generatedId, title: title, description: description));
      await _cacheService.saveIdeas(_ideas);
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Could not save the idea. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteIdea(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri url = Uri.parse(
        '${AppConfig.firebaseBaseUrl}${AppConfig.ideasCollectionPath}/$id.json',
      );
      final http.Response response = await http.delete(url);

      if (response.statusCode >= 400) {
        throw Exception('Failed to delete idea.');
      }

      _ideas.removeWhere((idea) => idea.id == id);
      await _cacheService.saveIdeas(_ideas);
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Could not delete the idea. Please try again.';
      notifyListeners();
      rethrow;
    }
  }
}
