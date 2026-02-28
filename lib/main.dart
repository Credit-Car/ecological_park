// flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080

import 'package:flutter/material.dart';
import 'package:travel_app/main_navigation.dart';
import 'package:video_player/video_player.dart';
import 'login_page.dart';
import 'admin_pages/admin_login_page.dart';
import 'admin_pages/admin_dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/providers/current_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
// import 'chatbot.dart';
// import 'main_navigation.dart';
// import 'settings.dart';
import 'package:universal_html/html.dart' as html;
// import 'package:uuid/uuid.dart'; // for token generation
// import 'package:firebase_data_connect/firebase_data_connect.dart';

// import 'package:firebase_data_connect/firebase_data_connect.dart';

import 'dataconnect_generated/generated.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // 1. ProviderScope must be the outermost widget
    ProviderScope(child: const WelcomePage()),
  );
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        // '/': (context) => const AdminLoginPage(),
        '/admin': (context) => const AdminLoginPage(),
      },
    );
  }
}

// 2. CONVERT TO STATEFUL WIDGET
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  bool _isLoading = true; // Start true to check immediately on load

  @override
  void initState() {
    super.initState();
    // 3. TRIGGER CHECK ON INIT
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Avoid running auto-login if LandingPage is not the active view
    await Future.delayed(Duration.zero);
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    // Wait for auth state to be ready
    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // 4. VERIFY WITH DATA CONNECT
      print("getting user profile for uid: ${user.uid}");
      // Execute the GetUser query (updated to accept String userId)
      final response = await ExampleConnector.instance.getUser(userId: user.uid).execute();
      
      // Note: 'user' field in response corresponds to the single user return
      if (response.data.user != null) {
        final dbUser = response.data.user!;
        print("Auto-login success for: ${dbUser.displayname}");

        // Populate Riverpod provider
        ref.read(currentUserProvider.notifier).state = CurrentUser(
          id: dbUser.userId,
          displayName: dbUser.displayname,
          avatarKey: dbUser.avatarKey, // Assuming updated schema
          email: dbUser.email,
          type: dbUser.type,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainNavigation()),
          );
          return; 
        }
      } else {
        print("User authenticated but no profile found in DB.");
      }

    } catch (e) {
      print("Session check failed: $e");
    } finally {
      // Stop loading so user can click "Get Started" manually
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // add a video in the background here that will play on loop covering the entire screen
          // VideoPlayerWidget(),
          VideoPlayerScreen(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  
                  // 6. CONDITIONAL UI
                  // Show Spinner if checking, Button if check failed/no cookie
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.teal,
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// void main() => runApp(const VideoPlayerApp());

// class VideoPlayerApp extends StatelessWidget {
//   const VideoPlayerApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Video Player Demo',
//       home: VideoPlayerScreen(),
//     );
//   }
// }

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    // _controller = VideoPlayerController.networkUrl(
    //   Uri.parse(
    //     'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    //   ),
    // );

    _controller = VideoPlayerController.asset('assets/videos/bird_view.mp4');

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);
    _controller.setVolume(0);
    _controller.play();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}