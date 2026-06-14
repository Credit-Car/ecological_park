import '../models/places.dart';
import '../models/trip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import to provide the unified LatLng model

class MockData {
  static const String mockUserId = 'user_999';

  static final List<Places> availablePlaces = [
    Places(
      id: 'p001',
      name: 'Visitor Service Center',
      category: '園區設施',
      detail: 'Introduction to the geographical location and regional context by the Township Office and Agriculture & Tourism Section.',
      location: const LatLng(23.6579, 121.4095), // FIX: Mapped to your updated unified LatLng object type
      imageUrl: 'assets/images/visitor-center.jpg',
    ),
    Places(
      id: 'p002',
      name: 'Wooden Boardwalk Area',
      category: '自然景觀t',
      detail: 'Wetland ecology interpretation area with rich biodiversity and walking paths.',
      location: const LatLng(23.6585, 121.4102), // FIX: Resolved missing parameter keys and converted structure
      imageUrl: 'assets/images/boardwalk.jpg',
    ),
    Places(
      id: 'p003',
      name: 'Water Willow Area',
      category: 'Wildlife',
      detail: 'Habitat for fireflies and aquatic plants; learn about firefly ecology.',
      location: const LatLng(23.6590, 121.4108),
      imageUrl: 'assets/images/water-willow.png',
    ),
    Places(
      id: 'p004',
      name: 'Egret Bridge',
      category: 'Scenic Spot',
      detail: 'Overview of the Fudeng Creek watershed and surrounding wetland environment.',
      location: const LatLng(23.6582, 121.4098),
      imageUrl: 'assets/images/egret-bridge.jpg',
    ),
    Places(
      id: 'p005',
      name: 'Shin-Lu Farm',
      category: 'Culture',
      detail: 'Experience Barago fishing culture and local indigenous way of life.',
      location: const LatLng(23.6573, 121.4089),
      imageUrl: 'assets/images/shin-lu.jpg',
    ),
    Places(
      id: 'p006',
      name: 'Red Tile House',
      category: 'Culture',
      detail: 'Waterside dining experience showcasing slow food and traditional cuisine.',
      location: const LatLng(23.6568, 121.4085),
      imageUrl: 'assets/images/red-tile.png',
    ),
  ];

  static List<Trip> getAllTrips() {
    return [
      Trip(
        id: 'trip_001',
        userId: mockUserId,
        name: 'Matai’an Wetland Learning Tour',
        type: 'Education',
        startDate: DateTime(2026, 4, 29),
        endDate: DateTime(2026, 4, 29),
        stops: [
          // FIX: Updated all sub-instantiations from 'TripStop' to 'Stop' to match trip.dart
          Stop(
            place: availablePlaces[0], 
            scheduledTime: DateTime(2026, 4, 29, 09, 00),
            customNotes: 'Group 1 & 2: Understand regional context and introduction.',
          ),
          Stop(
            place: availablePlaces[1], 
            scheduledTime: DateTime(2026, 4, 29, 09, 40),
            customNotes: 'Group 3 & 4: Observe wetland ecology and plant species.',
          ),
          Stop(
            place: availablePlaces[2], 
            scheduledTime: DateTime(2026, 4, 29, 10, 20),
            customNotes: 'Group 5 & 6: Learn about firefly habitats.',
          ),
        ],
      ),
      Trip(
        id: 'trip_002',
        userId: mockUserId,
        name: 'Cultural & Environmental Exploration',
        type: 'Leisure',
        startDate: DateTime(2026, 4, 29),
        endDate: DateTime(2026, 4, 29),
        stops: [
          Stop(
            place: availablePlaces[3], 
            scheduledTime: DateTime(2026, 4, 29, 11, 00),
            customNotes: 'Group 7 & 8: Study watershed and ecosystem connections.',
          ),
          Stop(
            place: availablePlaces[4], 
            scheduledTime: DateTime(2026, 4, 29, 12, 00),
            customNotes: 'Group 9 & 10: Experience indigenous fishing culture.',
          ),
          Stop(
            place: availablePlaces[5], 
            scheduledTime: DateTime(2026, 4, 29, 13, 00),
            customNotes: 'Group 11 & 12: Lunch and slow food experience.',
          ),
        ],
      ),
    ];
  }
}