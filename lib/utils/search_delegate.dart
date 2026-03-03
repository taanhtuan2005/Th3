import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';
import '../screens/detail_screen.dart';

class NewsSearchDelegate extends SearchDelegate<String> {
  final ApiService apiService = ApiService();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a keyword to search'));
    }

    return FutureBuilder<List<Article>>(
      future: apiService.fetchArticles(query: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        final articles = snapshot.data!;
        return ListView.separated(
          itemCount: articles.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final article = articles[index];
            return ListTile(
              title: Text(article.title),
              subtitle: Text(article.source),
              leading: article.imageUrl.isNotEmpty
                  ? Image.network(
                      article.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.article),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(article: article),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Search for space news (e.g. SpaceX, NASA, Moon)'),
          leading: const Icon(Icons.search),
          onTap: () {
            // Optional: trigger suggestions
          },
        ),
      ],
    );
  }
}
