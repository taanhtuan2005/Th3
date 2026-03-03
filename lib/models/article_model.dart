class Article {
  final String title;
  final String description; // Was 'summary'
  final String imageUrl;
  final String pubDate; // Was 'publishedAt'
  final String source; // Was 'newsSite'
  final String link; // New

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pubDate,
    required this.source,
    required this.link,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Không có tiêu đề',
      description: _cleanDescription(json['description'] ?? ''),
      // RSS often puts image in 'enclosure'->'link', or 'thumbnail'
      // rss2json usually puts it in 'thumbnail' or 'enclosure' object
      imageUrl: _extractImage(json),
      pubDate: json['pubDate'] ?? '',
      source: 'VnExpress', // Can be dynamic
      link: json['link'] ?? '',
    );
  }

  static String _extractImage(Map<String, dynamic> json) {
    if (json['thumbnail'] != null && json['thumbnail'].isNotEmpty) {
      return json['thumbnail'];
    }
    if (json['enclosure'] != null && json['enclosure']['link'] != null) {
      return json['enclosure']['link'];
    }
    // Fallback if inside description (regex could be used, but simple fallback for now)
    return '';
  }

  static String _cleanDescription(String htmlString) {
    // Remove CDATA
    htmlString = htmlString.replaceAll('<![CDATA[', '').replaceAll(']]>', '');
    // Remove <img> tags to avoid duplicates if description contains image
    htmlString = htmlString.replaceAll(RegExp(r'<img[^>]*>'), '');
    // Remove <br>
    htmlString = htmlString.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    // Remove <a> tags (links) but keep text? Or remove whole link? usually just strip tags
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }
}
