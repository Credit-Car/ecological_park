import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:intl/intl.dart';
import 'models/trip.dart';
import 'add_itinerary_item_page.dart';
import 'mockdata.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  /// Updates the Map Markers and Path whenever data changes
  void _loadMapData() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      final List<LatLng> points = [];
      
      for (int i = 0; i < widget.route.stops.length; i++) {
        final stop = widget.route.stops[i];
        final position = LatLng(stop.place.lat, stop.place.lng);
        points.add(position);
        
        _markers.add(Marker(
          markerId: MarkerId(stop.place.id), // Using the new Places ID
          position: position,
          infoWindow: InfoWindow(title: stop.place.name, snippet: stop.place.category),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      }
      
      if (points.length >= 2) {
        _polylines.add(Polyline(
          polylineId: PolylineId(widget.route.id), // Using Trip ID for the path
          points: points,
          color: Colors.teal.shade300,
          width: 5,
          jointType: JointType.round,
        ));
      }
    });
  }

  /// Calculates the bounds to show all stops on the screen
  void _centerMapOnRoute() {
    if (_mapController == null || widget.route.stops.isEmpty) return;
    
    double minLat = widget.route.stops.first.place.lat;
    double minLng = widget.route.stops.first.place.lng;
    double maxLat = widget.route.stops.first.place.lat;
    double maxLng = widget.route.stops.first.place.lng;
    
    for (var stop in widget.route.stops) {
      if (stop.place.lat < minLat) minLat = stop.place.lat;
      if (stop.place.lat > maxLat) maxLat = stop.place.lat;
      if (stop.place.lng < minLng) minLng = stop.place.lng;
      if (stop.place.lng > maxLng) maxLng = stop.place.lng;
    }
    
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 
      80, // Padding
    ));
  }

  Future<void> _exportToGoogleMaps() async {
    if (widget.route.stops.length < 2) return;
    final first = widget.route.stops.first.place;
    final last = widget.route.stops.last.place;
    // Note: Replaced curly brace typo in your original URL template
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${first.lat},${first.lng}&destination=${last.lat},${last.lng}&travelmode=walking';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
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
        title: Text(widget.route.name, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          if (widget.route.stops.length >= 2)
            IconButton(
              icon: const Icon(Icons.share_location_rounded),
              onPressed: _exportToGoogleMaps,
            ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigating to the Add Page with updated parameters
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTripStopPage(
                trip: widget.route, // Passing the full Trip object
                availablePlaces: MockData.availablePlaces,
              ),
            ),
          );
          
          if (result == true) {
            _loadMapData();
            _centerMapOnRoute();
          }
        },
        backgroundColor: Colors.teal.shade700,
        child: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
      ),
      body: Stack(
        children: [
          // MAP BACKGROUND
          Positioned.fill(
            child: PointerInterceptor(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.route.stops.isNotEmpty
                      ? LatLng(widget.route.stops.first.place.lat, widget.route.stops.first.place.lng)
                      : const LatLng(23.8967, 121.5398),
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (widget.route.stops.length >= 2) {
                    Future.delayed(const Duration(milliseconds: 500), _centerMapOnRoute);
                  }
                },
                markers: _markers,
                polylines: _polylines,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),

          // BOTTOM DRAGGABLE SHEET
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.4,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.15, 0.4, 0.85],
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
                  padding: const EdgeInsets.only(top: 15, bottom: 100), // Padding for FAB
                  itemCount: widget.route.stops.length + 1, 
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildHeader(primaryTeal);
                    
                    final stopIndex = index - 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildPlaceTimelineItem(
                        widget.route.stops[stopIndex],
                        isLast: stopIndex == widget.route.stops.length - 1,
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

  Widget _buildHeader(Color primaryTeal) {
    final dateStr = DateFormat('EEEE, MMM dd').format(widget.route.startDate);
    return Column(
      children: [
        // Pull handle
        Container(
          width: 40, height: 5,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  const Text('Trip Schedule', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), 
                  const SizedBox(height: 4), 
                  Text(dateStr, style: TextStyle(fontSize: 14, color: primaryTeal, fontWeight: FontWeight.w700))
                ]
              ), 
              CircleAvatar(
                backgroundColor: Colors.teal.shade50,
                child: Icon(Icons.calendar_month, color: Colors.teal.shade700, size: 20),
              )
            ]
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceTimelineItem(TripStop stop, {required bool isLast}) {
    final timeStr = DateFormat('jm').format(stop.scheduledTime);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          // TIMELINE LINE
          Column(
            children: [
              Container(
                width: 16, height: 16, 
                decoration: BoxDecoration(
                  color: Colors.teal.shade400, 
                  border: Border.all(color: Colors.white, width: 3), 
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                )
              ), 
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.teal.shade100))
            ]
          ), 
          const SizedBox(width: 20), 
          // TIMELINE CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(stop.place.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontWeight: FontWeight.w800)),
                    ],
                  ), 
                  const SizedBox(height: 2),
                  Text(stop.place.category.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.teal.shade300, fontWeight: FontWeight.bold, letterSpacing: 0.5)), 
                  const SizedBox(height: 8), 
                  // Display custom notes if they exist, otherwise show building detail
                  Text(
                    stop.customNotes != null && stop.customNotes!.isNotEmpty 
                        ? stop.customNotes! 
                        : stop.place.detail, 
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }
}