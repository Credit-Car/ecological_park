// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart' as ll; 
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_app/dataconnect_generated/generated.dart'; 
import 'models/trip.dart'; 
import 'models/places.dart';
import 'mockdata.dart';
import 'l10n/app_localizations.dart';

class ItineraryDetailsPage extends StatefulWidget {
  final Trip route;
  const ItineraryDetailsPage({super.key, required this.route});

  @override
  State<ItineraryDetailsPage> createState() => _ItineraryDetailsPageState();
}

class _ItineraryDetailsPageState extends State<ItineraryDetailsPage> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final MapController _mapController = MapController();
  
  Map<int, String> _legDistances = {}; 
  bool _isLoadingData = true;
  List<Stop> _liveStops = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRouteStops();
  }

  /// 1. Straightforward Local Loading: Reads stops directly from the route object reference
  void _loadSavedRouteStops() {
    if (widget.route.stops != null) {
      _liveStops = List<Stop>.from(widget.route.stops);
    }
    _zoomToFitStops();
    _fetchGoogleRouteData();
  }

  void _zoomToFitStops() {
    if (_liveStops.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(const ll.LatLng(23.65775, 121.40966), 15.5);
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final List<ll.LatLng> mapPoints = _liveStops.map((stop) {
        return ll.LatLng(stop.place.location.latitude, stop.place.location.longitude);
      }).toList();

      final bounds = LatLngBounds.fromPoints(mapPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    });
  }

