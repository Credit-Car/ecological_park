// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'dart:convert';
import 'dart:async'; // For background slideshow timer loops
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart'; // Handles background audio streams cleanly on web
import 'package:travel_app/main_navigation.dart';
import 'login_page.dart';
import 'admin_pages/admin_login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/providers/current_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:travel_app/session_manager.dart';
import 'package:travel_app/dataconnect_generated/generated.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore show Timestamp;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(child: const WelcomePage()),
  );
}

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matai an Park',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/home': (context) => const MainNavigation(),
        '/admin': (context) => const AdminLoginPage(),
      },
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  bool _isLoading = true; 
  bool _audioIsPlaying = false; // State flag tracks if background music unlocked successfully
  late AudioPlayer _audioPlayer;
  late PageController _pageController;
  Timer? _slideshowTimer;
  int _currentImageIndex = 0;

  // 👇 YOUR SUBMITTED NGROK IMAGE ARRAY: Decoded and cleaned for direct compilation
  final List<String> _backgroundBackgroundUrls = [
    'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 3/宋浩瑋.jpg',
    // 'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 1/陳宜妤.jpg',
    'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 3/鄭家宜.jpg',
    'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 2/江芷欣.jpg',
    // 'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 1/謝昕諠.jpg',
    // 'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 1/翁睿婕.jpg',
    // 'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 1/李昱勳.jpg',
    //'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 3/余穠.jpg',
    'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 1/莊子萱.jpg',
    'https://professor-defile-bash.ngrok-free.dev/mataian/作業圖片 1/徐祥庭.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _pageController = PageController(initialPage: 0);
    
    _checkSession();
    _setupIntroMediaPipeline();
  }
  Future<void> _setupIntroMediaPipeline() async {
    try {
      await _audioPlayer.setAsset('assets/videos/intro_audio.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one); // Loops track seamlessly infinitely

      // Defensively intercept background web engine autoplay execution blocks safely
      try {
        await _audioPlayer.play();
        setState(() => _audioIsPlaying = true);
      } catch (browserPolicyException) {
        debugPrint("Autoplay held by Chrome design choices. Unlocking on structural screen tap gesture: $browserPolicyException");
      }

      // Configure background image rotation timer loop execution (every 5 seconds)
      _slideshowTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController.hasClients) {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundBackgroundUrls.length;
          _pageController.animateToPage(
            _currentImageIndex,
            duration: const Duration(milliseconds: 1200), // Soft cross-fade interpolation curve
            curve: Curves.easeInOut,
          );
        }
      });
    } catch (e) {
      debugPrint("Media pipeline setup warning: $e");
    }
  }

  Future<void> _checkSession() async {
    await Future.delayed(Duration.zero);
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final sessionManager = SessionManager();
      final sessionToken = sessionManager.getSessionToken();

      if (sessionToken == null) {
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.signOut();
        }
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      User? firebaseUser = FirebaseAuth.instance.currentUser;
      firebaseUser ??= await FirebaseAuth.instance.authStateChanges().first;

      if (firebaseUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final response = await ExampleConnector.instance.getUser(userId: firebaseUser.uid).execute();
      final dbUser = response.data.user;

      if (dbUser != null) {
        final expiry = dbUser.sessionExpiry;
        final now = cloud_firestore.Timestamp.now();
        bool isTokenExpired = expiry != null && now.compareTo(cloud_firestore.Timestamp(expiry.seconds, 0)) > 0;

        if (dbUser.sessionToken == sessionToken && !isTokenExpired) {
          ref.read(currentUserProvider.notifier).state = CurrentUser(
            id: dbUser.userId,
            displayName: dbUser.displayname,
            avatarKey: dbUser.avatarKey,
            email: dbUser.email,
            type: dbUser.type,
          );

          if (mounted) {
            _cleanupMedia();
            Navigator.pushReplacementNamed(context, '/home');
            return; 
          }
        } else {
          await FirebaseAuth.instance.signOut();
        }
      }
    } catch (e) {
      debugPrint("Session check failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _skipIntro() {
    _cleanupMedia();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _cleanupMedia() {
    _audioPlayer.stop();
    _slideshowTimer?.cancel();
  }

  @override
  void dispose() {
    _cleanupMedia();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // 👇 BACKSTOP TRIGGER: Clicking anywhere on the viewport safely overrides browser autoplay blocks
        onTap: () {
          if (!_audioPlayer.playing) {
            _audioPlayer.play();
            setState(() => _audioIsPlaying = true);
          }
        },
        child: Stack(
          children: [
            // 1. Continuous cross-fade network URL image background gallery slider
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _backgroundBackgroundUrls.length,
                physics: const NeverScrollableScrollPhysics(), 
                itemBuilder: (context, index) {
                  return Image.network(
                    _backgroundBackgroundUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: Colors.black); 
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.teal.withOpacity(0.05),
                      child: const Center(
                        child: Icon(Icons.landscape_rounded, color: Colors.teal, size: 48),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Translucent Text Overlay Panels & Bottom Gradient Cover Guard
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 60, 32, 60),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    const Text(
                      'Welcome to Matai’an',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hear the story of our land.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // 3. Conditional Loader UI Anchor Checkpoint
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.teal,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: _skipIntro,
                                    icon: const Text(
                                      'Get Started',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    label: const Icon(Icons.arrow_forward_rounded, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}