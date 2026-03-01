import '../models/places.dart';
import '../models/trip.dart';

class MockData {
  static const List<Places> availablePlaces = [
    Places(
      name: 'NDHU Library',
      category: 'Study',
      detail: 'Main library building',
      lat: 23.8969381, lng: 121.5421631,
      imageUrl: 'assets/images/ndhu_library.png',
    ),
    Places(
      name: 'Lake Donghua',
      category: 'Nature',
      detail: 'Scenic lake',
      lat: 23.8955, lng: 121.5440,
      imageUrl: 'assets/images/lakeside.jpeg',
    ),
    Places(
      name: 'Dorm V',
      category: 'Hotel',
      detail: 'University accommodation',
      lat: 23.8971,
      lng: 121.5412,
      imageUrl: 'assets/images/dorm_V.png',
    ),
    Places(
      name: 'Administration Building',
      category: 'Office',
      detail: 'Central admin hub',
      lat: 23.8930,
      lng: 121.5360,
      imageUrl: 'assets/images/admin.jpg',
    ),
    Places(
      name: 'Solar Farm',
      category: 'Nature',
      detail: 'Renewable energy site',
      lat: 23.8940,
      lng: 121.5400,
      imageUrl: 'assets/images/solar_farm.png',
    ),
  ];

  static List<Trip> getAllTrips() {
    return [
      // Trip 1: Campus Visit
      Trip(
        id: 'trip_001',
        name: 'NDHU Campus Visit',
        type: 'Business',
        startDate: DateTime(2026, 3, 10),
        endDate: DateTime(2026, 3, 12),
        stops: [
          TripStop(
            place: availablePlaces[0],
            scheduledTime: DateTime(2026, 3, 10, 09, 00),
            customNotes: 'Meet the research team at the entrance.',
          ),
          TripStop(
            place: availablePlaces[2],
            scheduledTime: DateTime(2026, 3, 10, 11, 30),
            customNotes: 'Project introduction session.',
          ),
        ],
      ),
      Trip(
        id: 'trip_002',
        name: 'Solar Farm Expo',
        type: 'Leisure',
        startDate: DateTime(2026, 2, 15), 
        endDate: DateTime(2026, 2, 16),
        stops: [
          TripStop(
            place: availablePlaces[4],
            scheduledTime: DateTime(2026, 2, 15, 14, 00),
            customNotes: 'Guided tour of the photovoltaic arrays.',
          ),
        ],
      ),
    ];
  }
}