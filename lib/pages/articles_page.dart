import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as htmlDom;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HabrArticleView extends StatefulWidget {
  final String articleLink;
  final String articleTitle;

  HabrArticleView({required this.articleLink, required this.articleTitle});

  @override
  _HabrArticleViewState createState() => _HabrArticleViewState();
}

class _HabrArticleViewState extends State<HabrArticleView> {
  Future<String> fetchArticle() async {
    final response = await http.get(Uri.parse(widget.articleLink));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load article');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.articleTitle),
      ),
      body: FutureBuilder<String>(
        future: fetchArticle(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final articleHtml = extractArticleContent(snapshot.data ?? "");
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: HtmlWidget(articleHtml),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  String extractArticleContent(String htmlContent) {
    final document = htmlParser.parse(htmlContent);
    final elements = document.getElementsByClassName('tm-article-body');
    if (elements.isNotEmpty) {
      return elements.first.outerHtml;
    }
    return 'Failed to parse article content.';
  }
}
