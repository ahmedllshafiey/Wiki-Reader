import 'dart:convert';
import 'dart:io';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'summary.dart';

void main() {
  runApp(const MainApp());
}

// ============================================================
// APPLICATION
// ============================================================

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wikipedia Random Articles',
      home: ArticleView(),
    );
  }
}

// ============================================================
// MODEL
// ============================================================

class ArticleModel {
  static const String _host = 'en.wikipedia.org';
  static const String _path = '/api/rest_v1/page/random/summary';

  Future<Summary> getRandomArticleSummary() async {
    final uri = Uri.https(_host, _path);

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to fetch article. Status code: ${response.statusCode}',
        uri: uri,
      );
    }

    final json = jsonDecode(response.body) as Map<String, Object?>;

    return Summary.fromJson(json);
  }
}

// ============================================================
// VIEW MODEL
// ============================================================

class ArticleViewModel extends ChangeNotifier {
  final ArticleModel model;

  Summary? summary;
  Object? error;
  bool isLoading = false;

  bool _isDisposed = false;

  ArticleViewModel(this.model);

  Future<void> fetchArticle() async {
    // Prevent overlapping requests.
    if (isLoading || _isDisposed) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await model.getRandomArticleSummary();

      if (_isDisposed) return;

      summary = result;
    } catch (e) {
      if (_isDisposed) return;

      error = e;
      summary = null;
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

// ============================================================
// ARTICLE WIDGET
// ============================================================

class ArticleWidget extends StatelessWidget {
  const ArticleWidget({super.key, required this.summary});

  final Summary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 12.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.hasImage)
            Image.network(
              summary.originalImage!.source,
              width: double.infinity,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, size: 48));
              },
            ),

          Text(summary.titles.normalized, style: textTheme.titleLarge),

          if (summary.description != null)
            Text(summary.description!, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ============================================================
// ARTICLE PAGE
// ============================================================

class ArticlePage extends StatelessWidget {
  const ArticlePage({
    super.key,
    required this.summary,
    required this.onNextArticle,
  });

  final Summary summary;
  final VoidCallback onNextArticle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ArticleWidget(summary: summary),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onNextArticle,
              child: const Text('Next Random Article'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ARTICLE VIEW
// ============================================================

class ArticleView extends StatefulWidget {
  const ArticleView({super.key});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  late final ArticleViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = ArticleViewModel(ArticleModel());
    viewModel.fetchArticle();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wikipedia Random Articles')),

      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12.0,
          children: [
            const Icon(Icons.error_outline, size: 48),

            Text(
              'Failed to load article:\n${viewModel.error}',
              textAlign: TextAlign.center,
            ),

            ElevatedButton(
              onPressed: viewModel.fetchArticle,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final summary = viewModel.summary;

    if (summary == null) {
      return const Center(child: Text('Something went wrong!'));
    }

    return ArticlePage(summary: summary, onNextArticle: viewModel.fetchArticle);
  }
}
