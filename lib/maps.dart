// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart' as ll;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng; 
import 'package:travel_app/dataconnect_generated/generated.dart'; 
import '../models/places.dart';
import 'chatbot.dart'; 
import 'l10n/app_localizations.dart';

class CampusMapViewerPage extends StatefulWidget {
  const CampusMapViewerPage({super.key});

  @override
  State<CampusMapViewerPage> createState() => _CampusMapViewerPageState();
}

class _CampusMapViewerPageState extends State<CampusMapViewerPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  
  Places? _selectedPlace;
  List<Places> _allPlaces = []; 
  List<Places> _searchResults = [];
  bool _isLoading = true;
  String _selectedCategory = "全部";

  // Category Translation Map: Bridges Chinese Chips to Hardcoded Memory Category Keys
  final Map<String, String> _categoryUiToDbMapping = {
    "全部": "All",
    "野生動植物": "Wildlife",
    "在地文化": "Culture",
    "景點": "Scenic Spot",
    "設備": "Facility",
  };

  // Custom Category Markers Mapping Config
  final Map<String, String> _markerPaths = {
    'p001': 'assets/images/markers/marker.png',
    'p002': 'assets/images/markers/marker.png',
    'p003': 'assets/images/markers/marker.png',
    'p004': 'assets/images/markers/marker.png',
    'p005': 'assets/images/markers/marker.png',
    'p006': 'assets/images/markers/marker.png',
  };

  final Color guideTeal = const Color(0xFF14B8A6);
  final ll.LatLng _initialCenter = const ll.LatLng(23.65775, 121.40966);

  @override
  void initState() {
    super.initState();
    _fetchPlacesFromFirebase();
  }

  Future<void> _fetchPlacesFromFirebase() async {
    try {
      final res = await ExampleConnector.instance.listPlaces().execute();
      
      final mappedPlaces = res.data.places.map((e) {
        final parts = e.coordinates.split(',');
        final lat = parts.isNotEmpty ? double.tryParse(parts.first.trim()) ?? 0.0 : 0.0;
        final lng = parts.length > 1 ? double.tryParse(parts.last.trim()) ?? 0.0 : 0.0;

  
        String rawDbCategory = 'Explore';
        try {
          final jsonMap = e.toJson(); 
          if (jsonMap.containsKey('category') && jsonMap['category'] != null) {
            rawDbCategory = jsonMap['category'].toString();
          }
        } catch (_) {}

        String resolvedCategory = rawDbCategory;
        if (resolvedCategory == 'Explore' || resolvedCategory.trim().isEmpty) {
          switch (e.placeId) {
            case 'p001':
              resolvedCategory = 'Facility';
              break;
            case 'p002':
              resolvedCategory = 'Scenic Spot';
              break;
            case 'p003':
              resolvedCategory = 'Wildlife';
              break;
            case 'p004':
              resolvedCategory = 'Scenic Spot';
              break;
            case 'p005':
              resolvedCategory = 'Culture';
              break;
            case 'p006':
              resolvedCategory = 'Culture';
              break;
            default:
              final String nameLower = e.name.toLowerCase();
              if (nameLower.contains('center') || nameLower.contains('visitor')) {
                resolvedCategory = 'Facility';
              } else if (nameLower.contains('boardwalk') || nameLower.contains('bridge')) {
                resolvedCategory = 'Scenic Spot';
              } else if (nameLower.contains('willow') || nameLower.contains('firefly') || nameLower.contains('pond')) {
                resolvedCategory = 'Wildlife';
              } else if (nameLower.contains('farm') || nameLower.contains('house') || nameLower.contains('culture')) {
                resolvedCategory = 'Culture';
              }
              break;
          }
        }

        return Places(
          id: e.placeId,
          name: e.name,
          category: resolvedCategory,
          imageUrl: (e.images != null && e.images!.isNotEmpty) ? e.images!.join(',') : '',
          detail: e.description ?? '',
          location: LatLng(lat, lng), 
        );
      }).toList();

      setState(() {
        _allPlaces = mappedPlaces;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Firebase connection dropped or map sync failed: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onPlaceTap(Places place) {
    setState(() {
      _selectedPlace = place;
      _searchResults = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
    _mapController.move(ll.LatLng(place.location.latitude, place.location.longitude), 17.5);
  }

  Future<void> _openGoogleMaps(Places place) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${place.location.latitude},${place.location.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.teal))
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 17.8,
                  minZoom: 14.0, 
                  maxZoom: 20.0,
                  onTap: (_, _) => setState(() => _selectedPlace = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ndhu.travelapp',
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(),
                  ),
                ],
              ),

              // TOP OVERLAY UI
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16, right: 16,
                child: PointerInterceptor(
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 8),
                      _buildFilterChips(), // Customized Chinese ChoiceChips Layout
                      if (_searchResults.isNotEmpty) _buildSearchResultsDropdown(),
                    ],
                  ),
                ),
              ),

              // BOTTOM DETAILS PANEL
              if (_selectedPlace != null)
                Positioned(
                  bottom: 24, left: 16, right: 16,
                  child: PointerInterceptor(child: _buildModernInfoCard()),
                ),
            ],
          ),
    );
  }

  List<Marker> _buildMarkers() {
    final String mappedDbTarget = _categoryUiToDbMapping[_selectedCategory] ?? "All";

    return _allPlaces.where((place) {
      if (mappedDbTarget == "All") return true;
      return place.category.toLowerCase().trim() == mappedDbTarget.toLowerCase().trim();
    }).map((place) {
      
      String? assetPath = _markerPaths[place.id];
      
      if (assetPath == null) {
        final String currentCategory = place.category.toLowerCase();
        if (currentCategory.contains('wildlife')) assetPath = _markerPaths['p002'];
        else if (currentCategory.contains('facility')) assetPath = _markerPaths['p001'];
        else if (currentCategory.contains('scenic spot')) assetPath = _markerPaths['p004'];
        else if (currentCategory.contains('culture')) assetPath = _markerPaths['p005'];
      }
      
      return Marker(
        point: ll.LatLng(place.location.latitude, place.location.longitude),
        width: 40,
        height: 40,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _onPlaceTap(place),
          child: assetPath != null 
            ? Image.asset(
                assetPath,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.location_on, color: guideTeal, size: 40),
              ) 
            : Icon(Icons.location_on, color: guideTeal, size: 40),
        ),
      );
    }).toList();
  }

  Widget _buildModernInfoCard() {
    final String cleanThumbnailUrl = _selectedPlace!.imageUrl.split(',').first.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 25, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: cleanThumbnailUrl.startsWith('https')
                  ? CachedNetworkImage(
                      imageUrl: cleanThumbnailUrl,
                      width: 70, height: 70, fit: BoxFit.cover,
                      placeholder: (c, u) => Container(width: 70, height: 70, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                      errorWidget: (c, u, e) => _buildImageErrorPlaceholder(),
                    )
                  : Image.asset(
                      cleanThumbnailUrl, 
                      width: 70, height: 70, fit: BoxFit.cover, 
                      errorBuilder: (c, e, s) => _buildImageErrorPlaceholder(),
                    ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedPlace!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: guideTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        _selectedPlace!.category.toUpperCase(), 
                        style: TextStyle(color: guideTeal, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedPlace = null), 
                icon: const Icon(Icons.close_rounded, size: 22, color: Colors.grey)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedPlace!.detail, 
            maxLines: 3, 
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatbotApp(initialPlace: _selectedPlace),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(AppLocalizations.of(context)!.chatbot_btn_ask, style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: guideTeal, foregroundColor: Colors.white, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _openGoogleMaps(_selectedPlace!),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: Text(AppLocalizations.of(context)!.trip_go, style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: guideTeal, side: BorderSide(color: guideTeal.withOpacity(0.2), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() => Container(width: 70, height: 70, color: Colors.grey[100], child: const Icon(Icons.map_rounded, color: Colors.grey));

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categoryUiToDbMapping.keys.map((cat) {
          bool isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: switch(cat) {
                "野生動植物" => Colors.green.shade300,
                "在地文化" => Colors.orange.shade300,
                "景點" => Colors.blue.shade300,
                _ => Colors.grey.shade300, 
              },
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedCategory = cat);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchResults = _allPlaces.where((p) => p.name.toLowerCase().contains(v.toLowerCase())).toList()),
        decoration: const InputDecoration(hintText: "Explore Matai’an...", icon: Icon(Icons.search), border: InputBorder.none),
      ),
    );
  }

  Widget _buildSearchResultsDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (c, i) => ListTile(title: Text(_searchResults[i].name), onTap: () => _onPlaceTap(_searchResults[i])),
      ),
    );
  }
}