import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/trip.dart';
import 'itinerary_details_page.dart';
import 'mockdata.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  int _activeSegment = 0;
  final PageController _pageController = PageController();

  final List<Trip> _allTrips = [
    Trip(
      id: 'u1',
      name: 'NDHU Library Visit',
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 3, 15),
      type: 'Study',
      stops: MockData.getAllTrips()[0].stops,
    ),
    Trip(
      id: 'p1',
      name: 'Solar Farm Expo',
      startDate: DateTime(2025, 12, 20),
      endDate: DateTime(2025, 12, 21),
      type: 'Leisure',
      stops: MockData.getAllTrips()[1].stops,
    ),
  ];

  // Create Trip Modal Sheet
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Plan New Journey", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              
              // Trip Name Input
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Trip Name",
                  hintText: "e.g. Hiking in Hualien",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Date Selection
              InkWell(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime(2030),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.teal)),
                      child: child!,
                    ),
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
                        style: TextStyle(color: selectedRange == null ? Colors.grey[600] : Colors.black, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: "Category",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: ['Leisure', 'Business', 'Study', 'Adventure']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setSheetState(() => selectedType = val!),
              ),
              const SizedBox(height: 32),

              // Create & Navigate Button
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
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        type: selectedType,
                        startDate: selectedRange!.start,
                        endDate: selectedRange!.end,
                        stops: [], 
                      );
                      
                      setState(() => _allTrips.add(newTrip));
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

  void _deleteTrip(String tripId) {
    setState(() => _allTrips.removeWhere((t) => t.id == tripId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Trip removed"), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Colors.teal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Journeys", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildSegmentHeader(primaryTeal),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeSegment = index),
              children: [
                _buildTripList(isPast: false, accentColor: primaryTeal),
                _buildTripList(isPast: true, accentColor: primaryTeal),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryTeal,
        onPressed: _showCreateTripSheet,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSegmentHeader(Color primaryTeal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _buildSegment(0, 'Upcoming', primaryTeal),
          _buildSegment(1, 'Past', primaryTeal),
        ],
      ),
    );
  }

  Widget _buildTripList({required bool isPast, required Color accentColor}) {
    final now = DateTime.now();
    final trips = _allTrips.where((t) {
      return isPast ? t.startDate.isBefore(now) : t.startDate.isAfter(now);
    }).toList();

    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No ${isPast ? 'past' : 'upcoming'} trips found", 
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Dismissible(
          key: Key(trip.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteTrip(trip.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 25),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
          ),
          child: _buildTripCard(trip, isPast, accentColor),
        );
      },
    );
  }

Widget _buildTripCard(Trip trip, bool isPast, Color accentColor) {
  String? coverImageUrl;
  if (trip.stops.isNotEmpty) {
    coverImageUrl = trip.stops.first.place.imageUrl;
  }

  return GestureDetector(
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ItineraryDetailsPage(route: trip)),
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: coverImageUrl != null
                ? Image.asset(
                    coverImageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => _buildPlaceholder(accentColor),
                  )
                : _buildPlaceholder(accentColor),
          ),
          
          ListTile(
            title: Text(
              trip.name, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
            ),
            subtitle: Row(
              children: [
                Text("${trip.type} • "),
                if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "COMPLETED",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text("${trip.stops.length} Stops Planned"),
              ],
            ),
            trailing: Icon(
              Icons.chevron_right_rounded, 
              color: Colors.grey.shade400
            ),
          ),
        ],
      ),
    ),
  );
}

// Placeholder
Widget _buildPlaceholder(Color accentColor) {
  return Container(
    height: 140,
    width: double.infinity,
    color: accentColor.withValues(alpha: 0.1),
    child: Icon(Icons.add_photo_alternate_outlined, color: accentColor.withValues(alpha: 0.4), size: 40),
  );
}

  Widget _buildSegment(int index, String label, Color activeColor) {
    bool isActive = _activeSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _pageController.animateToPage(index, 
            duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? activeColor : Colors.grey[500])),
        ),
      ),
    );
  }
}