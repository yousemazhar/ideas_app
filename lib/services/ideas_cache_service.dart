import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_config.dart';
import '../models/idea.dart';

class IdeasCacheService {
  Future<void> saveIdeas(List<Idea> ideas) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String encodedIdeas = jsonEncode(
      ideas.map((idea) => idea.toJson()).toList(),
    );
    await preferences.setString(AppConfig.ideasCacheKey, encodedIdeas);
  }

  Future<List<Idea>> loadIdeas() async {
    try {
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      final String? cachedIdeas = preferences.getString(AppConfig.ideasCacheKey);

      if (cachedIdeas == null || cachedIdeas.isEmpty) {
        return [];
      }

      final dynamic decodedData = jsonDecode(cachedIdeas);
      if (decodedData is! List) {
        return [];
      }

      return decodedData
          .whereType<Map>()
          .map(
            (ideaJson) => Idea.fromJson(
              Map<String, dynamic>.from(ideaJson),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
