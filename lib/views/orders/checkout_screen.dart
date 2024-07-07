import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/location/location_picker.dart';
import '../../utils/shared_styles.dart';
import '../../utils/texformfield.dart';

class CheckoutPage extends StatefulWidget {
  final List<String> selectedItems;

  CheckoutPage({required this.selectedItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Shipping address controllers
  final _shippingFullNameController = TextEditingController();
  final _shippingPostalCodeController = TextEditingController();
  final _shippingCountryController = TextEditingController(text: 'Bangladesh');
  final _shippingPhoneNumberController = TextEditingController();

  // Billing address controllers
  final _billingFullNameController = TextEditingController();
  final _billingPostalCodeController = TextEditingController();
  final _billingCountryController = TextEditingController(text: 'Bangladesh');
  final _billingPhoneNumberController = TextEditingController();

  // Payment method
  String? _paymentMethod;

  // Location variables
  String? _shippingDivision;
  String? _shippingDistrict;
  String? _shippingUpazila;
  String? _shippingArea;

  String? _billingDivision;
  String? _billingDistrict;
  String? _billingUpazila;
  String? _billingArea;

  void _updateShippingLocation(String? division, String? district, String? upazila, String? area) {
    setState(() {
      _shippingDivision = division;
      _shippingDistrict = district;
      _shippingUpazila = upazila;
      _shippingArea = area;
    });
  }

  void _updateBillingLocation(String? division, String? district, String? upazila, String? area) {
    setState(() {
      _billingDivision = division;
      _billingDistrict = district;
      _billingUpazila = upazila;
      _billingArea = area;
    });
  }

  void _copyShippingToBilling() {
    setState(() {
      _billingFullNameController.text = _shippingFullNameController.text;
      _billingPostalCodeController.text = _shippingPostalCodeController.text;
      _billingCountryController.text = _shippingCountryController.text;
      _billingPhoneNumberController.text = _shippingPhoneNumberController.text;
      _billingDivision = _shippingDivision;
      _billingDistrict = _shippingDistrict;
      _billingUpazila = _shippingUpazila;
      _billingArea = _shippingArea;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Checkout'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ...widget.selectedItems.map((cartItemId) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('cartItems').doc(cartItemId).get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          var cartItem = snapshot.data!.data() as Map<String, dynamic>;
                          var productId = cartItem['productId'];
                          var quantity = cartItem['quantity'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
                            builder: (context, productSnapshot) {
                              if (!productSnapshot.hasData) {
                                return Center(child: CircularProgressIndicator());
                              }
                              var productData = productSnapshot.data!.data() as Map<String, dynamic>;
                              var productName = productData['fixedFields']
                                  .firstWhere((field) => field['fieldName'] == 'Product Name')['value'];
                              var offerPrice = productData['fixedFields']
                                  .firstWhere((field) => field['fieldName'] == 'Offer Price')['value'];
                              var productImageUrl = productData['fixedFields']
                                  .firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];
                              var unitPrice = double.parse(offerPrice);
                              var totalPrice = unitPrice * quantity;

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  leading: Image.network(productImageUrl, width: 50, height: 50, fit: BoxFit.cover),
                                  title: Text(productName),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Quantity: $quantity'),
                                      Text('Unit Price: \৳${unitPrice.toStringAsFixed(2)}'),
                                      Text('Total Price: \৳${totalPrice.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                    SizedBox(height: 20),
                    _buildShippingAddressForm(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _copyShippingToBilling,
                      child: Text('Copy Shipping Address to Billing Address'),
                    ),
                    SizedBox(height: 20),
                    _buildBillingAddressForm(),
                    SizedBox(height: 20),
                    _buildPaymentMethodField(),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _createOrder(context, currentUser, widget.selectedItems);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order placed!!')),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Confirm Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShippingAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        CustomTextFormField(
          controller: _shippingFullNameController,
          label: 'Full Name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        CustomTextFormField(
          controller: _shippingPhoneNumberController,
          label: 'Phone Number',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        CustomTextFormField(
          controller: _shippingCountryController,
          label: 'Country',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your country';
            }
            return null;
          },
        ),
        LocationPicker(
          onLocationChanged: _updateShippingLocation,
          initialDivision: _shippingDivision,
          initialDistrict: _shippingDistrict,
          initialUpazila: _shippingUpazila,
          initialArea: _shippingArea,
        ),
        CustomTextFormField(
          controller: _shippingPostalCodeController,
          label: 'Postal Code',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your postal code';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBillingAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Billing Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        CustomTextFormField(
          controller: _billingFullNameController,
          label: 'Full Name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        CustomTextFormField(
          controller: _billingPhoneNumberController,
          label: 'Phone Number',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        CustomTextFormField(
          controller: _billingCountryController,
          label: 'Country',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your country';
            }
            return null;
          },
        ),
        LocationPicker(
          onLocationChanged: _updateBillingLocation,
          initialDivision: _billingDivision,
          initialDistrict: _billingDistrict,
          initialUpazila: _billingUpazila,
          initialArea: _billingArea,
        ),
        CustomTextFormField(
          controller: _billingPostalCodeController,
          label: 'Postal Code',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your postal code';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: DropdownButtonFormField<String>(
            decoration: inputDecoration('Select Payment Method'),
            value: _paymentMethod,
            items: [
              DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
              DropdownMenuItem(value: 'bKash', child: Text('bKash')),
              DropdownMenuItem(value: 'Nagad', child: Text('Nagad')),
              DropdownMenuItem(value: 'Rocket', child: Text('Rocket')),
              DropdownMenuItem(value: 'Cash on Delivery', child: Text('Cash on Delivery')),
            ],
            onChanged: (value) {
              setState(() {
                _paymentMethod = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a payment method';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _createOrder(BuildContext context, User currentUser, List<String> selectedItems) async {
    List<Map<String, dynamic>> orderItems = [];
    double totalAmount = 0.0;

    for (var cartItemId in selectedItems) {
      var cartItemSnapshot = await FirebaseFirestore.instance.collection('cartItems').doc(cartItemId).get();
      var cartItem = cartItemSnapshot.data() as Map<String, dynamic>;
      var productId = cartItem['productId'];
      var quantity = cartItem['quantity'];

      var productSnapshot = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      var productData = productSnapshot.data() as Map<String, dynamic>;
      var productName = productData['fixedFields']
          .firstWhere((field) => field['fieldName'] == 'Product Name')['value'];
      var offerPrice = productData['fixedFields']
          .firstWhere((field) => field['fieldName'] == 'Offer Price')['value'];
      var unitPrice = double.parse(offerPrice);
      var totalPrice = unitPrice * quantity;
      totalAmount += totalPrice;

      orderItems.add({
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': unitPrice,
        'totalPrice': totalPrice,
        'vendorId': cartItem['vendorId'],
        'productImageUrl': productData['fixedFields']
            .firstWhere((field) => field['fieldName'] == 'Product Image URL')['value']
      });

      // Remove item from cart
      await FirebaseFirestore.instance.collection('cartItems').doc(cartItemId).delete();
    }

    var shippingAddress = {
      'fullName': _shippingFullNameController.text,
      'postalCode': _shippingPostalCodeController.text,
      'country': _shippingCountryController.text,
      'phoneNumber': _shippingPhoneNumberController.text,
      'division': _shippingDivision,
      'district': _shippingDistrict,
      'upazila': _shippingUpazila,
      'area': _shippingArea,
    };

    var billingAddress = {
      'fullName': _billingFullNameController.text,
      'postalCode': _billingPostalCodeController.text,
      'country': _billingCountryController.text,
      'phoneNumber': _billingPhoneNumberController.text,
      'division': _billingDivision,
      'district': _billingDistrict,
      'upazila': _billingUpazila,
      'area': _billingArea,
    };

    // Create the order
    await FirebaseFirestore.instance.collection('orders').add({
      'customerId': currentUser.uid,
      'vendorId': orderItems.first['vendorId'], // assuming all items are from the same vendor
      'orderDate': Timestamp.now(),
      'orderStatus': 'Pending',
      'paymentStatus': 'Pending',
      'paymentMethod': _paymentMethod, // Add payment method
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'totalAmount': totalAmount,
      'currency': 'BDT',
      'items': orderItems,
      'shippingMethod': 'Standard Shipping', // Replace with actual shipping method
      'trackingNumber': '',
      'deliveryDate': null,
      'notes': '',
      'orderHistory': [
        {
          'status': 'Order Placed',
          'timestamp': Timestamp.now(),
          'notes': ''
        }
      ]
    });
  }
}