/// 2. Pull official spots from backend, filtering out custom itinerary entries safely
  Future<void> _showAddStopDialog() async {
    setState(() => _isLoadingData = true);
    List<Map<String, dynamic>> officialParkPlaces = [];

    try {
      final res = await ExampleConnector.instance.listPlaces().execute();
      
      final isolatedOfficialLandmarks = res.data.places.where((e) {
        final String desc = e.description?.trim() ?? '';
        final String currentId = e.placeId.toLowerCase();

        if (desc.contains('routeId:')) return false;
        if (currentId.contains('_')) return false;
        return true; 
      }).toList();

      for (var e in isolatedOfficialLandmarks) {
        final parts = e.coordinates.split(',');
        final lat = parts.isNotEmpty ? double.tryParse(parts.first.trim()) ?? 23.65775 : 23.65775;
        final lng = parts.length > 1 ? double.tryParse(parts.last.trim()) ?? 121.40966 : 121.40966;

        String assignedCategory = 'Scenic Spot';
        switch (e.placeId) {
          case 'p001': assignedCategory = 'Facility'; break;
          case 'p002': assignedCategory = 'Wildlife'; break;
          case 'p005':
          case 'p006': assignedCategory = 'Culture'; break;
          default: assignedCategory = 'Scenic Spot'; break;
        }

        officialParkPlaces.add({
          'id': e.placeId,
          'name': e.name,
          'category': assignedCategory,
          'lat': lat,
          'lng': lng,
        });
      }
    } catch (e) {
      debugPrint("Firebase lookup offline, using native fallback templates: $e");
      for (var item in MockData.availablePlaces) {
        officialParkPlaces.add({
          'id': item.id,
          'name': item.name,
          'category': item.category,
          'lat': item.location.latitude,
          'lng': item.location.longitude,
        });
      }
    } finally {
      setState(() => _isLoadingData = false);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) { // Use a distinct context name for the dialog frame layout
        TimeOfDay selectedTime = TimeOfDay.now();
        bool isDialogSaving = false;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Add Official Stop', style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setDialogState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select an official destination to add:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 12),
                  
                  Container(
                    height: 200,
                    width: double.maxFinite,
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
                    child: isDialogSaving
                        ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                        : officialParkPlaces.isEmpty
                            ? const Center(child: Text('No landmarks found', style: TextStyle(fontSize: 13, color: Colors.grey)))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: officialParkPlaces.length,
                                itemBuilder: (context, i) {
                                  final p = officialParkPlaces[i];
                                  return ListTile(
                                    title: Text(p['name'].toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    subtitle: Text(p['category'].toString(), style: const TextStyle(fontSize: 11, color: Colors.teal)),
                                    trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.teal, size: 20),
                                    onTap: isDialogSaving ? null : () async {
                                      final now = DateTime.now();
                                      final finalStopDateTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

                                      // 1. Immediately toggle the local state before triggering any async database actions
                                      setDialogState(() => isDialogSaving = true);

                                      try {
                                        final String formattedNameWithId = "${p['name']} (${widget.route.name})";
                                        
                                        final operationResult = await ExampleConnector.instance.createPlace(
                                          name: formattedNameWithId,
                                          coordinates: "${p['lat']},${p['lng']}",
                                        )
                                        .description('{"routeId":"${widget.route.id}","scheduledTime":"${finalStopDateTime.toIso8601String()}","category":"${p['category']}"}') 
                                        .execute();

                                        final String newGeneratedId = operationResult.data.place_insert.placeId;

                                        final newStopItem = Stop(
                                          scheduledTime: finalStopDateTime,
                                          place: Places(
                                            id: newGeneratedId, 
                                            name: p['name'].toString(),
                                            category: p['category'].toString(),
                                            detail: widget.route.id, 
                                            location: LatLng(p['lat'] as double, p['lng'] as double),
                                            imageUrl: '',
                                          ),
                                        );

                                        // 2. Clear out dialog stack securely *before* mutating the parent screen's state
                                        Navigator.pop(dialogContext);

                                        // 3. Update parent page structures safely
                                        if (mounted) {
                                          setState(() {
                                            _liveStops.add(newStopItem);
                                            _liveStops.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
                                            
                                            widget.route.stops
                                              ..clear()
                                              ..addAll(_liveStops);
                                          });

                                          _zoomToFitStops();
                                          _fetchGoogleRouteData();
                                        }

                                      } catch (e) {
                                        debugPrint("Failed saving custom stop entry row: $e");
                                        // Reset state flag safely if it fails so the user can try again
                                        setDialogState(() => isDialogSaving = false);
                                        
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Firebase Insertion Error: $e'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    tileColor: Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(Icons.access_time_filled_rounded, color: Colors.teal),
                    title: const Text('Arrival Time', style: TextStyle(fontSize: 14)),
                    trailing: Text(selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    onTap: isDialogSaving ? null : () async {
                      final tod = await showTimePicker(context: context, initialTime: selectedTime);
                      if (tod != null) setDialogState(() => selectedTime = tod);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 3. Wipe stops locally and trigger dynamic cloud cleanups on the matching row item
  void _deleteStopLocally(int index) async {
    final targetStop = _liveStops[index];
    
    setState(() {
      _liveStops.removeAt(index);
      _legDistances.remove(index);

      widget.route.stops
        ..clear()
        ..addAll(_liveStops);
    });

    _zoomToFitStops();
    _fetchGoogleRouteData();

    try {
      final connector = ExampleConnector.instance as dynamic;
      if (connector.toString().contains('delete_place')) {
        await connector.delete_place(placeId: targetStop.place.id).execute();
      }
    } catch (e) {
      debugPrint("Remote cleanup call skipped: $e");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stop removed from itinerary'), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _fetchGoogleRouteData() async {
    if (_liveStops.length < 2) {
      setState(() => _isLoadingData = false);
      return;
    }

    const String apiKey = 'AIzaSyA311vNSU51Bmatl-h9OPEQNT-isyeoLiw';
    final origin = "${_liveStops.first.place.location.latitude},${_liveStops.first.place.location.longitude}";
    final destination = "${_liveStops.last.place.location.latitude},${_liveStops.last.place.location.longitude}";
    
    String waypoints = "";
    if (_liveStops.length > 2) {
      final pts = _liveStops
          .sublist(1, _liveStops.length - 1)
          .map((s) => "${s.place.location.latitude},${s.place.location.longitude}").join('|');
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
          Map<int, String> newDistances = {};
          for (int i = 0; i < legs.length; i++) {
            newDistances[i] = legs[i]['distance']['text'];
          }
          setState(() {
            _legDistances = newDistances;
          });
        }
      }
    } catch (e) {
      debugPrint("Google API Pipeline Exception: $e");
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _exportToGoogleMaps() async {
    if (_liveStops.isEmpty) return;
    final origin = _liveStops.first.place;
    final destination = _liveStops.last.place;
    final pts = _liveStops.sublist(1, _liveStops.length - 1)
        .map((s) => "${s.place.location.latitude},${s.place.location.longitude}").join('|');

    final url = 'https://www.google.com/maps/dir/?api=1'
        '&origin=${origin.location.latitude},${origin.location.longitude}'
        '&destination=${destination.location.latitude},${destination.location.longitude}'
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
        backgroundColor: Colors.white.withValues(alpha: 0.8),
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
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const ll.LatLng(23.65775, 121.40966),
              initialZoom: 15.5,
              minZoom: 12.0,
              maxZoom: 19.0,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const ll.LatLng(23.64, 121.39),
                  const ll.LatLng(23.67, 121.43),
                ),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ndhu.travelapp',
              ),
              if (_liveStops.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _liveStops.map((s) => ll.LatLng(s.place.location.latitude, s.place.location.longitude)).toList(),
                      color: Colors.teal.withValues(alpha: 0.6),
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
              if (_liveStops.isNotEmpty)
                MarkerLayer(
                  markers: _liveStops.map((stop) {
                    return Marker(
                      point: ll.LatLng(stop.place.location.latitude, stop.place.location.longitude),
                      width: 37, 
                      height: 47,
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/images/markers/marker.png',
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.location_on, color: Colors.teal, size: 38);
                        },
                      ),
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
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, spreadRadius: 2)],
          ),
          child: ListView.builder(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            itemCount: _liveStops.length + 1,
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
        Container(width: 44, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.trip_your_journey, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            Row(
              children: [
                IconButton(
                  onPressed: _showAddStopDialog, 
                  icon: const Icon(Icons.add_location_alt_rounded, color: Colors.teal, size: 26),
                  tooltip: "Add Stop",
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _exportToGoogleMaps,
                  icon: const Icon(Icons.directions_walk, size: 16),
                  label: Text(AppLocalizations.of(context)!.trip_go, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTimelineItem(int index) {
    final stop = _liveStops[index];
    final isLast = index == _liveStops.length - 1;

    return Dismissible(
      key: Key('${stop.place.id}_${stop.scheduledTime.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 24),
      ),
      onDismissed: (_) => _deleteStopLocally(index), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.lens, color: Colors.teal, size: 10),
              ),
              if (!isLast) ...[
                Container(width: 2, height: 25, color: Colors.teal.withOpacity(0.15)),
                if (!_isLoadingData && _legDistances.containsKey(index))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        "${_legDistances[index]}", 
                        style: const TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Container(width: 2, height: 25, color: Colors.teal.withOpacity(0.15)),
              ]
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      "${stop.scheduledTime.hour.toString().padLeft(2, '0')}:${stop.scheduledTime.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12), 
                    Text(
                      stop.place.category, 
                      style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}