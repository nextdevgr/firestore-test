import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class DataDialog extends StatefulWidget {
  const DataDialog({super.key});

  @override
  _DataDialogState createState() => _DataDialogState();
}

class _DataDialogState extends State<DataDialog> {
  late Future<List<Map<String, dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }
    final dataSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)

        .collection('data')
        .get();
    return dataSnapshot.docs.map((doc) {
      final data = doc.data();
      data['documentId'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _deleteData(String documentId) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
          await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
                  .collection('data')
          .doc(documentId)
          .delete();
        setState(() {
          _dataFuture = _fetchData();
      });
    }
  }

  Future<void> _editData(Map<String, dynamic> item) async {
    TextEditingController nameController = TextEditingController(text: item['name']);
    TextEditingController phoneController = TextEditingController(text: item['phone']);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Name')),
                TextField(controller: phoneController, decoration: const InputDecoration(hintText: 'Phone')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('data').doc(item['documentId']).update({
                  'name': nameController.text,
                  'phone': phoneController.text,
                });
                setState(() {_dataFuture = _fetchData();});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User Data'),
      content: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No data available.');
          }
          final dataList = snapshot.data!;
          return SizedBox(width: double.maxFinite, height: 300, child: ListView.builder(itemCount: dataList.length, itemBuilder: (context, index) {
            final item = dataList[index];
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${item['phone']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _editData(item)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteData(item['documentId'])),
                ],
              ),
            );
          })
          );
        },
      ),
    );
  }
}
