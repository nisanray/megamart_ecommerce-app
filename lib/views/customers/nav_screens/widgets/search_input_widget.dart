import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchInputWidget extends StatelessWidget {
  const SearchInputWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Search for products",
          // fillColor: Colors.blueAccent.withOpacity(0.2),
          fillColor: Colors.grey.withOpacity(0.1),
          filled: true,
          prefixIcon: Icon(Icons.search_sharp,color: Colors.deepPurpleAccent.shade700,size: 30,),
          // border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
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
      ),
    );
  }
}
