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
      body: const _Bod(),
    );
  }
}

final _calcVals = <String, TextBox>{};

// inspired from https://stackoverflow.com/a/52991124/12555423
TextBox _calcLastLineEnd({
  required BuildContext context,
  required TextSpan targetText,
}) {
  if (_calcVals.containsKey(targetText.toPlainText())) {
    return _calcVals[targetText.toPlainText()]!;
  }

  final richTextWidget = Text.rich(targetText).build(context) as RichText;
  final renderObject = richTextWidget.createRenderObject(context);
  renderObject.layout(
    const BoxConstraints(),
  );
  final lastBox = renderObject
      .getBoxesForSelection(
        TextSelection(
          baseOffset: 0,
          extentOffset: targetText.toPlainText().length,
        ),
      )
      .last;

  _calcVals[targetText.toPlainText()] = lastBox;

  return lastBox;
}

bool _textWillRenderOnNewLine({
  required BuildContext context,
  required TextSpan targetText,
  required double maxWidth,
}) {
  final textRequiredSize = _calcLastLineEnd(
    context: context,
    targetText: targetText,
  );

  final textRequiredWidth = textRequiredSize.end;

  final willRenderOnNewLine = textRequiredWidth > maxWidth;

  return willRenderOnNewLine;
}

class _Bod extends StatefulWidget {
  const _Bod();

  @override
  State<_Bod> createState() => _BodState();
}

class _BodState extends State<_Bod> {
  double value = 0.5;

  void _onChanged(double newValue) {
    setState(() {
      value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: BalanceSliderWidget(
            leftText: 'COFFEE',
            rightText: 'MILK',
            leftColor: const Color.fromARGB(255, 78, 33, 5),
            rightColor: const Color.fromARGB(255, 152, 152, 152),
            value: value,
            onChanged: _onChanged,
          ),
        ),
      ],
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

class BalanceSliderWidget extends StatefulWidget {
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

  @override
  State<BalanceSliderWidget> createState() => _BalanceSliderWidgetState();
}

class _BalanceSliderWidgetState extends State<BalanceSliderWidget> {
  double get leftValue => widget.value;
  double get rightValue => 1 - widget.value;

  double get leftPercentage => (leftValue * 100);
  double get rightPercentage => (rightValue * 100);
  String get leftPercentageStr => leftPercentage.toStringAsFixed(0);
  String get rightPercentageStr => rightPercentage.toStringAsFixed(0);

  static const totalSize = 500.0;
  static const seperatorSize = 20.0;

  double get lSize => (totalSize - seperatorSize) * leftValue;
  double get rSize => (totalSize - seperatorSize) * rightValue;

  static const fontSize = 16.0;

  static const double textSidePadding = 20.0;

  TextSpan get rSpan => TextSpan(
        text: '${widget.rightText} %$rightPercentageStr',
        style: TextStyle(
          fontSize: fontSize,
          color: widget.rightColor.increaseBrightness(0.5),
        ),
      );

  TextSpan get lSpan => TextSpan(
        text: '${widget.leftText} %$leftPercentageStr',
        style: TextStyle(
          fontSize: fontSize,
          color: widget.leftColor.increaseBrightness(0.5),
        ),
      );

  bool get anyNeedsNewLine =>
      _textWillRenderOnNewLine(
        context: context,
        targetText: rSpan,
        maxWidth: rSize - textSidePadding * 2,
      ) ||
      _textWillRenderOnNewLine(
        context: context,
        targetText: lSpan,
        maxWidth: lSize - textSidePadding * 2,
      );

  @override
  Widget build(BuildContext context) {
    Widget txtPiece({
      required TextSpan span,
      required Color color,
      required double size,
    }) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxh = constraints.maxHeight;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: anyNeedsNewLine ? maxh - maxh / 3 : maxh,
                child: Center(
                  child: Text.rich(span),
                ),
              ),
            ],
          );
        },
      );
    }

    Widget bgPiece({
      required TextSpan span,
      required Color color,
      required double percentage,
      required double size,
    }) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxh = constraints.maxHeight;
          return SizedBox(
            width: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: anyNeedsNewLine ? maxh / 3 : maxh,
                  width: double.infinity,
                  child: SizedBox(
                    width: size,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.increaseBrightness(percentage / 100 / 6),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return SizedBox(
      height: 60,
      width: totalSize,
      child: Stack(
        children: [
          Row(
            children: [
              bgPiece(
                span: lSpan,
                color: widget.leftColor,
                percentage: leftPercentage,
                size: lSize,
              ),
              _seperator(),
              bgPiece(
                span: rSpan,
                color: widget.rightColor,
                percentage: rightPercentage,
                size: rSize,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: textSidePadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                txtPiece(
                  span: lSpan,
                  color: widget.leftColor,
                  size: lSize,
                ),
                txtPiece(
                  span: rSpan,
                  color: widget.rightColor,
                  size: rSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seperatorBod() {
    return Container(
      width: seperatorSize,
      padding: const EdgeInsets.symmetric(
        horizontal: 7.5,
        // vertical: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          color: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _seperator() {
    return GestureDetector(
      key: const ValueKey('seperator'),
      onPanUpdate: (details) {
        final dx = details.delta.dx;
        final newValue = widget.value + dx / totalSize;

        // debugPrint('dx: $dx, newValue: $newValue');

        if (newValue >= 0 && newValue <= 1) {
          widget.onChanged(newValue);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: Column(
          children: [
            Expanded(
              flex: anyNeedsNewLine ? 10 : 1,
              child: const SizedBox(),
            ),
            Expanded(
              flex: 6,
              child: _seperatorBod(),
            ),
            Expanded(
              flex: anyNeedsNewLine ? 0 : 1,
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
