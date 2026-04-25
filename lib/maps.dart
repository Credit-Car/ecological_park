import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'models/places.dart';
import 'mockdata.dart';

class CampusMapViewerPage extends StatefulWidget {
  const CampusMapViewerPage({super.key});

  @override
  State<CampusMapViewerPage> createState() => _CampusMapViewerPageState();
}

class _CampusMapViewerPageState extends State<CampusMapViewerPage> {

  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Places? _selectedPlace;
  List<Places> _searchResults = [];
  String _selectedCategory = "All";

  final List<Places> _allPlaces = MockData.availablePlaces;
  final GlobalKey _mapKey = GlobalKey(debugLabel: 'mataian_map_key');

  Map<String, BitmapDescriptor> _markerIcons = {};
  //Map<String, BitmapDescriptor> _customIcons = {};

  // Coherent Teal for the AI Guide
  final Color guideTeal = const Color(0xFF14B8A6);

  final LatLngBounds _mataianBounds = LatLngBounds(
    southwest: const LatLng(23.6545, 121.4065),
    northeast: const LatLng(23.6605, 121.4125),
  );
  
@override
void initState() {
  super.initState();
  _loadIcons();
}

Future<void> _loadIcons() async {
  final ids = ['p001', 'p002', 'p003', 'p004', 'p005', 'p006'];
  final paths = [
    'assets/images/markers/info.png',
    'assets/images/markers/firefly.png',
    'assets/images/markers/pond.png',
    'assets/images/markers/bridge.png',
    'assets/images/markers/fishing.png',
    'assets/images/markers/picnic-table.png',
  ];

  for (int i = 0; i < ids.length; i++) {
    // Note: Using BitmapDescriptor.asset for modern Flutter Google Maps versions
    _markerIcons[ids[i]] = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)), // Adjust size as needed
      paths[i],
    );
  }
  if (mounted) setState(() {});
}

  void _onPlaceTap(Places place) {
    setState(() {
      _selectedPlace = place;
      _searchResults = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.lat, place.lng), 17.5),
    );
  }

  // double _getMarkerHue(String category) {
  //   switch (category) {
  //     case 'Wildlife': return BitmapDescriptor.hueGreen;
  //     case 'Culture': return BitmapDescriptor.hueOrange;
  //     case 'Scenic Spot': return BitmapDescriptor.hueAzure;
  //     default: return BitmapDescriptor.hueRed; // Facilities or others
  //   }
  // }

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
    final url = 'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lng}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            key: _mapKey,
            initialCameraPosition: const CameraPosition(target: LatLng(23.65775, 121.40966), zoom: 17),
            cameraTargetBounds: CameraTargetBounds(_mataianBounds),
            onMapCreated: (controller) => _mapController = controller,
            markers: _buildMarkers(),
            onTap: (_) => setState(() => _selectedPlace = null),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
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

Set<Marker> _buildMarkers() {
  // Return empty set if icons aren't loaded yet to prevent the "Default Red Pin" flash
  if (_markerIcons.isEmpty) return {};

  return _allPlaces
      .where((p) => _selectedCategory == "All" || p.category == _selectedCategory)
      .map((place) {
    
    final bool isSelected = _selectedPlace?.id == place.id;
    
    return Marker(
      markerId: MarkerId(place.id),
      position: LatLng(place.lat, place.lng),
      // If custom icon exists, use it; otherwise, use a unique color default
      icon: _markerIcons[place.id] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      anchor: const Offset(0.5, 0.5),
      onTap: () => _onPlaceTap(place),
    );
  }).toSet();
}

Widget _buildModernInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12), 
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
                        color: guideTeal.withOpacity(0.1),
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
                    label: const Text("Ask Guide", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    label: const Text("Go", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: guideTeal,
                      side: BorderSide(color: guideTeal.withOpacity(0.2), width: 2),
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