import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mutual_fund.dart';
import '../models/watchlist.dart';
import '../services/mock_data_service.dart';
import '../services/watchlist_service.dart';

class WatchlistProvider with ChangeNotifier {
  late WatchlistService _watchlistService;
  List<MutualFund> _allFunds = [];
  List<MutualFund> _filteredFunds = [];
  List<Watchlist> _watchlists = [];
  String _searchQuery = '';

  List<MutualFund> get allFunds => _allFunds;
  List<MutualFund> get filteredFunds => _filteredFunds;
  List<Watchlist> get watchlists => _watchlists;
  String get searchQuery => _searchQuery;

  WatchlistProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    final prefs = await SharedPreferences.getInstance();
    _watchlistService = WatchlistService(prefs);
    _allFunds = MockDataService.getMockMutualFunds();
    _filteredFunds = _allFunds;
    await loadWatchlists();
  }

  Future<void> loadWatchlists() async {
    _watchlists = _watchlistService.getWatchlists();
    notifyListeners();
  }

  Future<void> createWatchlist(String name) async {
    await _watchlistService.createWatchlist(name);
    await loadWatchlists();
  }

  Future<void> updateWatchlistName(String watchlistId, String newName) async {
    await _watchlistService.updateWatchlistName(watchlistId, newName);
    await loadWatchlists();
  }

  Future<void> deleteWatchlist(String watchlistId) async {
    await _watchlistService.deleteWatchlist(watchlistId);
    await loadWatchlists();
  }

  Future<void> addFundToWatchlist(String watchlistId, String fundId) async {
    await _watchlistService.addFundToWatchlist(watchlistId, fundId);
    await loadWatchlists();
  }

  Future<void> removeFundFromWatchlist(String watchlistId, String fundId) async {
    await _watchlistService.removeFundFromWatchlist(watchlistId, fundId);
    await loadWatchlists();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredFunds = _allFunds;
    } else {
      _filteredFunds = _allFunds.where((fund) {
        return fund.name.toLowerCase().contains(query.toLowerCase()) ||
               fund.category.toLowerCase().contains(query.toLowerCase()) ||
               fund.fundManager.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  List<MutualFund> getWatchlistFunds(String watchlistId) {
    final watchlist = _watchlists.firstWhere((w) => w.id == watchlistId);
    return _allFunds.where((fund) => watchlist.fundIds.contains(fund.id)).toList();
  }

  bool isFundInWatchlist(String watchlistId, String fundId) {
    final watchlist = _watchlists.firstWhere((w) => w.id == watchlistId);
    return watchlist.fundIds.contains(fundId);
  }
} 