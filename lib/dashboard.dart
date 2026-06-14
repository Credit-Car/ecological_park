// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:travel_app/dataconnect_generated/generated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'mockdata.dart';
import '../models/places.dart';
import 'l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Places> filteredDestinations = [];
  List<Places> _allDestinations = []; 
  late Future<List<Places>> allDestinationsFuture;

  Future<List<Places>> fetchPlaces() async {
    try {
      final res = await ExampleConnector.instance.listPlaces().execute();
      
      if (res.data.places.isEmpty) {
        return MockData.availablePlaces;
      }

      // 👇 FIX 1: Filter out custom stops that belong to individual itineraries
      final officialLandmarks = res.data.places.where((e) {
        final desc = e.description?.trim() ?? '';
        // If the description tracks a routeId metadata block, it's not a global asset!
        return !(desc.startsWith('{') && desc.contains('routeId'));
      }).toList();

      return officialLandmarks.map((e) {
        final parts = e.coordinates.split(',');
        final lat = parts.isNotEmpty ? double.tryParse(parts.first.trim()) ?? 0.0 : 0.0;
        final lng = parts.length > 1 ? double.tryParse(parts.last.trim()) ?? 0.0 : 0.0;

        // 👇 FIX 2: Apply your system's hardcoded category structure 
        String assignedCategory = 'Scenic Spot';
        switch (e.placeId) {
          case 'p001': assignedCategory = 'Facility'; break;
          case 'p002': assignedCategory = 'Wildlife'; break;
          case 'p003':
          case 'p004': assignedCategory = 'Scenic Spot'; break;
          case 'p005':
          case 'p006': assignedCategory = 'Culture'; break;
        }

        return Places(
          id: e.placeId,
          name: e.name,
          category: assignedCategory, // Swapped generic 'Explore' for hardcoded keys
          imageUrl: (e.images != null && e.images!.isNotEmpty) ? e.images!.join(',') : 'https://via.placeholder.com/150',
          detail: e.description ?? '',
          location: LatLng(lat, lng),
        );
      }).toList();

    } catch (e) {
      debugPrint("Backend unreachable, using MockData: $e");
      return MockData.availablePlaces;
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allDestinationsFuture = fetchPlaces();
    allDestinationsFuture.then((destinations) {
      if (mounted) {
        setState(() {
          _allDestinations = destinations;
          filteredDestinations = destinations.take(7).toList();
        });
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        filteredDestinations = _allDestinations.take(7).toList();
      } else {
        filteredDestinations = _allDestinations
            .where((d) => d.name.toLowerCase().contains(value.toLowerCase()) ||
                          d.category.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  void _refreshDashboard() {
    setState(() {
      _searchController.clear();
      _allDestinations.shuffle();
      filteredDestinations = _allDestinations.take(7).toList();
    });
  }

  Widget buildDestinationCard(Places data) {
    final String previewUrl = data.imageUrl.split(',').first.trim();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsPage(destination: data)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 4.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(data.category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              subtitle: Text(data.name),
              trailing: const Icon(Icons.favorite_outline),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: previewUrl.startsWith('https') 
                ? CachedNetworkImage(
                    imageUrl: previewUrl,
                    memCacheHeight: (180 * MediaQuery.of(context).devicePixelRatio).toInt(),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => _buildErrorPlaceholder(),
                  )
                : Image.asset(
                    previewUrl, 
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image_not_supported)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                      hintText: "Explore Matai’an...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.teal),
                    onPressed: _refreshDashboard,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDestinations.length,
                itemBuilder: (context, index) {
                  return buildDestinationCard(filteredDestinations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final Places destination; 
  const DetailsPage({super.key, required this.destination});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _currentPage = 0;

  String get placePrice {
    return widget.destination.category == 'Culture' ? '\$250' : 'Free';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.destination.imageUrl
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  images.isEmpty
                      ? Container(
                          color: Colors.grey[300],
                          width: double.infinity,
                          child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
                        )
                      : PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final String currentPath = images[index];

                            if (currentPath.startsWith('assets/')) {
                              return Image.asset(
                                currentPath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            } else {
                              return CachedNetworkImage(
                                imageUrl: currentPath,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(child: Icon(Icons.broken_image, size: 30, color: Colors.grey)),
                                ),
                              );
                            }
                          },
                        ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 50, 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: _currentPage == index ? 12.0 : 8.0,
                            height: _currentPage == index ? 12.0 : 8.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(111, 158, 158, 158),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.destination.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(placePrice, style: const TextStyle(fontSize: 22, color: Colors.teal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blueAccent, size: 18),
                        Text("${widget.destination.location.latitude}, ${widget.destination.location.longitude}", style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Clipboard.setData(ClipboardData(text: "${widget.destination.location.latitude},${widget.destination.location.longitude}")).then((_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Location copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          icon: const Icon(Icons.copy, size: 16),
                          label: Text(AppLocalizations.of(context)!.btn_add, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 15, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Note: Pictures were taken from East Rift Valley National Scenic Area website.",
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(AppLocalizations.of(context)!.btn_overview, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(height: 3, width: 35, color: Colors.teal, margin: const EdgeInsets.only(top: 4)),
                    const SizedBox(height: 15),
                    MarkdownBody(
                      data: widget.destination.detail,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Colors.black54, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.library_add_check_outlined, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.btn_add, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.map_outlined, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.btn_view, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}