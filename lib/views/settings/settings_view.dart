import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megamart/views/auth/login_screen.dart';
import 'account_info_update.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Subtle background color
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(color: Colors.black), // Black color for title
          ),
          backgroundColor: Colors.white,
          elevation: 2, // Slight elevation for shadow effect
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16), // Add padding around the list
          children: [
            _buildSettingsOption(
              context,
              title: 'Account Information',
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountInformationView()),
                );
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Address Book',
              icon: Icons.location_on,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Messages',
              icon: Icons.message,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Country',
              icon: Icons.flag,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Language',
              icon: Icons.language,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Account Security',
              icon: Icons.lock,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Notification Settings',
              icon: Icons.notifications,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'General',
              icon: Icons.settings,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Conditions',
              icon: Icons.rule,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Policies',
              icon: Icons.policy,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Help',
              icon: Icons.help,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Feedback',
              icon: Icons.feedback,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Request Account Deletion',
              icon: Icons.delete_forever,
              onTap: () {
                // Add your navigation logic here
              },
            ),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4), // Adds spacing between list items
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Light shadow for a subtle elevation effect
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2), // Offset to make the shadow appear below the container
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent), // Icon with accent color
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Font style enhancements
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Arrow icon to indicate navigation
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding inside the tile
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _showLogoutConfirmation(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Logout',
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _logout(context);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    // Clear user data and set login status to false
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogInScreen()),
    );
  }
}
