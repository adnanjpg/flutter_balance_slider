import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Balance Slider',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Balance Slider'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: BalanceSliderWidget(
              leftText: 'COFFEE',
              rightText: 'MILK',
              leftColor: const Color.fromARGB(255, 78, 33, 5),
              rightColor: const Color(0xFFE6E6E6),
              value: 0.5,
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}

extension on Color {
  Color increaseBrightness(double amount) {
    final newRed = red + (255 - red) * amount;
    final newGreen = green + (255 - green) * amount;
    final newBlue = blue + (255 - blue) * amount;

    return Color.fromARGB(
      alpha,
      newRed.toInt(),
      newGreen.toInt(),
      newBlue.toInt(),
    );
  }
}

class BalanceSliderWidget extends StatelessWidget {
  final String leftText;
  final String rightText;

  final Color leftColor;
  final Color rightColor;

  final double value;
  final Function(double) onChanged;

  const BalanceSliderWidget({
    super.key,
    required this.leftText,
    required this.rightText,
    required this.value,
    required this.onChanged,
    required this.leftColor,
    required this.rightColor,
  });

  double get leftValue => value;
  double get rightValue => 1 - value;

  String get leftPercentage => (leftValue * 100).toStringAsFixed(0);
  String get rightPercentage => (rightValue * 100).toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    const totalSize = 500.0;
    const seperatorSize = 20.0;
    final leftSize = (totalSize - seperatorSize) * leftValue;
    final rightSize = (totalSize - seperatorSize) * rightValue;

    Widget txtPiece({
      required String text,
      required Color color,
      required String percentage,
      required double size,
    }) {
      return Column(
        children: [
          Expanded(
            child: SizedBox(
              width: size,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$text %$percentage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: color.increaseBrightness(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 60,
      width: totalSize,
      child: Row(
        children: [
          txtPiece(
            text: leftText,
            color: leftColor,
            percentage: leftPercentage,
            size: leftSize,
          ),
          Container(
            width: seperatorSize,
            padding: const EdgeInsets.symmetric(
              horizontal: 7.5,
              vertical: 10,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                color: Colors.grey[100],
              ),
            ),
          ),
          txtPiece(
            text: rightText,
            color: rightColor,
            percentage: rightPercentage,
            size: rightSize,
          ),
        ],
      ),
    );
  }
}
