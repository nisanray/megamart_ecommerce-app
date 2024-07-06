import 'package:flutter/material.dart';

InputDecoration inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
