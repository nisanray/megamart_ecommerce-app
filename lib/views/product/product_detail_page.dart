import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megamart/utils/assets_link.dart';
import 'package:megamart/views/nav_screens/cart_screen.dart';

import '../../utils/quantity_selector.dart';
import '../main_screen.dart';
import 'vendor_detail_page.dart';

class ProductDetailPage extends StatefulWidget {
  final DocumentSnapshot product;

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
  String _regularPrice = "";
  String _offerPrice = "";

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

    // Fetch product details
    final fixedFields = List<Map<String, dynamic>>.from(widget.product['fixedFields']);
    final productNameField = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Name');
    final regularPriceField = fixedFields.firstWhere((field) => field['fieldName'] == 'Regular Price');
    final offerPriceField = fixedFields.firstWhere((field) => field['fieldName'] == 'Offer Price');

    setState(() {
      _productName = productNameField['value'];
      _regularPrice = regularPriceField['value'].toString();
      _offerPrice = offerPriceField['value'].toString();
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
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(initialIndex: 3),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {},
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  child: Text('Home'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(initialIndex: 0),
                      ),
                    );
                  },
                ),
                PopupMenuItem<String>(
                  child: Text('My account'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(initialIndex: 5),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Center(child: Image.network(productImageUrl, fit: BoxFit.fitHeight)),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('\৳$_offerPrice', style: TextStyle(fontSize: 30)),
                      SizedBox(width: 10),
                      Text(
                        '\৳$_regularPrice',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('1K Sold'),
                      SizedBox(width: 10),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            child: Text('♥50'),
                          )),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Rating: 4.5 stars'),
                  SizedBox(height: 8),
                  Text('Delivery Time: 3-5 days'),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorDetailPage(
                            vendorId: vendorId,
                            vendorData: _vendorData!,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.store_mall_directory_outlined),
                        Text(' ${_vendorData?['profile']['storeName'] ?? ''} (Ratings: ${_vendorData?['profile']['ratings'] ?? 0} stars)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              height: 100,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Variations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Add variations here
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              // height: ,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Delivery   ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Image.asset(AssetsLink.approvalIcon, height: 18, color: Colors.deepPurpleAccent.shade700),
                      Text('  Standard Delivery , 5-7 Days ,  120\৳',style: TextStyle(fontSize: 15),)
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text(
                        'Service    ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Image.asset(AssetsLink.leftArrowInCircleIcon, height: 18, color: Colors.deepPurpleAccent.shade700),
                      Text('  7 Days Returns.',style: TextStyle(fontSize: 15),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.30,
                      ),
                      Icon(Icons.arrow_forward_ios,size: 18,)
                    ],
                  ),
                  // Add delivery info here
                ],
              ),
            ),
            // SizedBox(height: 10),
            // Container(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       // Add service info here
            //     ],
            //   ),
            // ),
            SizedBox(height: 10),
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ratings and Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Add ratings and reviews here
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              height: 130,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'QNA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text('Ask Question'),
                      ),
                    ],
                  ),
                  // Add QNA section here
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorDetailPage(
                            vendorId: vendorId,
                            vendorData: _vendorData!,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(_vendorData?['profile']['storeLogoUrl'] ?? ''),
                          radius: 20,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Store Name: ${_vendorData?['profile']['storeName'] ?? ''}'),
                            Text('Ratings: ${_vendorData?['profile']['ratings'] ?? 0} stars'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Add store info here
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Add product details from fixed fields
                  ...fixedFields.map((field) => _buildField(field)).toList(),
                  // Add product details from additional fields
                  ...additionalFields.map((field) => _buildField(field)).toList(),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Add recommended products here
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorDetailPage(
                        vendorId: vendorId,
                        vendorData: _vendorData!,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.store_mall_directory_outlined),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.chat_outlined)),
              ElevatedButton(
                onPressed: () {},
                child: Text('Buy Now'),
              ),
              ElevatedButton(
                onPressed: _currentUser == null ? null : () {
                  _addToCart(context);
                },
                child: Text('Add to Cart'),
              ),
            ],
          ),
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
        'storeName': _vendorData!['profile']['storeName'],
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field['fieldName']+'   : ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(field['value'].toString()),
        ],
      ),
    );
  }
}
