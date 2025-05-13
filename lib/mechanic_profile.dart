import 'package:flutter/material.dart';

class MechanicProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Profile",style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // This changes the back arrow color
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/mechanic_avatar.png'), // Replace with your image asset or NetworkImage
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Certified Auto Mechanic',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 30),
            _buildInfoTile(Icons.email, "Email", "john.doe@autofix.com"),
            _buildInfoTile(Icons.phone, "Phone", "+1 234 567 890"),
            _buildInfoTile(Icons.location_on, "Location", "Los Angeles, CA"),
            _buildInfoTile(Icons.build, "Experience", "5 Years"),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to edit profile page
              },
              icon: Icon(Icons.edit),
              label: Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextButton.icon(
              onPressed: () {
                // Logout logic
              },
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
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
