import 'dart:convert';
import 'package:flutter/material.dart';

class MutualFund {
  final String id;
  final String name;
  final String category;
  final double currentNav;
  final double previousNav;
  final double oneYearReturn;
  final double threeYearReturn;
  final double fiveYearReturn;
  final Map<DateTime, double> dailyReturns;
  final String riskLevel;
  final double expenseRatio;
  final double aum;
  final String fundManager;
  final DateTime launchDate;
  final String benchmark;
  final bool isBookmarked;
  final List<double> navValues;
  final List<double> benchmarkValues;
  final List<DateTime> dates;

  MutualFund({
    required this.id,
    required this.name,
    required this.category,
    required this.currentNav,
    required this.previousNav,
    required this.oneYearReturn,
    required this.threeYearReturn,
    required this.fiveYearReturn,
    required this.dailyReturns,
    required this.riskLevel,
    required this.expenseRatio,
    required this.aum,
    required this.fundManager,
    required this.launchDate,
    required this.benchmark,
    this.isBookmarked = false,
    this.navValues = const [],
    this.benchmarkValues = const [],
    this.dates = const [],
  });

  double get navChange => currentNav - previousNav;
  double get navChangePercentage => (navChange / previousNav) * 100;
  Color get returnColor => navChangePercentage >= 0 ? Colors.green : Colors.red;

  MutualFund copyWith({
    String? id,
    String? name,
    String? category,
    double? currentNav,
    double? previousNav,
    double? oneYearReturn,
    double? threeYearReturn,
    double? fiveYearReturn,
    Map<DateTime, double>? dailyReturns,
    String? riskLevel,
    double? expenseRatio,
    double? aum,
    String? fundManager,
    DateTime? launchDate,
    String? benchmark,
    bool? isBookmarked,
    List<double>? navValues,
    List<double>? benchmarkValues,
    List<DateTime>? dates,
  }) {
    return MutualFund(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentNav: currentNav ?? this.currentNav,
      previousNav: previousNav ?? this.previousNav,
      oneYearReturn: oneYearReturn ?? this.oneYearReturn,
      threeYearReturn: threeYearReturn ?? this.threeYearReturn,
      fiveYearReturn: fiveYearReturn ?? this.fiveYearReturn,
      dailyReturns: dailyReturns ?? this.dailyReturns,
      riskLevel: riskLevel ?? this.riskLevel,
      expenseRatio: expenseRatio ?? this.expenseRatio,
      aum: aum ?? this.aum,
      fundManager: fundManager ?? this.fundManager,
      launchDate: launchDate ?? this.launchDate,
      benchmark: benchmark ?? this.benchmark,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      navValues: navValues ?? this.navValues,
      benchmarkValues: benchmarkValues ?? this.benchmarkValues,
      dates: dates ?? this.dates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'currentNav': currentNav,
      'previousNav': previousNav,
      'oneYearReturn': oneYearReturn,
      'threeYearReturn': threeYearReturn,
      'fiveYearReturn': fiveYearReturn,
      'dailyReturns': dailyReturns.map((key, value) => MapEntry(key.toIso8601String(), value)),
      'riskLevel': riskLevel,
      'expenseRatio': expenseRatio,
      'aum': aum,
      'fundManager': fundManager,
      'launchDate': launchDate.toIso8601String(),
      'benchmark': benchmark,
      'isBookmarked': isBookmarked,
      'navValues': navValues,
      'benchmarkValues': benchmarkValues,
      'dates': dates.map((e) => e.toIso8601String()),
    };
  }

  factory MutualFund.fromJson(Map<String, dynamic> json) {
    return MutualFund(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      currentNav: json['currentNav'] as double,
      previousNav: json['previousNav'] as double,
      oneYearReturn: json['oneYearReturn'] as double,
      threeYearReturn: json['threeYearReturn'] as double,
      fiveYearReturn: json['fiveYearReturn'] as double,
      dailyReturns: (json['dailyReturns'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(DateTime.parse(key), value as double),
      ),
      riskLevel: json['riskLevel'] as String,
      expenseRatio: json['expenseRatio'] as double,
      aum: json['aum'] as double,
      fundManager: json['fundManager'] as String,
      launchDate: DateTime.parse(json['launchDate'] as String),
      benchmark: json['benchmark'] as String,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      navValues: json['navValues'] as List<double> ?? const [],
      benchmarkValues: json['benchmarkValues'] as List<double> ?? const [],
      dates: (json['dates'] as List<dynamic>).map((e) => DateTime.parse(e as String)).toList(),
    );
  }
}

class NavPoint {
  final DateTime date;
  final double value;

  NavPoint({
    required this.date,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'value': value,
  };

  factory NavPoint.fromJson(Map<String, dynamic> json) => NavPoint(
    date: DateTime.parse(json['date']),
    value: json['value'].toDouble(),
  );
} 