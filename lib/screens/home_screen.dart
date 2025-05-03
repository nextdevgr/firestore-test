import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/user_form.dart';
import '../dialogs/data_dialog.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    // Function to show the user data dialog
    Future<void> showUserDataDialog(BuildContext context) async {
      showDialog(
        context: context,
        builder: (ctx) {
          return DataDialog(
              key: ValueKey('dataDialog')
          ); // Using the DataDialog widget
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        automaticallyImplyLeading: false,  // Disable the back button
        actions: [
          // Sign-out button
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              // Navigate to the login screen and remove all previous routes from the stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,  // This ensures all previous routes are removed
              );
            },
          ),
          // Eye button to show the data dialog
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () => showUserDataDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the email of the user
            Text(
              'Welcome, ${user?.email ?? 'User'}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Include the UserForm widget here
            UserForm(), // The UserForm widget is being used here
          ],
        ),
      ),
    );
  }
}


