import 'package:flutter/material.dart';

class SearchInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const SearchInputWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "Search for products",
          fillColor: Colors.grey.withOpacity(0.1),
          filled: true,
          prefixIcon: Icon(
            Icons.search_sharp,
            color: Colors.deepPurpleAccent.shade700,
            size: 30,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: Colors.blueAccent,
              width: 2.0,
            ),
          ),
        ),
        onSubmitted: (_) => onSubmitted(),
      ),
    );
  }
}
