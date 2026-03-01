import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/main.dart';
import 'package:travel_app/providers/current_user.dart';
import 'main_navigation.dart';
import 'package:universal_html/html.dart' as html;
import 'dataconnect_generated/generated.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Tracks the last time a password reset email was sent
final passwordResetTimeProvider = StateProvider<DateTime?>((ref) => null);

void main() {
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Settings UI',
      theme: ThemeData(
        // Defining the specific Green color from the design
        primaryColor: const Color(0xFF10A37F),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF10A37F),
          secondary: const Color(0xFF10A37F),
        ),
      ),
      home: ProfileMenuScreen(),
    );
  }
}

// =============================================================================
// SCREEN 1: Main Profile Menu
// =============================================================================

class ProfileMenuScreen extends ConsumerWidget {
  ProfileMenuScreen({super.key});

  final String avatar = "butterfly";
  final List<String> _avatars = [ "butterfly", "dandelion", "default", "lake", "leaf", "sun", "tree",];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD0F0C0), // Light green bg
                            image: DecorationImage(
                              // default image from asstes 

                              // make call to firebase to retreive user avatar


                              image: AssetImage(AvatarManager.getAssetPath(currentUser?.avatarKey)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (currentUser?.displayName ?? "USER").toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  DropdownButton<String>(
                      hint: const Text(
                        "Select Avatar",
                        style: TextStyle(fontSize: 15, color: Colors.teal),
                      ),
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      // icon: const Icon(Icons.keyboard_arrow_down),
                      underline: Container(
                        color: Colors.white,
                      ),
                      items: _avatars
                          .map<DropdownMenuItem<String>>((String value) =>
                              DropdownMenuItem<String>(
                                value: value,
                                child: Text(capitalize(value)),
                              ))
                          .toList(),
                      onChanged: (newItem) {
                        if (newItem != null && currentUser != null) {
                          // 1. Update global state so UI reflects change immediately
                          ref.read(currentUserProvider.notifier).update((state) {
                            if (state != null) {
                              return CurrentUser(
                                id: state.id,
                                displayName: state.displayName,
                                avatarKey: newItem,
                                email: state.email,
                                type: state.type,
                              );
                            }
                            return state;
                          });
                          
                          // 2. Persist to database
                          ExampleConnector.instance.updateUserAvatar(
                            userId: currentUser.id, // Updated to use userId
                            avatarKey: newItem,
                          ).execute();
                        }
                      },
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      borderRadius: BorderRadius.circular(16.0),  
                    ),
                  // IconButton(icon: Icon(Icons.sort), onPressed: () {})  
                ],
              ),

                    // TextButton(
                    //   onPressed: () {},
                    //   child: 
                    //   const Text(
                    //     "Edit Picture",
                    //     style: TextStyle(color: Color(0xFF10A37F)),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section: My Account
              _buildSectionHeader("MY ACCOUNT"),
              _buildMenuContainer(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    text: "Personal Information",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PersonalInfoScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  // _buildMenuItem(icon: Icons.card_membership, text: "Subscriptions"),
                  // _buildDivider(),
                  // _buildMenuItem(icon: Icons.receipt_long, text: "Purchase History"),
                  // _buildDivider(),
                  _buildMenuItem(icon: Icons.notifications_none, text: "Notifications"),
                ],
              ),

              const SizedBox(height: 20),

              // Section: Rewards
              _buildSectionHeader("REWARDS AND BENEFITS"),
              _buildMenuContainer(
                children: [
                  _buildMenuItem(icon: Icons.card_giftcard, text: "Referral Program"),
                  _buildDivider(),
                  _buildMenuItem(icon: Icons.confirmation_number_outlined, text: "Redeem"),
                ],
              ),
              const SizedBox(height: 30),

              // Section: Security
              _buildSectionHeader("SECURITY"),
              _buildMenuContainer(
                children: [
                  _buildMenuItem(
                    icon: Icons.vpn_key_outlined,
                    text: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),

                  _buildDivider(),
                  
                  _buildMenuItem(
                    icon: Icons.door_back_door_outlined,
                    text: "Logout",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LogoutScreen()),
                      );
                    },
                  ),
                  // _buildDivider(),
                  // _buildMenuItem(icon: Icons.fingerprint, text: "Biometrics"),
                  // _buildDivider(),
                  // _buildMenuItem(icon: Icons.shield_outlined, text: "Security Question"),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF10A37F), size: 20),
      ),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 60, endIndent: 16);
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}




