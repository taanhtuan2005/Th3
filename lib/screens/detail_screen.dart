import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import 'dart:developer' as developer;

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(article.link);

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        developer.log('Could not launch $url');
        // Fallback or show snackbar
      }
    } catch (e) {
      developer.log('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.indigo[900],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black87),
              ),
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  article.source,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              // Negative margin to overlap the image slightly if we wanted,
              // but slivers place it below. To overlap we'd need a Stack.
              // Let's keep it simple and clean.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.indigo[300],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(article.pubDate),
                        style: TextStyle(
                          color: Colors.indigo[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    article.description,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _launchUrl,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text(
                        'READ FULL ARTICLE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${dateAsString(date.weekday)}, ${date.day} ${monthAsString(date.month)} ${date.year}';
    } catch (e) {
      return '';
    }
  }

  String monthAsString(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String dateAsString(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
