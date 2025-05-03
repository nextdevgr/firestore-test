import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/user_form.dart';
import '../dialogs/data_dialog.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;


    Future<void> showUserDataDialog(BuildContext context) async {
      showDialog(
        context: context,
        builder: (ctx) {
          return DataDialog(
              key: ValueKey('dataDialog')
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        automaticallyImplyLeading: false,
        actions: [

          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
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
            Text(
              'Welcome, ${user?.email ?? 'User'}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            UserForm(),
          ],
        ),
      ),
    );
  }
}