// =============================================================================
// SCREEN 2: Personal Information
// =============================================================================

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  // Widget build(BuildContext context) {
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information"),
        centerTitle: false,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: TextButton(
        //       onPressed: () {},
        //       child: const Text(
        //         "Edit Profile",
        //         style: TextStyle(color: Color(0xFF10A37F), fontWeight: FontWeight.bold),
        //       ),
        //     ),
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow("Display name", (currentUser?.displayName ?? "USER").toUpperCase()),
              const Divider(indent: 16, endIndent: 16),
              _buildInfoRow("Email", (currentUser?.email ?? "user@example.com").toUpperCase()),
              // const Divider(indent: 16, endIndent: 16),
              // const Divider(indent: 16, endIndent: 16),
              // _buildInfoRow("Phone Number", "+2347085634212"),
              // const Divider(indent: 16, endIndent: 16),
              // _buildInfoRow("Gender", "Female"),
              // const Divider(indent: 16, endIndent: 16),
              // _buildInfoRow("Birthday", "09 June, 2024"),
              // const SizedBox(height: 20),
              // SizedBox(
              //   width: double.infinity,
              //   height: 50,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.pushAndRemoveUntil(
              //         context,
              //         MaterialPageRoute(builder: (context) => const MainNavigation()),
              //         (route) => false,
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF10A37F),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(25),
              //       ),
              //       elevation: 0,
              //     ),
              //     child: const Text(
              //       "Confirm Logout",
              //       style: TextStyle(fontSize: 16, color: Colors.white),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SCREEN 3: Change Password
// =============================================================================

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  String? newPasswordError;

  void validatePassword(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Password is required';
    } else if (value.length < 8 || value.length > 20) {
      error = 'Password must be 8–20 characters';
    } else if (!RegExp(r'[A-Z]').hasMatch(value) &&
        !RegExp(r'[a-z]').hasMatch(value)) {
      error = 'Must contain at least one letter';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      error = 'Must contain at least one number';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      error = 'Must contain a special character';
    } else if (!RegExp(r'^[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]+$').hasMatch(value)) {
      error = 'Only English characters allowed';
    }

    setState(() {
      newPasswordError = error;
    });
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // PASSWORD FIELD
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => {},
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
                      labelText: 'Current Password',
                      hintText: 'Enter secure password',
                      // errorText: newPasswordError,
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


                // CONFIRM PASSWORD FIELD
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    onChanged: (_) => validatePassword(_newPasswordController.text),
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
                      labelText: 'New Password',
                      hintText: 'Re-enter Password',
                      errorText: newPasswordError, // Was passwordError in original copy
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    final currentPassword = _oldPasswordController.text;
                    final newPassword = _newPasswordController.text;

                    if (user == null || user.email == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No user logged in')),
                        );
                      }
                      return;
                    }

                    // Re-authenticate user to confirm current password
                    final cred = EmailAuthProvider.credential(
                      email: user.email!,
                      password: currentPassword,
                    );

                    await user.reauthenticateWithCredential(cred);

                    // Update password
                    await user.updatePassword(newPassword);
                    print('password changed successfully');

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password changed successfully'),
                          backgroundColor: Color(0xFF10A37F),
                        ),
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainNavigation()),
                        (Route<dynamic> route) => false,
                      );
                    }

                  } on FirebaseAuthException catch (e) {
                    String errorMessage = 'An error occurred';
                    if (e.code == 'wrong-password' ||
                        e.code == 'invalid-credential') {
                      errorMessage = 'Current password is incorrect';
                    } else if (e.code == 'weak-password') {
                      errorMessage = 'The new password is too weak';
                    } else if (e.code == 'requires-recent-login') {
                      errorMessage = 'Please log in again before changing password';
                    }

                    print('Error changing password: ${e.code} - ${e.message}');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error changing password: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10A37F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Forgot Password? ",
                    style: TextStyle(color: Colors.grey)),

                GestureDetector(
                  onTap: () async {

                    final email = FirebaseAuth.instance.currentUser?.email;
                    final lastResetTime = ref.read(passwordResetTimeProvider);
                    final now = DateTime.now();

                    // Check if 5 minutes (300 seconds) have passed
                    if (lastResetTime != null) {
                      final difference = now.difference(lastResetTime);
                      if (difference.inMinutes < 5) {
                        final remaining = 5 - difference.inMinutes;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please wait $remaining minute(s) before requesting another email.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                        return;
                      }
                    }

                    if (email != null && email.isNotEmpty) {
                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                        
                        // Update the timestamp on success
                        ref.read(passwordResetTimeProvider.notifier).state = now;

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Password reset email sent to $email'),
                              backgroundColor: const Color(0xFF10A37F),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error sending reset email: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Reset Password",
                    style: TextStyle(
                      color: Color(0xFF10A37F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


// =============================================================================
// SCREEN 4: Logout Screen
// =============================================================================


class LogoutScreen extends ConsumerWidget {
  const LogoutScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await FirebaseAuth.instance.signOut();
    ref.read(currentUserProvider.notifier).state = null;
    if (context.mounted) {
       Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
       );
    }
  }



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Logout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 64,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                "Log Out?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                "Are you sure you want to log out?\nYou'll need to login again to use the app.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const Spacer(),
              
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleLogout(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Yes, Log Out",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.grey[100],
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
