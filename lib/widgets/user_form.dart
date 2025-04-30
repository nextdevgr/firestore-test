import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> _submitData(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Αν δεν υπάρχει συνδεδεμένος χρήστης, ειδοποιούμε τον χρήστη να συνδεθεί πρώτα
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to submit data.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        // Αποθήκευση των δεδομένων κάτω από το uid του χρήστη
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('data').add({
          'name': nameController.text,
          'phone': phoneController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Καθαρισμός των πεδίων
        nameController.clear();
        phoneController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          ),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _submitData(context),
            child: Text('Submit to Firestore'),
          ),
        ],
      ),
    );
  }
}
