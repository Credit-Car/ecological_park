import '../models/places.dart';
import '../models/trip.dart';

class MockData {
  static const String mockUserId = 'user_999';

  static const List<Places> availablePlaces = [
    Places(
      id: 'p001',
      name: 'NDHU Library',
      category: 'Study',
      detail: 'Main library building with 24/7 study areas.',
      lat: 23.8969381, 
      lng: 121.5421631,
      imageUrl: 'assets/images/ndhu_library.png',
    ),
    Places(
      id: 'p002',
      name: 'Lake Donghua',
      category: 'Nature',
      detail: 'Scenic lake perfect for evening walks.',
      lat: 23.8955, 
      lng: 121.5440,
      imageUrl: 'assets/images/lakeside.jpeg',
    ),
    Places(
      id: 'p003',
      name: 'Dorm V',
      category: 'Accommodation',
      detail: 'Student housing and guest accommodation.',
      lat: 23.8971,
      lng: 121.5412,
      imageUrl: 'assets/images/dorm_V.png',
    ),
    Places(
      id: 'p004',
      name: 'Administration Building',
      category: 'Office',
      detail: 'Central hub for university administrative tasks.',
      lat: 23.8930,
      lng: 121.5360,
      imageUrl: 'assets/images/admin.jpg',
    ),
    Places(
      id: 'p005',
      name: 'Solar Farm',
      category: 'Research',
      detail: 'NDHU renewable energy testing and exhibition site.',
      lat: 23.8940,
      lng: 121.5400,
      imageUrl: 'assets/images/solar_farm.png',
    ),
  ];
  static List<Trip> getAllTrips() {
    return [
      Trip(
        id: 'trip_001',
        userId: mockUserId,
        name: 'NDHU Campus Visit',
        type: 'Business',
        startDate: DateTime(2026, 3, 10),
        endDate: DateTime(2026, 3, 12),
        stops: [
          TripStop(
            place: availablePlaces[0], // Library
            scheduledTime: DateTime(2026, 3, 10, 09, 00),
            customNotes: 'Meet the research team at the entrance.',
          ),
          TripStop(
            place: availablePlaces[2], // Dorm V
            scheduledTime: DateTime(2026, 3, 10, 11, 30),
            customNotes: 'Check-in and drop off luggage.',
          ),
        ],
      ),
      Trip(
        id: 'trip_002',
        userId: mockUserId,
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