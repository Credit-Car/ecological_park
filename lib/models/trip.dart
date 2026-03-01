import 'places.dart';

class Trip {
  final String id;
  final String name;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripStop> stops;

  Trip({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.stops,
  });
}

class TripStop {
  final Places place;
  final DateTime scheduledTime;
  final String? customNotes;

  TripStop({
    required this.place,
    required this.scheduledTime,
    this.customNotes,
  });
}