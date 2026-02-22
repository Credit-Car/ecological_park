import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'models/place_item.dart';
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AddItineraryStopPage(),
  ));
}
class AddItineraryStopPage extends StatefulWidget {
  const AddItineraryStopPage({super.key});
  @override
  State<AddItineraryStopPage> createState() => _AddItineraryStopPageState();
}

class _AddItineraryStopPageState extends State<AddItineraryStopPage> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  PlaceItem? _selectedPlace;
  List<PlaceItem> _searchResults = [];
  String _selectedCategory = "All";

  final LatLngBounds _ndhuBounds = LatLngBounds(
    southwest: const LatLng(23.8850, 121.5280),
    northeast: const LatLng(23.9050, 121.5550),
  );

  final List<PlaceItem> _PlaceItems = const [
    PlaceItem(name: "NDHU Library", category: "Academic", detail: "Main university library", lat: 23.896943, lng: 121.5395882),
    PlaceItem(name: "Administration Building", category: "Administrative", detail: "University admin office", lat: 23.8971, lng: 121.5412),
    PlaceItem(name: "Gymnasium", category: "Sports", detail: "Sports and recreation center", lat: 23.8930, lng: 121.5360),
    PlaceItem(name: "NDHU Stadium", category: "Sports", detail: "Athletic Field and Track Field", lat: 23.9016242, lng: 121.5375676),
    PlaceItem(name: "Dorm V", category: "Dorm", detail: "Student housing area", lat: 23.8982, lng: 121.5375),
  ];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() {
      _searchResults = _PlaceItems.where((place) {
        bool matchesQuery = place.name.toLowerCase().contains(query.toLowerCase());
        bool matchesCategory = _selectedCategory == "All" || place.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _onPlaceTap(PlaceItem place) {
    setState(() {
      _selectedPlace = place;
      _searchResults = [];
      _searchController.text = place.name;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(place.lat, place.lng), 17.5));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5D5FEF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(23.8967, 121.5398), zoom: 16),
            cameraTargetBounds: CameraTargetBounds(_ndhuBounds),
            minMaxZoomPreference: const MinMaxZoomPreference(14, 20),
            onMapCreated: (controller) => _mapController = controller,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _selectedPlace == null ? {} : {
              Marker(
                markerId: const MarkerId("selected"),
                position: LatLng(_selectedPlace!.lat, _selectedPlace!.lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
              )
            },
          ),
          Positioned(
            top: 50, left: 20, right: 20,
            child: PointerInterceptor(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _performSearch,
                      decoration: const InputDecoration(
                        hintText: "Where to in NDHU?",
                        prefixIcon: Icon(Icons.search, color: primaryColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All", "Academic", "Dorm", "Sports", "Administrative"].map((cat) => _buildFilterChip(cat)).toList(),
                    ),
                  ),
                  // Search Results Dropdown
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, i) => ListTile(
                          title: Text(_searchResults[i].name),
                          subtitle: Text(_searchResults[i].category),
                          onTap: () => _onPlaceTap(_searchResults[i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Details Card
          if (_selectedPlace != null)
            Positioned(
              bottom: 30, left: 20, right: 20,
              child: PointerInterceptor(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_selectedPlace!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(_selectedPlace!.detail, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const Icon(Icons.directions, color: primaryColor, size: 30),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () => print("Location Confirmed"),
                        child: const Text("Add to Itinerary", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF5D5FEF).withValues(alpha: 0.2),
        labelStyle: TextStyle(color: isSelected ? const Color(0xFF5D5FEF) : Colors.black87, fontWeight: FontWeight.bold),
        onSelected: (val) => setState(() {
          _selectedCategory = label;
          _performSearch(_searchController.text);
        }),
      ),
    );
  }
}