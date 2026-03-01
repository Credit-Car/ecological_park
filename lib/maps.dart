import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  final LatLngBounds _ndhuBounds = LatLngBounds(
    southwest: const LatLng(23.8850, 121.5280),
    northeast: const LatLng(23.9050, 121.5550),
  );

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty && _selectedCategory == "All") {
        _searchResults = [];
      } else {
        _searchResults = _allPlaces.where((place) {
          bool matchesQuery = place.name.toLowerCase().contains(query.toLowerCase());
          bool matchesCategory = _selectedCategory == "All" || place.category == _selectedCategory;
          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5D5FEF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(23.8967, 121.5398), zoom: 16),
            cameraTargetBounds: CameraTargetBounds(_ndhuBounds),
            minMaxZoomPreference: const MinMaxZoomPreference(14, 20),
            onMapCreated: (controller) => _mapController = controller,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _buildMarkers(),
            onTap: (_) => setState(() => _selectedPlace = null),
          ),
          Positioned(
            top: 20, left: 20, right: 20,
            child: PointerInterceptor(
              child: Column(
                children: [
                  _buildSearchBar(primaryColor),
                  const SizedBox(height: 12),
                  _buildFilterChips(primaryColor),
                  if (_searchResults.isNotEmpty) _buildSearchResultsDropdown(),
                ],
              ),
            ),
          ),

          // Info Card
          if (_selectedPlace != null)
            Positioned(
              bottom: 30, left: 20, right: 20,
              child: PointerInterceptor(
                child: _buildInfoCard(primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return _allPlaces.map((place) {
      return Marker(
        markerId: MarkerId(place.name),
        position: LatLng(place.lat, place.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selectedPlace?.name == place.name 
              ? BitmapDescriptor.hueViolet 
              : BitmapDescriptor.hueAzure,
        ),
        onTap: () => _onPlaceTap(place),
      );
    }).toSet();
  }

  Widget _buildSearchBar(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _performSearch,
        decoration: const InputDecoration(
          hintText: "Explore NDHU Buildings...",
          prefixIcon: Icon(Icons.search, color: Color(0xFF5D5FEF)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterChips(Color primaryColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["All", "Academic", "Dorm", "Sports", "Administrative"].map((cat) {
          bool isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: primaryColor.withOpacity(0.2),
              onSelected: (val) {
                setState(() {
                  _selectedCategory = cat;
                  _performSearch(_searchController.text);
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResultsDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        itemBuilder: (context, i) => ListTile(
          title: Text(_searchResults[i].name),
          subtitle: Text(_searchResults[i].category),
          onTap: () => _onPlaceTap(_searchResults[i]),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  _selectedPlace!.imageUrl,
                  width: 85, height: 85, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 85, height: 85, color: Colors.grey[100], child: const Icon(Icons.business)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedPlace!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_selectedPlace!.category, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(_selectedPlace!.detail, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {}, // For viewing purposes
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text("Building Wiki"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => setState(() => _selectedPlace = null),
              )
            ],
          )
        ],
      ),
    );
  }
}