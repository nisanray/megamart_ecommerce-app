import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../utils/quantity_selector.dart';



class ProductDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedQuantity = 1;
  bool _isLoading = true;
  User? _currentUser;
  Map<String, dynamic>? _vendorData;
  String _productName = "";

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchProductDetails();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Future<void> _fetchProductDetails() async {
    final vendorId = widget.product['vendorId'];

    // Fetch vendor information
    final vendorDoc = await FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();
    if (vendorDoc.exists) {
      setState(() {
        _vendorData = vendorDoc.data();
      });
    }

    // Fetch product name
    final fixedFields = List<Map<String, dynamic>>.from(widget.product['fixedFields']);
    final productNameField = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Name');
    setState(() {
      _productName = productNameField['value'];
    });

    // Check if the product is already in the cart
    _checkCartForExistingQuantity();
  }

  Future<void> _checkCartForExistingQuantity() async {
    if (_currentUser == null) {
      return;
    }

    final cartItemsRef = FirebaseFirestore.instance.collection('cartItems');
    final customerId = _currentUser!.uid;

    final querySnapshot = await cartItemsRef
        .where('customerId', isEqualTo: customerId)
        .where('productId', isEqualTo: widget.product.id)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final existingCartItem = querySnapshot.docs.first;
      setState(() {
        _selectedQuantity = existingCartItem['quantity'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var fixedFields = List<Map<String, dynamic>>.from(widget.product['fixedFields']);
    var additionalFields = List<Map<String, dynamic>>.from(widget.product['fields']);

    // Extract and remove unwanted fields
    var productImageUrl = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];
    fixedFields.removeWhere((field) => field['fieldName'] == 'Product Image URL' || field['fieldName'] == 'createdAt' || field['fieldName'] == 'updatedAt');

    var productName = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Name')['value'];
    var vendorId = widget.product['vendorId'];

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productImageUrl.isNotEmpty)
              Center(
                child: Image.network(productImageUrl, height: 250, fit: BoxFit.fitHeight),
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
            Text('Select Quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            QuantitySelector(
              initialQuantity: _selectedQuantity,
              onQuantityChanged: (newQuantity) {
                setState(() {
                  _selectedQuantity = newQuantity;
                });
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
                  child: Text('Buy Now', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: _currentUser == null ? null : () {
                    _addToCart(context);
                  },
                  child: Text('Add to Cart', style: TextStyle(color: Colors.white)),
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

  Future<void> _addToCart(BuildContext context) async {
    final cartItemsRef = FirebaseFirestore.instance.collection('cartItems');
    final customerId = _currentUser!.uid; // Use the current user's uid

    // Check if the product already exists in the cart
    final querySnapshot = await cartItemsRef
        .where('customerId', isEqualTo: customerId)
        .where('productId', isEqualTo: widget.product.id)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If the product exists, update the quantity
      final existingCartItem = querySnapshot.docs.first;
      final existingQuantity = existingCartItem['quantity'] as int;

      await existingCartItem.reference.update({
        'quantity': existingQuantity + _selectedQuantity,
        'addedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product quantity updated in cart')),
      );
    } else {
      // If the product does not exist, add a new cart item
      await cartItemsRef.add({
        'customerId': customerId,
        'productId': widget.product.id,
        'quantity': _selectedQuantity,
        'addedAt': FieldValue.serverTimestamp(),
        'vendorId': widget.product['vendorId'],
        'vendorName': _vendorData!['name'],
        'storeName': _vendorData!['storeName'],
        'productName': _productName,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added to cart')),
      );
    }
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
