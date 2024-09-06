import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../product/product_detail_page.dart';

class CategoryProductsPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> category;

  const CategoryProductsPage({super.key, required this.category});

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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found for this category.'));
        }

        var products = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            var productName = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Product Name')['value'] ??
                '';
            var productPrice = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Regular Price')['value'] ??
                '';
            var productImageUrl = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'] ??
                '';
            var vendorId = product['vendorId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('vendors').doc(vendorId).get(),
              builder: (context, vendorSnapshot) {
                if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildProductCard(
                    context,
                    productName: productName,
                    productPrice: productPrice,
                    productImageUrl: productImageUrl,
                    vendorName: 'Loading vendor info...',
                    storeName: '',
                    isLoading: true,
                  );
                }
                if (vendorSnapshot.hasError) {
                  return _buildProductCard(
                    context,
                    productName: productName,
                    productPrice: productPrice,
                    productImageUrl: productImageUrl,
                    vendorName: 'Error loading vendor info',
                    storeName: '',
                  );
                }
                if (!vendorSnapshot.hasData || !vendorSnapshot.data!.exists) {
                  return _buildProductCard(
                    context,
                    productName: productName,
                    productPrice: productPrice,
                    productImageUrl: productImageUrl,
                    vendorName: 'Vendor not found',
                    storeName: '',
                  );
                }

                var vendorData = vendorSnapshot.data!.data() as Map<String, dynamic>;
                var vendorName = vendorData['name'] ?? 'Unknown';
                var storeName = vendorData['storeName'] ?? 'Unknown';

                return _buildProductCard(
                  context,
                  productName: productName,
                  productPrice: productPrice,
                  productImageUrl: productImageUrl,
                  vendorName: vendorName,
                  storeName: storeName,
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

  Widget _buildProductCard(
      BuildContext context, {
        required String productName,
        required String productPrice,
        required String productImageUrl,
        required String vendorName,
        required String storeName,
        bool isLoading = false,
        VoidCallback? onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: productImageUrl.isNotEmpty
                    ? Image.network(
                  productImageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.fitHeight,
                )
                    : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Price: \$${productPrice.toString()}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    if (!isLoading)
                      Text(
                        'Vendor: $vendorName',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    if (!isLoading)
                      Text(
                        'Store: $storeName',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: LinearProgressIndicator(minHeight: 2.0),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
