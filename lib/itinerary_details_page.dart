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

  void _loadMapData() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      final List<LatLng> points = [];
      
      // Using widget.route.stops from your Trip model
      for (int i = 0; i < widget.route.stops.length; i++) {
        final stop = widget.route.stops[i];
        final position = LatLng(stop.place.lat, stop.place.lng);
        points.add(position);
        
        _markers.add(Marker(
          markerId: MarkerId('stop_$i'),
          position: position,
          infoWindow: InfoWindow(title: stop.place.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(180.0),
        ));
      }
      
      if (points.length >= 2) {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route_path'),
          points: points,
          color: Colors.teal.shade300,
          width: 5,
        ));
      }
    });
  }

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
      70,
    ));
  }

  Future<void> _exportToGoogleMaps() async {
    if (widget.route.stops.length < 2) return;
    final first = widget.route.stops.first.place;
    final last = widget.route.stops.last.place;
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${first.lat},${first.lng}&destination=${last.lat},${last.lng}&travelmode=walking';
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTripStopPage(
                trip: widget.route,
                availablePlaces: MockData.availablePlaces,
              ),
            ),
          );
          if (result == true) {
            _loadMapData();
            _centerMapOnRoute();
          }
        },
        backgroundColor: Colors.teal.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
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
                  padding: const EdgeInsets.only(top: 25, bottom: 80),
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
    final dateStr = DateFormat('MMM dd').format(widget.route.startDate);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              const Text('Trip Schedule', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), 
              const SizedBox(height: 4), 
              Text('${widget.route.name} • $dateStr', style: TextStyle(fontSize: 14, color: primaryTeal, fontWeight: FontWeight.w700))
            ]
          ), 
          const Icon(Icons.edit_calendar_outlined, color: Colors.grey)
        ]
      )
    );
  }

  Widget _buildPlaceTimelineItem(TripStop stop, {required bool isLast}) {
    final timeStr = DateFormat('jm').format(stop.scheduledTime);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          Column(
            children: [
              Container(
                width: 14, 
                height: 14, 
                decoration: BoxDecoration(color: Colors.teal.shade400, border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle)
              ), 
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.teal.shade100))
            ]
          ), 
          const SizedBox(width: 20), 
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
                      Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ), 
                  Text(stop.place.category, style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontWeight: FontWeight.w600)), 
                  const SizedBox(height: 4), 
                  Text(stop.customNotes ?? stop.place.detail, style: TextStyle(fontSize: 14, color: Colors.grey.shade600))
                ]
              )
            )
          )
        ]
      )
    );
  }
}