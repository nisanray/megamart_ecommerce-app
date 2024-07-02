import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fixedFields = List<Map<String, dynamic>>.from(product['fixedFields']);
    var additionalFields = List<Map<String, dynamic>>.from(product['fields']);

    // Extract and remove unwanted fields
    var productImageUrl = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];
    fixedFields.removeWhere((field) => field['fieldName'] == 'Product Image URL' || field['fieldName'] == 'createdAt' || field['fieldName'] == 'updatedAt');

    var productName = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Name')['value'];
    var vendorId = product['vendorId'];

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productImageUrl.isNotEmpty)
              Center(
                child: Image.network(productImageUrl, height: 250, fit: BoxFit.cover),
              ),
            SizedBox(height: 20),
            if (fixedFields.isNotEmpty) ...[
              Text('Product Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...fixedFields.map((field) => _buildField(field)),
              SizedBox(height: 20),
            ],
            if (additionalFields.isNotEmpty) ...[
              Text('Additional Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...additionalFields.map((field) => _buildField(field)),
              SizedBox(height: 20),
            ],
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('vendors').doc(vendorId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error loading vendor info');
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('Vendor not found');
                }

                var vendorData = snapshot.data!.data() as Map<String, dynamic>;
                var vendorName = vendorData['name'] ?? 'Unknown';
                var storeName = vendorData['storeName'] ?? 'Unknown';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vendor: $vendorName', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Store: $storeName'),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle Buy Now action
                  },
                  child: Text('Buy Now',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Add to Cart action
                  },
                  child: Text('Add to Cart',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field['fieldName'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(field['value']),
        ],
      ),
    );
  }
}
