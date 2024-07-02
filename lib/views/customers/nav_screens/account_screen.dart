import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megamart/utils/custom_navigation_icon.dart';
import 'package:megamart/views/settings/settings_view.dart';

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
      DocumentSnapshot snapshot = await _firestore.collection('customers').doc(user.uid).get();
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
      backgroundColor: Colors.blueAccent.withOpacity(0.3),
      appBar:AppBar(
        backgroundColor: Colors.white,
        title: Text(_fullName),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: _profilePictureUrl.isNotEmpty
              ? NetworkImage(_profilePictureUrl)
              : AssetImage('assets/default_profile.png') as ImageProvider,
            radius: 20,
          ),
        ),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsView(),));
          }, icon: Icon(CupertinoIcons.settings))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     CircleAvatar(
                  //       backgroundImage: AssetImage('assets/profile.jpg'),
                  //       radius: 30,
                  //     ),
                  //     Column(
                  //       children: [
                  //         Text(
                  //           'NISAN RAY',
                  //           style: TextStyle(fontSize: 18),
                  //         ),
                  //
                  //         ElevatedButton(
                  //           onPressed: () {},
                  //           child: Text('Add mobile number now >'),
                  //         ),
                  //
                  //
                  //
                  //       ],
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: () {},
                  //       child: Text('Daraz Club Member'),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '8',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            'My Wishlist',
                            style: TextStyle( fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '66',
                            style: TextStyle( fontSize: 18),
                          ),
                          Text(
                            'Followed Stores',
                            style: TextStyle( fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '16',
                            style: TextStyle( fontSize: 18),
                          ),
                          Text(
                            'Vouchers',
                            style: TextStyle( fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Image.asset('assets/promo.jpg'),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(15),
                    width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('My Orders'),
                          Text('View All >'),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.payment),
                              Text('To Pay'),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.local_shipping),
                              Text('To Ship'),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.receipt),
                              Text('To Receive'),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.rate_review),
                              Text('To Review'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.refresh),
                              Text('My Returns'),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.cancel),
                              Text('My Cancellations'),
                            ],
                          ),
                        ],
                      ),
                    ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.local_shipping),
                      title: Text('Track Package'),
                      subtitle: Text('Delivered > Your package has been delivered. Tap here to share a review'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(15),
                    color: Colors.white,
                  child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Coins'),
                            Text('Collect Coins Daily >'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '0 Coins',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                  ),
                  ),
                      ],
                    ),
                  ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(15),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('My Services'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomBottomNavigationItem(icon: Icons.email_outlined, label: 'My Messages', onTap: () {
                      },),

                      CustomBottomNavigationItem(icon: Icons.credit_card_outlined, label: 'Payment Options', onTap: () {

                      },),

                      CustomBottomNavigationItem(icon: Icons.help_outline, label: 'Help Center', onTap: () {

                      },),

                      CustomBottomNavigationItem(icon: Icons.headset_mic_outlined, label: 'Caht With Us', onTap: () {

                      },)
                    ],
                  ),
SizedBox(
  height: 25,
),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomBottomNavigationItem(icon: Icons.reviews_outlined, label: 'My Reviews', onTap: () {

                      },),

                      CustomBottomNavigationItem(icon: Icons.connect_without_contact_outlined, label: "Influencer Hub", onTap: () {

                      },),

                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),

    );
  }
}