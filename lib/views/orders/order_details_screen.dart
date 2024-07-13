import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../product/product_detail_page.dart';
// import 'product_detail_page.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  Future<DocumentSnapshot> _fetchProductSnapshot(String productId) async {
    return await FirebaseFirestore.instance.collection('products').doc(productId).get();
  }

  Future<Map<String, dynamic>> _fetchVendorDetails(String vendorId) async {
    DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();
    return vendorSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
        ),
        body: const Center(child: Text('You need to be logged in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var order = snapshot.data!.data() as Map<String, dynamic>;

          if (order['customerId'] != currentUser.uid) {
            return const Center(child: Text('You do not have permission to view this order.'));
          }

          var orderItems = order['items'] as List<dynamic>;
          var orderHistory = order['orderHistory'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: $orderId', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Order Status: ${order['orderStatus']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Total Amount: ৳${order['totalAmount'].toString()}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...orderItems.map((item) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: _fetchProductSnapshot(item['productId']),
                    builder: (context, productSnapshot) {
                      if (!productSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var product = productSnapshot.data!;
                      var productData = product.data() as Map<String, dynamic>;
                      var productImageUrl = productData['fixedFields'].firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _fetchVendorDetails(productData['vendorId']),
                        builder: (context, vendorSnapshot) {
                          if (!vendorSnapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          var vendor = vendorSnapshot.data!;
                          var storeName = vendor['profile']['storeName'];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: product),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Image.network(productImageUrl, width: 50, height: 50),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${item['productName']} x ${item['quantity']}', style: const TextStyle(fontSize: 16)),
                                          Text('Price: ৳${item['price']}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                          Text('Store: $storeName', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: 16),
                const Text('Shipping Address:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${order['shippingAddress']['fullName']}', style: const TextStyle(fontSize: 16)),
                        Text('${order['shippingAddress']['postalCode']}, ${order['shippingAddress']['country']}', style: const TextStyle(fontSize: 16)),
                        Text('${order['shippingAddress']['phoneNumber']}', style: const TextStyle(fontSize: 16)),
                        Text('${order['shippingAddress']['division']}, ${order['shippingAddress']['district']}', style: const TextStyle(fontSize: 16)),
                        Text('${order['shippingAddress']['upazila']}, ${order['shippingAddress']['area']}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Billing Address:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${order['billingAddress']['fullName']}', style: const TextStyle(fontSize: 16)),
                        Text('${order['billingAddress']['postalCode']}, ${order['billingAddress']['country']}', style: const TextStyle(fontSize: 16)),
                        Text('${order['billingAddress']['phoneNumber']}', style: const TextStyle(fontSize: 16)),
                        Text('${order['billingAddress']['division']}, ${order['billingAddress']['district']}', style: const TextStyle(fontSize: 16)),
                        Text('${order['billingAddress']['upazila']}, ${order['billingAddress']['area']}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Order History:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...orderHistory.map((history) {
                  var timestamp = (history['timestamp'] as Timestamp).toDate();
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('${history['status']} at ${timestamp.toString()}', style: const TextStyle(fontSize: 16)),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
