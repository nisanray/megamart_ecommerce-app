import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megamart/utils/custom_navigation_icon.dart';
import 'package:megamart/views/settings/settings_view.dart';

import '../orders/order_list_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  static const routeName = '/account';

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _profilePictureUrl = '';
  String _fullName = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('customers').doc(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          _profilePictureUrl = snapshot['profile']['profilePicture'] ?? '';
          _fullName = snapshot['fullName'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          _fullName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: _profilePictureUrl.isNotEmpty
                ? NetworkImage(_profilePictureUrl)
                : const AssetImage('assets/default_profile.png')
            as ImageProvider,
            radius: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsView(),
                ),
              );
            },
            icon: const Icon(CupertinoIcons.settings, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildStatsCard(),
            const SizedBox(height: 10),
            _buildPromoBanner(context),
            const SizedBox(height: 10),
            _buildOrdersSection(context),
            const SizedBox(height: 10),
            _buildTrackPackage(),
            const SizedBox(height: 10),
            _buildCoinsSection(),
            const SizedBox(height: 10),
            _buildMyServicesSection(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('8', 'My Wishlist', Colors.pinkAccent),
              _buildStatItem('66', 'Followed Stores', Colors.blueAccent),
              _buildStatItem('16', 'Vouchers', Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.asset(
        'assets/promo/promo.jpg',
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width * 0.9,
        height: 150,
      ),
    );
  }

  Widget _buildOrdersSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Orders',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderListScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All >',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderItem(Icons.payment, 'To Pay'),
              _buildOrderItem(Icons.local_shipping, 'To Ship'),
              _buildOrderItem(Icons.receipt, 'To Receive'),
              _buildOrderItem(Icons.rate_review, 'To Review'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderItem(Icons.refresh, 'My Returns'),
              _buildOrderItem(Icons.cancel, 'My Cancellations'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildTrackPackage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const ListTile(
        leading: Icon(Icons.local_shipping, color: Colors.green),
        title: Text('Track Package'),
        subtitle: Text(
          'Delivered > Your package has been delivered. Tap here to share a review',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCoinsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Coins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('Collect Coins Daily >', style: TextStyle(color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '0 Coins',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildMyServicesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('My Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomBottomNavigationItem(
                icon: Icons.email_outlined,
                label: 'My Messages',
                onTap: () {},
              ),
              CustomBottomNavigationItem(
                icon: Icons.credit_card_outlined,
                label: 'Payment Options',
                onTap: () {},
              ),
              CustomBottomNavigationItem(
                icon: Icons.help_outline,
                label: 'Help Center',
                onTap: () {},
              ),
              CustomBottomNavigationItem(
                icon: Icons.headset_mic_outlined,
                label: 'Chat With Us',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomBottomNavigationItem(
                icon: Icons.reviews_outlined,
                label: 'My Reviews',
                onTap: () {},
              ),
              CustomBottomNavigationItem(
                icon: Icons.connect_without_contact_outlined,
                label: "Influencer Hub",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
