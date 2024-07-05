import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});
  static const routeName = '/store';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        // centerTitle: true,
        // backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('vendors')
            .where('profile.approved', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error retrieving vendor data: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No stores found', style: TextStyle(fontSize: 18)));
          }

          final stores = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final storeData = stores[index];
              final storeProfile = storeData['profile'] as Map<String, dynamic>?;

              if (storeProfile == null) {
                print('Missing profile data for store: ${storeData.id}');
                return ListTile(
                  title: Text('Unknown Store'),
                  subtitle: Text('Missing profile data'),
                );
              }

              final vendorName = storeData['name'] ?? 'Unknown Vendor';
              final storeName = storeProfile['storeName'] ?? 'Unknown Store';
              final storeAddress = storeProfile['address'] ?? 'No address provided';
              final storeLogoUrl = storeProfile['storeLogoUrl'] ?? '';

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: storeLogoUrl.isNotEmpty
                            ? Image.network(storeLogoUrl, width: 80, height: 80, fit: BoxFit.cover)
                            : Icon(Icons.store, size: 80, color: Colors.grey),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              storeName,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Vendor: $vendorName',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Address: $storeAddress',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
