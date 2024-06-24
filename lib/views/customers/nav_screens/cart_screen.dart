import 'package:flutter/material.dart';
import 'package:megamart/utils/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Your shopping cart is empty.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
          SizedBox(
            height: 40,
          ),
          CustomButton(color: Colors.blueAccent.shade700, widthPercentage: 0.5, padding: 10, buttonText: "Continue shopping.", textSize: 20, textColor: Colors.white, maxwidth: 600, onTap: () {
          },)
        ],
      ),
    );
  }
}
