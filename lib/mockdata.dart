import '../models/places.dart';
import '../models/trip.dart';

class MockData {
  static const String mockUserId = 'user_999';

  static const List<Places> availablePlaces = [
    Places(
      id: 'p001',
      name: 'Visitor Service Center',
      category: 'Facility',
      detail: 'Introduction to the geographical location and regional context by the Township Office and Agriculture & Tourism Section.',
      lat: 23.6579,
      lng: 121.4095,
      imageUrl: 'assets/images/visitor-center.jpg',
    ),
    Places(
      id: 'p002',
      name: 'Wooden Boardwalk Area',
      category: 'Scenic Spot',
      detail: 'Wetland ecology interpretation area with rich biodiversity and walking paths.',
      lat: 23.6585,
      lng: 121.4102,
      imageUrl: 'assets/images/boardwalk.jpg',
    ),
    Places(
      id: 'p003',
      name: 'Water Willow Area',
      category: 'Wildlife',
      detail: 'Habitat for fireflies and aquatic plants; learn about firefly ecology.',
      lat: 23.6590,
      lng: 121.4108,
      imageUrl: 'assets/images/water-willow.png',
    ),
    Places(
      id: 'p004',
      name: 'Egret Bridge',
      category: 'Scenic Spot',
      detail: 'Overview of the Fudeng Creek watershed and surrounding wetland environment.',
      lat: 23.6582,
      lng: 121.4098,
      imageUrl: 'assets/images/egret-bridge.jpg',
    ),
    Places(
      id: 'p005',
      name: 'Shin-Lu Farm',
      category: 'Culture',
      detail: 'Experience Barago fishing culture and local indigenous way of life.',
      lat: 23.6573,
      lng: 121.4089,
      imageUrl: 'assets/images/shin-lu.jpg',
    ),
    Places(
      id: 'p006',
      name: 'Red Tile House',
      category: 'Culture',
      detail: 'Waterside dining experience showcasing slow food and traditional cuisine.',
      lat: 23.6568,
      lng: 121.4085,
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
          TripStop(
            place: availablePlaces[0], // Visitor Center
            scheduledTime: DateTime(2026, 4, 29, 09, 00),
            customNotes: 'Group 1 & 2: Understand regional context and introduction.',
          ),
          TripStop(
            place: availablePlaces[1], // Boardwalk
            scheduledTime: DateTime(2026, 4, 29, 09, 40),
            customNotes: 'Group 3 & 4: Observe wetland ecology and plant species.',
          ),
          TripStop(
            place: availablePlaces[2], // Water Willow
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
          TripStop(
            place: availablePlaces[3], // Egret Bridge
            scheduledTime: DateTime(2026, 4, 29, 11, 00),
            customNotes: 'Group 7 & 8: Study watershed and ecosystem connections.',
          ),
          TripStop(
            place: availablePlaces[4], // Shin-Lu Farm
            scheduledTime: DateTime(2026, 4, 29, 12, 00),
            customNotes: 'Group 9 & 10: Experience indigenous fishing culture.',
          ),
          TripStop(
            place: availablePlaces[5], // Red Tile House
            scheduledTime: DateTime(2026, 4, 29, 13, 00),
            customNotes: 'Group 11 & 12: Lunch and slow food experience.',
          ),
        ],
      ),
    ];
  }
}