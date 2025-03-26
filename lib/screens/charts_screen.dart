import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as Math;
import 'package:mutual_fund_watchlist/models/mutual_fund.dart';
import 'package:mutual_fund_watchlist/widgets/heatmap_chart.dart';

class ChartsScreen extends StatefulWidget {
  final MutualFund fund;

  const ChartsScreen({Key? key, required this.fund}) : super(key: key);

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> with SingleTickerProviderStateMixin {
  String _selectedTimeframe = '1Y';
  late AnimationController _controller;
  late Animation<double> _chartAnimation;
  double? _hoverX;
  double? _hoverY;
  double _investmentAmount = 1.0; // in lakhs
  bool _isSIP = false;
  final TextEditingController _investmentController = TextEditingController(text: '1.0');
  List<double> _filteredNavValues = [];
  List<double> _filteredBenchmarkValues = [];
  List<DateTime> _filteredDates = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
    _controller.forward();
    
    // Print initial fund data
    print('Fund Name: ${widget.fund.name}');
    print('Current NAV: ${widget.fund.currentNav}');
    print('Total NAV Values: ${widget.fund.navValues.length}');
    print('Total Benchmark Values: ${widget.fund.benchmarkValues.length}');
    print('Total Dates: ${widget.fund.dates.length}');
    print('First Date: ${widget.fund.dates.first}');
    print('Last Date: ${widget.fund.dates.last}');
    print('First NAV: ${widget.fund.navValues.first}');
    print('Last NAV: ${widget.fund.navValues.last}');
    print('First Benchmark: ${widget.fund.benchmarkValues.first}');
    print('Last Benchmark: ${widget.fund.benchmarkValues.last}');
    
    _updateFilteredData();
  }

