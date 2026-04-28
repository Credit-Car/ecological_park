import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:travel_app/dataconnect_generated/generated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'mockdata.dart';
import '../models/places.dart';

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

      // Map Backend data to your Places model
      return res.data.places.map((e) => Places(
        id: e.placeId,
        name: e.name,
        category: 'Explore', 
        imageUrl: (e.images != null && e.images!.isNotEmpty) 
            ? e.images!.first 
            : 'https://via.placeholder.com/150',
        detail: e.description ?? '',
        lat: double.tryParse(e.coordinates.split(',').first) ?? 0.0,
        lng: double.tryParse(e.coordinates.split(',').last) ?? 0.0,
      )).toList();

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
      setState(() {
        _allDestinations = destinations;
        // Initially show only 7 random items
        filteredDestinations = destinations.take(7).toList();
      });
    });
  }
  
  // [
  //   Destination(
  //     name: 'Lakeside Restaurant',
  //     category: 'Restaurants',
  //     image: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/09/a8/32/57/caption.jpg?w=1200&h=-1&s=1',
  //     location: 'Shoufeng, Hualien',
  //     rating: 4.5,
  //     price: '\$150',
  //     description: 'The Lakeside Restaurant at NDHU offers a peaceful dining experience with a stunning view of the central lake. It is a favorite spot for students and faculty to enjoy local Hualien cuisine.',
  //   ),
  //   Destination(
  //     name: 'NDHU Library',
  //     category: 'Buildings',
  //     image: 'assets/images/ndhu_library.png',
  //     location: 'Shoufeng, Hualien',
  //     rating: 4.9,
  //     price: 'Free',
  //     description: 'The National Dong Hwa University Library is an architectural masterpiece. It serves as the primary research hub for students and offers breathtaking views of the campus mountains.',
  //   ),
  // ];



  // @override
  // void initState() {
  //   super.initState();
  //   filteredDestinations = allDestinations;
  // }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        // If search is cleared, show the initial 7 random places again
        // (For a sticky selection, store the initial random set in another variable)
        filteredDestinations = _allDestinations.take(7).toList();
      } else {
        // Search through ALL destinations
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
      // shuffle the existing list to get a new set of 7
      _allDestinations.shuffle();
      filteredDestinations = _allDestinations.take(7).toList();
    });
  }

  Widget buildDestinationCard(Places data) {
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
              child: data.imageUrl.startsWith('http') 
                ? CachedNetworkImage(
                    imageUrl: data.imageUrl.split(',').first,
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
                    data.imageUrl.split(',').first, // Loads from assets/images/
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
  final Places destination; // Changed from Destination
  const DetailsPage({super.key, required this.destination});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _currentPage = 0;
  String get placePrice {
    return widget.destination.category == 'Culture'
        ? '\$250'
        : 'Free';
  }

  String get placeLocation {
    return "Guangfu, Hualien";
  }
  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.destination.imageUrl.split(',');
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
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (images[index].startsWith('assets/')) {
                        return Image.asset(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      } else {
                        return CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                        );
                      }
},
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 50, // Just above the white content sheet
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
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Back Button
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

          // 3. The Content Sheet
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
                    // Dynamic Title and Price
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
                            //const Text("/person", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blueAccent, size: 18),
                        Text(placeLocation, style: const TextStyle(color: Colors.grey)),

                        Spacer(),

                        ElevatedButton.icon(
                          onPressed: () {
                            // Copy location to clipboard
                            // import 'package:flutter/services.dart'; needs to be imported if not available, 
                            // but usually available via material.dart -> services.dart
                            // actually it is in services.dart. 
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Clipboard.setData(ClipboardData(text:placeLocation)).then((_) {
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
                          label: const Text('Copy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Note Section
                    Row(children: [
                      const Icon(Icons.info_outline_rounded, size: 15, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Note: Pictures were taken from East Rift Valley National Scenic Area website.",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],),
                    // Reviews and Rating Row
                    // Row(
                    //   children: [
                    //     _buildAvatarStack(),
                    //     const SizedBox(width: 8),
                    //     const Text("People Reviewed", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    //     const Spacer(),
                    //     const Icon(Icons.star, color: Colors.orange, size: 20),
                    //     Text(" ${widget.destination.rating} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    //     const Text("/5", style: TextStyle(color: Colors.grey)),
                    //   ],
                    // ),
                    const SizedBox(height: 30),

                    // Overview Section
                    const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(height: 3, width: 35, color: Colors.teal, margin: const EdgeInsets.only(top: 4)),
                    const SizedBox(height: 15),

                    // Dynamic Description
                    // display the decription in markdown format with line breaks and paragraphs
                    
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
          
          // Button to new view to display the place in embedded google maps
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
                    label: const Text('Add ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                    label: const Text('View', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

// Reviewer
//   Widget _buildAvatarStack() {
//     return SizedBox(
//       width: 70, height: 30,
//       child: Stack(
//         children: List.generate(3, (index) {
//           return Positioned(
//             left: index * 15.0,
//             child: CircleAvatar(
//               radius: 15,
//               backgroundColor: Colors.white,
//               child: CircleAvatar(
//                 radius: 13,
//                 backgroundImage: NetworkImage('https://www.shutterstock.com/image-photo/smiling-african-american-millennial-businessman-600nw-1437938108.jpg'),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
}