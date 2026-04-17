import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  // Use --dart-define=NEXT_PUBLIC_STOCK_API_KEY=your_key when running the app
  static const String _apiKey = String.fromEnvironment(
    'NEXT_PUBLIC_STOCK_API_KEY',
    defaultValue: '',
  );

  static Future<Map<String, dynamic>> fetchStockPrice(String ticker) async {
    final uri = Uri.parse(
        'https://finnhub.io/api/v1/quote?symbol=$ticker&token=$_apiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load stock price');
    }
  }

  /// Replicates the useQuery behavior with refetchInterval: 10000
  static Stream<Map<String, dynamic>> useStockPrice(String ticker) async* {
    // Yield the initial fetch immediately
    yield await fetchStockPrice(ticker);

    // Yield periodic updates every 10 seconds
    yield* Stream.periodic(const Duration(seconds: 10), (_) async {
      return await fetchStockPrice(ticker);
    }).asyncMap((event) => event);
  }
}