  void _updateFilteredData() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedTimeframe) {
      case '1M':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '3M':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case '6M':
        startDate = now.subtract(const Duration(days: 180));
        break;
      case '1Y':
        startDate = now.subtract(const Duration(days: 365));
        break;
      case '3Y':
        startDate = now.subtract(const Duration(days: 1095));
        break;
      default: // MAX
        startDate = widget.fund.launchDate;
        break;
    }

    final indices = widget.fund.dates.asMap().entries
        .where((entry) => entry.value.isAfter(startDate))
        .map((entry) => entry.key)
        .toList();

    setState(() {
      _filteredNavValues = indices.map((i) => widget.fund.navValues[i]).toList();
      _filteredBenchmarkValues = indices.map((i) => widget.fund.benchmarkValues[i]).toList();
      _filteredDates = indices.map((i) => widget.fund.dates[i]).toList();
    });
  }

  @override
  void didUpdateWidget(ChartsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fund != widget.fund) {
      _updateFilteredData();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _investmentController.dispose();
    super.dispose();
  }

  void _updateInvestmentAmount(String value) {
    double? amount = double.tryParse(value);
    if (amount != null && amount >= 1 && amount <= 10) {
      setState(() {
        _investmentAmount = amount;
        if (_investmentController.text != value) {
          _investmentController.text = value;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildValueBoxes(),
              const SizedBox(height: 24),
              _buildTimeframeSelector(),
              const SizedBox(height: 24),
              _buildLineChart(),
              const SizedBox(height: 32),
              _buildInvestmentComparison(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fund.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${widget.fund.currentNav}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      widget.fund.navChangePercentage >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: widget.fund.returnColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.fund.navChangePercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: widget.fund.returnColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              widget.fund.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Implement bookmark functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValueBoxes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildValueBox('Invested', '₹50,000', Colors.blue),
          const SizedBox(width: 12),
          _buildValueBox('Current Value', '₹65,000', Colors.green),
          const SizedBox(width: 12),
          _buildValueBox('Total Gain', '+30%', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildValueBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['1M', '3M', '6M', '1Y', '3Y', 'MAX'].map((timeframe) {
          final isSelected = timeframe == _selectedTimeframe;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeframe = timeframe;
                _updateFilteredData();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                timeframe,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: ChartPainter(
          progress: _chartAnimation.value,
          hoverX: _hoverX,
          hoverY: _hoverY,
          navValues: _filteredNavValues,
          benchmarkValues: _filteredBenchmarkValues,
          dates: _filteredDates,
        ),
      ),
    );
  }

  Widget _buildInvestmentComparison() {
    const maxHeight = 140.0;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'If you invested ₹',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[700]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _investmentController,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        border: InputBorder.none,
                      ),
                      onChanged: _updateInvestmentAmount,
                    ),
                  ),
                  const Text(
                    'L',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoSlidingSegmentedControl<bool>(
                  backgroundColor: Colors.grey[800]!,
                  thumbColor: Colors.blue,
                  groupValue: _isSIP,
                  children: {
                    false: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: const Text(
                        '1-Time',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    true: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: const Text(
                        'Monthly SIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (value) {
                    setState(() {
                      _isSIP = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          const Text(
            "This Fund's past returns",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Text(
            'Profit % (Absolute Return)',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withOpacity(0.2),
              valueIndicatorColor: Colors.blue,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            child: Column(
              children: [
                Slider(
                  value: _investmentAmount,
                  min: 1.0,
                  max: 10.0,
                  divisions: 90,
                  label: '₹${_investmentAmount.toStringAsFixed(1)}L',
                  onChanged: (value) {
                    _updateInvestmentAmount(value.toStringAsFixed(1));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹1L',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '₹10L',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: maxHeight + 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildReturnBar(
                    label: 'Saving A/C',
                    value: 1.19 * _investmentAmount,
                    percentage: 19.0,
                    maxHeight: maxHeight,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReturnBar(
                    label: 'Category Avg',
                    value: 3.43 * _investmentAmount,
                    percentage: 243.0,
                    maxHeight: maxHeight,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReturnBar(
                    label: 'Direct Plan',
                    value: 4.55 * _investmentAmount,
                    percentage: 355.0,
                    maxHeight: maxHeight,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnBar({
    required String label,
    required double value,
    required double percentage,
    required double maxHeight,
    required Color color,
  }) {
    final barHeight = (percentage / 355.0) * maxHeight; // Normalize height based on max percentage

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '₹${value.toStringAsFixed(2)}L',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: maxHeight,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: barHeight,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement sell functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sell',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement invest more functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Invest More',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final double progress;
  final double? hoverX;
  final double? hoverY;
  final List<double> navValues;
  final List<double> benchmarkValues;
  final List<DateTime> dates;

  ChartPainter({
    required this.progress,
    this.hoverX,
    this.hoverY,
    required this.navValues,
    required this.benchmarkValues,
    required this.dates,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    _drawGridLines(canvas, size);

    // Draw the charts
    _drawChart(
      canvas, 
      size, 
      Colors.blue, 
      navValues,
      true
    );
    _drawChart(
      canvas, 
      size, 
      Colors.orange, 
      benchmarkValues,
      false
    );

    // Draw hover effects
    if (hoverX != null && hoverY != null) {
      _drawHoverEffects(canvas, size);
    }
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!.withOpacity(0.5)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (var i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical grid lines
    for (var i = 0; i <= 6; i++) {
      final x = size.width * (i / 6);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawChart(
    Canvas canvas, 
    Size size, 
    Color color, 
    List<double> values,
    bool isMainChart,
  ) {
    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    // Find min and max values for normalization
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;

    // Draw the chart
    path.moveTo(0, size.height);
    fillPath.moveTo(0, size.height);

    for (var i = 0; i < values.length; i++) {
      final x = (size.width * i / (values.length - 1)) * progress;
      final normalizedValue = (values[i] - minValue) / valueRange;
      final y = size.height * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete the fill path
    if (isMainChart) {
      fillPath.lineTo(size.width * progress, size.height);
      fillPath.close();
    }

    // Draw the gradient fill first
    if (isMainChart) {
      canvas.drawPath(fillPath, gradientPaint);
    }

    // Draw the line on top
    canvas.drawPath(path, linePaint);
  }

  void _drawHoverEffects(Canvas canvas, Size size) {
    if (navValues.isEmpty || benchmarkValues.isEmpty) return;

    // Vertical hover line
    final hoverLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(hoverX!, 0),
      Offset(hoverX!, size.height),
      hoverLinePaint,
    );

    // Find the closest data point
    final index = (hoverX! / size.width * (navValues.length - 1)).round();
    if (index >= 0 && index < navValues.length) {
      // Draw value boxes
      _drawValueBox(
        canvas,
        Offset(hoverX!, size.height * 0.2),
        '₹${navValues[index].toStringAsFixed(2)}',
        Colors.blue,
      );
      _drawValueBox(
        canvas,
        Offset(hoverX!, size.height * 0.8),
        '₹${benchmarkValues[index].toStringAsFixed(2)}',
        Colors.orange,
      );
    }
  }

  void _drawValueBox(Canvas canvas, Offset position, String value, Color color) {
    const boxWidth = 80.0;
    const boxHeight = 30.0;
    
    final rect = Rect.fromCenter(
      center: position,
      width: boxWidth,
      height: boxHeight,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(6),
    );

    // Draw box
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );

    // Draw border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hoverX != hoverX ||
        oldDelegate.hoverY != hoverY ||
        oldDelegate.navValues != navValues ||
        oldDelegate.benchmarkValues != benchmarkValues;
  }
}