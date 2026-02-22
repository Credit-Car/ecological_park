import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'trips_page.dart';
import 'chatbot.dart';
import 'maps.dart';
import 'settings.dart';
// import 'package:firebase_data_connect/firebase_data_connect.dart';
// import 'dataconnect_generated/generated.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/providers/current_user.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class AvatarManager {
  // This maps the Database Key -> The Local Asset Path
  static const Map<String, String> avatars = {
    'default': 'images/avatars/default.jpg',
    'butterfly': 'images/avatars/butterfly.jpg',
    'dandelion': 'images/avatars/dandelion.jpg',
    'lake': 'images/avatars/lake.jpg',
    'leaf': 'images/avatars/leaf.jpg',
    'sun': 'images/avatars/sun.jpg',
    'tree': 'images/avatars/tree.jpg',
  };

  // Safe getter: Returns the default image if the key is missing/corrupted
  static String getAssetPath(String? key) {
    return avatars[key] ?? avatars['default']!;
  }
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  // final String _defaultAvatar = AvatarManager.getAssetPath('default');

  final List<int> _navigationHistory = [0];

  late final List<Widget> _pages = [
    const Dashboard(),
    const TripsPage(),
    AddItineraryStopPage(),
    const ChatbotApp(),
    ProfileMenuScreen(),
  ];

  final Set<int> _pagesWithHeader = {0, 1, 2}; 

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == index) return;
      
      _selectedIndex = index;

      if (_navigationHistory.length > 1 && _navigationHistory[_navigationHistory.length - 2] == index) {
        _navigationHistory.removeLast();
      } else {
        _navigationHistory.add(index);
      }
    });
  }
  
  void _onBackTapped() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      
      setState(() {
        _selectedIndex = _navigationHistory.last;
      });
    }
  }

  PreferredSizeWidget? _buildAppBar() {
  if (!_pagesWithHeader.contains(_selectedIndex)) return null;

  final bool showBackButton = _navigationHistory.length > 1;

  final currentUser = ref.watch(currentUserProvider);
  final userAvatarUrl = AvatarManager.getAssetPath(currentUser?.avatarKey);

  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _onBackTapped,
          )
        : null,
    
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align title left
              mainAxisSize: MainAxisSize.min,
              children: const [
                // Text(
                //   "Hi Bella,",
                //   style: TextStyle(fontSize: 16, color: Colors.black54),
                // ),
                Text(
                  "NDHU Travel App",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

        // Notif Icon and Profile
        Row(
          children: [
             IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.teal),
                onPressed: () {},
             ),
             CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(userAvatarUrl),
              ),
          ],
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),

      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          key: ValueKey<int>(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Plan"),
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "GuideBook"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}