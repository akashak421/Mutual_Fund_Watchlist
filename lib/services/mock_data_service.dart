import 'dart:math';
import 'package:mutual_fund_watchlist/models/mutual_fund.dart';

class MockDataService {
  static final Random _random = Random();
  
  static Map<DateTime, double> _generateDailyReturns() {
    final Map<DateTime, double> returns = {};
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 365));

    for (var date = startDate; date.isBefore(now); date = date.add(const Duration(days: 1))) {
      // Generate random returns between -3% and 3%
      final return_ = (_random.nextDouble() * 6) - 3;
      returns[date] = double.parse(return_.toStringAsFixed(2));
    }

    return returns;
  }

  static List<MutualFund> getMockMutualFunds() {
    return [
      MutualFund(
        id: '1',
        name: 'HDFC Mid-Cap Opportunities Fund',
        category: 'Mid Cap',
        currentNav: 100.25,
        previousNav: 99.75,
        oneYearReturn: 15.8,
        threeYearReturn: 22.4,
        fiveYearReturn: 18.6,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'High',
        expenseRatio: 1.85,
        aum: 28750,
        fundManager: 'Chirag Setalvad',
        launchDate: DateTime(2007, 6, 25),
        benchmark: 'NIFTY Midcap 100 TRI',
        navValues: _generateNavValues(100.25),
        benchmarkValues: _generateBenchmarkValues(100.25),
        dates: _generateDates(),
      ),
      MutualFund(
        id: '2',
        name: 'Axis Bluechip Fund',
        category: 'Large Cap',
        currentNav: 45.80,
        previousNav: 45.60,
        oneYearReturn: 12.5,
        threeYearReturn: 18.2,
        fiveYearReturn: 15.4,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'Moderate',
        expenseRatio: 1.65,
        aum: 32450,
        fundManager: 'Shreyash Devalkar',
        launchDate: DateTime(2009, 1, 5),
        benchmark: 'NIFTY 50 TRI',
        navValues: _generateNavValues(45.80),
        benchmarkValues: _generateBenchmarkValues(45.80),
        dates: _generateDates(),
      ),
      MutualFund(
        id: '3',
        name: 'SBI Small Cap Fund',
        category: 'Small Cap',
        currentNav: 85.40,
        previousNav: 84.90,
        oneYearReturn: 18.9,
        threeYearReturn: 25.6,
        fiveYearReturn: 21.2,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'Very High',
        expenseRatio: 1.95,
        aum: 15680,
        fundManager: 'R. Srinivasan',
        launchDate: DateTime(2013, 9, 16),
        benchmark: 'NIFTY Smallcap 100 TRI',
        navValues: _generateNavValues(85.40),
        benchmarkValues: _generateBenchmarkValues(85.40),
        dates: _generateDates(),
      ),
      MutualFund(
        id: '4',
        name: 'Mirae Asset Emerging Bluechip Fund',
        category: 'Large & Mid Cap',
        currentNav: 92.15,
        previousNav: 91.80,
        oneYearReturn: 16.4,
        threeYearReturn: 21.8,
        fiveYearReturn: 19.5,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'Moderately High',
        expenseRatio: 1.75,
        aum: 24890,
        fundManager: 'Neelesh Surana',
        launchDate: DateTime(2010, 7, 9),
        benchmark: 'NIFTY Large Midcap 250 TRI',
        navValues: _generateNavValues(92.15),
        benchmarkValues: _generateBenchmarkValues(92.15),
        dates: _generateDates(),
      ),
      MutualFund(
        id: '5',
        name: 'Parag Parikh Flexi Cap Fund',
        category: 'Flexi Cap',
        currentNav: 52.30,
        previousNav: 52.10,
        oneYearReturn: 14.2,
        threeYearReturn: 20.1,
        fiveYearReturn: 17.8,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'Moderately High',
        expenseRatio: 1.55,
        aum: 18960,
        fundManager: 'Rajeev Thakkar',
        launchDate: DateTime(2013, 5, 24),
        benchmark: 'NIFTY 500 TRI',
        navValues: _generateNavValues(52.30),
        benchmarkValues: _generateBenchmarkValues(52.30),
        dates: _generateDates(),
      ),
    ];
  }

  static List<double> _generateNavValues(double currentNav) {
    final List<double> values = [];
    final random = Random();
    final numPoints = 365; // One year of daily data
    var value = currentNav;

    for (var i = 0; i < numPoints; i++) {
      // Generate random daily change between -2% and +2%
      final change = (random.nextDouble() * 4 - 2) / 100;
      value *= (1 + change);
      values.add(double.parse(value.toStringAsFixed(2)));
    }

    return values.reversed.toList(); // Reverse to get oldest to newest
  }

  static List<double> _generateBenchmarkValues(double currentNav) {
    final List<double> values = [];
    final random = Random();
    final numPoints = 365; // One year of daily data
    var value = currentNav * 0.95; // Start slightly lower than NAV

    for (var i = 0; i < numPoints; i++) {
      // Generate random daily change between -1.5% and +1.5%
      final change = (random.nextDouble() * 3 - 1.5) / 100;
      value *= (1 + change);
      values.add(double.parse(value.toStringAsFixed(2)));
    }

    return values.reversed.toList(); // Reverse to get oldest to newest
  }

  static List<DateTime> _generateDates() {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    
    for (var i = 364; i >= 0; i--) {
      dates.add(now.subtract(Duration(days: i)));
    }

    return dates;
  }

  // Helper method to get mock heat map data
  static Map<DateTime, double> getHeatMapData(String fundId) {
    final Map<DateTime, double> heatMapData = {};
    final now = DateTime.now();
    final random = Random();

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final value = -3.0 + random.nextDouble() * 6.0; // Returns between -3% and 3%
      heatMapData[date] = double.parse(value.toStringAsFixed(2));
    }

    return heatMapData;
  }

  static List<MutualFund> getMockFunds() {
    return [
      MutualFund(
        id: '1',
        name: 'HDFC Mid-Cap Opportunities Fund',
        category: 'Mid Cap',
        currentNav: 100.25,
        previousNav: 99.75,
        oneYearReturn: 15.8,
        threeYearReturn: 22.4,
        fiveYearReturn: 18.6,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'High',
        expenseRatio: 1.85,
        aum: 28750,
        fundManager: 'Chirag Setalvad',
        launchDate: DateTime(2007, 6, 25),
        benchmark: 'NIFTY Midcap 100 TRI',
      ),
      MutualFund(
        id: '2',
        name: 'Axis Bluechip Fund',
        category: 'Large Cap',
        currentNav: 45.80,
        previousNav: 45.60,
        oneYearReturn: 12.5,
        threeYearReturn: 18.2,
        fiveYearReturn: 15.4,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'Moderate',
        expenseRatio: 1.65,
        aum: 32450,
        fundManager: 'Shreyash Devalkar',
        launchDate: DateTime(2009, 1, 5),
        benchmark: 'NIFTY 50 TRI',
      ),
      MutualFund(
        id: '3',
        name: 'SBI Small Cap Fund',
        category: 'Small Cap',
        currentNav: 85.40,
        previousNav: 84.90,
        oneYearReturn: 18.9,
        threeYearReturn: 25.6,
        fiveYearReturn: 21.2,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'Very High',
        expenseRatio: 1.95,
        aum: 15680,
        fundManager: 'R. Srinivasan',
        launchDate: DateTime(2013, 9, 16),
        benchmark: 'NIFTY Smallcap 100 TRI',
      ),
      MutualFund(
        id: '4',
        name: 'Mirae Asset Emerging Bluechip Fund',
        category: 'Large & Mid Cap',
        currentNav: 92.15,
        previousNav: 91.80,
        oneYearReturn: 16.4,
        threeYearReturn: 21.8,
        fiveYearReturn: 19.5,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'Moderately High',
        expenseRatio: 1.75,
        aum: 24890,
        fundManager: 'Neelesh Surana',
        launchDate: DateTime(2010, 7, 9),
        benchmark: 'NIFTY Large Midcap 250 TRI',
      ),
      MutualFund(
        id: '5',
        name: 'Parag Parikh Flexi Cap Fund',
        category: 'Flexi Cap',
        currentNav: 52.30,
        previousNav: 52.10,
        oneYearReturn: 14.2,
        threeYearReturn: 20.1,
        fiveYearReturn: 17.8,
        dailyReturns: _generateDailyReturns(),
        riskLevel: 'Moderately High',
        expenseRatio: 1.55,
        aum: 18960,
        fundManager: 'Rajeev Thakkar',
        launchDate: DateTime(2013, 5, 24),
        benchmark: 'NIFTY 500 TRI',
      ),
    ];
  }
} 