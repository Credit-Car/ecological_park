import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/providers/current_user.dart';

import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';

import 'dashboard.dart';
import 'trips_page.dart';
import 'chatbot.dart';
import 'maps.dart';
import 'settings.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class AvatarManager {
  static const Map<String, String> avatars = {
    'default': 'assets/images/avatars/default.jpg',
    'butterfly': 'assets/images/avatars/butterfly.jpg',
    'dandelion': 'assets/images/avatars/dandelion.jpg',
    'lake': 'assets/images/avatars/lake.jpg',
    'leaf': 'assets/images/avatars/leaf.jpg',
    'sun': 'assets/images/avatars/sun.jpg',
    'tree': 'assets/images/avatars/tree.jpg',
  };

  static String getAssetPath(String? key) {
    return avatars[key] ?? avatars['default']!;
  }
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;
  final List<int> _navigationHistory = [0];

  late final List<Widget> _pages = [
    const Dashboard(),
    const TripsPage(),
    CampusMapViewerPage(),
    const ChatbotApp(),
    ProfileMenuScreen(),
  ];

  final Set<int> _pagesWithHeader = {0, 1, 2}; 

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == index) return;
      _selectedIndex = index;
      if (_navigationHistory.isEmpty || _navigationHistory.last != index) {
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
    
    // Read the current localization strings context
    final l10n = AppLocalizations.of(context)!;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.app_title, // Localized title: "馬太鞍溼地休閒農業區" / "Matai'an Wetland..."
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              // 🌐 THE LANGUAGE TOGGLE BUTTON
              IconButton(
                icon: const Icon(Icons.translate, color: Colors.teal),
                tooltip: l10n.btn_language,
                onPressed: () {
                  // Toggle language between English and Chinese globally via Riverpod
                  ref.read(localeProvider.notifier).toggleLanguage();
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.teal),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
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

  Widget _buildAppFootnote() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          _footnoteRow(
            Icons.construction, 
            "Prototype: Unfinished version.", 
            Colors.orange
          ),
          const SizedBox(height: 4),
          _footnoteRow(
            Icons.info_outline, 
            "Images sourced from erv-nsa.gov.tw.", 
            Colors.grey
          ),
        ],
      ),
    );
  }

  Widget _footnoteRow(IconData icon, String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAppFootnote(),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            // 🏷️ Localized Navigation Items labels
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.nav_home),
              BottomNavigationBarItem(icon: const Icon(Icons.map), label: l10n.nav_trips),
              BottomNavigationBarItem(icon: const Icon(Icons.gps_fixed), label: l10n.nav_map), // Reuses map string context
              BottomNavigationBarItem(icon: const Icon(Icons.auto_awesome), label: l10n.nav_audio_guide),
            ],
          )
        ],
      ),
    );
  }
}