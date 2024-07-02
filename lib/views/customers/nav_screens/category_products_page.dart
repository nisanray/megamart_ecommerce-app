import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_page.dart';

class CategoryProductsPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> category;

  const CategoryProductsPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products of ${category['name']}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              category['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildProductList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('categoryId', isEqualTo: category.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No products found for this category.');
        }

        var products = snapshot.data!.docs;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            var productName = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Product Name')['value'] ?? '';
            var productPrice = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Regular Price')['value'] ?? '';
            var productImageUrl = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'] ?? '';
            var vendorId = product['vendorId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('vendors').doc(vendorId).get(),
              builder: (context, vendorSnapshot) {
                if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text(productName),
                    subtitle: Text('Loading vendor info...'),
                  );
                }
                if (vendorSnapshot.hasError) {
                  return ListTile(
                    title: Text(productName),
                    subtitle: Text('Error loading vendor info'),
                  );
                }
                if (!vendorSnapshot.hasData || !vendorSnapshot.data!.exists) {
                  return ListTile(
                    title: Text(productName),
                    subtitle: Text('Vendor not found'),
                  );
                }

                var vendorData = vendorSnapshot.data!.data() as Map<String, dynamic>;
                var vendorName = vendorData['name'] ?? 'Unknown';
                var storeName = vendorData['storeName'] ?? 'Unknown';

                return ListTile(
                  leading: productImageUrl.isNotEmpty
                      ? Image.network(productImageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : Container(width: 50, height: 50, color: Colors.grey),
                  title: Text(productName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${productPrice}'),
                      Text('Vendor: $vendorName'),
                      Text('Store: $storeName'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
