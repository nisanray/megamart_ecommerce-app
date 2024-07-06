import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../main_screen.dart';
import 'product_detail_page.dart';

class VendorDetailPage extends StatefulWidget {
  final String vendorId;
  final Map<String, dynamic> vendorData;

  const VendorDetailPage({Key? key, required this.vendorId, required this.vendorData}) : super(key: key);

  @override
  _VendorDetailPageState createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends State<VendorDetailPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 2; // Set the index for Store tab
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: index),
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchVendorProducts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('vendorId', isEqualTo: widget.vendorId)
        .get();

    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.vendorData['profile'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text(profile?['storeName'] ?? 'Vendor Details'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(profile?['storeLogoUrl'] ?? ''),
                radius: 50,
                backgroundColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                profile?['storeName'] ?? 'N/A',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                'Ratings: ${profile?['ratings']?.toString() ?? 'N/A'} stars',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Vendor Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
            ),
            SizedBox(height: 10),
            Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.grey.shade700),
                title: Text('Email'),
                subtitle: Text(widget.vendorData['email'] ?? 'N/A'),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.grey.shade700),
                title: Text('Phone'),
                subtitle: Text(profile?['phone'] ?? 'N/A'),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.grey.shade700),
                title: Text('Address'),
                subtitle: Text(profile?['address'] ?? 'N/A'),
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Products',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
            ),
            SizedBox(height: 10),
            FutureBuilder<List<DocumentSnapshot>>(
              future: _fetchVendorProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No products found.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var product = snapshot.data![index];
                    var fixedFields = product['fixedFields'] as List<dynamic>;
                    var productName = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Name')['value'];
                    var productImageUrl = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Image.network(
                            productImageUrl ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.fitHeight,
                          ),
                          title: Text(productName ?? 'Unnamed Product'),
                          trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade900),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(product: product),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.deepPurpleAccent.shade400,
        selectedItemColor: Colors.amberAccent.shade700,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Store",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
    );
  }
}
