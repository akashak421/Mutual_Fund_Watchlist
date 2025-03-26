import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/watchlist.dart';

class WatchlistService {
  static const String _watchlistsKey = 'watchlists';
  final SharedPreferences _prefs;

  WatchlistService(this._prefs);

  // Get all watchlists
  List<Watchlist> getWatchlists() {
    final String? watchlistsJson = _prefs.getString(_watchlistsKey);
    if (watchlistsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(watchlistsJson);
    return decoded.map((json) => Watchlist.fromJson(json)).toList();
  }

  // Save all watchlists
  Future<bool> saveWatchlists(List<Watchlist> watchlists) async {
    final String encoded = jsonEncode(watchlists.map((w) => w.toJson()).toList());
    return await _prefs.setString(_watchlistsKey, encoded);
  }

  // Create a new watchlist
  Future<bool> createWatchlist(String name) async {
    final watchlists = getWatchlists();
    final newWatchlist = Watchlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      fundIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    watchlists.add(newWatchlist);
    return await saveWatchlists(watchlists);
  }

  // Add a fund to a watchlist
  Future<bool> addFundToWatchlist(String watchlistId, String fundId) async {
    final watchlists = getWatchlists();
    final index = watchlists.indexWhere((w) => w.id == watchlistId);
    if (index == -1) return false;

    final watchlist = watchlists[index];
    if (watchlist.fundIds.contains(fundId)) return true;

    final updatedWatchlist = watchlist.copyWith(
      fundIds: [...watchlist.fundIds, fundId],
      updatedAt: DateTime.now(),
    );
    
    watchlists[index] = updatedWatchlist;
    return await saveWatchlists(watchlists);
  }

  // Remove a fund from a watchlist
  Future<bool> removeFundFromWatchlist(String watchlistId, String fundId) async {
    final watchlists = getWatchlists();
    final index = watchlists.indexWhere((w) => w.id == watchlistId);
    if (index == -1) return false;

    final watchlist = watchlists[index];
    final updatedWatchlist = watchlist.copyWith(
      fundIds: watchlist.fundIds.where((id) => id != fundId).toList(),
      updatedAt: DateTime.now(),
    );
    
    watchlists[index] = updatedWatchlist;
    return await saveWatchlists(watchlists);
  }

  // Delete a watchlist
  Future<bool> deleteWatchlist(String watchlistId) async {
    final watchlists = getWatchlists();
    watchlists.removeWhere((w) => w.id == watchlistId);
    return await saveWatchlists(watchlists);
  }

  // Update watchlist name
  Future<bool> updateWatchlistName(String watchlistId, String newName) async {
    final watchlists = getWatchlists();
    final index = watchlists.indexWhere((w) => w.id == watchlistId);
    if (index == -1) return false;

    final watchlist = watchlists[index];
    final updatedWatchlist = watchlist.copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
    
    watchlists[index] = updatedWatchlist;
    return await saveWatchlists(watchlists);
  }

  // Check if a fund exists in any watchlist
  bool isFundInAnyWatchlist(String fundId) {
    final watchlists = getWatchlists();
    return watchlists.any((w) => w.fundIds.contains(fundId));
  }

  // Get watchlists containing a specific fund
  List<Watchlist> getWatchlistsContainingFund(String fundId) {
    final watchlists = getWatchlists();
    return watchlists.where((w) => w.fundIds.contains(fundId)).toList();
  }
} 