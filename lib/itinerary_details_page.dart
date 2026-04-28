import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'models/trip.dart';

class ItineraryDetailsPage extends StatefulWidget {
  final Trip route;
  const ItineraryDetailsPage({super.key, required this.route});

  @override
  State<ItineraryDetailsPage> createState() => _ItineraryDetailsPageState();
}

class _ItineraryDetailsPageState extends State<ItineraryDetailsPage> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  Map<int, String> _legDistances = {}; 
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fetchGoogleRouteData();
  }
  
  Future<void> _fetchGoogleRouteData() async {
    if (widget.route.stops.length < 2) {
      setState(() => _isLoadingData = false);
      return;
    }

    const String apiKey = 'AIzaSyA311vNSU51Bmatl-h9OPEQNT-isyeoLiw';
    final origin = "${widget.route.stops.first.place.lat},${widget.route.stops.first.place.lng}";
    final destination = "${widget.route.stops.last.place.lat},${widget.route.stops.last.place.lng}";
    
    String waypoints = "";
    if (widget.route.stops.length > 2) {
      final pts = widget.route.stops
          .sublist(1, widget.route.stops.length - 1)
          .map((s) => "${s.place.lat},${s.place.lng}").join('|');
      waypoints = "&waypoints=$pts";
    }

    final url = "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=$origin&destination=$destination$waypoints&mode=walking&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final legs = data['routes'][0]['legs'] as List;
          for (int i = 0; i < legs.length; i++) {
            _legDistances[i] = legs[i]['distance']['text'];
          }
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  /// Launch the actual Google Maps app for live navigation
  Future<void> _exportToGoogleMaps() async {
    final origin = widget.route.stops.first.place;
    final destination = widget.route.stops.last.place;
    final pts = widget.route.stops.sublist(1, widget.route.stops.length - 1)
        .map((s) => "${s.place.lat},${s.place.lng}").join('|');

    final url = 'https://www.google.com/maps/dir/?api=1'
        '&origin=${origin.lat},${origin.lng}'
        '&destination=${destination.lat},${destination.lng}'
        '&waypoints=$pts'
        '&travelmode=walking';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(widget.route.name, 
        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
    ),
    body: Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: () {
              double avgLat = widget.route.stops.map((s) => s.place.lat).reduce((a, b) => a + b) / widget.route.stops.length;
              double avgLng = widget.route.stops.map((s) => s.place.lng).reduce((a, b) => a + b) / widget.route.stops.length;
              return ll.LatLng(avgLat, avgLng);
            }(),
            initialZoom: 18.0,
            minZoom: 14.0,
            maxZoom: 20.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ndhu.travelapp',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: widget.route.stops.map((s) => ll.LatLng(s.place.lat, s.place.lng)).toList(),
                  color: Colors.red.withOpacity(0.7),
                  strokeWidth: 4.0,
                ),
              ],
            ),
            MarkerLayer(
              markers: widget.route.stops.map((stop) {
                return Marker(
                  point: ll.LatLng(stop.place.lat, stop.place.lng),
                  width: 37, 
                  height: 47,
                  child: Image.asset('assets/images/markers/marker.png'), 
                );
              }).toList(),
            ),
          ],
        ),
        _buildDraggableSheet(),
      ],
    ),
  );
}

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: widget.route.stops.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeader();
              return _buildTimelineItem(index - 1);
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Your Journey", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _exportToGoogleMaps,
              icon: const Icon(Icons.directions_walk, size: 18),
              label: const Text("GO"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTimelineItem(int index) {
    final stop = widget.route.stops[index];
    final isLast = index == widget.route.stops.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.circle, color: Colors.teal, size: 12),
            if (!isLast) ...[
              Container(width: 2, height: 40, color: Colors.teal.withOpacity(0.2)),
              // Display the Google-fetched distance here!
              if (!_isLoadingData && _legDistances.containsKey(index))
                RotatedBox(quarterTurns: 1, child: Text(" ${_legDistances[index]} ", style: const TextStyle(fontSize: 9, color: Colors.teal, fontWeight: FontWeight.bold))),
              Container(width: 2, height: 40, color: Colors.teal.withOpacity(0.2)),
            ]
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stop.place.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),// Small gap between name and metadata
              // Row for Icon and Time
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    "${stop.scheduledTime.hour.toString().padLeft(2, '0')}:${stop.scheduledTime.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12), // Gap before category
                  
                  // Category Badge/Text
                  Text(
                    stop.place.category,
                    style: TextStyle(
                      color: Colors.grey[400], 
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}