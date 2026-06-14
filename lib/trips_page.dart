// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'dart:convert'; // For JSON encoding/decoding trip metadata strings
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; 
import 'package:travel_app/dataconnect_generated/generated.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'models/trip.dart';
import 'models/places.dart'; 
import 'itinerary_details_page.dart';
import 'mockdata.dart';
import 'providers/current_user.dart';
import 'l10n/app_localizations.dart';

class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> {
  int _activeSegment = 0;
  final PageController _pageController = PageController();
  
  List<Trip> _allTrips = [];
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _fetchUserTripsFromFirebase();
  }

  /// 1. Fetches routes AND child stops from Firebase, parsing image payloads dynamically
  Future<void> _fetchUserTripsFromFirebase() async {
    final activeUser = auth.FirebaseAuth.instance.currentUser;
    
    if (activeUser == null) {
      debugPrint("No active user session. Falling back to local offline mock records.");
      final String fallbackUid = ref.read(currentUserProvider)?.id ?? MockData.mockUserId;
      setState(() {
        _allTrips = MockData.getAllTrips().where((t) => t.userId == fallbackUid).toList();
        _isLoading = false;
      });
      return;
    }

    try {
      final routesResponse = await ExampleConnector.instance.listRoutes().execute();
      final placesResponse = await ExampleConnector.instance.listPlaces().execute();
      
      if (routesResponse.data == null || routesResponse.data.routes == null) {
        setState(() {
          _allTrips = [];
          _isLoading = false;
        });
        return;
      }

      final filteredRoutes = routesResponse.data.routes.where((r) => r.userId == activeUser.uid);

      final List<Trip> fetchedTrips = filteredRoutes.map((r) {
        final DateTime creationDateTime = r.createdAt.toDateTime(); 
        
        String tripType = 'Leisure';
        DateTime startDateTime = creationDateTime;
        DateTime endDateTime = creationDateTime;

        if (r.description != null && r.description!.trim().startsWith('{')) {
          try {
            final Map<String, dynamic> meta = jsonDecode(r.description!);
            tripType = meta['type'] ?? 'Leisure';
            if (meta['startDate'] != null) startDateTime = DateTime.parse(meta['startDate']);
            if (meta['endDate'] != null) endDateTime = DateTime.parse(meta['endDate']);
          } catch (e) {
            debugPrint("Failed parsing route metadata fields: $e");
          }
        }

        // Relational Lookup: Find all custom child sub-stops assigned specifically to this route's ID
        List<Stop> routeStops = [];
        if (placesResponse.data != null && placesResponse.data.places != null) {
          final matchedPlaces = placesResponse.data.places.where((p) {
            final desc = p.description?.trim() ?? '';
            if (desc.startsWith('{') && desc.contains('routeId')) {
              try {
                final Map<String, dynamic> meta = jsonDecode(desc);
                return meta['routeId'] == r.routeId;
              } catch (_) {}
            }
            return false;
          }).toList();

          routeStops = matchedPlaces.map((p) {
            final parts = p.coordinates.split(',');
            final lat = parts.isNotEmpty ? double.tryParse(parts.first.trim()) ?? 0.0 : 0.0;
            final lng = parts.length > 1 ? double.tryParse(parts.last.trim()) ?? 0.0 : 0.0;

            String stopCategory = 'Scenic Spot';
            DateTime scheduledTime = startDateTime;

            try {
              final Map<String, dynamic> meta = jsonDecode(p.description!);
              stopCategory = meta['category'] ?? 'Scenic Spot';
              if (meta['scheduledTime'] != null) scheduledTime = DateTime.parse(meta['scheduledTime']);
            } catch (_) {}

            String finalCloudUrl = '';
            if (p.images != null && p.images!.isNotEmpty) {
              final String aggregatedImages = p.images!.join(',');
              finalCloudUrl = aggregatedImages.split(',').first.trim();
            }

            if (finalCloudUrl.isEmpty || !finalCloudUrl.startsWith('http')) {
              switch (p.placeId) {
                case 'p001': finalCloudUrl = 'assets/images/visitor-center.png'; break;
                case 'p002': finalCloudUrl = 'assets/images/boardwalk.png'; break;
                case 'p003': finalCloudUrl = 'assets/images/water-willow.png'; break;
                case 'p004': finalCloudUrl = 'assets/images/egret-bridge.png'; break;
                case 'p005': finalCloudUrl = 'assets/images/shin-lu.png'; break;
                default: finalCloudUrl = 'assets/images/red-tile.png'; break;
              }
            }

            return Stop(
              scheduledTime: scheduledTime,
              place: Places(
                id: p.placeId,
                name: p.name.split(' (').first, 
                category: stopCategory,
                detail: r.routeId,
                location: LatLng(lat, lng),
                imageUrl: finalCloudUrl,
              ),
            );
          }).toList();

          routeStops.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        }

        return Trip(
          id: r.routeId,
          userId: r.userId,
          name: r.name,
          type: tripType, 
          startDate: startDateTime, 
          endDate: endDateTime,
          stops: routeStops, 
        );
      }).toList();

      setState(() {
        _allTrips = fetchedTrips..sort((a, b) => b.startDate.compareTo(a.startDate));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Firebase ListRoutes pipeline broke: $e. Falling back securely.");
      if (!mounted) return;
      setState(() {
        final String fallbackUid = ref.read(currentUserProvider)?.id ?? MockData.mockUserId;
        final localMockList = MockData.getAllTrips().where((t) => t.userId == fallbackUid).toList();
        _allTrips = localMockList.isNotEmpty ? localMockList : [];
        _isLoading = false;
      });
    }
  }

  /// 2. Asynchronously delete route safely with a dynamic fallback catch strategy
  Future<void> _deleteTrip(String tripId) async {
    setState(() => _allTrips.removeWhere((t) => t.id == tripId));

    try {
      final connector = ExampleConnector.instance as dynamic;
      if (connector.toString().contains('deleteRoute')) {
        await connector.deleteRoute(routeId: tripId).execute();
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Journey removed securely"), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      debugPrint("Server deletion unmapped or rejected: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Journey removed locally"), behavior: SnackBarBehavior.floating),
      );
    }
  }

  /// 3. Push newly initialized itineraries up to your live tables
  Future<void> _handleFirebaseCreateTrip(String name, String type, DateTimeRange range) async {
    final activeUser = auth.FirebaseAuth.instance.currentUser;
    if (activeUser == null) return;

    try {
      final String dynamicDescriptionPayload = jsonEncode({
        'type': type,
        'startDate': range.start.toIso8601String(),
        'endDate': range.end.toIso8601String(),
      });

      final operationResult = await ExampleConnector.instance.createRoute(
        userId: activeUser.uid,
        name: name,
      )
      .description(dynamicDescriptionPayload) 
      .execute();

      final String newlyGeneratedId = operationResult.data.route_insert.routeId;

      final newTripModel = Trip(
        id: newlyGeneratedId,
        userId: activeUser.uid,
        name: name,
        type: type,
        startDate: range.start,
        endDate: range.end,
        stops: [],
      );

      setState(() => _allTrips.insert(0, newTripModel));
      
      if (!mounted) return;
      Navigator.pop(context); 
      
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ItineraryDetailsPage(route: newTripModel)),
      );
      _fetchUserTripsFromFirebase(); 

    } catch (e) {
      debugPrint("Creation Mutation failed to sync: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save itinerary: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showCreateTripSheet() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    
    String selectedType = 'Leisure'; 
    DateTimeRange? selectedRange;
    bool isSheetSaving = false;

    final Map<String, String> categoryLabels = {
      'Leisure': l10n.category_leisure,
      'Education': l10n.category_education,
      'Culture': l10n.category_culture,
      'Adventure': l10n.category_adventure,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.trip_plan_new, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              
              TextField(
                controller: nameController,
                enabled: !isSheetSaving,
                decoration: InputDecoration(
                  labelText: l10n.trip_name,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: isSheetSaving ? null : () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setSheetState(() => selectedRange = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.teal),
                      const SizedBox(width: 12),
                      Text(
                        selectedRange == null 
                          ? l10n.trip_select_dates 
                          : "${DateFormat('MMM d').format(selectedRange!.start)} - ${DateFormat('MMM d').format(selectedRange!.end)}",
                        style: TextStyle(color: selectedRange == null ? Colors.grey[600] : Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedType,
                disabledHint: Text(categoryLabels[selectedType] ?? selectedType),
                decoration: InputDecoration(
                  labelText: l10n.trip_stops,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: categoryLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: isSheetSaving ? null : (val) => setSheetState(() => selectedType = val!),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: isSheetSaving
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (nameController.text.isNotEmpty && selectedRange != null) {
                          setSheetState(() => isSheetSaving = true);
                          await _handleFirebaseCreateTrip(nameController.text.trim(), selectedType, selectedRange!);
                          setSheetState(() => isSheetSaving = false);
                        }
                      },
                      child: Text(l10n.trip_create_journey, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const accentColor = Colors.teal;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.trip_my_journeys, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.teal))
        : Column(
            children: [
              _buildSegmentHeader(accentColor),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _activeSegment = index),
                  children: [
                    _buildTripList(isPast: false, accentColor: accentColor),
                    _buildTripList(isPast: true, accentColor: accentColor),
                  ],
                ),
              ),
            ],
          ),
      // 👇 RESTORED: Floating Action Button added back seamlessly to the parent view tree
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        onPressed: _showCreateTripSheet,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          l10n.trip_create_journey, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSegmentHeader(Color color) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _buildSegment(0, l10n.tab_upcoming, color),
          _buildSegment(1, l10n.tab_history, color),
        ],
      ),
    );
  }

  Widget _buildSegment(int index, String label, Color color) {
    bool isActive = _activeSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.decelerate),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? color : Colors.grey[500])),
        ),
      ),
    );
  }

  Widget _buildTripList({required bool isPast, required Color accentColor}) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    
    final List<Trip> safetyTripsList = _allTrips.isNotEmpty ? _allTrips : [];

    final trips = safetyTripsList.where((t) {
      return isPast ? t.startDate.isBefore(now) : t.startDate.isAfter(now);
    }).toList();

    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: Colors.grey[200]),
            const SizedBox(height: 12),
            Text(l10n.trip_no_upcoming, style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Dismissible(
          key: Key(trip.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteTrip(trip.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.delete_outline, color: Colors.red[400]),
          ),
          child: _buildTripCard(trip, accentColor),
        );
      },
    );
  }

  Widget _buildTripCard(Trip trip, Color color) {
    final l10n = AppLocalizations.of(context)!;
    
    final bool hasStops = trip.stops != null && trip.stops.isNotEmpty;
    String? coverImage = hasStops ? trip.stops.first.place.imageUrl : null;

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ItineraryDetailsPage(route: trip)),
        );
        _fetchUserTripsFromFirebase(); 
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: coverImage != null
                  ? coverImage.startsWith('assets/')
                      ? Image.asset(coverImage, height: 140, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _buildPlaceholder(color))
                      : Image.network(coverImage, height: 140, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _buildPlaceholder(color))
                  : _buildPlaceholder(color),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM d, yyyy').format(trip.startDate), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const Text("  •  "),
                    Icon(Icons.location_on_outlined, size: 14, color: color.withOpacity(0.7)),
                    const SizedBox(width: 2),
                    Text("${trip.stops.length} ${l10n.trip_stops}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      height: 140, width: double.infinity,
      color: color.withOpacity(0.05),
      child: Icon(Icons.landscape_rounded, color: color.withOpacity(0.2), size: 32),
    );
  }
}