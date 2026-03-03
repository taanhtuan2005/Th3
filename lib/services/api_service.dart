import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';
import 'dart:developer' as developer;

class ApiService {
  // Public Spaceflight News API (International)
  static const String _baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles/';

  Future<List<Article>> fetchArticles({String query = ''}) async {
    try {
      String url = '$_baseUrl?limit=20';
      if (query.isNotEmpty) {
        // Use multiple filters or just title_contains as it is most reliable
        url += '&title_contains=$query';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        if (body['results'] == null) {
          return [];
        }

        List<dynamic> itemsJson = body['results'];

        List<Article> articles = itemsJson.map((dynamic item) {
          return Article(
            title: item['title'] ?? 'No Title',
            description: item['summary'] ?? '',
            imageUrl: item['image_url'] ?? '',
            pubDate: item['published_at'] ?? '',
            source: item['news_site'] ?? 'SpaceNews',
            link: item['url'] ?? '',
          );
        }).toList();

        return articles;
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching news: $e');
      throw Exception('Connection error: $e');
    }
  }

  // Simulated Login remains same
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return username.isNotEmpty && password.length >= 6;
  }
}
