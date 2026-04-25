import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final DraggableScrollableController _sheetController = DraggableScrollableController();

String _getStaticMapUrl() {
  if (widget.route.stops.isEmpty) return "";

  //const String navyColor = "0x000080";
  const String apiKey = 'AIzaSyA311vNSU51Bmatl-h9OPEQNT-isyeoLiw';

  String path = "path=color:red|weight:5";
  for (var stop in widget.route.stops) {
    path += "|${stop.place.lat},${stop.place.lng}";
  }

  String markers = "markers=color:red|size:small";
  for (var stop in widget.route.stops) {
    markers += "|${stop.place.lat},${stop.place.lng}";
  }
  
  return "https://maps.googleapis.com/maps/api/staticmap?"
      "size=800x1200&"
      "scale=2&" // High-DPI for mobile web
      "maptype=roadmap&"
      "$path&"
      "$markers&"
      "key=$apiKey";
}

  Future<void> _exportToGoogleMaps() async {
    if (widget.route.stops.isEmpty) return;

    final origin = widget.route.stops.first.place;
    final destination = widget.route.stops.last.place;
    
    String waypoints = "";
    if (widget.route.stops.length > 2) {
      waypoints = "&waypoints=" + widget.route.stops
          .sublist(1, widget.route.stops.length - 1)
          .map((s) => "${s.place.lat},${s.place.lng}")
          .join('|');
    }

    final url = 'https://www.google.com/maps/dir/?api=1'
        '&origin=${origin.lat},${origin.lng}'
        '&destination=${destination.lat},${destination.lng}'
        '$waypoints'
        '&travelmode=walking';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _navigateToAddStop() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTripStopPage(
          trip: widget.route,
          availablePlaces: MockData.availablePlaces,
        ),
      ),
    );
    if (result == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.route.name, 
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900)),
      ),
      body: Stack(
        children: [
          // MINIMALIST MAP BACKGROUND
          Positioned.fill(
            child: Image.network(
              _getStaticMapUrl(),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: Colors.white, child: const Center(child: CircularProgressIndicator(color: Colors.teal)));
              },
              errorBuilder: (context, e, s) => Container(color: Colors.teal.shade50, child: const Icon(Icons.map_outlined, size: 48, color: Colors.teal)),
            ),
          ),

          // DRAGGABLE ITINERARY
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.4,
            minChildSize: 0.15,
            maxChildSize: 1.0,
            snap: true,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
                ),
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                  itemCount: widget.route.stops.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildSheetHeader();
                    return _buildModernTimelineItem(index - 1);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Column(
      children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Trip Plan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            Row(
              children: [
                IconButton(onPressed: _navigateToAddStop, icon: const Icon(Icons.add_circle_outline, color: Colors.teal, size: 28)),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _exportToGoogleMaps,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.directions_walk, size: 18),
                  label: const Text("GO", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildModernTimelineItem(int index) {
    final stop = widget.route.stops[index];
    final isLast = index == widget.route.stops.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match the Map's Dot Style
        Column(
          children: [
            Container(
              width: 12, height: 12,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
            ),
            if (!isLast) Container(width: 2, height: 80, color: Colors.teal.shade50),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(stop.place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    Text(DateFormat('h:mm a').format(stop.scheduledTime), style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(stop.place.category.toUpperCase(), style: const TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                const SizedBox(height: 10),
                Text(stop.customNotes ?? stop.place.detail, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}