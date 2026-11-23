import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class Quote {
  const Quote({
    required this.text,
    required this.author,
    required this.source,
    this.dynasty = '',
    this.online = false,
  });

  final String text;
  final String author;
  final String source;
  final String dynasty;
  final bool online;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'author': author,
        'source': source,
        'dynasty': dynasty,
      };

  static Quote? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final text = raw['text'];
    final author = raw['author'];
    final source = raw['source'];
    if (text is! String || text.trim().isEmpty) return null;
    return Quote(
      text: text.trim(),
      author: author is String ? author.trim() : '佚名',
      source: source is String ? source.trim() : '',
      dynasty: raw['dynasty'] is String ? raw['dynasty'] as String : '',
    );
  }

  /// 设置页/关于页展示的一行出处。
  String get attribution {
    final parts = <String>[];
    if (dynasty.isNotEmpty) parts.add(dynasty);
    if (author.isNotEmpty) parts.add(author);
    if (source.isNotEmpty) parts.add(source);
    return parts.join(' · ');
  }
}

/// 每日一句：优先使用当天在线缓存；没有则使用内置公版古诗文。
class QuoteStore extends ChangeNotifier {
  QuoteStore(this._prefs);

  static const String _cacheKey = 'quote_online_today_v1';
  static List<Quote>? _assetCache;

  final SharedPreferences _prefs;
  final List<Quote> _local = <Quote>[];
  Quote? _onlineToday;
  DateTime? _onlineDate;
  bool _loading = false;
  String? _error;

  List<Quote> get localQuotes => List<Quote>.unmodifiable(_local);

  bool get isLoading => _loading;

  String? get error => _error;

  Future<void> load() async {
    if (_local.isNotEmpty) return;
    final cachedAssets = _assetCache;
    if (cachedAssets != null) {
      _local.addAll(cachedAssets);
      _restoreOnlineCache();
      notifyListeners();
      return;
    }
    try {
      final raw = await rootBundle.loadString('assets/quotes/quotes.json');
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final item in decoded) {
          final quote = Quote.tryFromJson(item);
          if (quote != null) _local.add(quote);
        }
      }
      _assetCache = List<Quote>.unmodifiable(_local);
      _restoreOnlineCache();
      notifyListeners();
    } catch (error) {
      debugPrint('读取每日一句失败: $error');
    }
  }

  Quote get todayQuote {
    final cached = _onlineToday;
    if (cached != null && _isToday(_onlineDate)) return cached;
    if (_local.isEmpty) {
      return const Quote(
        text: '心有山海，静而无边。',
        author: '佚名',
        source: '',
      );
    }
    final dayOfYear = _dayOfYear(DateTime.now());
    return _local[dayOfYear % _local.length];
  }

  /// 在线更新（调用方需先确认用户已开启联网金句）。
  Future<bool> refreshOnline() async {
    if (_loading) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await http
          .get(Uri.parse('https://v1.jinrishici.com/all.json'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw StateError('HTTP ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) throw const FormatException('返回格式不正确');
      final text = decoded['content'];
      if (text is! String || text.trim().isEmpty) {
        throw const FormatException('没有返回诗句');
      }
      _onlineToday = Quote(
        text: text.trim(),
        author: (decoded['author'] as String? ?? '佚名').trim(),
        source: (decoded['origin'] as String? ?? '').trim(),
        online: true,
      );
      _onlineDate = DateTime.now();
      await _prefs.setString(
        _cacheKey,
        jsonEncode(<String, dynamic>{
          'date': _dateKey(_onlineDate!),
          'quote': _onlineToday!.toJson(),
        }),
      );
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 用户开启联网金句时调用：当天已有缓存就不再请求。
  Future<void> refreshIfNeeded() async {
    if (_onlineToday != null && _isToday(_onlineDate)) return;
    await refreshOnline();
  }

  void _restoreOnlineCache() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final date = decoded['date'];
      if (date is! String || date != _dateKey(DateTime.now())) return;
      final quote = Quote.tryFromJson(decoded['quote']);
      if (quote == null) return;
      _onlineToday = Quote(
        text: quote.text,
        author: quote.author,
        source: quote.source,
        dynasty: quote.dynasty,
        online: true,
      );
      _onlineDate = DateTime.now();
    } catch (_) {
      // 缓存损坏时忽略，继续使用内置数据。
    }
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static int _dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year)).inDays + 1;
  }
}
