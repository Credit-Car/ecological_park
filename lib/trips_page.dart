import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/trip.dart';
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
  late List<Trip> _allTrips;

  @override
  void initState() {
    super.initState();
    _syncWithMockData();
  }

  void _syncWithMockData() {
    final currentUser = ref.read(currentUserProvider);
    final String uid = currentUser?.id ?? MockData.mockUserId;

    _allTrips = MockData.getAllTrips()
        .where((t) => t.userId == uid)
        .toList();
  }

  void _deleteTrip(String tripId) {
    setState(() => _allTrips.removeWhere((t) => t.id == tripId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Journey removed"),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
      ),
    );
  }

  void _showCreateTripSheet() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    
    //  FIX 1: Keep the backend key value generic/constant ('Leisure')
    String selectedType = 'Leisure'; 
    DateTimeRange? selectedRange;

    // Define a map matching raw backend database keys to localized display labels
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
              Text(l10n.trip_plan_new, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.trip_name,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async {
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

              //  FIX 2: Match raw selection keys to localized display text
              DropdownButtonFormField<String>(
                value: selectedType, // Initial constant key 'Leisure'
                decoration: InputDecoration(
                  labelText: l10n.trip_stops,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: categoryLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,          // Backend value ('Leisure', 'Culture')
                    child: Text(entry.value),  // Localized visible label ("休閒活動", "文化體驗")
                  );
                }).toList(),
                onChanged: (val) => setSheetState(() => selectedType = val!),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty && selectedRange != null) {
                      final newTrip = Trip(
                        id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
                        userId: ref.read(currentUserProvider)?.id ?? MockData.mockUserId,
                        name: nameController.text.trim(),
                        type: selectedType, // Saves the structured language key safely
                        startDate: selectedRange!.start,
                        endDate: selectedRange!.end,
                        stops: [], 
                      );
                      
                      setState(() => _allTrips.insert(0, newTrip));
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ItineraryDetailsPage(route: newTrip)),
                      );
                    }
                  },
                  child: Text(l10n.trip_create_journey, 
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
        title: Text(l10n.trip_my_journeys, 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        onPressed: _showCreateTripSheet,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(l10n.trip_create_journey, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSegmentHeader(Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _buildSegment(0, AppLocalizations.of(context)!.tab_upcoming, color),
          _buildSegment(1, AppLocalizations.of(context)!.tab_history, color),
        ],
      ),
    );
  }

  Widget _buildSegment(int index, String label, Color color) {
    bool isActive = _activeSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _pageController.animateToPage(index, 
            duration: const Duration(milliseconds: 300), curve: Curves.decelerate),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isActive ? color : Colors.grey[500])),
        ),
      ),
    );
  }

  Widget _buildTripList({required bool isPast, required Color accentColor}) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final trips = _allTrips.where((t) {
      return isPast ? t.startDate.isBefore(now) : t.startDate.isAfter(now);
    }).toList();

    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: Colors.grey[200]),
            const SizedBox(height: 12),
            Text(l10n.trip_no_upcoming, 
              style: TextStyle(color: Colors.grey[400])),
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
    String? coverImage = trip.stops.isNotEmpty ? trip.stops.first.place.imageUrl : null;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ItineraryDetailsPage(route: trip)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: coverImage != null
                  ? Image.asset(coverImage, height: 120, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _buildPlaceholder(color))
                  : _buildPlaceholder(color),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM d').format(trip.startDate), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const Text("  •  "),
                    // Localized Stops dynamic context handling
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
      height: 120, width: double.infinity,
      color: color.withValues(alpha: 0.05),
      child: Icon(Icons.landscape_rounded, color: color.withValues(alpha: 0.2), size: 32),
    );
  }
}