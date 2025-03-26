import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeatmapChart extends StatelessWidget {
  final Map<DateTime, double> data;
  final double cellSize;
  final int weeksToShow;

  const HeatmapChart({
    Key? key,
    required this.data,
    this.cellSize = 14.0,
    this.weeksToShow = 52,
  }) : super(key: key);

  Color _getColorForValue(double value) {
    if (value > 2) return Colors.green.withOpacity(0.8);
    if (value > 1) return Colors.green.withOpacity(0.6);
    if (value > 0) return Colors.green.withOpacity(0.4);
    if (value == 0) return Colors.grey.withOpacity(0.2);
    if (value > -1) return Colors.red.withOpacity(0.4);
    if (value > -2) return Colors.red.withOpacity(0.6);
    return Colors.red.withOpacity(0.8);
  }

  List<Widget> _buildWeekLabels() {
    return ['Mon', 'Wed', 'Fri'].map((day) {
      return SizedBox(
        height: cellSize,
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildMonthLabels(DateTime startDate) {
    final months = <Widget>[];
    var currentDate = startDate;
    var currentMonth = '';
    var weekCounter = 0;

    while (weekCounter < weeksToShow) {
      final month = DateFormat('MMM').format(currentDate);
      if (month != currentMonth) {
        months.add(
          Positioned(
            left: weekCounter * cellSize,
            child: Text(
              month,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ),
        );
        currentMonth = month;
      }
      currentDate = currentDate.add(const Duration(days: 7));
      weekCounter++;
    }

    return months;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: weeksToShow * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 32, bottom: 8),
          child: Text(
            'Returns Heatmap',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
                child: Stack(
                  children: _buildMonthLabels(startDate),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _buildWeekLabels(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SizedBox(
                      height: 7 * cellSize,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: weeksToShow,
                        itemBuilder: (context, weekIndex) {
                          return Column(
                            children: List.generate(7, (dayIndex) {
                              final date = startDate.add(
                                Duration(days: weekIndex * 7 + dayIndex),
                              );
                              final value = data[date] ?? 0;

                              return Container(
                                width: cellSize - 2,
                                height: cellSize - 2,
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: _getColorForValue(value),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Tooltip(
                                  message: '${DateFormat('MMM d, y').format(date)}\n${value.toStringAsFixed(2)}%',
                                  textStyle: const TextStyle(color: Colors.white),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildLegendItem('Negative', Colors.red),
                  _buildLegendItem('Neutral', Colors.grey),
                  _buildLegendItem('Positive', Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
} 