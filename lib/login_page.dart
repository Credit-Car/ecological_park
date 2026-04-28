import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'signup.dart';
import 'dataconnect_generated/generated.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/current_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'web_auth/auth_button.dart';
import 'package:shared_preferences/shared_preferences.dart';


// LOG IN PAGE
import 'package:travel_app/session_manager.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; 
// Use Timestamp from firebase_data_connect to match generated code
import 'package:firebase_data_connect/firebase_data_connect.dart'; 


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => LoginState();
}

class LoginState extends ConsumerState<LoginPage> {
  bool _isChecked = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _obscurePassword = true;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleSignInSubscription;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _googleSignInSubscription = GoogleSignIn.instance.authenticationEvents.listen((event) async {
       if (event is GoogleSignInAuthenticationEventSignIn) {
          await _handleGoogleAuthAccount(event.user);
       }
    });
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = prefs.getBool('remember_me') ?? false;
      if (_isChecked) {
        _emailController.text = prefs.getString('saved_email') ?? '';
      }
    });
  }

  @override
  void dispose() {
    _googleSignInSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //   // Set the cookie
  //   void _setSessionCookie(String sessionToken) {
  //     // Calculate 2 days in seconds (2 * 24 * 60 * 60 = 172800)
  //     const int maxAgeSeconds = 172800;

  //     // Create the cookie string
  //     // "Secure" ensures it's only sent over HTTPS (recommended)
  //     // "SameSite=Strict" prevents CSRF attacks
  //     final cookieValue =
  //         "sessionToken=$sessionToken; max-age=$maxAgeSeconds; path=/; SameSite=Strict; Secure";

  //     // Set the cookie in the browser
  //     html.document.cookie = cookieValue;
  //   }

  // // Helper to generate a secure random token
  //   String _generateSessionToken() {
  //     return const Uuid().v4(); // Generates a random UUID string
  //   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(title: Text("Login")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 110.0),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      // color: Colors.red,
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Image.asset('assets/images/pheasant.png'),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 0),
                child: Center(
                  child: Text(
                    'Enter your email and password to access your account securly.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,

                    // decoration: InputDecoration(
                    //   filled: true,
                    //   fillColor: Colors.white,
                    //   enabledBorder: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(60.0),
                    //     borderSide: BorderSide(color: Colors.white, width: 2.0),
                    //   ),
                    //   labelText: 'Email',
                    //   hintText: 'example@gmail.com',
                    // ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60.0),
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    labelText: 'email',
                    hintText: 'example@mail.com',
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    labelText: 'Password',
                    hintText: 'Enter secure password',
                    // errorText: passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.only(top: 15, bottom: 0),
              //   child: TextField(
              //     controller: _passwordController,
              //     obscureText: true,
              //     decoration: InputDecoration(
              //       filled: true,
              //       fillColor: Colors.white,
              //       enabledBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(60.0),
              //         borderSide: BorderSide(color: Colors.white, width: 2.0),
              //       ),
              //       labelText: 'Password',
              //       hintText: 'Enter secure password',
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 0),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value:
                                    _isChecked, // The current state of the checkbox
                                onChanged: (bool? newValue) {
                                  // Callback when the checkbox is tapped
                                  setState(() {
                                    _isChecked =
                                        newValue ?? false; // Update the state
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                fillColor: WidgetStateProperty.resolveWith((
                                  states,
                                ) {
                                  if (!states.contains(WidgetState.selected)) {
                                    return Colors.white;
                                  }
                                  return null;
                                }),
                                side: WidgetStateBorderSide.resolveWith(
                                  (states) => BorderSide(
                                    color: Colors.teal,
                                    width: 2.0,
                                  ),
                                ),
                                activeColor: Colors.teal, // Color when checked
                                checkColor:
                                    Colors.white, // Color of the checkmark
                              ),
                              Text(
                                'Remember me',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgotPwdPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot password',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 0),
                child: SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                    ),
                    // 1. Move onPressed here
                    onPressed: _isLoading
                        ? null
                        : () async {
                            await _handleLogin();
                            // Remember to add: if (!mounted) return; here if you navigate next!
                          },
                    // 2. Put the child last
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text('Log in ', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              GoogleSignIn.instance.supportsAuthenticate()
                  ? SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.teal, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Sign in with Google',
                            style: TextStyle(color: Colors.teal, fontSize: 18)),
                      ),
                    )
                  : SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: Center(child: buildGoogleSignInButton()),
                    ),
              const SizedBox(height: 20),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    'or sign up instead',
                    style: TextStyle(fontSize: 14, color: Colors.teal),
                  ),
                ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<bool> _logIn() async {
  //   return true;
  // }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Firebase Email/Password Login
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // --- Remember Me Logic ---
      final prefs = await SharedPreferences.getInstance();
      if (_isChecked) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', email);
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_email');
      }
      
      await _onAuthSuccess(userCredential.user);

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleAuthAccount(GoogleSignInAccount account) async {
    // If called from listener (Web), _isLoading might be false.
    if (!_isLoading) {
      setState(() => _isLoading = true);
    }

    try {
     // debugPrint("Google Sign-In successful: ${account.email}");

      // 3. Obtain the auth details (synchronous in v7)
      final GoogleSignInAuthentication googleAuth = account.authentication;

      // 4. Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // 5. Once signed in, return the UserCredential
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      
      // 6. Pass the user to your existing Data Connect / Riverpod logic
      await _onAuthSuccess(userCredential.user);
        
    } catch (e) {
      debugPrint('Google Login Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-In processing failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // Ensure loading state is cleared
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    // 1. Prevent multiple simultaneous login attempts
    if (_isLoading) return;

    // Guard: authenticate() is not supported on Web in v7.
    // The UI should hide the button, but we add a safety check here.
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please use the Google Sign-In button provided.')),
         );
       }
       return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Trigger the Google Authentication flow
      final GoogleSignInAccount user = await GoogleSignIn.instance.authenticate();
      
      await _handleGoogleAuthAccount(user);
        
    } catch (e) {
      debugPrint('Google Login Error: $e');
      if (mounted) {
        // Don't show confusing error if user cancelled
        if (!e.toString().contains('canceled')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Sign-In failed. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } finally {
      // Ensure loading state is cleared
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  // Future<void> _handleGoogleLogin() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn();
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
  //     if (googleUser == null) {
  //       setState(() => _isLoading = false);
  //       return; // User canceled
  //     }

  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  //     await _onAuthSuccess(userCredential.user);
      
  //   } catch (e) {
  //     print('Google Login Error: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Google Sign-In failed: $e')),
  //       );
  //     }
  //     setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _onAuthSuccess(User? user) async {
      if (user == null) return;
      
      // Fetch user profile from Data Connect
      // Check if user exists in DB. If not (first time Google login), create them.
      try {
        final response = await ExampleConnector.instance.getUser(userId: user.uid).execute();
        var dbUser = response.data.user;

        if (dbUser == null) {
           // First time login with Google -> Create User record
           await ExampleConnector.instance.createUser(
             uid: user.uid,
             displayname: user.displayName ?? 'User',
             email: user.email ?? '',
           ).execute();
           
           // Fetch again
           final newResponse = await ExampleConnector.instance.getUser(userId: user.uid).execute();
           dbUser = newResponse.data.user;
        }
        
        if (dbUser != null) {
            // --- Session Logic ---
            if (_isChecked) {
              final sessionManager = SessionManager();
              final token = sessionManager.generateSessionToken();
              
              // Calculate expiry (2 days)
              final expiryDate = DateTime.now().add(const Duration(days: 2));
              // Timestamp(nanoseconds, seconds)
              // (millisecondsSinceEpoch % 1000) * 1000000 gives nanoseconds
              // millisecondsSinceEpoch ~/ 1000 gives seconds
              final timestamp = Timestamp(
                expiryDate.millisecondsSinceEpoch * 1000000,
                expiryDate.millisecondsSinceEpoch ~/ 1000
              );
              
              // Update DB with token
              await ExampleConnector.instance.updateUser(
                userId: user.uid,
              )
              .sessionToken(token) 
              .sessionExpiry(timestamp)
              .execute();
              
              // Set Cookie
              sessionManager.setSessionCookie(token, persistent: true);
            } else {
              SessionManager().clearSession();
            }

            ref.read(currentUserProvider.notifier).state = CurrentUser(
              id: dbUser.userId,
              displayName: dbUser.displayname,
              avatarKey: dbUser.avatarKey,
              email: dbUser.email,
              type: dbUser.type,
            );
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainNavigation()),
            (route) => false,
          );
        }
      } catch(e) {
        debugPrint("Error fetching/creating user profile: $e");
        // Proceed anyway? Or show error?
      }
  }
}

// FORGOT PASSWORD PAGE
class ForgotPwdPage extends StatefulWidget {
  const ForgotPwdPage({super.key});

  @override
  ForgotPwdState createState() => ForgotPwdState();
}

class ForgotPwdState extends State<ForgotPwdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(title: Text("Forgot Password")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 110.0),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      // color: Colors.red,
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Image.asset('assets/images/pheasant.png'),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 0),
                child: Center(
                  child: Text(
                    'Enter your email address associated to your account to receive a reset link and regain access to your account.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,

                    // decoration: InputDecoration(
                    //   filled: true,
                    //   fillColor: Colors.white,
                    //   enabledBorder: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(60.0),
                    //     borderSide: BorderSide(color: Colors.white, width: 2.0),
                    //   ),
                    //   labelText: 'Email',
                    //   hintText: 'example@gmail.com',
                    // ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 0),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60.0),
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    labelText: 'Email',
                    hintText: 'example@gmail.com',
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 0),
                child: SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                    ),
                    child: Text('Continue', style: TextStyle(fontSize: 20)),
                    onPressed: () {
                      debugPrint('Successfully log in ');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
