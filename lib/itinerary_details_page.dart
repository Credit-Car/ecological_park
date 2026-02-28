import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'models/trip.dart';
import '../models/places.dart';

class ItineraryDetailsPage extends StatefulWidget {
  final Trip route;
  const ItineraryDetailsPage({super.key, required this.route});

  @override
  State<ItineraryDetailsPage> createState() => _ItineraryDetailsPageState();
}

class _ItineraryDetailsPageState extends State<ItineraryDetailsPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  final List<Places> _itineraryPlaces = [
    const Places(name: 'NDHU Library', category: 'Study', detail: 'Flight BOS to EDI arrival', lat: 23.8969381, lng: 121.5421631),
    const Places(name: 'NDHU Guest House', category: 'Hotel', detail: 'Check-in and drop off luggage', lat: 23.8971, lng: 121.5412),
    const Places(name: 'Administration Building', category: 'Meeting', detail: 'NDHU Project Intro Session', lat: 23.8930, lng: 121.5360),
  ];

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  void _loadMapData() {
    _markers.clear();
    _polylines.clear();
    final List<LatLng> points = [];
    for (int i = 0; i < _itineraryPlaces.length; i++) {
      final place = _itineraryPlaces[i];
      final position = LatLng(place.lat, place.lng);
      points.add(position);
      _markers.add(Marker(markerId: MarkerId('stop_$i'), position: position, infoWindow: InfoWindow(title: place.name), icon: BitmapDescriptor.defaultMarkerWithHue(180.0)));
    }
    if (points.length >= 2) {
      _polylines.add(Polyline(polylineId: const PolylineId('route_path'), points: points, color: Colors.teal.shade300, width: 5));
    }
  }

  void _centerMapOnRoute() {
    if (_mapController == null || _itineraryPlaces.isEmpty) return;
    double minLat = _itineraryPlaces.first.lat;
    double minLng = _itineraryPlaces.first.lng;
    double maxLat = _itineraryPlaces.first.lat;
    double maxLng = _itineraryPlaces.first.lng;
    for (var place in _itineraryPlaces) {
      if (place.lat < minLat) minLat = place.lat;
      if (place.lat > maxLat) maxLat = place.lat;
      if (place.lng < minLng) minLng = place.lng;
      if (place.lng > maxLng) maxLng = place.lng;
    }
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 70));
  }

  Future<void> _exportToGoogleMaps() async {
    if (_itineraryPlaces.length < 2) return;
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${_itineraryPlaces.first.lat},${_itineraryPlaces.first.lng}&destination=${_itineraryPlaces.last.lat},${_itineraryPlaces.last.lng}&travelmode=walking';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color.fromARGB(255, 98, 131, 128);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.route.destination, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          if (_itineraryPlaces.length >= 2)
            IconButton(
              icon: const Icon(Icons.share_location_rounded),
              onPressed: _exportToGoogleMaps,
            ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: PointerInterceptor(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _itineraryPlaces.isNotEmpty
                      ? LatLng(_itineraryPlaces.first.lat, _itineraryPlaces.first.lng)
                      : const LatLng(23.8967, 121.5398),
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_itineraryPlaces.length >= 2) {
                    Future.delayed(const Duration(milliseconds: 300), _centerMapOnRoute);
                  }
                },
                markers: _markers,
                polylines: _polylines,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),

          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.5,
            minChildSize: 0.15,
            maxChildSize: 0.75,
            snap: true,
            snapSizes: const [0.15, 0.5, 0.75],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                  ],
                ),
                child: ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 25),
                  itemCount: _itineraryPlaces.length + 1, 
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildHeader(primaryTeal);
                    
                    final placeIndex = index - 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildPlaceTimelineItem(
                        _itineraryPlaces[placeIndex],
                        isLast: placeIndex == _itineraryPlaces.length - 1,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildGrabHandle() {
  //   return Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))));
  // }

  Widget _buildHeader(Color primaryTeal) {
    return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Trip Schedule', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('${widget.route.destination} • Mar 10', style: TextStyle(fontSize: 14, color: primaryTeal, fontWeight: FontWeight.w700))]), const Icon(Icons.edit_calendar_outlined, color: Colors.grey)]));
  }

  Widget _buildPlaceTimelineItem(Places place, {required bool isLast}) {
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Column(children: [Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.teal.shade400, border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle)), if (!isLast) Expanded(child: Container(width: 2, color: Colors.teal.shade100))]), const SizedBox(width: 20), Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 30.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(place.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(place.category, style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(place.detail, style: TextStyle(fontSize: 14, color: Colors.grey.shade600))])))]));
  }

  // Widget _buildGlassCircle(IconData icon, VoidCallback onTap) {
  //   return GestureDetector(onTap: onTap, child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9), child: Icon(icon, color: Colors.black, size: 18)));
  // }

  // Widget _buildGlassButton(String label, IconData icon, VoidCallback onTap) {
  //   return TextButton.icon(onPressed: onTap, style: TextButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), icon: Icon(icon, size: 20, color: Colors.black), label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)));
  // }
}