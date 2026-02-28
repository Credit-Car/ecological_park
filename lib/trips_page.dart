import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/trip.dart';
import 'itinerary_details_page.dart';

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
      destination: 'NDHU Library',
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 3, 15),
      durationDays: 5,
      type: 'Study',
      imageUrl: 'assets/images/ndhu_library.png',
    ),
    Trip(
      id: 'p1',
      destination: 'Solar Farm',
      startDate: DateTime(2025, 12, 20),
      endDate: DateTime(2025, 12, 21),
      durationDays: 1,
      type: 'Leisure',
      imageUrl: 'assets/images/solar_farm.png', 
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Primary Teal Color Scheme
    const primaryTeal = Colors.teal;
    //const lightTeal = Color(0xFFE0F2F1); // Teal 50

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 54,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildSegment(0, 'Upcoming', primaryTeal),
                _buildSegment(1, 'Past Trips', primaryTeal),
              ],
            ),
          ),
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
        onPressed: () {},
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Trip', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)
        ),
      ),
    );
  }

  Widget _buildSegment(int index, String label, Color activeColor) {
    bool isActive = _activeSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(index, 
              duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive 
                ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))] 
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isActive ? activeColor : Colors.blueGrey[400],
            ),
          ),
        ),
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
            Text(
              "No ${isPast ? 'past' : 'upcoming'} adventures yet!",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(trip, isPast, accentColor);
      },
    );
  }

  Widget _buildTripCard(Trip trip, bool isPast, Color accentColor) {
    return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ItineraryDetailsPage(route: trip),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06), 
            blurRadius: 20, 
            offset: const Offset(0, 12)
          )
        ],
      ),
      child: Column(
        children: [
          Hero(
            tag: 'trip_image_${trip.id}',
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.asset(
                trip.imageUrl, 
                height: 170, 
                width: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 170,
                  color: Colors.teal[50],
                  child: Icon(Icons.landscape_rounded, color: accentColor.withOpacity(0.3), size: 48),
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
            title: Text(
              trip.destination, 
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.5)
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                DateFormat('EEEE, MMM dd').format(trip.startDate),
                style: TextStyle(color: Colors.blueGrey[600], fontWeight: FontWeight.w500),
              ),
            ),
            trailing: isPast 
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'COMPLETED', 
                    style: TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    shape: BoxShape.circle,
                  ),
                child: Icon(Icons.chevron_right_rounded, color: accentColor),
              ),
          )
        ],
      ),
    ),
    );
  }
}