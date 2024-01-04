import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
//import 'package:enough_convert/enough_convert.dart';
//import 'package:flutter_html/flutter_html.dart';
//import 'package:flutter_html_all/flutter_html_all.dart';
//import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'pages/articles_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habr - Лучшее за неделю',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RssFeed? feed;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('https://habr.com/ru/rss/articles/top/weekly/?fl=ru'),
    );

    if (response.statusCode == 200) {
      final encodedBytes = response.bodyBytes;
      //const codec = Koi8rCodec(allowInvalid: false);
      final encoded = utf8.decode(encodedBytes);

      final document = xml.parse(encoded!);
      final rssElement = document.findElements('rss').first;
      setState(() {
        feed = RssFeed.parse(rssElement.toXmlString());
      });
    } else {
      throw Exception('Failed to load RSS feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habr - Лучшее за неделю'),
      ),
      body: feed == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: feed?.items?.length ?? 0,
              itemBuilder: (context, index) {
                final List<RssItem>? items = feed?.items;
                if (items != null && index < items.length) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.title ?? ''),
                    subtitle: Text(item.pubDate?.toString() ?? ''),
                    onTap: () {
                      // Handle tap on a news item
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabrArticleView(
                            articleLink: item.link ?? "",
                            articleTitle: item.title ?? "",
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
    );
  }
}
