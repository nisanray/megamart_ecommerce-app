import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final ValueChanged<int> onQuantityChanged;

  const QuantitySelector({
    Key? key,
    required this.initialQuantity,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      widget.onQuantityChanged(_quantity);
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        widget.onQuantityChanged(_quantity);
      });
    }
  }

  void _updateQuantity(String value) {
    final newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity > 0) {
      setState(() {
        _quantity = newQuantity;
        widget.onQuantityChanged(_quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: _decrementQuantity,
        ),
        SizedBox(
          width: 50,
          child: TextFormField(
            initialValue: _quantity.toString(),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(),
            ),
            onChanged: _updateQuantity,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _incrementQuantity,
        ),
      ],
    );
  }
}
