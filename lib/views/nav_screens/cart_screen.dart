import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:megamart/utils/custom_button.dart';
import '../../utils/quantity_selector.dart';
import '../main_screen.dart';
import 'category_screen.dart';
import 'product_detail_page.dart'; // Import the ProductDetailPage

class CartScreen extends StatefulWidget {
  CartScreen({super.key});
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? _currentUser;
  bool _isSelectionMode = false;
  Set<String> _selectedItems = Set<String>();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  void _onItemSelect(String cartItemId) {
    setState(() {
      if (_selectedItems.contains(cartItemId)) {
        _selectedItems.remove(cartItemId);
      } else {
        _selectedItems.add(cartItemId);
      }
      _isSelectionMode = _selectedItems.isNotEmpty;
    });
  }

  Future<void> _removeSelectedItems() async {
    for (var itemId in _selectedItems) {
      await FirebaseFirestore.instance.collection('cartItems').doc(itemId).delete();
    }
    _toggleSelectionMode();
  }

  Future<void> _checkoutSelectedItems() async {
    // Handle the checkout logic here
    // This is a placeholder function for the checkout process
    // You can integrate your checkout logic here
    _toggleSelectionMode();
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
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _toggleSelectionMode,
            )
          else
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: _toggleSelectionMode,
            ),
        ],
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
            padding: EdgeInsets.symmetric(vertical: 8),
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
                  var offerPrice = productData['fixedFields']
                      .firstWhere((field) => field['fieldName'] == 'Offer Price')['value'];
                  var unitPrice = double.parse(offerPrice);
                  var regularUnitPrice = double.parse(productPrice);
                  var totalPrice = unitPrice * quantity;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(product: productSnapshot.data!),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          children: [
                            if (productImageUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  productImageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            if (productImageUrl.isEmpty)
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade700,
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                      productName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Store: $storeName'),
                                        Text('Offer Price: \$${offerPrice.toString()}'),
                                        Text('Regular Price: \$${regularUnitPrice.toStringAsFixed(2)}'),
                                        Text('Total: \$${totalPrice.toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: _selectedItems.contains(cartItem.id)
                                              ? Icon(Icons.check_box,
                                              color: Colors.blue)
                                              : Icon(Icons.check_box_outline_blank),
                                          onPressed: () {
                                            _onItemSelect(cartItem.id);
                                          },
                                        ),
                                      ],
                                    ),
                                    trailing: Column(
                                      children: [
                                        Flexible(
                                          child: QuantitySelector(
                                            initialQuantity: quantity,
                                            onQuantityChanged: (newQuantity) {
                                              _updateCartItemQuantity(
                                                  cartItem.id, newQuantity);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
        },
      ),
      bottomNavigationBar: _isSelectionMode && _selectedItems.isNotEmpty
          ? BottomAppBar(
        height: 50,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: _removeSelectedItems,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: _checkoutSelectedItems,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Checkout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      )
          : SizedBox.shrink(),
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
      await FirebaseFirestore.instance
          .collection('cartItems')
          .doc(cartItemId)
          .update({
        'quantity': newQuantity,
      });
    }
  }

  Future<void> _removeCartItem(String cartItemId) async {
    await FirebaseFirestore.instance
        .collection('cartItems')
        .doc(cartItemId)
        .delete();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear();
    });
  }
}
