import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'charts_screen.dart';
import 'watchlist_screen.dart';
import '../models/mutual_fund.dart';
import '../providers/watchlist_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    ChartsScreen(fund: MutualFund(
      id: 'default',
      name: 'Select a fund to view charts',
      category: 'N/A',
      currentNav: 0,
      previousNav: 0,
      oneYearReturn: 0,
      threeYearReturn: 0,
      fiveYearReturn: 0,
      dailyReturns: {},
      riskLevel: 'N/A',
      expenseRatio: 0,
      aum: 0,
      fundManager: 'N/A',
      launchDate: DateTime.now(),
      benchmark: 'N/A',
    )),
    const WatchlistScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WatchlistProvider(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: _screens,
            ),
            if (_currentIndex == 0) Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem('assets/images/home.svg', 'Home', _currentIndex == 0, 0),
                    _buildNavItem('assets/images/chart.svg', 'Charts', _currentIndex == 1, 1),
                    _buildNavItem('assets/images/watchlist.svg', 'Watchlist', _currentIndex == 2, 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String path, String label, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            path,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.blue : Colors.grey,
              BlendMode.srcIn,
            ),
            height: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}