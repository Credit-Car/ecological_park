import 'package:google_maps_flutter/google_maps_flutter.dart';

class Places {
  final String id;
  final String name;
  final String category;
  final String detail;
  final LatLng location;
  final String imageUrl; 
  const Places({
    required this.id,
    required this.name,
    required this.category,
    required this.detail,
    required this.location,
    required this.imageUrl,
  });
}