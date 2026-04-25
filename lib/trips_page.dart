import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/trip.dart';
import 'itinerary_details_page.dart';
import 'mockdata.dart';
import 'providers/current_user.dart';

class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> {
  int _activeSegment = 0;
  final PageController _pageController = PageController();
  
  // This will hold our local state of trips during the session
  late List<Trip> _allTrips;

  @override
  void initState() {
    super.initState();
    _syncWithMockData();
  }

  /// Loads trips from mockdata.dart filtered by the current user
  void _syncWithMockData() {
    final currentUser = ref.read(currentUserProvider);
    // Use the mockUserId from your file if the provider is null (for testing)
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
    final nameController = TextEditingController();
    String selectedType = 'Leisure';
    DateTimeRange? selectedRange;

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
              const Text("Plan New Journey", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Trip Name",
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
                          ? "Select Dates" 
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
                decoration: InputDecoration(
                  labelText: "Category",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: ['Leisure', 'Education', 'Culture', 'Adventure']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
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
                        type: selectedType,
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
                  child: const Text("Create Journey", 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    const accentColor = Colors.teal;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Journeys", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1)),
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
        label: const Text('Plan New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          _buildSegment(0, 'Upcoming', color),
          _buildSegment(1, 'History', color),
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
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
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
    final now = DateTime.now();
    // Filter trips based on time and the data from MockData
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
            Text("No ${isPast ? 'past' : 'upcoming'} journeys", 
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
    // Dynamically pull the image from the first stop in MockData
    String? coverImage = trip.stops.isNotEmpty ? trip.stops.first.place.imageUrl : null;

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
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
                    Text("${trip.stops.length} Stops", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
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
      color: color.withOpacity(0.05),
      child: Icon(Icons.landscape_rounded, color: color.withOpacity(0.2), size: 32),
    );
  }
}