import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var order = snapshot.data!.data() as Map<String, dynamic>;
          var orderItems = order['items'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: $orderId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Order Status: ${order['orderStatus']}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Total Amount: \$${order['totalAmount'].toString()}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...orderItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('${item['productName']} x ${item['quantity']}'),
                  );
                }).toList(),
                SizedBox(height: 16),
                Text('Shipping Address:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${order['shippingAddress']['fullName']}'),
                Text('${order['shippingAddress']['postalCode']}, ${order['shippingAddress']['country']}'),
                Text('${order['shippingAddress']['phoneNumber']}'),
                Text('${order['shippingAddress']['division']}, ${order['shippingAddress']['district']}'),
                Text('${order['shippingAddress']['upazila']}, ${order['shippingAddress']['area']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
