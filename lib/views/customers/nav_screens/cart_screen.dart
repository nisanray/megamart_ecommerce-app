import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:megamart/utils/custom_button.dart';

import '../../../utils/quantity_selector.dart';
import '../main_screen.dart';
import 'category_screen.dart';
// import 'quantity_selector.dart'; // Import the QuantitySelector widget

class CartScreen extends StatefulWidget {

  CartScreen({super.key, });
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Cart'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        // backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cartItems')
            .where('customerId', isEqualTo: _currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyCart(context);
          }

          var cartItems = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              var cartItem = cartItems[index];
              var productId = cartItem['productId'];
              var quantity = cartItem['quantity'] as int;
              var storeName = cartItem['storeName'];
              var productName = cartItem['productName'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('Loading...'),
                      ),
                    );
                  }
                  if (productSnapshot.hasError) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('Error loading product info'),
                      ),
                    );
                  }
                  if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('Product not found'),
                      ),
                    );
                  }

                  var productData = productSnapshot.data!.data() as Map<String, dynamic>;
                  var productImageUrl = productData['fixedFields']
                      .firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];
                  var productPrice = productData['fixedFields']
                      .firstWhere((field) => field['fieldName'] == 'Regular Price')['value'];
                  var unitPrice = double.parse(productPrice);
                  var totalPrice = unitPrice * quantity;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // set the border color
                        width: 1.0, // set the border width
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(

                            leading: productImageUrl.isNotEmpty
                                ? Image.network(productImageUrl, width: 50, height: 50, fit: BoxFit.fitHeight)
                                : Container(width: 50, height: 50, color: Colors.grey.shade700),
                            title: Text(
                              productName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Text('Store: $storeName'),
                                        SizedBox(height: 4),
                                        Text('Unit Price: \$${unitPrice.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    QuantitySelector(
                                      initialQuantity: quantity,
                                      onQuantityChanged: (newQuantity) {
                                        _updateCartItemQuantity(cartItem.id, newQuantity);
                                      },
                                    ),
                                  ],
                                ),


                                SizedBox(height: 4),
                                Text('Total: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                _removeCartItem(cartItem.id);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            "Your shopping cart is empty.",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          SizedBox(height: 20),
          CustomButton(
            color: Colors.blueAccent.shade700,
            widthPercentage: 0.5,
            padding: 10,
            buttonText: "Continue shopping",
            textSize: 20,
            textColor: Colors.white,
            maxwidth: 600,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(initialIndex: 1),
                ),
              );

            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateCartItemQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      _removeCartItem(cartItemId);
    } else {
      await FirebaseFirestore.instance.collection('cartItems').doc(cartItemId).update({
        'quantity': newQuantity,
      });
    }
  }

  Future<void> _removeCartItem(String cartItemId) async {
    await FirebaseFirestore.instance.collection('cartItems').doc(cartItemId).delete();
  }
}
