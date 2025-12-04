import 'dart:math';
import 'package:flutter/foundation.dart';

class QuoteService extends ChangeNotifier {
  static final QuoteService instance = QuoteService._internal();
  factory QuoteService() => instance;
  QuoteService._internal();

  static const List<Map<String, String>> _quotes = [
    {
      'text': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain',
    },
    {
      'text': 'Don\'t watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson',
    },
    {
      'text': 'The future depends on what you do today.',
      'author': 'Mahatma Gandhi',
    },
    {
      'text':
          'You don\'t have to be great to start, but you have to start to be great.',
      'author': 'Zig Ziglar',
    },
    {
      'text':
          'Success is the sum of small efforts repeated day in and day out.',
      'author': 'Robert Collier',
    },
    {
      'text': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'text': 'Believe you can and you\'re halfway there.',
      'author': 'Theodore Roosevelt',
    },
    {
      'text': 'Your limitation—it\'s only your imagination.',
      'author': 'Unknown',
    },
    {
      'text': 'Push yourself, because no one else is going to do it for you.',
      'author': 'Unknown',
    },
    {
      'text': 'Great things never come from comfort zones.',
      'author': 'Unknown',
    },
    {'text': 'Dream it. Wish it. Do it.', 'author': 'Unknown'},
    {
      'text': 'Success doesn\'t just find you. You have to go out and get it.',
      'author': 'Unknown',
    },
    {
      'text':
          'The harder you work for something, the greater you\'ll feel when you achieve it.',
      'author': 'Unknown',
    },
    {'text': 'Dream bigger. Do bigger.', 'author': 'Unknown'},
    {
      'text': 'Don\'t stop when you\'re tired. Stop when you\'re done.',
      'author': 'Unknown',
    },
    {
      'text': 'Wake up with determination. Go to bed with satisfaction.',
      'author': 'Unknown',
    },
    {
      'text': 'Do something today that your future self will thank you for.',
      'author': 'Unknown',
    },
    {'text': 'Little things make big days.', 'author': 'Unknown'},
    {
      'text': 'It\'s going to be hard, but hard does not mean impossible.',
      'author': 'Unknown',
    },
    {'text': 'Don\'t wait for opportunity. Create it.', 'author': 'Unknown'},
    {
      'text':
          'Sometimes we\'re tested not to show our weaknesses, but to discover our strengths.',
      'author': 'Unknown',
    },
    {
      'text': 'The key to success is to focus on goals, not obstacles.',
      'author': 'Unknown',
    },
    {
      'text': 'Action is the foundational key to all success.',
      'author': 'Pablo Picasso',
    },
    {
      'text': 'The way to get started is to quit talking and begin doing.',
      'author': 'Walt Disney',
    },
    {
      'text':
          'The pessimist sees difficulty in every opportunity. The optimist sees opportunity in every difficulty.',
      'author': 'Winston Churchill',
    },
    {
      'text': 'Don\'t let yesterday take up too much of today.',
      'author': 'Will Rogers',
    },
    {
      'text':
          'You learn more from failure than from success. Don\'t let it stop you.',
      'author': 'Unknown',
    },
    {
      'text':
          'It\'s not whether you get knocked down, it\'s whether you get up.',
      'author': 'Vince Lombardi',
    },
    {
      'text':
          'If you are working on something that you really care about, you don\'t have to be pushed.',
      'author': 'Steve Jobs',
    },
    {
      'text':
          'People who are crazy enough to think they can change the world, are the ones who do.',
      'author': 'Rob Siltanen',
    },
    {
      'text':
          'Failure will never overtake me if my determination to succeed is strong enough.',
      'author': 'Og Mandino',
    },
    {
      'text': 'We may encounter many defeats but we must not be defeated.',
      'author': 'Maya Angelou',
    },
    {
      'text':
          'Knowing is not enough; we must apply. Wishing is not enough; we must do.',
      'author': 'Johann Wolfgang Von Goethe',
    },
    {
      'text':
          'Imagine your life is perfect in every respect; what would it look like?',
      'author': 'Brian Tracy',
    },
    {
      'text': 'We generate fears while we sit. We overcome them by action.',
      'author': 'Dr. Henry Link',
    },
    {
      'text': 'What you do today can improve all your tomorrows.',
      'author': 'Ralph Marston',
    },
    {
      'text': 'The only impossible journey is the one you never begin.',
      'author': 'Tony Robbins',
    },
    {
      'text':
          'Good things come to people who wait, but better things come to those who go out and get them.',
      'author': 'Unknown',
    },
    {
      'text':
          'You are never too old to set another goal or to dream a new dream.',
      'author': 'C.S. Lewis',
    },
    {
      'text':
          'Try not to become a person of success, but rather try to become a person of value.',
      'author': 'Albert Einstein',
    },
  ];

  final Random _random = Random();
  Map<String, String>? _currentQuote;
  DateTime? _lastQuoteDate;

  Map<String, String> get currentQuote {
    _ensureDailyQuote();
    return _currentQuote!;
  }

  String get quoteText => currentQuote['text']!;
  String get quoteAuthor => currentQuote['author']!;

  void _ensureDailyQuote() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate new quote if it's a new day or first time
    if (_lastQuoteDate == null || _lastQuoteDate!.isBefore(today)) {
      _currentQuote = _quotes[_random.nextInt(_quotes.length)];
      _lastQuoteDate = today;
      notifyListeners();
    }
  }

  // Get a random quote (not necessarily daily)
  Map<String, String> getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)];
  }

  // Refresh with a new random quote
  void refreshQuote() {
    _currentQuote = _quotes[_random.nextInt(_quotes.length)];
    _lastQuoteDate = DateTime.now();
    notifyListeners();
  }
}
