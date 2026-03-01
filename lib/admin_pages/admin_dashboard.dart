import 'package:flutter/material.dart';
import 'package:travel_app/dataconnect_generated/generated.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/admin_pages/seeded.dart';

// final List<(String, String, String, String)> places = [('Dong Lake', 'The central scenic heart of the campus features a large tranquil body of water where students often gather to enjoy the reflection of the coastal mountain range and iconic bridge.', '23.901542, 121.538211', 'https://images.pexels.com/photos/730981/pexels-photo-730981.jpeg, https://images.pexels.com/photos/732547/pexels-photo-732547.jpeg, https://images.pexels.com/photos/2662116/pexels-photo-2662116.jpeg'), ('Hua Lake', 'A secondary peaceful water feature located within the campus grounds offering a quiet space for ecological observation and reflection amidst the lush green landscaping that defines this beautiful university setting.', '23.894218, 121.545932', 'https://images.pexels.com/photos/925743/pexels-photo-925743.jpeg, https://images.pexels.com/photos/4215110/pexels-photo-4215110.jpeg, https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg'), ('Little Hua Lake', 'This smaller pond serves as a charming natural nook on the university grounds providing a habitat for local wildlife and a serene spot for students seeking a brief outdoor escape.', '23.903105, 121.540124', 'https://images.pexels.com/photos/33109/fall-autumn-red-season.jpg, https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg, https://images.pexels.com/photos/36717/amazing-animal-beautiful-beautifull.jpg'), ('Scenic Bridge', 'This elegant white arched structure spans the narrowest point of Dong Lake and serves as the most famous photographic landmark for graduates and tourists visiting the National Dong Hwa University.', '23.892154, 121.537845', 'https://images.pexels.com/photos/36717/amazing-animal-beautiful-beautifull.jpg, https://images.pexels.com/photos/1172064/pexels-photo-1172064.jpeg, https://images.pexels.com/photos/1591447/pexels-photo-1591447.jpeg'), ('Sakura Trail', 'A picturesque walking path lined with cherry blossom trees that transform into a vibrant pink display during the spring season attracting many visitors and photographers to this specific campus location.', '23.899876, 121.549210', 'https://images.pexels.com/photos/1624496/pexels-photo-1624496.jpeg, https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg, https://images.pexels.com/photos/592077/pexels-photo-592077.jpeg'), ('Humanities and Social Sciences Building I', 'The primary academic hub for literature and history studies featuring spacious lecture halls and departmental offices designed to foster intellectual growth within a modern and well equipped scholarly environment for students.', '23.895432, 121.534122', 'https://images.pexels.com/photos/1323550/pexels-photo-1323550.jpeg, https://images.pexels.com/photos/459203/pexels-photo-459203.jpeg, https://images.pexels.com/photos/2034892/pexels-photo-2034892.jpeg'), ('Humanities and Social Sciences Building II', 'This facility focuses on social research and linguistic studies providing various specialized classrooms and faculty meeting spaces that support the diverse academic needs of the growing student body at Dong Hwa.', '23.902341, 121.546781', 'https://images.pexels.com/photos/1183099/pexels-photo-1183099.jpeg, https://images.pexels.com/photos/459225/pexels-photo-459225.jpeg, https://images.pexels.com/photos/775203/pexels-photo-775203.jpeg'), ('Humanities and Social Sciences Building III', 'The newest addition to the humanities complex houses advanced research centers and multimedia labs intended to facilitate contemporary sociological studies and collaborative projects across different disciplines within the university department.', '23.890923, 121.542109', 'https://images.pexels.com/photos/1144176/pexels-photo-1144176.jpeg, https://images.pexels.com/photos/68147/waterfall-thac-dray-nur-buon-me-thuot-daklak-68147.jpeg, https://images.pexels.com/photos/1519088/pexels-photo-1519088.jpeg'), ('Science and Engineering Building I', 'A high tech facility dedicated to the physical sciences and basic engineering principles containing numerous laboratories where undergraduate students conduct essential experiments under the guidance of highly experienced faculty members.', '23.897654, 121.532987', 'https://images.pexels.com/photos/242616/pexels-photo-242616.jpeg, https://images.pexels.com/photos/3034343/pexels-photo-3034343.jpeg, https://images.pexels.com/photos/541101/pexels-photo-541101.jpeg'), ('Science and Engineering Building II', 'This building specializes in chemical and biological research featuring advanced safety equipment and specialized workstations designed for complex scientific inquiry and the development of new innovative technologies in various fields.', '23.904876, 121.543456', 'https://images.pexels.com/photos/1366913/pexels-photo-1366913.jpeg, https://images.pexels.com/photos/1260324/pexels-photo-1260324.jpeg, https://images.pexels.com/photos/775201/pexels-photo-775201.jpeg'), ('Science and Engineering Building III', 'Focusing on electrical engineering and computer sciences this structure provides the necessary infrastructure for digital innovation and hardware development projects within the university high level technical and engineering academic programs.', '23.893210, 121.548901', 'https://images.pexels.com/photos/7972506/pexels-photo-7972506.jpeg, https://images.pexels.com/photos/7683746/pexels-photo-7683746.jpeg, https://images.pexels.com/photos/7972518/pexels-photo-7972518.jpeg'), ('Management Building', 'The headquarters for business and finance studies featuring mock trading rooms and seminar halls where future leaders learn essential skills in marketing accounting and international business within a professional atmosphere.', '23.896543, 121.539876', 'https://images.pexels.com/photos/7972556/pexels-photo-7972556.jpeg, https://images.pexels.com/photos/7683692/pexels-photo-7683692.jpeg, https://images.pexels.com/photos/31056507/pexels-photo-31056507.jpeg'), ('Hua-Shih Education Building', 'Dedicated to teacher training and educational research this facility houses specialized classrooms and resources for students pursuing careers in pedagogy and early childhood development within the local and national systems.', '23.900123, 121.533543', 'https://images.pexels.com/photos/32907649/pexels-photo-32907649.jpeg, https://images.pexels.com/photos/7972659/pexels-photo-7972659.jpeg, https://images.pexels.com/photos/7972519/pexels-photo-7972519.jpeg'), ('Indigenous Studies Building', 'A dedicated facility designed to support the College of Indigenous Studies featuring unique architectural elements that reflect the rich cultural heritage and diverse traditions of the native peoples of Taiwan.', '23.891234, 121.544321', 'https://images.pexels.com/photos/7973205/pexels-photo-7973205.jpeg, https://images.pexels.com/photos/31297362/pexels-photo-31297362.jpeg, https://images.pexels.com/photos/14768533/pexels-photo-14768533.jpeg'), ('Arts Building', 'The creative heart of campus where music and visual arts students refine their skills in specialized practice rooms and studios designed to encourage artistic expression and high level performance excellence.', '23.905678, 121.541234', 'https://images.pexels.com/photos/279614/pexels-photo-279614.jpeg, https://images.pexels.com/photos/161758/governor-s-mansion-montgomery-alabama-grand-staircase-161758.jpeg, https://images.pexels.com/photos/1329711/pexels-photo-1329711.jpeg'), ('Arts Workshop', 'A creative space specifically designed for students in the arts to practice their crafts including sculpture and painting while surrounded by the inspiring natural beauty of the Hualien county landscape.', '23.894567, 121.536789', 'https://images.pexels.com/photos/6054896/pexels-photo-6054896.jpeg, https://images.pexels.com/photos/8753032/pexels-photo-8753032.jpeg, https://images.pexels.com/photos/774866/pexels-photo-774866.jpeg'), ('Environmental Studies Building', 'A green facility focused on sustainability and ecological research providing labs for analyzing local flora and fauna while promoting environmental awareness through various university initiatives and specialized academic degree programs.', '23.898901, 121.551234', 'https://images.pexels.com/photos/939331/pexels-photo-939331.jpeg, https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg, https://images.pexels.com/photos/2908984/pexels-photo-2908984.jpeg'), ('Administration Building', 'The primary hub for university governance and student services where administrative offices handle essential academic affairs and international exchange programs within a large and very modern red brick architectural complex.', '23.892345, 121.535432', 'https://images.pexels.com/photos/763135/pexels-photo-763135.jpeg, https://images.pexels.com/photos/2041540/pexels-photo-2041540.jpeg, https://images.pexels.com/photos/710744/pexels-photo-710744.jpeg'), ('University Library', 'Housing an extensive collection of academic resources this building is easily recognized by its distinctive tall clock tower which acts as a navigational beacon for everyone walking across the campus.', '23.901234, 121.547890', 'https://images.pexels.com/photos/5212695/pexels-photo-5212695.jpeg, https://images.pexels.com/photos/274422/pexels-photo-274422.jpeg, https://images.pexels.com/photos/538694/pexels-photo-538694.jpeg'), ('Student Activities Center', 'The bustling center of campus life provides space for various student clubs and recreational events including a large auditorium for performances and several small shops for purchasing essential daily supplies.', '23.890123, 121.540567', 'https://images.pexels.com/photos/1198172/pexels-photo-1198172.jpeg, https://images.pexels.com/photos/46798/the-ball-stadion-football-the-pitch-46798.jpeg, https://images.pexels.com/photos/257970/pexels-photo-257970.jpeg'), ('Lakeside Restaurant', 'Located right on the edge of the water this popular dining hub offers various meal options and a relaxing atmosphere where students can eat while looking out over the lake.', '23.897890, 121.549876', 'https://images.pexels.com/photos/326527/pexels-photo-326527.jpeg, https://images.pexels.com/photos/2365320/pexels-photo-2365320.png, https://images.pexels.com/photos/416717/pexels-photo-416717.jpeg'), ('Information and Network Center', 'The digital backbone of the university managing campus wide internet connectivity and providing technical support services for students and faculty while maintaining the essential servers and internal computer network systems.', '23.903456, 121.534567', 'https://images.pexels.com/photos/2202685/pexels-photo-2202685.jpeg, https://images.pexels.com/photos/342360/pexels-photo-342360.jpeg, https://images.pexels.com/photos/6203521/pexels-photo-6203521.jpeg'), ('Indoor Sports Center', 'A large multi purpose gymnasium featuring basketball courts and badminton facilities allowing students to stay active and participate in competitive indoor sports regardless of the weather conditions in Hualien county.', '23.895678, 121.543210', 'https://images.pexels.com/photos/1005456/pexels-photo-1005456.jpeg, https://images.pexels.com/photos/139303/pexels-photo-139303.jpeg, https://images.pexels.com/photos/39943/pexels-photo-39943.jpeg'), ('Swimming Pools', 'Featuring both indoor and outdoor options these aquatic facilities provide space for competitive training and recreational swimming for the university community within a safe and professionally managed water sports environment.', '23.906123, 121.539012', 'https://images.pexels.com/photos/1388069/pexels-photo-1388069.jpeg, https://images.pexels.com/photos/845242/pexels-photo-845242.jpeg, https://images.pexels.com/photos/701337/pexels-photo-701337.jpeg'), ('Athletic Field', 'A massive outdoor sports complex featuring a standard running track and green spaces where students participate in football matches and university wide sports festivals throughout the busy spring and autumn.', '23.893456, 121.537123', 'https://images.pexels.com/photos/557844/pexels-photo-557844.jpeg, https://images.pexels.com/photos/1563356/pexels-photo-1563356.jpeg, https://images.pexels.com/photos/46024/pexels-photo-46024.jpeg'), ('Dong Hwa Guest House', 'Providing comfortable accommodations for visiting scholars and university guests this facility offers a convenient place to stay on campus while attending academic conferences or participating in short term research projects.', '23.899012, 121.545678', 'https://images.pexels.com/photos/3299906/pexels-photo-3299906.jpeg, https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg, https://images.pexels.com/photos/13119038/pexels-photo-13119038.jpeg'), ('Community Center', 'A shared space designed for social interaction and local events where campus residents and students gather for meetings workshops and various community building activities throughout the busy university academic year.', '23.891567, 121.548234', 'https://images.pexels.com/photos/4587979/pexels-photo-4587979.jpeg, https://images.pexels.com/photos/1378849/pexels-photo-1378849.jpeg, https://images.pexels.com/photos/262047/pexels-photo-262047.jpeg'), ('Qin-Yue Court', 'One of the major residential dormitories on the northern side of the campus providing comfortable living quarters and communal study spaces for students residing away from home during their studies.', '23.904234, 121.536210', 'https://images.pexels.com/photos/763934/pexels-photo-763934.jpeg, https://images.pexels.com/photos/958545/pexels-photo-958545.jpeg, https://images.pexels.com/photos/3603453/pexels-photo-3603453.jpeg'), ('Faculty Quarters I and II', 'Dedicated residential areas providing housing for university professors and their families located within the campus grounds to foster a close knit academic community and convenient access to the various departments.', '23.896789, 121.550123', 'https://images.pexels.com/photos/5982898/pexels-photo-5982898.jpeg, https://images.pexels.com/photos/5982898/pexels-photo-5982898.jpeg, https://images.pexels.com/photos/7237616/pexels-photo-7237616.jpeg'), ('Scholar Hostel', 'A specialized housing facility designed for international researchers and graduate students offering modern amenities and a quiet environment conducive to advanced academic study and collaborative research during their university stay.', '23.890543, 121.538901', 'https://images.pexels.com/photos/159210/vespa-roller-motor-scooter-cult-159210.jpeg, https://images.pexels.com/photos/8717989/pexels-photo-8717989.jpeg, https://images.pexels.com/photos/28654623/pexels-photo-28654623.jpeg')];


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key}); // Removed userId parameter

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // TRIGGER ADMIN CHECK ON INIT!!!!
    // !!!!
    // !!!!
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
       setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
      return;
    }

    try {
      // Execute the IsAdmin query
      final response = await ExampleConnector.instance.isAdmin(userId: user.uid).execute();
      
      // Determine if user is admin based on the 'type' field
      if (response.data.user?.type == 'admin') {
        setState(() {
          _isAdmin = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAdmin = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      setState(() {
        _isAdmin = false; 
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(
          child: Text('Access Denied: You do not have admin privileges.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Places'),
            Tab(text: 'Users'),
            Tab(text: 'Routes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const PlacesTab(),
          const Center(child: Image(image: NetworkImage("https://images.pexels.com/photos/925743/pexels-photo-925743.jpeg"))),
          // const Center(child: Text('Users Management Placeholder')),
          const Center(child: Text('Routes Management Placeholder')),
        ],
      ),
    );
  }
}

class PlacesTab extends StatefulWidget {
  const PlacesTab({super.key});

  @override
  State<PlacesTab> createState() => _PlacesTabState();
}

class _PlacesTabState extends State<PlacesTab> {
  // Make sure to use the correct type from the generated code when available.
  List<ListPlacesPlaces> _places = []; 
  List<ListPlacesPlaces> _filteredPlaces = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  final mc = (23.898372, 121.541526);

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    setState(() => _loading = true);
    try {
      final response = await ExampleConnector.instance.listPlaces().execute();
      
      if (response.data.places.isEmpty) {
        // Auto-seed if empty
        await _seedPlaces();
        // Re-fetch after seeding
        final newResponse = await ExampleConnector.instance.listPlaces().execute();
         setState(() {
          _places = newResponse.data.places;
          _filteredPlaces = _places;
          _loading = false;
        });
      } else {
        setState(() {
          _places = response.data.places;
          _filteredPlaces = _places;
          _loading = false;
        });
      }

    } catch (e) {
      debugPrint('Error fetching places: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _seedPlaces() async {
     debugPrint("Seeding places...");
     for (final placeData in places) {
       final (name, desc, coords, images) = placeData;
       try {
         await ExampleConnector.instance.createPlace(
            name: name,
            coordinates: coords
          )
          .description(desc)
          .images(images.split(',').map((e) => e.trim()).toList())
          .execute();
       } catch (e) {
         debugPrint("Failed to seed place $name: $e");
       }
     }
     debugPrint("Seeding complete.");
  }

  void _filterPlaces(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredPlaces = _places.where((place) {
        final name = place.name.toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _deletePlace(String placeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this place?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ExampleConnector.instance.deletePlace(placeId: placeId).execute();
        await _fetchPlaces();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting place: $e')),
        );
      }
    }
  }

  void _openPlaceForm([ListPlacesPlaces? place]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: PlaceForm(
          place: place,
          onSave: _fetchPlaces,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Places',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filterPlaces,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredPlaces.length,
            itemBuilder: (context, index) {
              final place = _filteredPlaces[index];
              return ListTile(
                title: Text(place.name),
                subtitle: Text(place.description ?? 'No description'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openPlaceForm(place),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePlace(place.placeId),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _openPlaceForm(),
            icon: const Icon(Icons.add),
            label: const Text('Create New Place'),
          ),
        ),
      ],
    );
  }
}

class PlaceForm extends StatefulWidget {
  final ListPlacesPlaces? place; // If null, it's a create action
  final VoidCallback onSave;

  const PlaceForm({super.key, this.place, required this.onSave});

  @override
  State<PlaceForm> createState() => _PlaceFormState();
}

class _PlaceFormState extends State<PlaceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _coordsController;
  late TextEditingController _imagesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place?.name ?? '');
    _descController =
        TextEditingController(text: widget.place?.description ?? '');
    _coordsController =
        TextEditingController(text: widget.place?.coordinates ?? '');
    // Join images list to string for editing, or empty
    final images = widget.place?.images;
    _imagesController =
        TextEditingController(text: images?.join(',') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _coordsController.dispose();
    _imagesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final name = _nameController.text;
      final desc = _descController.text;
      final coords = _coordsController.text;
      final images = _imagesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (widget.place == null) {
        // Create
        await ExampleConnector.instance.createPlace(
          name: name,
          coordinates: coords
        )
        .description(desc)
        .images(images)
        .execute();
      } else {
        // Update
        await ExampleConnector.instance.updatePlace(
          placeId: widget.place!.placeId,
        )
        .name(name)
        .description(desc)
        .coordinates(coords)
        .images(images)
        .execute();
      }

      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving place: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.place == null ? 'Create Place' : 'Edit Place',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _coordsController,
                decoration: const InputDecoration(labelText: 'Coordinates'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Coordinates are required'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imagesController,
                decoration: const InputDecoration(
                    labelText: 'Images (comma separated URLs)'),
              ),
              const SizedBox(height: 16),
              if (_isSaving)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.place == null ? 'Create' : 'Update'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
