import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';

class DeezerApi {
  static Future<List<Track>> fetchLofiTracks({int limit = 10}) async {
    final url = 'https://api.deezer.com/search?q=lofi&limit=$limit';
    final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
    final response = await http.get(Uri.parse(proxyUrl));
    if (response.statusCode != 200) throw Exception('Failed to fetch tracks');
    final data = jsonDecode(response.body);
    if (data['data'] is! List) throw Exception('Invalid Deezer response');
    return (data['data'] as List).map((track) => Track.fromJson(track)).toList();
  }
} 