import 'package:app/welcome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mechanic_profile.dart';

class mechanic extends StatefulWidget {
  const mechanic({Key? key}) : super(key: key);

  @override
  State<mechanic> createState() => _mechanicState();
}

class _mechanicState extends State<mechanic> {
  late User _user;

  //get orders

  final databaseReference = FirebaseFirestore.instance;
  List<Map<dynamic, dynamic>> ordersList = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    String userId = _user.uid;
    databaseReference
        .collection("order")
        .where("Macid", isEqualTo: userId)
        .get()
        .then((QuerySnapshot snapshot) {
      setState(() {
        ordersList = snapshot.docs
            .map((DocumentSnapshot document) =>
                document.data() as Map<dynamic, dynamic>)
            .toList();
      });
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => welcome()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white), // This changes the back arrow color
      elevation: 0.0,
          actions: [
            IconButton(
              onPressed: () {
                _signOut();
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('My Account'),
                onTap: () {
                  // Handle navigation to the home screen
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MechanicProfileScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Handle navigation to the settings screen
                },
              ),
            ],
          ),
        ),
        body: ordersList.isEmpty
            ?  Center(child: Text("No orders found."))
        : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    children: List.generate(ordersList.length, (index) {
                      Map<dynamic, dynamic> order = ordersList[index];
                      dynamic uid = order['userName'];
                      String uidString = uid.toString();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    "Request Details",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailRow("Vehicle Model", order["v_type"]),
                                _buildDetailRow("Fuel Type", order["v_fuel"]),
                                _buildDetailRow("Damage Type", order["v_damage"]),
                                _buildDetailRow("Order Status", order["orderStatus"]),
                                const SizedBox(height: 20),
                                Center(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        print(uidString);
                                        getPhoneNumber(uid, context);
                                      },
                                      icon: Icon(Icons.call),
                                      label: Text(
                                        'Make A Call',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                ),
              ));
  }

// Define a function to retrieve the phone number based on UID
//   Future<void> displayMobilePopup(BuildContext context, String mobile) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Mobile Number'),
//           content: Text('The mobile number is: $mobile'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

  Future<void> getPhoneNumber(String uid, BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: uid)
          .get();

      querySnapshot.docs.forEach((doc) {
        // Access the role value and assign it to a string variable
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String mobile = data['mobile'] as String;
        print('Role: $mobile');
        popup(mobile);

        // displayMobilePopup(context, mobile);
      });
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
    } catch (e) {
      print(e);
    }
  }




  Future<void> popup(String mobile) async {
    bool _hasCallSupport = false;
    Future<void>? _launched;
    String _phone = '';

    @override
    void initState() {
      super.initState();
      // Check for phone call support.
      canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
        setState(() {
          _hasCallSupport = result;
        });
      });
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mobile Number'),
          content: Text('The mobile number is: $mobile'),
          actions: <Widget>[
            TextButton(
              child: Text('Call'),
              onPressed: () async {

                _makePhoneCall(mobile);


              },

            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }


}

Widget _buildDetailRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            "${value ?? "N/A"}",
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
      ],
    ),
  );
}
