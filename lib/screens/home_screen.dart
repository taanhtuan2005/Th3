import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import '../utils/search_delegate.dart'; // Import search delegate

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Article>> _futureArticles;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _futureArticles = _apiService.fetchArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      body: FutureBuilder<List<Article>>(
        future: _futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          } else if (snapshot.hasData) {
            final articles = snapshot.data!;
            if (articles.isEmpty) {
              return const Center(child: Text('Empty Feed'));
            }
            return RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  if (articles.isNotEmpty) _buildFeaturedItem(articles.first),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        // Skip the first item as it is featured
                        final article = articles[index + 1];
                        return _buildArticleItem(article);
                      }, childCount: articles.length - 1),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.indigo[900],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'TH3 - Tạ Anh Tuấn - 2351060494',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1000&q=80',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black45),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: NewsSearchDelegate());
          },
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showCompInfo, // Existing info button
        ),
      ],
    );
  }

  Widget _buildFeaturedItem(Article article) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => _navigateToDetail(article),
        child: Container(
          margin: const EdgeInsets.all(16),
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(article.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(article.pubDate),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleItem(Article article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(article),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.network(
                  article.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              // Right Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 12,
                            color: Colors.indigo[300],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              article.source,
                              style: TextStyle(
                                color: Colors.indigo[300],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(article.pubDate),
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Connection Lost',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please check your internet connection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _fetchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  void _showCompInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children: const [
              Icon(Icons.rocket, color: Colors.indigo),
              SizedBox(width: 10),
              Text('About App'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Space News Aggregator',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Data provided by Spaceflight News API v4.'),
              Divider(height: 30),
              Text('Student: Tạ Anh Tuấn', style: TextStyle(fontSize: 13)),
              Text('ID: 2351060494', style: TextStyle(fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      // Simple format
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return '';
    }
  }
}
