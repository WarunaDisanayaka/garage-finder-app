import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MechanicProfileScreen extends StatefulWidget {
  @override
  _MechanicProfileScreenState createState() => _MechanicProfileScreenState();
}


class _MechanicProfileScreenState extends State<MechanicProfileScreen> {

  Map<String, dynamic>? userData;

  String? userDocId;

  @override
  void initState() {
    super.initState();
    fetchUserData();

  }
  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;

      // Query Firestore where uid matches
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          userData = doc.data();
          userDocId = doc.id; // ✅ ADD THIS LINE
          userData!['vehicleTypes'] = userData!['vehicleTypes'] ?? [];

          userData!['docId'] = doc.id;
        });

        print("User document ID: ${doc.id}");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: userDocId == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  AssetImage('assets/mechanic_avatar.png'),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, color: Colors.green),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'John Doe',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Certified Auto Mechanic',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            _buildInfoTile(Icons.email, "Email", userData?['email'] ?? ''),
            _buildInfoTile(Icons.phone, "Phone", userData?['mobile'] ?? ''),
            _buildInfoTile(Icons.location_on, "Location", userData?['address'] ?? ''),
            _buildInfoTile(Icons.cake, "Age", userData?['age'] ?? ''),

            // ElevatedButton.icon(
            //   onPressed: () {
            //     // Navigate to edit profile page
            //   },
            //   icon: Icon(Icons.edit),
            //   label: Text("Edit Profile"),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.green[700],
            //     padding:
            //     EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            // ),
            SizedBox(height: 15),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.directions_car, color: Colors.green),
                title: Text("Vehicle Types"),
                subtitle: Text(
                  (userData?['vehicleTypes'] as List<dynamic>?)?.join(', ') ??
                      'Not specified',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.black54),
                  onPressed: _showVehicleTypeDialog,
                ),
              ),
            ),

          ],

        ),
      ),
    );
  }

  void _showVehicleTypeDialog() {
    final List<String> options = [
      'Cars/Vans/ Cabs and Jeeps',
      'Three wheelers',
      'Motor Bikes',
      'Busses/ Lorries',
    ];

    List<String> selected = List<String>.from(userData?['vehicleTypes'] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Vehicle Types"),
              content: SingleChildScrollView(
                child: Column(
                  children: options.map((type) {
                    return CheckboxListTile(
                      title: Text(type),
                      value: selected.contains(type),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selected.add(type);
                          } else {
                            selected.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _editVehicleTypes(selected);
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _editVehicleTypes(List<String> selectedTypes) async {
    if (userData != null && userData!['docId'] != null) {
      final docId = userData!['docId'];

      await FirebaseFirestore.instance
          .collection('user')
          .doc(docId)
          .update({'vehicleTypes': selectedTypes});

      setState(() {
        userData!['vehicleTypes'] = selectedTypes;
      });
    }
  }


  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}


