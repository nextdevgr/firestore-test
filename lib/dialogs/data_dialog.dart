import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataDialog extends StatefulWidget {
  const DataDialog({super.key});

  @override
  _DataDialogState createState() => _DataDialogState();
}

class _DataDialogState extends State<DataDialog> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _fetchData();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: $e';
      });
    }
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
    if (user == null) return;

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ??
        false;

    if (!confirmDelete) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc(documentId)
          .delete();
      _loadData(); // Refresh data after delete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting data: $e')),
      );
      print('Error deleting data: $e');
    }
  }

  Future<void> _editData(Map<String, dynamic> item) async {
    TextEditingController nameController =
    TextEditingController(text: item['name']);
    TextEditingController phoneController =
    TextEditingController(text: item['phone']);
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
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(hintText: 'Phone'),
                ),
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
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('data')
                      .doc(item['documentId'])
                      .update({
                    'name': nameController.text,
                    'phone': phoneController.text,
                  });
                  _loadData(); // Refresh data after edit
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error editing data: $e')),
                  );
                  print('Error editing data: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          minHeight: 150,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('My Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _isLoading
                  ? _buildLoadingPlaceholder()
                  : _data.isEmpty
                  ? const Center(child: Text('No data available.'))
                  : ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final item = _data[index];
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
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editData(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteData(item['documentId']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return const ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10, width: 100, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))),
              SizedBox(height: 5),
              SizedBox(height: 10, width: 150, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))),
            ],
          ),
        );
      },
    );
  }

}