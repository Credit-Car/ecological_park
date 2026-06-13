import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // New Import
import 'package:latlong2/latlong.dart';      // New Import
import 'package:url_launcher/url_launcher.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'models/places.dart';
import 'mockdata.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';

class CampusMapViewerPage extends StatefulWidget {
  const CampusMapViewerPage({super.key});

  @override
  State<CampusMapViewerPage> createState() => _CampusMapViewerPageState();
}

class _CampusMapViewerPageState extends State<CampusMapViewerPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  
  Places? _selectedPlace;
  List<Places> _searchResults = [];
  String _selectedCategory = "All";

  final List<Places> _allPlaces = MockData.availablePlaces;
  
  final Map<String, String> _markerPaths = {
    'p001': 'assets/images/markers/info.png',
    'p002': 'assets/images/markers/firefly.png',
    'p003': 'assets/images/markers/pond.png',
    'p004': 'assets/images/markers/bridge.png',
    'p005': 'assets/images/markers/fishing.png',
    'p006': 'assets/images/markers/picnic-table.png',
  };

  final Color guideTeal = const Color(0xFF14B8A6);

  // Boundary coordinates
  final LatLng _initialCenter = const LatLng(23.65775, 121.40966);

  void _onPlaceTap(Places place) {
    setState(() {
      _selectedPlace = place;
      _searchResults = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
    
    _mapController.move(LatLng(place.lat, place.lng), 17.5);
  }

  void _openChatForPlace(Places place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Ask about ${place.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _chatBubble("What is special about this place?", false),
                  _chatBubble("This area is known for wetland biodiversity and local culture.", true),
                ],
              ),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(Places place) async {
    // Corrected Google Maps URL format
    final url = 'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lng}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 17.8,
              minZoom: 17.3,
              maxZoom: 20.0,
              onTap: (_, _) => setState(() => _selectedPlace = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),

          // TOP UI
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16, right: 16,
            child: PointerInterceptor(
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 8),
                  _buildFilterChips(),
                  if (_searchResults.isNotEmpty) _buildSearchResultsDropdown(),
                ],
              ),
            ),
          ),

          // BOTTOM NAME CARD
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
    return _allPlaces
        .where((p) => _selectedCategory == "All" || p.category == _selectedCategory)
        .map((place) {
      
      final String? assetPath = _markerPaths[place.id];
      
      return Marker(
        point: LatLng(place.lat, place.lng),
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => _onPlaceTap(place),
          child: assetPath != null 
            ? Image.asset(assetPath) 
            : Icon(Icons.location_on, color: guideTeal, size: 40),
        ),
      );
    }).toList();
  }

Widget _buildModernInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12), 
            blurRadius: 25, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  _selectedPlace!.imageUrl, 
                  width: 70, height: 70, fit: BoxFit.cover, 
                  errorBuilder: (c, e, s) => Container(
                    width: 70, height: 70, 
                    color: Colors.grey[100], 
                    child: const Icon(Icons.map_rounded, color: Colors.grey)
                  )
                ),
              ),
              const SizedBox(width: 16),
              // Name and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedPlace!.name, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: guideTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
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
          
          // STOP DETAILS SECTION
          const SizedBox(height: 16),
          Text(
            _selectedPlace!.detail, 
            maxLines: 3, 
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600, 
              fontSize: 13, 
              height: 1.5, // Improves readability
              fontStyle: FontStyle.italic
            ),
          ),
          
          const SizedBox(height: 20),
          
          // COHERENT BUTTON ROW
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _openChatForPlace(_selectedPlace!),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text( AppLocalizations.of(context)!.chatbot_btn_ask, style: const TextStyle(fontWeight: FontWeight.bold),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: guideTeal, 
                      foregroundColor: Colors.white,
                      elevation: 0,
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
                      foregroundColor: guideTeal,
                      side: BorderSide(color: guideTeal.withValues(alpha: 0.2), width: 2),
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["All", "Wildlife", "Culture", "Scenic Spot", "Facility"].map((cat) {
          bool isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              // FIX: Default fallback color prevents the Null error
              selectedColor: switch(cat) {
                "Wildlife" => Colors.green.shade300,
                "Culture" => Colors.orange.shade300,
                "Scenic Spot" => Colors.blue.shade300,
                _ => Colors.grey.shade300, 
              },
              onSelected: (val) => setState(() => _selectedCategory = cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

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

  Widget _chatBubble(String text, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isBot ? Colors.grey[100] : guideTeal, borderRadius: BorderRadius.circular(15)),
        child: Text(text, style: TextStyle(color: isBot ? Colors.black87 : Colors.white)),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Row(
        children: [
          Expanded(child: TextField(decoration: InputDecoration(hintText: "Ask Guide...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(width: 8),
          IconButton(onPressed: () {}, icon: Icon(Icons.send, color: guideTeal)),
        ],
      ),
    );
  }
}