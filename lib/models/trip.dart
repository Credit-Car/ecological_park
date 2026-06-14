import 'places.dart';

class Trip {
  final String id;
  final String userId;
  final String name;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final List<Stop> stops; // Changed from TripStop to Stop to match your page layout

  Trip({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.stops,
  });
}

class Stop {
  final Places place;
  final DateTime scheduledTime;
  final String? customNotes;

  Stop({
    required this.place,
    required this.scheduledTime,
    this.customNotes,
  });
}