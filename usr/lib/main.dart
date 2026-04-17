import 'package:flutter/material.dart';
import 'stock_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Price Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const StockScreen(ticker: 'AAPL'),
    );
  }
}

class StockScreen extends StatefulWidget {
  final String ticker;
  const StockScreen({super.key, required this.ticker});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  late Stream<Map<String, dynamic>> _stockStream;

  @override
  void initState() {
    super.initState();
    // Initialize the polling stream
    _stockStream = StockService.useStockPrice(widget.ticker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ticker} Stock Price'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: _stockStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              );
            }

            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final data = snapshot.data!;
            // Finnhub returns 'c' for current price
            final currentPrice = data['c'];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.ticker,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (currentPrice != null && currentPrice != 0)
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                  )
                else
                  const Text('Price data unavailable (Check API key)'),
                const SizedBox(height: 8),
                const Text(
                  'Updates every 10 seconds',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
