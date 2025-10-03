import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'CoralConnect',
            debugShowCheckedModeBanner: false,
            themeMode: appState.themeMode,
            theme: ThemeData(
              primarySwatch: Colors.orange,
              primaryColor: Color(0xFFFF6B6B),
              scaffoldBackgroundColor: Color(0xFFFFF8F5),
              fontFamily: 'SF Pro Display',
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black87,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Color(0xFFFF6B6B),
              scaffoldBackgroundColor: Color(0xFF1A1A1A),
              fontFamily: 'SF Pro Display',
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            home: Consumer<AppState>(
              builder: (context, appState, _) {
                return appState.isLoggedIn ? MainScreen() : LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late AnimationController _navController;
  bool _showFab = true;

  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    MarketplaceScreen(),
    NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _navController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();
    _navController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8F5), Color(0xFFFFE8E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            _navController.reset();
            _navController.forward();
          },
          children: _screens,
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabController.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF6B6B).withOpacity(0.5),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _showCreateMenu(context),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBuilder(
        animation: _navController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _navController.value)),
            child: Container(
              height: 75,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(37),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF6B6B).withOpacity(0.4),
                    blurRadius: 25,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.explore_rounded, 'Explore'),
                  SizedBox(width: 40),
                  _buildNavItem(2, Icons.shopping_bag_rounded, 'Shop'),
                  _buildNavItem(3, Icons.notifications_rounded, 'Alerts'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isSelected ? 26 : 22,
        ),
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 220,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF6B6B).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 25),
            Text(
              '🌟 Create Something Amazing 🌟',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCreateOption(Icons.post_add_rounded, 'Post'),
                _buildCreateOption(Icons.video_call_rounded, 'Live'),
                _buildCreateOption(Icons.camera_alt_rounded, 'Story'),
                _buildCreateOption(Icons.shopping_cart_rounded, 'Shop'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Color(0xFFFF6B6B), size: 28),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    _navController.dispose();
    super.dispose();
  }
}