import 'package:flutter/material.dart';
import '../dataconnect_generated/generated.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Admin Access",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Admin Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _login();

                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text("Admin login not implemented yet"),
                    //   ),
                    // );
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      debugPrint("eemail: $email");
      debugPrint("password: $password");

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,  
        password: password
      );

      debugPrint('singed in: ${cred.user?.uid}');
      
      if (cred.user != null) {
          final response = await ExampleConnector.instance.isAdmin(userId: cred.user!.uid).execute();
          final userType = response.data.user?.type;

          if (userType == 'admin') {
             if (mounted) {
               Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(builder: (context) => const AdminDashboard()),
               );
             }
          } else {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Denied: Not an admin.")));
             }
             await FirebaseAuth.instance.signOut();
          }
      }
    } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
        }
    }
  }
}
