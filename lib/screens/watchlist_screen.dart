import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mutual_fund.dart';
import '../models/watchlist.dart';
import '../providers/watchlist_provider.dart';
import '../screens/charts_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _watchlistNameController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTabController();
    });
  }

  void _initializeTabController() {
    if (_tabController != null) {
      _tabController!.dispose();
    }
    final watchlists = context.read<WatchlistProvider>().watchlists;
    _tabController = TabController(
      length: watchlists.isEmpty ? 1 : watchlists.length,
      vsync: this,
    );
    setState(() {});
  }

  @override
  void didUpdateWidget(WatchlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeTabController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    _watchlistNameController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showCreateWatchlistModal() {
    final provider = context.read<WatchlistProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: Builder(
            builder: (context) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create new watchlist',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Watchlist Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _watchlistNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter watchlist name',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_watchlistNameController.text.isNotEmpty) {
                            await context.read<WatchlistProvider>().createWatchlist(_watchlistNameController.text);
                            _watchlistNameController.clear();
                            _initializeTabController();
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAllWatchlistsModal() {
    final provider = context.read<WatchlistProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: Builder(
            builder: (context) => Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 24),
                        child: Text(
                          'All Watchlists',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...context.read<WatchlistProvider>().watchlists.map((watchlist) => ListTile(
                    title: Text(
                      watchlist.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () => _showEditWatchlistModal(watchlist),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () async {
                            await context.read<WatchlistProvider>().deleteWatchlist(watchlist.id);
                            _initializeTabController();
                            if (mounted) Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      final index = context.read<WatchlistProvider>().watchlists.indexOf(watchlist);
                      _tabController!.animateTo(index);
                      Navigator.pop(context);
                    },
                  )),
                  ListTile(
                    leading: const Icon(Icons.add_circle, color: Colors.blue),
                    title: const Text(
                      'Create a new watchlist',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateWatchlistModal();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditWatchlistModal(Watchlist watchlist) {
    _watchlistNameController.text = watchlist.name;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ChangeNotifierProvider.value(
          value: context.read<WatchlistProvider>(),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Watchlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _watchlistNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter watchlist name',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_watchlistNameController.text.isNotEmpty) {
                          await context.read<WatchlistProvider>().updateWatchlistName(
                            watchlist.id,
                            _watchlistNameController.text,
                          );
                          _watchlistNameController.clear();
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for Mutual Funds, AMC, Fund Managers..',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          context.read<WatchlistProvider>().updateSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildMutualFundCard(MutualFund fund) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, child) {
        final currentWatchlist = provider.watchlists.isNotEmpty ? provider.watchlists[_tabController!.index] : null;
        final isInWatchlist = currentWatchlist != null && provider.isFundInWatchlist(currentWatchlist.id, fund.id);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChartsScreen(fund: fund),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[900]!, width: 1),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance, color: Colors.black),
              ),
              title: Text(
                fund.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${fund.category} • ${fund.fundManager}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                  color: isInWatchlist ? Colors.blue : Colors.grey[600],
                ),
                onPressed: () async {
                  if (provider.watchlists.isEmpty) {
                    // If no watchlists exist, show the create watchlist modal
                    Navigator.pop(context); // Close any open modals
                    _showCreateWatchlistModal();
                    return;
                  }

                  if (currentWatchlist != null) {
                    try {
                      if (isInWatchlist) {
                        await provider.removeFundFromWatchlist(
                          currentWatchlist.id,
                          fund.id,
                        );
                      } else {
                        await provider.addFundToWatchlist(
                          currentWatchlist.id,
                          fund.id,
                        );
                      }
                    } catch (e) {
                      // Handle any errors
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error: ${e.toString()}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Watchlist',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement filter functionality
                        },
                      ),
                    ],
                  ),
                ),
                if (provider.watchlists.isNotEmpty) Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: provider.watchlists.map((watchlist) => Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(watchlist.name),
                      ),
                    )).toList(),
                    indicator: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                Expanded(
                  child: provider.searchQuery.isNotEmpty
                    ? ListView.builder(
                        itemCount: provider.filteredFunds.length,
                        itemBuilder: (context, index) => _buildMutualFundCard(provider.filteredFunds[index]),
                      )
                    : provider.watchlists.isEmpty
                        ? _buildEmptyState()
                        : TabBarView(
                            controller: _tabController,
                            children: provider.watchlists.map((watchlist) {
                              final watchlistFunds = provider.getWatchlistFunds(watchlist.id);
                              return watchlistFunds.isEmpty
                                  ? _buildEmptyWatchlist()
                                  : ListView.builder(
                                      itemCount: watchlistFunds.length,
                                      itemBuilder: (context, index) => _buildMutualFundCard(watchlistFunds[index]),
                                    );
                            }).toList(),
                          ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAllWatchlistsModal,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.format_list_bulleted,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first watchlist',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateWatchlistModal,
            icon: const Icon(Icons.add),
            label: const Text('Create Watchlist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWatchlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Looks like your watchlist is empty',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Add Mutual Funds',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     context.read<WatchlistProvider>().updateSearchQuery('');
          //     _searchController.clear();
          //     _searchFocusNode.requestFocus();
          //     _searchController.selection = TextSelection.fromPosition(
          //       TextPosition(offset: _searchController.text.length),
          //     );
          //   },
          //   icon: const Icon(Icons.add),
          //   label: const Text('Add Mutual Funds'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue,
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
} 